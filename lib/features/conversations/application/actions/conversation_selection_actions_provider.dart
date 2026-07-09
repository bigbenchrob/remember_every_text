import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../essentials/sidebar/domain/sidebar_action_intent.dart';

part 'conversation_selection_actions_provider.g.dart';

/// Conversation-owned selection boundary for graph Conversation navigation.
@riverpod
class ConversationSelectionActions extends _$ConversationSelectionActions {
  @override
  FutureOr<void> build() {}

  Future<void> selectConversation(
    int conversationId, {
    int? anchorMessageId,
    String? searchQuery,
  }) async {
    try {
      await ref
          .read(sidebarActionDispatcherProvider.notifier)
          .dispatch(
            intent: ConversationSelected(
              conversationId: conversationId,
              anchorMessageId: anchorMessageId,
              searchQuery: searchQuery,
            ),
            context: const SidebarActionDispatchContext(
              sidebarMode: SidebarMode.messages,
            ),
          );
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Conversation selection failed',
            source: 'ConversationSelectionActions',
            context: <String, Object?>{
              'conversationId': conversationId,
              'anchorMessageId': anchorMessageId,
              'searchQuery': searchQuery,
              'error': error.toString(),
              'stackTrace': stackTrace.toString(),
            },
          );
    }
  }
}
