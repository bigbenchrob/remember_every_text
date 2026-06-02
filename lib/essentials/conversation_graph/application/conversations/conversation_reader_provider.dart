import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../infrastructure/repositories/conversation_repository.dart';
import 'conversation.dart';
import 'conversation_reader.dart';

part 'conversation_reader_provider.g.dart';

@riverpod
Future<ConversationReader> conversationReader(Ref ref) async {
  final workingDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return ConversationReader(
    repository: SqliteConversationRepository(workingDatabase: workingDatabase),
  );
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
