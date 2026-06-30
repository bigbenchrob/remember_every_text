import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';

part 'recovered_message_navigation_actions_provider.g.dart';

@riverpod
class RecoveredMessageNavigationActions
    extends _$RecoveredMessageNavigationActions {
  @override
  FutureOr<void> build() {}

  Future<void> focusMonth({
    required DateTime monthAnchor,
    int? contactId,
    bool onlyNoHandleFromMe = false,
  }) async {
    await _dispatch(
      RecoveredMonthFocused(
        contactId: contactId,
        monthAnchor: monthAnchor,
        onlyNoHandleFromMe: onlyNoHandleFromMe,
      ),
    );
  }

  Future<void> openNoHandleFromMe() async {
    await _dispatch(const RecoveredNoHandleFromMeOpened());
  }

  Future<void> _dispatch(SidebarActionIntent intent) async {
    await ref
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: intent,
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
          ),
        );
  }
}
