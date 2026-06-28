import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' as sched;
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart'
    show ExternalLibrary;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'config/theme/colors/theme_colors.dart';
import 'config/theme/theme_typography.dart';
import 'essentials/app_mode/feature_level_providers.dart'
    show platformBrightnessProvider, switchableDarkModeProvider;
import 'essentials/conversation_graph/feature_level_providers.dart'
    show chatDbChangeMonitorProvider;
import 'essentials/db/database_directory.dart';
import 'essentials/logging/application/diagnostic_report_actions.dart';
import 'essentials/logging/feature_level_providers.dart'
    show appLoggerProvider, diagnosticReportExporterProvider;
import 'essentials/navigation/application/router.dart';
import 'essentials/services/startup_flags_service.dart';
import 'essentials/window_state/feature_level_providers.dart'
    show windowStateServiceProvider;
import 'frb_generated.dart';

/// This method initializes macos_window_utils and styles the window.
Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig(
    // toolbarStyle: NSWindowToolbarStyle.unified, // default
    toolbarStyle: NSWindowToolbarStyle.expanded,
  );
  await config.apply();
}

class _MyDelegate extends NSWindowDelegate {
  ProviderContainer? _container;
  Timer? _pendingSave;

  void attachContainer(ProviderContainer container) {
    _container = container;
  }

  @override
  void windowDidMove() {
    super.windowDidMove();
    _scheduleWindowStateSave(includeSize: false);
  }

  @override
  void windowDidEndLiveResize() {
    super.windowDidEndLiveResize();
    _scheduleWindowStateSave(includeSize: true);
  }

  @override
  void windowDidChangeScreen() {
    super.windowDidChangeScreen();
    final container = _container;
    if (container == null) {
      return;
    }

    // Cancel any in-flight save while the window is transitioning between displays.
    _pendingSave?.cancel();

    () async {
      final service = container.read(windowStateServiceProvider);
      await service.reconcileAfterScreenChange();
      _scheduleWindowStateSave(includeSize: false);
    }();
  }

  void _scheduleWindowStateSave({required bool includeSize}) {
    final container = _container;
    if (container != null) {
      _pendingSave?.cancel();
      _pendingSave = Timer(const Duration(milliseconds: 240), () {
        container
            .read(windowStateServiceProvider)
            .saveCurrentWindowState(includeSize: includeSize)
            .catchError((Object error, StackTrace stackTrace) {
              container
                  .read(appLoggerProvider.notifier)
                  .warn(
                    'Failed to save window state: $error',
                    source: 'WindowState',
                    context: {
                      'includeSize': includeSize.toString(),
                      'stack': stackTrace
                          .toString()
                          .split('\n')
                          .take(10)
                          .join('\n'),
                    },
                  );
            });
      });
    }
  }
}

