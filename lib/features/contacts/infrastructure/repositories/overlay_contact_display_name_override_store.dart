import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/display_name_overrides/contact_display_name_override_store.dart';

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
  }) {
    return _overlayDatabase.setParticipantDisplayNameOverride(
      contactId,
      displayName,
    );
  }
}
