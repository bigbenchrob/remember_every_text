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

  Future<List<int>> readGlobalMessageIdsMatchingText({required String query}) {
    return repository.readGlobalMessageIdsMatchingText(query: query);
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

  Future<List<ConversationMessageTimelineEntry>> readMessageContextTimeline({
    required int messageId,
    required int chatId,
    required int beforeCount,
    required int afterCount,
  }) {
    return repository.readMessageContextTimeline(
      messageId: messageId,
      chatId: chatId,
      beforeCount: beforeCount,
      afterCount: afterCount,
    );
  }
}
