import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/db/feature_level_providers.dart';
import 'application/contact_access/contact_access_store.dart';
import 'application/display_identity/display_identity.dart';
import 'application/display_name_overrides/contact_display_name_override_store.dart';
import 'application/read_models/contact_profile_reader.dart';
import 'application/read_models/contact_profile_summary.dart';
import 'application/read_models/contact_summary.dart';
import 'application/read_models/contact_summary_identity.dart';
import 'application/read_models/contacts_list_reader.dart';
import 'application/read_models/handles_for_contact_reader.dart';
import 'application/read_models/linked_handle.dart';
import 'application/read_models/recent_contact_summary.dart';
import 'application/read_models/recent_contacts_reader.dart';
import 'application/read_models/virtual_participants_reader.dart';
import 'application/services/manual_handle_link_store.dart';
import 'application/sidebar_cassette_spec/resolver_tools/picker_filter_mode_store.dart';
import 'domain/overlay_virtual_contact.dart';
import 'infrastructure/repositories/display_identity_repository.dart';
import 'infrastructure/repositories/favorite_contacts_repository.dart';
import 'infrastructure/repositories/graph_contact_profile_reader.dart';
import 'infrastructure/repositories/graph_contacts_list_reader.dart';
import 'infrastructure/repositories/graph_handles_for_contact_reader.dart';
import 'infrastructure/repositories/overlay_contact_access_store.dart';
import 'infrastructure/repositories/overlay_contact_display_name_override_store.dart';
import 'infrastructure/repositories/overlay_manual_handle_link_store.dart';
import 'infrastructure/repositories/overlay_picker_filter_mode_store.dart';
import 'infrastructure/repositories/overlay_recent_contacts_reader.dart';
import 'infrastructure/repositories/overlay_virtual_participants_reader.dart';

// =============================================================================
// CONTACTS FEATURE — PUBLIC API
// =============================================================================
//
// This barrel file exports only the public API of the contacts feature.
// External code should import ONLY this file.
//
// Exports:
// - Spec classes (domain)
// - Coordinators (application)
// - Cassette payloads and render-edge builders
// - Settings providers
// - Repositories (for cross-feature data access)
// - Public contact display identity read models/providers
// - Public contact-selection dialog used by cross-feature linking flows
//
// Does NOT export:
// - Resolvers
// - Internal widget builders
// - Infrastructure details
// =============================================================================

export './application/display_identity/display_identity.dart';
export './application/read_models/contact_profile_reader.dart';
export './application/read_models/contact_profile_summary.dart';
export './application/read_models/contact_summary.dart';
export './application/read_models/contacts_list_reader.dart';
export './application/read_models/handles_for_contact_reader.dart';
export './application/read_models/linked_handle.dart';
export './application/read_models/recent_contact_summary.dart';
export './application/read_models/recent_contacts_reader.dart';
export './application/read_models/virtual_participants_reader.dart';
export './application/services/manual_handle_link_service.dart';
export './application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart';
export './application/sidebar_cassette_spec/coordinators/contact_chooser_cassette_state_provider.dart';
export './application/sidebar_cassette_spec/coordinators/info_cassette_coordinator.dart';
export './application/sidebar_cassette_spec/payloads/contact_chooser_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/contact_hero_summary_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/contact_message_scope_toggle_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/contact_selection_control_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/handle_filter_cassette_payload.dart';
export './application/sidebar_cassette_spec/rendering/contacts_cassette_body_builder.dart';
export './application/tooltips_spec/coordinators/contacts_tooltip_coordinator.dart';
export './domain/overlay_virtual_contact.dart';
export './domain/spec_classes/contacts_cassette_spec.dart';
export './domain/spec_classes/contacts_tooltip_spec.dart';
export './presentation/widgets/contact_picker_dialog.dart';

part 'feature_level_providers.g.dart';

@riverpod
Future<ContactDisplayNameOverrideStore> contactDisplayNameOverrideStore(
  Ref ref,
) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayContactDisplayNameOverrideStore(
    overlayDatabase: overlayDatabase,
  );
}

/// Semantic display-identity boundary.
///
/// This resolver answers "what should the user see?", not "which database row
/// owns this information?". Row ids and handle values are inputs/provenance;
/// the output is an app-facing identity label.
@riverpod
Future<DisplayIdentityResolver> displayIdentityResolver(Ref ref) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return SqliteDisplayIdentityRepository(
    graphDatabase: graphDb,
    overlayDatabase: overlayDb,
  ).readResolver();
}

@riverpod
Future<FavoriteContactsRepository> favoriteContactsRepository(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return FavoriteContactsRepository(overlayDatabase);
}

@riverpod
Future<ManualHandleLinkStore> manualHandleLinkStore(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayManualHandleLinkStore(overlayDatabase: overlayDatabase);
}

@riverpod
Future<PickerFilterModeStore> pickerFilterModeStore(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayPickerFilterModeStore(overlayDatabase: overlayDatabase);
}

@riverpod
Future<VirtualParticipantsReader> virtualParticipantsReader(Ref ref) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return OverlayVirtualParticipantsReader(overlayDb: overlayDb);
}

@riverpod
Future<List<OverlayVirtualContact>> virtualParticipants(Ref ref) async {
  final reader = await ref.watch(virtualParticipantsReaderProvider.future);
  return reader.readVirtualParticipants();
}

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
