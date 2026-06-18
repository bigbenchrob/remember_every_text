import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/display_name_overrides/contact_display_name_override_store.dart';
import '../../application/read_models/contact_summary_identity.dart';

class OverlayContactDisplayNameOverrideStore
    implements ContactDisplayNameOverrideStore {
  const OverlayContactDisplayNameOverrideStore({
    required OverlayDatabase overlayDatabase,
  }) : _overlayDatabase = overlayDatabase;

  final OverlayDatabase _overlayDatabase;

  @override
  Future<void> setDisplayNameOverride({
    required int contactId,
    required String? displayName,
  }) async {
    final trimmed = displayName?.trim();
    final canonicalContactId = canonicalContactIdentityKey(contactId);
    for (final key in contactIdentityKeyVariants(contactId)) {
      await _overlayDatabase.deleteParticipantOverride(key);
    }
    if (trimmed == null || trimmed.isEmpty) {
      return;
    }
    await _overlayDatabase.setParticipantDisplayNameOverride(
      canonicalContactId,
      trimmed,
    );
  }
}
