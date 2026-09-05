import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' as sched;
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart'
    show ExternalLibrary;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'config/theme/colors/theme_colors.dart';
import 'config/theme/theme_typography.dart';
import 'essentials/app_mode/feature_level_providers.dart'
    show platformBrightnessProvider, switchableDarkModeProvider;
import 'essentials/archive_environment/application.dart'
    show
        ArchiveAdmissionService,
        admittedArchiveAccessAuthorityProvider,
        archiveAccessAuthorityProvider;
import 'essentials/archive_environment/domain.dart'
    show
        ArchiveAccessAuthority,
        ArchiveAccessMode,
        ArchiveBuildIdentity,
        ArchiveIdentityValidator,
        ResolvedArchiveIdentity;
import 'essentials/archive_environment/infrastructure.dart'
    show
        DevelopmentArchiveRootOverrideResolver,
        ExactCanonicalArchiveRootPolicy,
        FileSystemCompleteInstallationEraseStore,
        FileSystemArchiveMarkerStore,
        MethodChannelArchiveAdmissionFailurePresenter,
        MethodChannelNativeArchiveClaimReader;
import 'essentials/conversation_graph/feature_level_providers.dart'
    show chatDbChangeMonitorProvider;
import 'essentials/logging/application/diagnostic_report_actions.dart';
import 'essentials/logging/application/flutter_framework_error_reporter.dart';
import 'essentials/logging/feature_level_providers.dart'
    show appLoggerProvider, diagnosticReportExporterProvider;
import 'essentials/navigation/application/router.dart';
import 'essentials/onboarding/application/complete_installation_erase_virgin_verifier.dart';
import 'essentials/onboarding/domain/message_lens_installation_state.dart';
import 'essentials/onboarding/feature_level_providers.dart'
    show
        completeInstallationEraseServiceProvider,
        messageLensInstallationStateProvider,
        startFreshServiceProvider;
import 'essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart';
import 'essentials/onboarding/presentation/complete_installation_erase_authorization_dialog.dart';
import 'essentials/onboarding/presentation/start_fresh_authorization_dialog.dart';
import 'essentials/services/startup_flags_service.dart';
import 'essentials/window_state/feature_level_providers.dart'
    show windowStateServiceProvider;
import 'features/presence_iteration_simple/presentation/linear_presence_experiment_host.dart';
import 'frb_generated.dart';

const bool _presenceDevelopmentHarnessEnabled = bool.fromEnvironment(
  'PRESENCE_DEVELOPMENT_HARNESS',
);

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

Future<ArchiveAccessAuthority> _admitArchive() async {
  const claimReader = MethodChannelNativeArchiveClaimReader();
  final claim = await claimReader.read();
  final applicationSupportDirectory = await getApplicationSupportDirectory();
  const rootOverrideResolver = DevelopmentArchiveRootOverrideResolver();
  final expectedRoot = rootOverrideResolver.resolveExpectedRoot(
    environment: claim.environment,
    defaultRootPath: applicationSupportDirectory.path,
    requireConfiguredOverride:
        claim.buildIdentity == ArchiveBuildIdentity.fdaExperiment,
  );
  final rootPolicy = ExactCanonicalArchiveRootPolicy(
    canonicalRoots: {claim.environment: expectedRoot},
    platformApplicationSupportRoot: applicationSupportDirectory.parent.path,
  );
  final validator = ArchiveIdentityValidator(rootPolicy: rootPolicy);
  validator.validateClaim(claim);
  const eraseStore = FileSystemCompleteInstallationEraseStore();
  final pendingErase = await eraseStore.readPending(
    canonicalRootPath: claim.canonicalRootPath,
  );
  if (pendingErase != null) {
    if (pendingErase.environment != claim.environment) {
      throw StateError(
        'Pending complete erase belongs to a different archive environment.',
      );
    }
    final recoveryAuthority = ArchiveAccessAuthority(
      identity: ResolvedArchiveIdentity(
        environment: claim.environment,
        buildIdentity: claim.buildIdentity,
        archiveInstanceId: pendingErase.newArchiveInstanceId,
        canonicalRootPath: claim.canonicalRootPath,
        bundleIdentifier: claim.bundleIdentifier,
        productName: claim.productName,
      ),
    );
    await eraseStore.eraseOwnedState(authority: recoveryAuthority);
    await eraseStore.installVirginIdentity(
      authority: recoveryAuthority,
      transaction: pendingErase,
    );
    await const CompleteInstallationEraseVirginVerifier(
      evidenceReader: SqliteMessageLensInstallationEvidenceReader(),
    ).verify(archiveRootPath: recoveryAuthority.rootPath);
    await eraseStore.complete(authority: recoveryAuthority);
  }
  final admissionService = ArchiveAdmissionService(
    validator: validator,
    markerStore: FileSystemArchiveMarkerStore(
      rootPath: claim.canonicalRootPath,
    ),
  );
  return admissionService.admit(claim);
}

