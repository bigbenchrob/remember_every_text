import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/sidebar_mode.dart';
import 'sidebar_mode_provider.dart';

part 'app_mode_actions_provider.g.dart';

@riverpod
class AppModeActions extends _$AppModeActions {
  @override
  FutureOr<void> build() {}

  void selectMode(SidebarMode mode) {
    ref.read(activeSidebarModeProvider.notifier).setMode(mode);
  }
}
