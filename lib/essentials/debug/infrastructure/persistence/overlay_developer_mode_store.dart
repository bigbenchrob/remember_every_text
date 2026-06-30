import '../../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/developer_mode_store.dart';

class OverlayDeveloperModeStore implements DeveloperModeStore {
  const OverlayDeveloperModeStore({required OverlayDatabase overlayDatabase})
    : _overlayDatabase = overlayDatabase;

  static const String _settingKey = 'developer_mode';

  final OverlayDatabase _overlayDatabase;

  @override
  Future<String?> readMode() {
    return _overlayDatabase.readOverlaySetting(_settingKey);
  }

  @override
  Future<void> writeMode(String mode) {
    return _overlayDatabase.writeOverlaySetting(
      settingKey: _settingKey,
      settingValue: mode,
    );
  }
}