Future<void> _reportArchiveAdmissionFailure(Object error) async {
  debugPrint('Archive admission failed: $error');
  if (!Platform.isMacOS) {
    return;
  }

  try {
    await const MethodChannelArchiveAdmissionFailurePresenter().present(error);
  } catch (reportingError) {
    debugPrint('Could not present archive admission failure: $reportingError');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ArchiveAccessAuthority archiveAuthority;
  try {
    archiveAuthority = await _admitArchive();
  } catch (error, stackTrace) {
    // Persistent diagnostics are forbidden before admission.
    debugPrintStack(stackTrace: stackTrace);
    await _reportArchiveAdmissionFailure(error);
    return;
  }

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
      admittedArchiveAccessAuthorityProvider.overrideWith(
        (ref) => archiveAuthority,
      ),
      // Initialize platform brightness immediately.
      platformBrightnessProvider.overrideWith((ref) => brightness),
    ],
  );

  MessageLensInstallationState? initialInstallationState;
  if (archiveAuthority.permitsPersistentArchiveAccess) {
    try {
      initialInstallationState = await container.read(
        messageLensInstallationStateProvider.future,
      );
    } catch (error, stackTrace) {
      // Classification is intentionally pre-persistence. Admission/classifier
      // failures remain available through stderr and the startup error surface.
      debugPrint('Installation classification failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  if (initialInstallationState != null) {
    delegate.attachContainer(container);
    final logger = container.read(appLoggerProvider.notifier);
    logger.info('App launch', source: 'App');
    logger.info(
      'Resolved startup flags',
      source: 'StartupFlags',
      context: {
        'optionLaunchResetRequested': startupFlags.optionLaunchResetRequested
            .toString(),
        'installationKind': initialInstallationState.kind.name,
        'installationReason': initialInstallationState.reason,
      },
    );

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      unawaited(deferFlutterFrameworkErrorLog(details, logError: logger.error));
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      logger.error(
        error.toString(),
        source: 'PlatformDispatcher',
        context: {'stack': stack.toString().split('\n').take(10).join('\n')},
      );
      return true;
    };
  } else {
    FlutterError.onError = FlutterError.presentError;
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Uncaught platform error before persistent startup: $error');
      debugPrintStack(stackTrace: stack);
      return true;
    };
  }

  if (initialInstallationState != null &&
      shouldRestorePersistedWindowStateAfterClassification(
        initialInstallationState,
      )) {
    try {
      await container.read(windowStateServiceProvider).restoreWindowState();
    } catch (error) {
      container
          .read(appLoggerProvider.notifier)
          .warn(
            'Failed to restore window state: $error',
            source: 'WindowState',
          );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      container.read(windowStateServiceProvider).enforceMinSize();
    });
  }
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: StartupApp(startupFlags: startupFlags),
    ),
  );
}

bool shouldRestorePersistedWindowStateAfterClassification(
  MessageLensInstallationState installationState,
) {
  return installationState.kind == MessageLensInstallationStateKind.completed;
}

class StartupApp extends ConsumerStatefulWidget {
  const StartupApp({
    required this.startupFlags,
    this.admittedChild = const App(),
    super.key,
  });

  final StartupFlags startupFlags;
  final Widget admittedChild;

  @override
  ConsumerState<StartupApp> createState() => _StartupAppState();
}

class _StartupAppState extends ConsumerState<StartupApp> {
  bool _startupChoiceResolved = false;
  bool _startupAdmissionScheduled = false;

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
    final authority = ref.watch(archiveAccessAuthorityProvider);
    if (authority.mode == ArchiveAccessMode.completeEraseOnly) {
      return const _EraseOnlyStartup();
    }
    if (_startupChoiceResolved) {
      return widget.admittedChild;
    }

    final themeMode = ref.watch(switchableDarkModeProvider);
    final installationState = ref.watch(messageLensInstallationStateProvider);

    return installationState.when(
      data: (state) {
        final mustPauseStartup =
            widget.startupFlags.optionLaunchResetRequested ||
            state.requiresStartupAttention;
        if (!mustPauseStartup) {
          if (!_startupAdmissionScheduled) {
            _startupAdmissionScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _continueStartup();
            });
          }
          return widget.admittedChild;
        }

