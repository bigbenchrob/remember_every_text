import '../conversations/conversation.dart';
import 'message_graph_repository.dart';

class MessageGraphReader {
  const MessageGraphReader({required this.repository});

  final MessageGraphRepository repository;

  Future<List<ConversationMessageTimelineEntry>> readGlobalMessageTimeline() {
    return repository.readGlobalMessageTimeline();
  }

  Future<ConversationMessage?> readGlobalMessageById({required int messageId}) {
    return repository.readGlobalMessageById(messageId: messageId);
  }

  Future<List<int>> readGlobalMessageIdsMatchingText({
    required String query,
    bool matchAnyTerm = false,
  }) {
    return repository.readGlobalMessageIdsMatchingText(
      query: query,
      matchAnyTerm: matchAnyTerm,
    );
  }

  Future<List<ConversationMessageTimelineEntry>> readHandleMessageTimeline({
    required int handleId,
  }) {
    return repository.readHandleMessageTimeline(handleId: handleId);
  }

  Future<ConversationMessage?> readHandleMessageById({
    required int handleId,
    required int messageId,
  }) {
    return repository.readHandleMessageById(
      handleId: handleId,
      messageId: messageId,
    );
  }

  Future<List<int>> readHandleMessageIdsMatchingText({
    required int handleId,
    required String query,
    bool matchAnyTerm = false,
  }) {
    return repository.readHandleMessageIdsMatchingText(
      handleId: handleId,
      query: query,
      matchAnyTerm: matchAnyTerm,
    );
  }

  Future<List<ConversationMessageTimelineEntry>>
  readConversationExcerptTimeline({
    required int conversationId,
    required int anchorMessageId,
    required int beforeCount,
    required int afterCount,
  }) {
    return repository.readConversationExcerptTimeline(
      conversationId: conversationId,
      anchorMessageId: anchorMessageId,
      beforeCount: beforeCount,
      afterCount: afterCount,
    );
  }
}
