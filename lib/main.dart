// ignore_for_file: unnecessary_overrides, use_setters_to_change_properties

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import './providers.dart';
import 'essentials/db_import/application/monitor/chat_db_change_monitor_provider.dart';
import 'essentials/navigation/application/router.dart';
import 'essentials/window_state/feature_level_providers.dart';
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

  void setContainer(ProviderContainer container) {
    _container = container;
  }

  @override
  void windowDidResize() {
    super.windowDidResize();
    _saveWindowState();
  }

  @override
  void windowDidMove() {
    super.windowDidMove();
    _saveWindowState();
  }

  void _saveWindowState() {
    final container = _container;
    if (container != null) {
      // Don't await - save in background
      container
          .read(windowStateServiceProvider)
          .saveCurrentWindowState() // Use the method that preserves sidebar widths
          .catchError((error) {
            // Silently ignore errors in background saves
          });
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize Rust library for URL preview parsing
  await RustLib.init();

  await _configureMacosWindowUtils();

  // Initialize Media Kit
  MediaKit.ensureInitialized();

  /// By default, enableWindowDelegate is set to false to ensure compatibility
  /// with other plugins. Set it to true if you wish to use NSWindowDelegate.
  /// WindowManipulator.initialize(enableWindowDelegate: true);\
  final delegate = _MyDelegate();
  // ignore: unused_local_variable
  final handle = WindowManipulator.addNSWindowDelegate(delegate);

  final brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  // Create provider container
  final container = ProviderContainer(
    overrides: [
      // Initialize platform brightness immediately
      platformBrightnessProvider.overrideWith((ref) => brightness),
    ],
  );

  // Set up the delegate to access the container
  delegate.setContainer(container);

  // Restore window state
  try {
    await container.read(windowStateServiceProvider).restoreWindowState();
  } catch (e) {
    // If window state restoration fails, continue with default state
    debugPrint('Failed to restore window state: $e');
  }

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    ref.watch(chatDbChangeMonitorProvider);

    return MacosApp.router(
      title: 'remember_that_text',
      theme: MacosThemeData.light().copyWith(),
      darkTheme: MacosThemeData.dark().copyWith(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