        return MacosApp(
          title: 'remember_that_text',
          theme: MacosThemeData.light().copyWith(),
          darkTheme: MacosThemeData.dark().copyWith(),
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          home: _StartupDialogHost(
            installationState: state,
            onChoiceHandled: _continueStartup,
          ),
        );
      },
      loading: () {
        return _startupMacosApp(
          themeMode: themeMode,
          child: const Center(child: ProgressCircle()),
        );
      },
      error: (error, _) {
        return _startupMacosApp(
          themeMode: themeMode,
          child: _StartupClassificationFailure(error: error),
        );
      },
    );
  }

  MacosApp _startupMacosApp({
    required ThemeMode themeMode,
    required Widget child,
  }) {
    return MacosApp(
      title: 'remember_that_text',
      theme: MacosThemeData.light().copyWith(),
      darkTheme: MacosThemeData.dark().copyWith(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: child,
    );
  }
}

class _EraseOnlyStartup extends ConsumerStatefulWidget {
  const _EraseOnlyStartup();

  @override
  ConsumerState<_EraseOnlyStartup> createState() => _EraseOnlyStartupState();
}

class _EraseOnlyStartupState extends ConsumerState<_EraseOnlyStartup> {
  bool _erasing = false;
  String? _failure;

  Future<void> _requestErase() async {
    final colors = ref.read(themeColorsProvider.notifier);
    final confirmed = await showCompleteInstallationEraseAuthorizationDialog(
      context,
      barrierColor: colors.surfaces.canvas,
    );
    if (!mounted || !confirmed) {
      return;
    }
    setState(() {
      _erasing = true;
      _failure = null;
    });
    await sched.SchedulerBinding.instance.endOfFrame;
    try {
      await ref
          .read(completeInstallationEraseServiceProvider)
          .eraseAndRelaunch();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _erasing = false;
        _failure = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(switchableDarkModeProvider);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    return MacosApp(
      title: 'MessageLens',
      theme: MacosThemeData.light().copyWith(),
      darkTheme: MacosThemeData.dark().copyWith(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: ColoredBox(
        color: colors.surfaces.canvas,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_erasing)
                    const ProgressCircle()
                  else
                    Icon(
                      Icons.history_toggle_off,
                      size: 44,
                      color: colors.content.textSecondary,
                    ),
                  const SizedBox(height: 24),
                  Text(
                    _erasing
                        ? 'Erasing the old MessageLens setup'
                        : 'This older MessageLens setup needs a clean start',
                    style: typography.title1.copyWith(
                      color: colors.content.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _erasing
                        ? 'Your Apple Messages, Contacts, and source folders '
                              'remain unchanged. MessageLens will relaunch into '
                              'Onboarding.'
                        : 'MessageLens will not open or migrate this obsolete '
                              'installation. You can erase the MessageLens-owned '
                              'setup and begin the current Onboarding journey.',
                    style: typography.body.copyWith(
                      color: colors.content.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!_erasing) ...[
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _requestErase,
                      child: const Text(
                        'Erase MessageLens Setup and Start Over…',
                      ),
                    ),
                  ],
                  if (_failure != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'MessageLens stopped without touching external source '
                      'data. $_failure',
                      style: typography.body.copyWith(
                        color: colors.status.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartupDialogHost extends ConsumerStatefulWidget {
  const _StartupDialogHost({
    required this.installationState,
    required this.onChoiceHandled,
  });

  final MessageLensInstallationState installationState;
  final VoidCallback onChoiceHandled;

  @override
  ConsumerState<_StartupDialogHost> createState() => _StartupDialogHostState();
}

class _StartupDialogHostState extends ConsumerState<_StartupDialogHost> {
  bool _dialogShown = false;
  bool _isStartingFresh = false;

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
    final colors = ref.read(themeColorsProvider.notifier);
    final action = await showDialog<_StartupDialogAction>(
      context: context,
      barrierDismissible: false,
      barrierColor: colors.surfaces.canvas,
      builder: (_) {
        return _StartupResetConfirmationDialog(
          installationState: widget.installationState,
        );
      },
    );

    if (!mounted) {
      return;
    }

    final logger = ref.read(appLoggerProvider.notifier);
    switch (action ?? _StartupDialogAction.quit) {
      case _StartupDialogAction.continueStartup:
        logger.info('Startup continued', source: 'StartupDialog');
        widget.onChoiceHandled();
        return;
      case _StartupDialogAction.startFresh:
        await _confirmAndStartFresh();
        return;
      case _StartupDialogAction.exportLogs:
        logger.info('Export Logs clicked', source: 'StartupDialog');
        return;
      case _StartupDialogAction.quit:
        logger.info('Startup stopped by user', source: 'StartupDialog');
        exit(0);
    }
  }

  Future<void> _confirmAndStartFresh() async {
    final colors = ref.read(themeColorsProvider.notifier);
    final confirmed = await showStartFreshAuthorizationDialog(
      context,
      barrierColor: colors.surfaces.canvas,
    );
    if (!mounted) {
      return;
    }
    if (!confirmed) {
      _dialogShown = false;
      await _showStartupDialog();
      return;
    }

    setState(() {
      _isStartingFresh = true;
    });

    try {
      final service = await ref.read(startFreshServiceProvider.future);
      await service.startFresh();
      if (!mounted) {
        return;
      }
      widget.onChoiceHandled();
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .error(
            'Start Fresh failed: $error',
            source: 'StartupDialog',
            context: {'stack': stackTrace.toString()},
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _isStartingFresh = false;
      });
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("MessageLens couldn't start fresh"),
            content: const Text(
              'Your Apple Messages, Contacts, customizations, and archived '
              'attachments were not targeted. You can try again or export '
              'logs for diagnosis.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      _dialogShown = false;
      await _showStartupDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: _isStartingFresh
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProgressCircle(),
                  SizedBox(height: 16),
                  Text(
                    "I'm preparing a clean MessageLens setup. Your Messages "
                    "and Contacts won't be changed.",
                  ),
                ],
              ),
            )
          : const SizedBox.expand(),
    );
  }
}

enum _StartupDialogAction { continueStartup, exportLogs, startFresh, quit }

class _StartupResetConfirmationDialog extends ConsumerStatefulWidget {
  const _StartupResetConfirmationDialog({required this.installationState});

  final MessageLensInstallationState installationState;

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

    final title = switch (widget.installationState.kind) {
      MessageLensInstallationStateKind.virgin => 'No setup to reset',
      MessageLensInstallationStateKind.resumable =>
        'MessageLens setup can continue',
      MessageLensInstallationStateKind.completed =>
        'MessageLens setup is complete',
      MessageLensInstallationStateKind.abandoned =>
        "This MessageLens setup wasn't completed",
      MessageLensInstallationStateKind.remediationRequired =>
        'This MessageLens setup needs attention',
    };
    final message = switch (widget.installationState.kind) {
      MessageLensInstallationStateKind.virgin =>
        'MessageLens has not begun importing data. Continue to start setup.',
      MessageLensInstallationStateKind.resumable =>
        'MessageLens can continue from a safe boundary. You may also start '
            'again with a clean import and conversation index.',
      MessageLensInstallationStateKind.completed =>
        'The imported messages and conversation data reconcile. No reset is '
            'needed.',
      MessageLensInstallationStateKind.abandoned =>
        'You can start again with this version. Your Messages and Contacts on '
            "this Mac won't be changed.",
      MessageLensInstallationStateKind.remediationRequired =>
        'MessageLens found inconsistent or unreadable installation evidence. '
            'It will not continue or remove preserved data automatically.',
    };

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
                title,
                style: typography.title2.copyWith(
                  color: colors.content.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: typography.body.copyWith(
                  color: colors.content.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (widget.installationState.mayContinue) ...[
                OutlinedButton(
                  onPressed: _isExporting
                      ? null
                      : () {
                          Navigator.of(
                            context,
                          ).pop(_StartupDialogAction.continueStartup);
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.content.textPrimary,
                    side: BorderSide(color: colors.lines.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
                const SizedBox(height: 12),
              ],
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
              if (widget.installationState.mayStartFresh)
                FilledButton(
                  onPressed: _isExporting
                      ? null
                      : () {
                          Navigator.of(
                            context,
                          ).pop(_StartupDialogAction.startFresh);
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.buttons.primaryBackground,
                    foregroundColor: colors.buttons.primaryForeground,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Start Fresh'),
                ),
              if (!widget.installationState.mayContinue) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isExporting
                      ? null
                      : () {
                          Navigator.of(context).pop(_StartupDialogAction.quit);
                        },
                  child: const Text('Quit MessageLens'),
                ),
              ],
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

class _StartupClassificationFailure extends ConsumerWidget {
  const _StartupClassificationFailure({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            "MessageLens couldn't determine whether this installation is "
            'safe to open. No data was changed.\n\n$error',
            style: typography.body.copyWith(color: colors.content.textPrimary),
            textAlign: TextAlign.center,
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
    final themeMode = ref.watch(switchableDarkModeProvider);

    if (kDebugMode && _presenceDevelopmentHarnessEnabled) {
      return MacosApp(
        title: 'Presence Iteration Simple',
        theme: MacosThemeData.light().copyWith(),
        darkTheme: MacosThemeData.dark().copyWith(),
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        home: const LinearPresenceExperimentHost(),
      );
    }

    final router = ref.watch(goRouterProvider);
    ref.watch(chatDbChangeMonitorProvider);

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
