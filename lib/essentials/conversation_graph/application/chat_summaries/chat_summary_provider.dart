import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../infrastructure/repositories/chat_summary_repository.dart';
import 'chat_summary.dart';
import 'chat_summary_reader.dart';

part 'chat_summary_provider.g.dart';

@riverpod
Future<List<ChatSummary>> chatSummaries(Ref ref) async {
  final workingDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return ChatSummaryReader(
    repository: SqliteChatSummaryRepository(workingDatabase: workingDatabase),
  ).readSummaries(limit: 1000000);
}

@riverpod
Future<ChatSummarySanityCounts> chatSummarySanityCounts(Ref ref) async {
  final workingDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return ChatSummaryReader(
    repository: SqliteChatSummaryRepository(workingDatabase: workingDatabase),
  ).readSanityCounts();
}

@riverpod
Future<List<RecentChatMessage>> recentChatMessages(
  Ref ref,
  int chatSsId,
) async {
  final workingDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return ChatSummaryReader(
    repository: SqliteChatSummaryRepository(workingDatabase: workingDatabase),
  ).readRecentMessages(chatSsId: chatSsId);
}

@riverpod
Future<List<RecentChatMessage>> recentTextChatMessages(
  Ref ref,
  int chatSsId,
) async {
  final workingDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return ChatSummaryReader(
    repository: SqliteChatSummaryRepository(workingDatabase: workingDatabase),
  ).readRecentTextMessages(chatSsId: chatSsId);
}

@riverpod
Future<ChatMessageTextStats> chatMessageTextStats(Ref ref, int chatSsId) async {
  final workingDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return ChatSummaryReader(
    repository: SqliteChatSummaryRepository(workingDatabase: workingDatabase),
  ).readMessageTextStats(chatSsId: chatSsId);
}

@riverpod
Future<ChatAttachmentStats> chatAttachmentStats(Ref ref, int chatSsId) async {
  final workingDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  final archiveDirectory = ref.watch(attachmentArchiveDirectoryProvider);
  return ChatSummaryReader(
    repository: SqliteChatSummaryRepository(
      workingDatabase: workingDatabase,
      overlayDatabase: overlayDatabase,
      attachmentArchiveDirectory: archiveDirectory,
    ),
  ).readAttachmentStats(chatSsId: chatSsId);
}

@riverpod
Future<List<MessageAttachment>> messageAttachments(
  Ref ref,
  int messageSsId,
) async {
  final workingDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  final archiveDirectory = ref.watch(attachmentArchiveDirectoryProvider);
  return ChatSummaryReader(
    repository: SqliteChatSummaryRepository(
      workingDatabase: workingDatabase,
      overlayDatabase: overlayDatabase,
      attachmentArchiveDirectory: archiveDirectory,
    ),
  ).readMessageAttachments(messageSsId: messageSsId);
}
