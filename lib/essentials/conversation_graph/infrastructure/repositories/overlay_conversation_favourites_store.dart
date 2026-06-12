import '../../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/conversation_favourites/conversation_favourites_store.dart';

class OverlayConversationFavouritesStore
    implements ConversationFavouritesStore {
  const OverlayConversationFavouritesStore({
    required OverlayDatabase overlayDatabase,
  }) : _overlayDatabase = overlayDatabase;

  static const String _settingKey = 'conversation_favourites/core';

  final OverlayDatabase _overlayDatabase;

  @override
  Future<String?> readCoreFavourites() {
    return _overlayDatabase.readOverlaySetting(_settingKey);
  }

  @override
  Future<void> writeCoreFavourites(String storageValue) {
    return _overlayDatabase.writeOverlaySetting(
      settingKey: _settingKey,
      settingValue: storageValue,
    );
  }
}
