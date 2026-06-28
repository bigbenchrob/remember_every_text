import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers/persistent_database_providers.dart'
    show driftConversationGraphDatabaseProvider, overlayDatabaseProvider;
import '../../infrastructure/repositories/graph_handles_for_contact_reader.dart';
import 'handles_for_contact_reader.dart';
import 'linked_handle.dart';

part 'handles_for_contact_provider.g.dart';

@riverpod
Future<HandlesForContactReader> handlesForContactReader(Ref ref) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return GraphHandlesForContactReader(graphDb: graphDb, overlayDb: overlayDb);
}

@riverpod
Future<List<LinkedHandle>> handlesForContact(
  Ref ref, {
  required int contactId,
}) async {
  final reader = await ref.watch(handlesForContactReaderProvider.future);
  return reader.readHandlesForContact(contactId: contactId);
}
