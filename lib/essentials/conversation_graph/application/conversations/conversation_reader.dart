import 'conversation.dart';
import 'conversation_repository.dart';

class ConversationReader {
  const ConversationReader({required this.repository});

  final ConversationRepository repository;

  Future<List<ConversationOverview>> readOverviews({int limit = 100}) {
    return repository.readOverviews(limit: limit);
  }

  Future<List<ConversationOverview>> readOverviewsByIds({
    required List<int> conversationIds,
  }) {
    return repository.readOverviewsByIds(conversationIds: conversationIds);
  }

  Future<List<ConversationMessage>> readMessages({
    required int conversationId,
    int limit = 100,
  }) {
    return repository.readMessages(
      conversationId: conversationId,
      limit: limit,
    );
  }

  Future<List<ConversationMessageTimelineEntry>> readMessageTimeline({
    required int conversationId,
  }) {
    return repository.readMessageTimeline(conversationId: conversationId);
  }

  Future<ConversationMessage?> readMessageById({
    required int conversationId,
    required int messageId,
  }) {
    return repository.readMessageById(
      conversationId: conversationId,
      messageId: messageId,
    );
  }

  Future<List<int>> readMessageIdsMatchingText({
    required int conversationId,
    required String query,
  }) {
    return repository.readMessageIdsMatchingText(
      conversationId: conversationId,
      query: query,
    );
  }

  Future<Map<int, ConversationActivityTrace>> readActivityTraces({
    required List<int> conversationIds,
  }) {
    return repository.readActivityTraces(conversationIds: conversationIds);
  }

  Future<Set<int>> readConversationIdsMatchingMessageText({
    required String query,
    int limit = 500,
  }) async {
    final matches = await readConversationMessageTextMatches(
      query: query,
      limit: limit,
    );
    return matches.keys.toSet();
  }

  Future<Map<int, ConversationMessageTextMatch>>
  readConversationMessageTextMatches({
    required String query,
    int limit = 500,
    int snippetsPerConversation = 3,
  }) {
    return repository.readConversationMessageTextMatches(
      query: query,
      limit: limit,
      snippetsPerConversation: snippetsPerConversation,
    );
  }
}
