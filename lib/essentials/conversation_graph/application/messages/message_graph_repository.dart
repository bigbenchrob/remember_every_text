import '../conversations/conversation.dart';

abstract interface class MessageGraphRepository {
  Future<List<ConversationMessageTimelineEntry>> readGlobalMessageTimeline();

  Future<ConversationMessage?> readGlobalMessageById({required int messageId});

  Future<List<int>> readGlobalMessageIdsMatchingText({
    required String query,
    bool matchAnyTerm = false,
  });

  Future<List<ConversationMessageTimelineEntry>> readHandleMessageTimeline({
    required int handleId,
  });

  Future<ConversationMessage?> readHandleMessageById({
    required int handleId,
    required int messageId,
  });

  Future<List<int>> readHandleMessageIdsMatchingText({
    required int handleId,
    required String query,
    bool matchAnyTerm = false,
  });

  Future<List<ConversationMessageTimelineEntry>>
  readConversationExcerptTimeline({
    required int conversationId,
    required int anchorMessageId,
    required int beforeCount,
    required int afterCount,
  });
}
