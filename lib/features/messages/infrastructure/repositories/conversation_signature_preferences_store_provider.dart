import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../application/sidebar_cassette_spec/resolver_tools/conversation_signature_preferences_store.dart';
import 'overlay_conversation_signature_preferences_store.dart';

part 'conversation_signature_preferences_store_provider.g.dart';

@riverpod
Future<ConversationSignaturePreferencesStore>
conversationSignaturePreferencesStore(
  ConversationSignaturePreferencesStoreRef ref,
) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayConversationSignaturePreferencesStore(
    overlayDatabase: overlayDatabase,
  );
}
