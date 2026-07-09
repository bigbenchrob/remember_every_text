import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/spec_classes/conversations_view_spec.dart';
import '../../../presentation/view/conversation_messages_view.dart';
import '../resolvers/conversation_excerpt_panel_resolver.dart';

part 'view_spec_coordinator.g.dart';

/// Coordinator that maps [ConversationsSpec] to rendered Conversation surfaces.
@riverpod
class ViewSpecCoordinator extends _$ViewSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator.
  }

  Widget buildForSpec(ConversationsSpec spec) {
    return spec.when(
      conversationMessages: (conversationId, anchorMessageId, searchQuery) =>
          ConversationMessagesView(
            conversationId: conversationId,
            anchorMessageId: anchorMessageId,
            searchQuery: searchQuery,
          ),
      conversationExcerpt:
          (conversationId, anchorMessageId, beforeCount, afterCount) =>
              ConversationExcerptPanelResolver().resolve(
                conversationId: conversationId,
                anchorMessageId: anchorMessageId,
                beforeCount: beforeCount,
                afterCount: afterCount,
              ),
    );
  }
}
