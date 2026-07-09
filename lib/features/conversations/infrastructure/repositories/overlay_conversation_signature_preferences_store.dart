import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/sidebar_cassette_spec/resolver_tools/conversation_signature_preferences_store.dart';

class OverlayConversationSignaturePreferencesStore
    implements ConversationSignaturePreferencesStore {
  const OverlayConversationSignaturePreferencesStore({
    required OverlayDatabase overlayDatabase,
  }) : _overlayDatabase = overlayDatabase;

  static const String _settingKey = 'conversation_signature_preferences';

  final OverlayDatabase _overlayDatabase;

  @override
  Future<String?> readPreferences() {
    return _overlayDatabase.readOverlaySetting(_settingKey);
  }

  @override
  Future<void> writePreferences(String storageValue) {
    return _overlayDatabase.writeOverlaySetting(
      settingKey: _settingKey,
      settingValue: storageValue,
    );
  }
}
