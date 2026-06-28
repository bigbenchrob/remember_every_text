import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers/db_maintenance_lock_provider.dart'
    show dbMaintenanceLockProvider;
import '../../../../essentials/db/feature_level_providers/message_data_version_provider.dart'
    show messageDataVersionProvider;
import '../../../../essentials/db/feature_level_providers/persistent_database_providers.dart'
    show driftConversationGraphDatabaseProvider, overlayDatabaseProvider;
import '../../infrastructure/repositories/graph_contacts_list_reader.dart';
import 'contact_summary.dart';
import 'contacts_list_reader.dart';

part 'contacts_list_repository_provider.g.dart';

@riverpod
Future<ContactsListReader> contactsListReader(Ref ref) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return GraphContactsListReader(graphDb: graphDb, overlayDb: overlayDb);
}

@riverpod
Future<List<ContactSummary>> contactsListRepository(Ref ref) async {
  final maintenanceLocked = ref.watch(dbMaintenanceLockProvider);
  if (maintenanceLocked) {
    return const <ContactSummary>[];
  }

  ref.watch(messageDataVersionProvider);

  final reader = await ref.watch(contactsListReaderProvider.future);
  return reader.readContacts();
}
