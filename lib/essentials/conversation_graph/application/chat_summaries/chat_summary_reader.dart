import 'chat_summary.dart';
import 'chat_summary_repository.dart';

class ChatSummaryReader {
  const ChatSummaryReader({required this.repository});

  final ChatSummaryRepository repository;

  Future<List<ChatSummary>> readSummaries({
    ChatSummaryFilter filter = ChatSummaryFilter.all,
    ChatSummarySort sort = ChatSummarySort.mostRecentMessage,
    int? limit = 50,
  }) => repository.readSummaries(filter: filter, sort: sort, limit: limit);

  Future<ChatSummarySanityCounts> readSanityCounts() =>
      repository.readSanityCounts();

  Future<List<RecentChatMessage>> readRecentMessages({
    required int chatSsId,
    int limit = 20,
  }) => repository.readRecentMessages(chatSsId: chatSsId, limit: limit);

  Future<List<RecentChatMessage>> readRecentTextMessages({
    required int chatSsId,
    int limit = 20,
  }) => repository.readRecentTextMessages(chatSsId: chatSsId, limit: limit);

  Future<ChatMessageTextStats> readMessageTextStats({required int chatSsId}) =>
      repository.readMessageTextStats(chatSsId: chatSsId);

  Future<ChatAttachmentStats> readAttachmentStats({required int chatSsId}) =>
      repository.readAttachmentStats(chatSsId: chatSsId);

  Future<List<MessageAttachment>> readMessageAttachments({
    required int messageSsId,
  }) => repository.readMessageAttachments(messageSsId: messageSsId);
}
