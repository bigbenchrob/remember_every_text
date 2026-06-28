import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider, overlayDatabaseProvider;
import '../../infrastructure/repositories/graph_contact_profile_reader.dart';
import 'contact_profile_reader.dart';
import 'contact_profile_summary.dart';
import 'virtual_participants_provider.dart';

part 'contact_profile_provider.g.dart';

@riverpod
Future<ContactProfileReader> contactProfileReader(Ref ref) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return GraphContactProfileReader(graphDb: graphDb, overlayDb: overlayDb);
}

@riverpod
Future<ContactProfileSummary?> contactProfile(
  Ref ref, {
  required int contactId,
}) async {
  final reader = await ref.watch(contactProfileReaderProvider.future);
  final virtualContacts = await ref.watch(virtualParticipantsProvider.future);
  return reader.readContactProfile(
    contactId: contactId,
    virtualContacts: virtualContacts,
  );
}
