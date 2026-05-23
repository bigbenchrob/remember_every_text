import 'conversation.dart';

abstract interface class ConversationRepository {
  Future<List<ConversationOverview>> readOverviews({int limit = 100});

  Future<List<ConversationMessage>> readMessages({
    required int conversationId,
    int limit = 100,
  });

  Future<Map<int, ConversationMessageTextMatch>>
  readConversationMessageTextMatches({
    required String query,
    int limit = 500,
    int snippetsPerConversation = 3,
  });
}
