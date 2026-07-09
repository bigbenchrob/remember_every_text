import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_mode/feature_level_providers.dart'
    show switchableDarkModeProvider;
import '../../debug/feature_level_providers.dart'
    show columnBandDebugMarginsProvider, developerModeProvider;
import '../../window_state/feature_level_providers.dart'
    show windowStateServiceProvider;

part 'app_shell_actions_provider.g.dart';

@riverpod
class AppShellActions extends _$AppShellActions {
  @override
  FutureOr<void> build() {}

  Future<void> toggleDeveloperMode() async {
    await ref.read(developerModeProvider.notifier).toggleMode();
  }

  void toggleColumnBandDebugMargins() {
    ref.read(columnBandDebugMarginsProvider.notifier).toggle();
  }

  void cycleThemeMode() {
    ref.read(switchableDarkModeProvider.notifier).cycle();
  }

  Future<void> saveCurrentWindowState({required bool includeSize}) {
    return ref
        .read(windowStateServiceProvider)
        .saveCurrentWindowState(includeSize: includeSize);
  }

  Future<void> animateEndSidebarWindowWidth({
    required bool showing,
    required double sidebarWidth,
  }) {
    return ref
        .read(windowStateServiceProvider)
        .animateEndSidebarWindowWidth(
          showing: showing,
          sidebarWidth: sidebarWidth,
        );
  }
}
