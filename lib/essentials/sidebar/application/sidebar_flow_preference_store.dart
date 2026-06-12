const String sidebarContactContextPreferenceSettingKey =
    'sidebar_contact_context';
const String sidebarFlowNavigationPreferenceSettingKey =
    'sidebar_flow_navigation';

abstract interface class SidebarFlowPreferenceStore {
  Future<String?> readContactContextPreference();

  Future<void> writeContactContextPreference(String value);

  Future<String?> readNavigationPreference();

  Future<void> writeNavigationPreference(String value);
}
