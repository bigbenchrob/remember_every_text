import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../../source_scoped_import/domain/known_sources.dart';
import '../../../source_scoped_import/domain/source_scoped_row_key.dart';
import '../../infrastructure/repositories/contact_graph_repository.dart';
import '../conversations/conversation.dart';
import 'contact_graph.dart';
import 'contact_graph_reader.dart';

part 'contact_graph_provider.g.dart';

@riverpod
Future<ContactGraphReader> contactGraphReader(Ref ref) async {
  final workingDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final legacyDatabase = await ref.watch(driftWorkingDatabaseProvider.future);
  return ContactGraphReader(
    repository: SqliteContactGraphRepository(
      workingDatabase: workingDatabase,
      legacyDatabase: legacyDatabase,
    ),
  );
}

@riverpod
Future<ContactGraphSnapshot> contactGraphSnapshot(
  Ref ref, {
  required int contactId,
}) async {
  final reader = await ref.watch(contactGraphReaderProvider.future);
  return reader.readContactGraph(contactId: contactId);
}

@riverpod
Future<ContactGraphSnapshot> contactPageGraphSnapshot(
  Ref ref, {
  required int contactId,
}) async {
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

int graphContactIdForContactPage(int contactId) {
  const virtualContactIdFloor = 1000000000;
  if (contactId <= 0 || contactId >= virtualContactIdFloor) {
    return contactId;
  }

  return SourceScopedRowKey.pack(
    sourceId: liveAddressBookSourceId,
    sourceRowId: contactId,
  );
}
