import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers/persistent_database_providers.dart'
    show overlayDatabaseProvider;
import '../../infrastructure/repositories/overlay_contact_access_store.dart';
import '../read_models/contact_summary_identity.dart';
import '../read_models/recent_contacts_provider.dart'
    show recentContactsProvider;
import 'contact_access_store.dart';

part 'contact_access_provider.g.dart';

@riverpod
Future<ContactAccessStore> contactAccessStore(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayContactAccessStore(overlayDatabase: overlayDatabase);
}

@riverpod
class ContactAccessActions extends _$ContactAccessActions {
  @override
  FutureOr<void> build() {}

  Future<void> recordContactSelection(int contactId) async {
    final store = await ref.watch(contactAccessStoreProvider.future);
    for (final key in contactIdentityKeyVariants(contactId)) {
      await store.clearContactAccess(key);
    }
    await store.trackContactAccess(canonicalContactIdentityKey(contactId));
    ref.invalidate(recentContactsProvider);
  }
}
