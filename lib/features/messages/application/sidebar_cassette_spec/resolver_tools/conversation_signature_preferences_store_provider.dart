import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/db/feature_level_providers/persistent_database_providers.dart'
    show overlayDatabaseProvider;
import '../../../infrastructure/repositories/overlay_conversation_signature_preferences_store.dart';
import 'conversation_signature_preferences_store.dart';

part 'conversation_signature_preferences_store_provider.g.dart';

@riverpod
Future<ConversationSignaturePreferencesStore>
conversationSignaturePreferencesStore(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayConversationSignaturePreferencesStore(
    overlayDatabase: overlayDatabase,
  );
}
