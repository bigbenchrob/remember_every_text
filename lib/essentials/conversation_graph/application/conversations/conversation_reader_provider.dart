import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers/message_data_version_provider.dart'
    show messageDataVersionProvider;
import 'conversation.dart';
import 'conversation_reader.dart';
import 'conversation_repository_provider.dart';

part 'conversation_reader_provider.g.dart';

@riverpod
Future<ConversationReader> conversationReader(Ref ref) async {
  final repository = await ref.watch(conversationRepositoryProvider.future);
  return ConversationReader(repository: repository);
}

@riverpod
Future<List<ConversationOverview>> conversationOverviews(
  Ref ref, {
  int limit = 100,
}) async {
  ref.watch(messageDataVersionProvider);

  final reader = await ref.watch(conversationReaderProvider.future);
  return reader.readOverviews(limit: limit);
}

@riverpod
Future<ConversationOverview?> conversationOverviewById(
  Ref ref, {
  required int conversationId,
}) async {
  ref.watch(messageDataVersionProvider);

  final reader = await ref.watch(conversationReaderProvider.future);
  final overviews = await reader.readOverviewsByIds(
    conversationIds: [conversationId],
  );
  return overviews.isEmpty ? null : overviews.first;
}

@riverpod
Future<List<ConversationMessage>> conversationMessages(
  Ref ref, {
  required int conversationId,
  int limit = 100,
}) async {
  ref.watch(messageDataVersionProvider);

  final reader = await ref.watch(conversationReaderProvider.future);
  return reader.readMessages(conversationId: conversationId, limit: limit);
}

@riverpod
Future<Set<int>> conversationIdsMatchingMessageText(
  Ref ref, {
  required String query,
  int limit = 500,
}) async {
  ref.watch(messageDataVersionProvider);

  final reader = await ref.watch(conversationReaderProvider.future);
  return reader.readConversationIdsMatchingMessageText(
    query: query,
    limit: limit,
  );
}

@riverpod
Future<Map<int, ConversationMessageTextMatch>> conversationMessageTextMatches(
  Ref ref, {
  required String query,
  int limit = 500,
  int snippetsPerConversation = 3,
}) async {
  ref.watch(messageDataVersionProvider);

  final reader = await ref.watch(conversationReaderProvider.future);
  return reader.readConversationMessageTextMatches(
    query: query,
    limit: limit,
    snippetsPerConversation: snippetsPerConversation,
  );
}
