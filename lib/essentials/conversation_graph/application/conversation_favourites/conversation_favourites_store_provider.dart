import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers/persistent_database_providers.dart'
    show overlayDatabaseProvider;
import '../../infrastructure/repositories/overlay_conversation_favourites_store.dart';
import 'conversation_favourites_store.dart';

part 'conversation_favourites_store_provider.g.dart';

@riverpod
Future<ConversationFavouritesStore> conversationFavouritesStore(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayConversationFavouritesStore(overlayDatabase: overlayDatabase);
}
