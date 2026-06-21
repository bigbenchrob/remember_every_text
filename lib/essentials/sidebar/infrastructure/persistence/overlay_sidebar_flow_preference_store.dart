import '../../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/sidebar_flow_preference_store.dart';

class OverlaySidebarFlowPreferenceStore implements SidebarFlowPreferenceStore {
  const OverlaySidebarFlowPreferenceStore({
    required OverlayDatabase overlayDatabase,
    void Function(String settingKey, Object error, StackTrace stackTrace)?
    onReadFailure,
    void Function(
      String settingKey,
      String settingValue,
      Object error,
      StackTrace stackTrace,
    )?
    onWriteFailure,
  }) : _overlayDatabase = overlayDatabase,
       _onReadFailure = onReadFailure,
       _onWriteFailure = onWriteFailure;

  final OverlayDatabase _overlayDatabase;
  final void Function(String settingKey, Object error, StackTrace stackTrace)?
  _onReadFailure;
  final void Function(
    String settingKey,
    String settingValue,
    Object error,
    StackTrace stackTrace,
  )?
  _onWriteFailure;

  @override
  Future<String?> readContactContextPreference() {
    return _readSetting(sidebarContactContextPreferenceSettingKey);
  }

  @override
  Future<void> writeContactContextPreference(String value) {
    return _writeSetting(sidebarContactContextPreferenceSettingKey, value);
  }

  @override
  Future<String?> readNavigationPreference() {
    return _readSetting(sidebarFlowNavigationPreferenceSettingKey);
  }

  @override
  Future<void> writeNavigationPreference(String value) {
    return _writeSetting(sidebarFlowNavigationPreferenceSettingKey, value);
  }

  Future<String?> _readSetting(String settingKey) async {
    try {
      return await _overlayDatabase.readOverlaySetting(settingKey);
    } catch (error, stackTrace) {
      _onReadFailure?.call(settingKey, error, stackTrace);
      return null;
    }
  }

  Future<void> _writeSetting(String settingKey, String settingValue) async {
    try {
      await _overlayDatabase.writeOverlaySetting(
        settingKey: settingKey,
        settingValue: settingValue,
      );
    } catch (error, stackTrace) {
      _onWriteFailure?.call(settingKey, settingValue, error, stackTrace);
      rethrow;
    }
  }
}
