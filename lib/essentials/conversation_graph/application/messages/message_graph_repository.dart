import '../conversations/conversation.dart';

abstract interface class MessageGraphRepository {
  Future<List<ConversationMessageTimelineEntry>> readGlobalMessageTimeline();

  Future<ConversationMessage?> readGlobalMessageById({required int messageId});

  Future<List<int>> readGlobalMessageIdsMatchingText({required String query});

  Future<List<ConversationMessageTimelineEntry>> readHandleMessageTimeline({
    required int handleId,
  });

  Future<ConversationMessage?> readHandleMessageById({
    required int handleId,
    required int messageId,
  });

  Future<List<ConversationMessageTimelineEntry>> readMessageContextTimeline({
    required int messageId,
    required int chatId,
    required int beforeCount,
    required int afterCount,
  });
}
