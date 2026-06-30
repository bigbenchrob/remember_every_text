import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/sidebar_cassette_spec/resolver_tools/picker_filter_mode_store.dart';

class OverlayPickerFilterModeStore implements PickerFilterModeStore {
  const OverlayPickerFilterModeStore({required OverlayDatabase overlayDatabase})
    : _overlayDatabase = overlayDatabase;

  static const String _settingKey = 'contact_picker_filter_mode';

  final OverlayDatabase _overlayDatabase;

  @override
  Future<String?> readMode() {
    return _overlayDatabase.readOverlaySetting(_settingKey);
  }

  @override
  Future<void> writeMode(String storageValue) {
    return _overlayDatabase.writeOverlaySetting(
      settingKey: _settingKey,
      settingValue: storageValue,
    );
  }
}
