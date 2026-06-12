import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/contact_access/contact_access_store.dart';

class OverlayContactAccessStore implements ContactAccessStore {
  const OverlayContactAccessStore({required OverlayDatabase overlayDatabase})
    : _overlayDatabase = overlayDatabase;

  final OverlayDatabase _overlayDatabase;

  @override
  Future<void> trackContactAccess(int contactId) {
    return _overlayDatabase.trackContactAccess(contactId);
  }
}
