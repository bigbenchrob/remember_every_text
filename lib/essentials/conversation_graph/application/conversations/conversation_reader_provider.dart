import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../infrastructure/working_database_provider.dart';
import 'conversation.dart';
import 'conversation_reader.dart';

part 'conversation_reader_provider.g.dart';

@riverpod
Future<ConversationReader> conversationReader(Ref ref) async {
  final workingDatabase = await ref.watch(workingDatabaseProvider.future);
  return ConversationReader(workingDatabase: workingDatabase);
}

@riverpod
Future<List<ConversationOverview>> conversationOverviews(
  Ref ref, {
  int limit = 100,
}) async {
  final reader = await ref.watch(conversationReaderProvider.future);
  return reader.readOverviews(limit: limit);
}

@riverpod
Future<List<ConversationMessage>> conversationMessages(
  Ref ref, {
  required int conversationId,
  int limit = 100,
}) async {
  final reader = await ref.watch(conversationReaderProvider.future);
  return reader.readMessages(conversationId: conversationId, limit: limit);
}

@riverpod
Future<Set<int>> conversationIdsMatchingMessageText(
  Ref ref, {
  required String query,
  int limit = 500,
}) async {
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
}) async {
  final reader = await ref.watch(conversationReaderProvider.future);
  return reader.readConversationMessageTextMatches(query: query, limit: limit);
}
