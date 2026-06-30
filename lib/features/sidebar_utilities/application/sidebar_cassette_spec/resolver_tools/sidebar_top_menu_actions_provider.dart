import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../domain/settings_top_menu_row.dart';
import '../../../domain/sidebar_utilities_constants.dart';

part 'sidebar_top_menu_actions_provider.g.dart';

@riverpod
class SidebarTopMenuActions extends _$SidebarTopMenuActions {
  @override
  FutureOr<void> build() {}

  Future<void> selectMessageMenuChoice({
    required TopChatMenuChoice choice,
    required SidebarMode sidebarMode,
    required int cassetteIndex,
  }) async {
    await ref
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: TopMenuChanged(choice: _mapTopMenuChoice(choice)),
          context: SidebarActionDispatchContext(
            sidebarMode: sidebarMode,
            cassetteIndex: cassetteIndex,
          ),
        );
  }

  Future<void> selectSettingsMenuRow({
    required SettingsTopMenuActionRow row,
    required int cassetteIndex,
  }) async {
    await ref
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: row.intent,
          context: SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: cassetteIndex,
          ),
        );
  }
}

SidebarTopMenuChoice _mapTopMenuChoice(TopChatMenuChoice choice) {
  return switch (choice) {
    TopChatMenuChoice.conversations => SidebarTopMenuChoice.conversations,
    TopChatMenuChoice.contacts => SidebarTopMenuChoice.contacts,
    TopChatMenuChoice.strayHandles => SidebarTopMenuChoice.strayHandles,
    TopChatMenuChoice.searchAllMessages =>
      SidebarTopMenuChoice.searchAllMessages,
    TopChatMenuChoice.recoveredUnlinkedMessages =>
      SidebarTopMenuChoice.recoveredUnlinkedMessages,
    TopChatMenuChoice.recoveredNoHandleFromMeMessages =>
      SidebarTopMenuChoice.recoveredNoHandleFromMeMessages,
  };
}
