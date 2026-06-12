import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../application/conversation_favourites/conversation_favourites_store.dart';
import 'overlay_conversation_favourites_store.dart';

part 'conversation_favourites_store_provider.g.dart';

@riverpod
Future<ConversationFavouritesStore> conversationFavouritesStore(
  ConversationFavouritesStoreRef ref,
) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayConversationFavouritesStore(overlayDatabase: overlayDatabase);
}