final List<Object> _windowDelegateLifetimeHandles = <Object>[];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Resolve the Application Support directory for all database files.
  await initDatabaseDirectoryPath();

  // Initialize sqflite FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    // Suppress sqflite warning about changing default factory
    runZoned(
      () => databaseFactory = databaseFactoryFfi,
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          if (!line.contains('sqflite warning')) {
            debugPrint(line);
          }
        },
      ),
    );
  }

  // Initialize Rust library for URL preview parsing.
  // FRB's default loader uses Directory.current to resolve the ioDirectory,
  // which breaks when launched via macOS LaunchServices (CWD is /).
  // We resolve the dylib from the app bundle's Frameworks directory first,
  // falling back to the default (works during development from project dir).
  try {
    final bundlePath =
        Platform.resolvedExecutable; // .../MacOS/remember_every_text
    final frameworksDir = Directory(
      '${File(bundlePath).parent.parent.path}/Frameworks',
    );
    final bundledDylib = File(
      '${frameworksDir.path}/attributed_string_decoder.framework/attributed_string_decoder',
    );
    if (bundledDylib.existsSync()) {
      await RustLib.init(
        externalLibrary: ExternalLibrary.open(bundledDylib.path),
      );
    } else {
      await RustLib.init();
    }
  } catch (error) {
    debugPrint(
      'RustLib.init failed: $error — URL preview parsing will be unavailable',
    );
  }

  await _configureMacosWindowUtils();

  final startupFlags = await StartupFlagsService.instance.initialize();
  debugPrint(
    'Startup flags: optionLaunchResetRequested=${startupFlags.optionLaunchResetRequested}',
  );

  // Initialize Media Kit.
  MediaKit.ensureInitialized();

  // Keep the window delegate handle for the app lifetime so macOS window
  // close events keep flowing into the app-shell action boundary.
  final delegate = _MyDelegate();
  _windowDelegateLifetimeHandles.add(
    WindowManipulator.addNSWindowDelegate(delegate),
  );

  final brightness =
      sched.SchedulerBinding.instance.platformDispatcher.platformBrightness;

  // Create provider container.
  final container = ProviderContainer(
    overrides: [
      // Initialize platform brightness immediately.
      platformBrightnessProvider.overrideWith((ref) => brightness),
    ],
  );

  // Set up the delegate to access the container.
  delegate.attachContainer(container);

  // Initialize the app logger early so all subsequent operations are captured.
  final logger = container.read(appLoggerProvider.notifier);
  logger.info('App launch', source: 'App');
  logger.info(
    'Resolved startup flags',
    source: 'StartupFlags',
    context: {
      'optionLaunchResetRequested': startupFlags.optionLaunchResetRequested
          .toString(),
    },
  );

  // Capture Flutter framework errors (layout, rendering, gestures).
  FlutterError.onError = (details) {
    logger.error(
      details.exceptionAsString(),
      source: 'FlutterError',
      context: {
        'library': details.library ?? 'unknown',
        'stack':
            details.stack?.toString().split('\n').take(10).join('\n') ?? '',
      },
    );
  };

  // Capture platform-level errors (plugin crashes, isolate errors).
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error(
      error.toString(),
      source: 'PlatformDispatcher',
      context: {'stack': stack.toString().split('\n').take(10).join('\n')},
    );
    return true; // Prevent app termination.
  };

  // Restore window state
  try {
    await container.read(windowStateServiceProvider).restoreWindowState();
  } catch (error) {
    logger.warn(
      'Failed to restore window state: $error',
      source: 'WindowState',
    );
  }

  // Reassert minimum window size after the first frame when the NSWindow exists.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    container.read(windowStateServiceProvider).enforceMinSize();
  });
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: StartupApp(startupFlags: startupFlags),
    ),
  );
}

class StartupApp extends ConsumerStatefulWidget {
  const StartupApp({required this.startupFlags, super.key});

  final StartupFlags startupFlags;

  @override
  ConsumerState<StartupApp> createState() => _StartupAppState();
}

class _StartupAppState extends ConsumerState<StartupApp> {
  late bool _startupChoiceResolved;

  @override
  void initState() {
    super.initState();
    _startupChoiceResolved = !widget.startupFlags.optionLaunchResetRequested;
  }

  void _continueStartup() {
    if (!mounted || _startupChoiceResolved) {
      return;
    }

    setState(() {
      _startupChoiceResolved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_startupChoiceResolved) {
      return const App();
    }

    final themeMode = ref.watch(switchableDarkModeProvider);

    return MacosApp(
      title: 'remember_that_text',
      theme: MacosThemeData.light().copyWith(),
      darkTheme: MacosThemeData.dark().copyWith(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: _StartupDialogHost(onChoiceHandled: _continueStartup),
    );
  }
}

class _StartupDialogHost extends ConsumerStatefulWidget {
  const _StartupDialogHost({required this.onChoiceHandled});

  final VoidCallback onChoiceHandled;

  @override
  ConsumerState<_StartupDialogHost> createState() => _StartupDialogHostState();
}

class _StartupDialogHostState extends ConsumerState<_StartupDialogHost> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_showStartupDialog());
    });
  }

  Future<void> _showStartupDialog() async {
    if (!mounted || _dialogShown) {
      return;
    }

    _dialogShown = true;
    final action = await showDialog<_StartupDialogAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const _StartupResetConfirmationDialog();
      },
    );

    if (!mounted) {
      return;
    }

    final logger = ref.read(appLoggerProvider.notifier);
    switch (action ?? _StartupDialogAction.cancel) {
      case _StartupDialogAction.cancel:
        logger.info('Startup dialog canceled', source: 'StartupDialog');
      case _StartupDialogAction.deleteMessageLensAppData:
        logger.warn('Delete requested', source: 'StartupDialog');
      case _StartupDialogAction.exportLogs:
        logger.info('Export Logs clicked', source: 'StartupDialog');
    }

    widget.onChoiceHandled();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: const SizedBox.expand(),
    );
  }
}

