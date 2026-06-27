import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers/message_data_version_provider.dart';
import '../conversations/conversation.dart';
import '../identity/contact_page_graph_identity.dart';
import 'contact_graph.dart';
import 'contact_graph_reader.dart';
import 'contact_graph_repository_provider.dart';

part 'contact_graph_provider.g.dart';

@riverpod
Future<ContactGraphReader> contactGraphReader(Ref ref) async {
  final repository = await ref.watch(contactGraphRepositoryProvider.future);
  return ContactGraphReader(repository: repository);
}

@riverpod
Future<ContactGraphSnapshot> contactGraphSnapshot(
  Ref ref, {
  required int contactId,
}) async {
  ref.watch(messageDataVersionProvider);

  final reader = await ref.watch(contactGraphReaderProvider.future);
  return reader.readContactGraph(contactId: contactId);
}

@riverpod
Future<ContactGraphSnapshot> contactPageGraphSnapshot(
  Ref ref, {
  required int contactId,
}) async {
  ref.watch(messageDataVersionProvider);

  final reader = await ref.watch(contactGraphReaderProvider.future);
  final graphContactId = graphContactIdForContactPage(contactId);
  return reader.readContactPageGraph(
    contactId: contactId,
    graphContactId: graphContactId,
  );
}

@riverpod
Future<List<ConversationMessage>> contactPageGraphMessages(
  Ref ref, {
  required int contactId,
  int limit = 500,
  DateTime? monthAnchor,
}) async {
  ref.watch(messageDataVersionProvider);

  final reader = await ref.watch(contactGraphReaderProvider.future);
  final graphContactId = graphContactIdForContactPage(contactId);
  return reader.readContactPageMessages(
    contactId: contactId,
    graphContactId: graphContactId,
    limit: limit,
    monthAnchor: monthAnchor,
  );
}

@riverpod
Future<List<ContactGraphMessageTimelineEntry>> contactPageGraphMessageTimeline(
  Ref ref, {
  required int contactId,
}) async {
  ref.watch(messageDataVersionProvider);

  final reader = await ref.watch(contactGraphReaderProvider.future);
  final graphContactId = graphContactIdForContactPage(contactId);
  return reader.readContactPageMessageTimeline(
    contactId: contactId,
    graphContactId: graphContactId,
  );
}

@riverpod
Future<ConversationMessage?> contactPageGraphMessageById(
  Ref ref, {
  required int contactId,
  required int messageId,
}) async {
  final reader = await ref.watch(contactGraphReaderProvider.future);
  final graphContactId = graphContactIdForContactPage(contactId);
  return reader.readContactPageMessageById(
    contactId: contactId,
    graphContactId: graphContactId,
    messageId: messageId,
  );
}

@riverpod
Future<List<ContactGraphMessageTimelineEntry>>
contactPageGraphHandleMessageTimeline(
  Ref ref, {
  required int contactId,
  required int handleId,
}) async {
  ref.watch(messageDataVersionProvider);

  final reader = await ref.watch(contactGraphReaderProvider.future);
  final graphContactId = graphContactIdForContactPage(contactId);
  return reader.readContactPageHandleMessageTimeline(
    contactId: contactId,
    graphContactId: graphContactId,
    handleId: handleId,
  );
}

@riverpod
Future<ConversationMessage?> contactPageGraphHandleMessageById(
  Ref ref, {
  required int contactId,
  required int handleId,
  required int messageId,
}) async {
  final reader = await ref.watch(contactGraphReaderProvider.future);
  final graphContactId = graphContactIdForContactPage(contactId);
  return reader.readContactPageHandleMessageById(
    contactId: contactId,
    graphContactId: graphContactId,
    handleId: handleId,
    messageId: messageId,
  );
}

@riverpod
Future<List<ConversationMessage>> contactPageGraphHandleMessages(
  Ref ref, {
  required int contactId,
  required int handleId,
  int limit = 500,
  DateTime? monthAnchor,
}) async {
  ref.watch(messageDataVersionProvider);

  final reader = await ref.watch(contactGraphReaderProvider.future);
  final graphContactId = graphContactIdForContactPage(contactId);
  return reader.readContactPageHandleMessages(
    contactId: contactId,
    graphContactId: graphContactId,
    handleId: handleId,
    limit: limit,
    monthAnchor: monthAnchor,
  );
}

@riverpod
Future<List<int>> contactPageGraphMessageIdsMatchingText(
  Ref ref, {
  required int contactId,
  required String query,
  bool matchAnyTerm = false,
  int? handleId,
}) async {
  ref.watch(messageDataVersionProvider);

  final reader = await ref.watch(contactGraphReaderProvider.future);
  final graphContactId = graphContactIdForContactPage(contactId);
  return reader.readContactPageMessageIdsMatchingText(
    contactId: contactId,
    graphContactId: graphContactId,
    query: query,
    matchAnyTerm: matchAnyTerm,
    handleId: handleId,
  );
}
