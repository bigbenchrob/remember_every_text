import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';

part 'contact_conversation_navigation_actions_provider.g.dart';

@riverpod
class ContactConversationNavigationActions
    extends _$ContactConversationNavigationActions {
  @override
  FutureOr<void> build() {}

  Future<void> selectContactConversation({
    required int contactId,
    required int conversationId,
  }) async {
    await ref
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: ContactConversationSelected(
            contactId: contactId,
            conversationId: conversationId,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
          ),
        );
  }
}
