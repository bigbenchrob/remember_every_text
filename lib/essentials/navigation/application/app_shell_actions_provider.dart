import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers.dart';
import '../../debug/application/developer_mode_provider.dart';

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
}
