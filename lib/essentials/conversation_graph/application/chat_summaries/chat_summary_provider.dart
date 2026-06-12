import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers/message_data_version_provider.dart';
import '../../infrastructure/repositories/chat_summary_repository_provider.dart';
import 'chat_summary.dart';
import 'chat_summary_reader.dart';

part 'chat_summary_provider.g.dart';

@riverpod
Future<List<ChatSummary>> chatSummaries(Ref ref) async {
  ref.watch(messageDataVersionProvider);

  final repository = await ref.watch(chatSummaryRepositoryProvider.future);
  return ChatSummaryReader(
    repository: repository,
  ).readSummaries(limit: 1000000);
}

@riverpod
Future<ChatSummarySanityCounts> chatSummarySanityCounts(Ref ref) async {
  ref.watch(messageDataVersionProvider);

  final repository = await ref.watch(chatSummaryRepositoryProvider.future);
  return ChatSummaryReader(repository: repository).readSanityCounts();
}

@riverpod
Future<List<RecentChatMessage>> recentChatMessages(
  Ref ref,
  int chatSsId,
) async {
  ref.watch(messageDataVersionProvider);

  final repository = await ref.watch(chatSummaryRepositoryProvider.future);
  return ChatSummaryReader(
    repository: repository,
  ).readRecentMessages(chatSsId: chatSsId);
}

@riverpod
Future<List<RecentChatMessage>> recentTextChatMessages(
  Ref ref,
  int chatSsId,
) async {
  ref.watch(messageDataVersionProvider);

  final repository = await ref.watch(chatSummaryRepositoryProvider.future);
  return ChatSummaryReader(
    repository: repository,
  ).readRecentTextMessages(chatSsId: chatSsId);
}

@riverpod
Future<ChatMessageTextStats> chatMessageTextStats(Ref ref, int chatSsId) async {
  ref.watch(messageDataVersionProvider);

  final repository = await ref.watch(chatSummaryRepositoryProvider.future);
  return ChatSummaryReader(
    repository: repository,
  ).readMessageTextStats(chatSsId: chatSsId);
}

@riverpod
Future<ChatAttachmentStats> chatAttachmentStats(Ref ref, int chatSsId) async {
  ref.watch(messageDataVersionProvider);

  final repository = await ref.watch(chatSummaryRepositoryProvider.future);
  return ChatSummaryReader(
    repository: repository,
  ).readAttachmentStats(chatSsId: chatSsId);
}

@riverpod
Future<List<MessageAttachment>> messageAttachments(
  Ref ref,
  int messageSsId,
) async {
  final repository = await ref.watch(chatSummaryRepositoryProvider.future);
  return ChatSummaryReader(
    repository: repository,
  ).readMessageAttachments(messageSsId: messageSsId);
}
