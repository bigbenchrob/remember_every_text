import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../infrastructure/working_database_provider.dart';
import 'chat_summary.dart';
import 'chat_summary_reader.dart';

part 'chat_summary_provider.g.dart';

@riverpod
Future<List<ChatSummary>> chatSummaries(Ref ref) async {
  final workingDatabase = await ref.watch(workingDatabaseProvider.future);
  return ChatSummaryReader(
    workingDatabase: workingDatabase,
  ).readSummaries(limit: 1000000);
}

@riverpod
Future<ChatSummarySanityCounts> chatSummarySanityCounts(Ref ref) async {
  final workingDatabase = await ref.watch(workingDatabaseProvider.future);
  return ChatSummaryReader(workingDatabase: workingDatabase).readSanityCounts();
}

@riverpod
Future<List<RecentChatMessage>> recentChatMessages(
  Ref ref,
  int chatSsId,
) async {
  final workingDatabase = await ref.watch(workingDatabaseProvider.future);
  return ChatSummaryReader(
    workingDatabase: workingDatabase,
  ).readRecentMessages(chatSsId: chatSsId);
}

@riverpod
Future<List<RecentChatMessage>> recentTextChatMessages(
  Ref ref,
  int chatSsId,
) async {
  final workingDatabase = await ref.watch(workingDatabaseProvider.future);
  return ChatSummaryReader(
    workingDatabase: workingDatabase,
  ).readRecentTextMessages(chatSsId: chatSsId);
}

@riverpod
Future<ChatMessageTextStats> chatMessageTextStats(Ref ref, int chatSsId) async {
  final workingDatabase = await ref.watch(workingDatabaseProvider.future);
  return ChatSummaryReader(
    workingDatabase: workingDatabase,
  ).readMessageTextStats(chatSsId: chatSsId);
}
