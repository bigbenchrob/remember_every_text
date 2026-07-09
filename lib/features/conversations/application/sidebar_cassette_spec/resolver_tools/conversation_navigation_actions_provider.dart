import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';

part 'conversation_navigation_actions_provider.g.dart';

@riverpod
class ConversationNavigationActions extends _$ConversationNavigationActions {
  @override
  FutureOr<void> build() {}

  Future<void> selectConversation({required int conversationId}) async {
    await ref
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: ConversationSelected(conversationId: conversationId),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
          ),
        );
  }
}
