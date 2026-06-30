import 'chat_summary.dart';

abstract interface class ChatSummaryRepository {
  Future<List<ChatSummary>> readSummaries({
    ChatSummaryFilter filter = ChatSummaryFilter.all,
    ChatSummarySort sort = ChatSummarySort.mostRecentMessage,
    int? limit = 50,
  });

  Future<ChatSummarySanityCounts> readSanityCounts();

  Future<List<RecentChatMessage>> readRecentMessages({
    required int chatSsId,
    int limit = 20,
  });

  Future<List<RecentChatMessage>> readRecentTextMessages({
    required int chatSsId,
    int limit = 20,
  });

  Future<ChatMessageTextStats> readMessageTextStats({required int chatSsId});

  Future<ChatAttachmentStats> readAttachmentStats({required int chatSsId});

  Future<List<MessageAttachment>> readMessageAttachments({
    required int messageSsId,
  });
}
