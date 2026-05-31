import 'conversation.dart';

abstract interface class ConversationRepository {
  Future<List<ConversationOverview>> readOverviews({int limit = 100});

  Future<List<ConversationOverview>> readOverviewsByIds({
    required List<int> conversationIds,
  });

  Future<List<ConversationMessage>> readMessages({
    required int conversationId,
    int limit = 100,
  });

  Future<List<ConversationMessageTimelineEntry>> readMessageTimeline({
    required int conversationId,
  });

  Future<ConversationMessage?> readMessageById({
    required int conversationId,
    required int messageId,
  });

  Future<List<int>> readMessageIdsMatchingText({
    required int conversationId,
    required String query,
    bool matchAnyTerm = false,
  });

  Future<Map<int, ConversationActivityTrace>> readActivityTraces({
    required List<int> conversationIds,
  });

  Future<Map<int, ConversationMessageTextMatch>>
  readConversationMessageTextMatches({
    required String query,
    int limit = 500,
    int snippetsPerConversation = 3,
  });
}