enum _StartupDialogAction { cancel, exportLogs, deleteMessageLensAppData }

class _StartupResetConfirmationDialog extends ConsumerStatefulWidget {
  const _StartupResetConfirmationDialog();

  @override
  ConsumerState<_StartupResetConfirmationDialog> createState() =>
      _StartupResetConfirmationDialogState();
}

class _StartupResetConfirmationDialogState
    extends ConsumerState<_StartupResetConfirmationDialog> {
  bool _isExporting = false;
  String? _feedbackMessage;
  bool _exportFailed = false;

  Future<void> _exportLogs() async {
    if (_isExporting) {
      return;
    }

    final logger = ref.read(appLoggerProvider.notifier);
    setState(() {
      _isExporting = true;
      _feedbackMessage = null;
      _exportFailed = false;
    });

    logger.info('Export Logs clicked', source: 'StartupDialog');

    final diagnosticReportExporter = await ref.read(
      diagnosticReportExporterProvider.future,
    );
    final result = await exportDiagnosticReport(diagnosticReportExporter);
    if (!mounted) {
      return;
    }

    final exportPath = result.exportPath;
    if (exportPath == null) {
      logger.error('Startup log export failed', source: 'StartupDialog');
      setState(() {
        _isExporting = false;
        _exportFailed = true;
        _feedbackMessage =
            'Log export failed. The startup dialog will remain open.';
      });
      return;
    }

    logger.info(
      'Startup log export succeeded',
      source: 'StartupDialog',
      context: {'exportPath': exportPath},
    );
    setState(() {
      _isExporting = false;
      _exportFailed = false;
      _feedbackMessage = 'Logs exported to:\n$exportPath';
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: colors.surfaces.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Start Over?',
                style: typography.title2.copyWith(
                  color: colors.content.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "MessageLens can delete its local app data and rebuild everything from scratch.\n\nThis deletes only MessageLens's own local data folder, including imported databases, caches, indexes, graph build state, and other generated app data. It does not delete your system Library folder or other applications' data.",
                style: typography.body.copyWith(
                  color: colors.content.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _isExporting
                    ? null
                    : () {
                        Navigator.of(context).pop(_StartupDialogAction.cancel);
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.content.textPrimary,
                  side: BorderSide(color: colors.lines.borderSubtle),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isExporting ? null : _exportLogs,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.content.textPrimary,
                  side: BorderSide(color: colors.lines.borderSubtle),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(_isExporting ? 'Exporting Logs...' : 'Export Logs'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _isExporting
                    ? null
                    : () {
                        Navigator.of(
                          context,
                        ).pop(_StartupDialogAction.deleteMessageLensAppData);
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.buttons.primaryBackground,
                  foregroundColor: colors.buttons.primaryForeground,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Delete MessageLens App Data'),
              ),
              if (_feedbackMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _feedbackMessage!,
                  style: typography.caption.copyWith(
                    color: _exportFailed
                        ? colors.content.textPrimary
                        : colors.content.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class App extends ConsumerWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    ref.watch(chatDbChangeMonitorProvider);
    final themeMode = ref.watch(switchableDarkModeProvider);

    return MacosApp.router(
      title: 'remember_that_text',
      theme: MacosThemeData.light().copyWith(),
      darkTheme: MacosThemeData.dark().copyWith(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
