import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_mode/feature_level_providers.dart';
import '../../debug/feature_level_providers.dart';
import '../../window_state/application/window_state_providers.dart';

part 'app_shell_actions_provider.g.dart';

@riverpod
class AppShellActions extends _$AppShellActions {
  @override
  FutureOr<void> build() {}

  Future<void> toggleDeveloperMode() async {
    await ref.read(developerModeProvider.notifier).toggleMode();
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
