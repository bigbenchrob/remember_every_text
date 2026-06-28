import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers/persistent_database_providers.dart'
    show overlayDatabaseProvider;
import '../../infrastructure/repositories/overlay_recent_contacts_reader.dart';
import 'contacts_list_repository_provider.dart';
import 'recent_contact_summary.dart';
import 'recent_contacts_reader.dart';

part 'recent_contacts_provider.g.dart';

@riverpod
Future<RecentContactsReader> recentContactsReader(Ref ref) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return OverlayRecentContactsReader(overlayDb: overlayDb);
}

@riverpod
Future<List<RecentContactSummary>> recentContacts(Ref ref) async {
  final reader = await ref.watch(recentContactsReaderProvider.future);
  final contacts = await ref.watch(contactsListRepositoryProvider.future);
  return reader.readRecentContacts(contacts: contacts);
}
