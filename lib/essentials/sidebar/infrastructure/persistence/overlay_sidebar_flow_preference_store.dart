import '../../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/sidebar_flow_preference_store.dart';

class OverlaySidebarFlowPreferenceStore implements SidebarFlowPreferenceStore {
  const OverlaySidebarFlowPreferenceStore({
    required OverlayDatabase overlayDatabase,
  }) : _overlayDatabase = overlayDatabase;

  final OverlayDatabase _overlayDatabase;

  @override
  Future<String?> readContactContextPreference() {
    return _overlayDatabase.readOverlaySetting(
      sidebarContactContextPreferenceSettingKey,
    );
  }

  @override
  Future<void> writeContactContextPreference(String value) {
    return _overlayDatabase.writeOverlaySetting(
      settingKey: sidebarContactContextPreferenceSettingKey,
      settingValue: value,
    );
  }

  @override
  Future<String?> readNavigationPreference() {
    return _overlayDatabase.readOverlaySetting(
      sidebarFlowNavigationPreferenceSettingKey,
    );
  }

  @override
  Future<void> writeNavigationPreference(String value) {
    return _overlayDatabase.writeOverlaySetting(
      settingKey: sidebarFlowNavigationPreferenceSettingKey,
      settingValue: value,
    );
  }
}
