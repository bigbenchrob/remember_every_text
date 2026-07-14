import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import '../../infrastructure/repositories/overlay_conversation_tag_repository.dart';
import 'conversation_tag_repository.dart';

part 'conversation_tag_repository_provider.g.dart';

@riverpod
Future<ConversationTagRepository> conversationTagRepository(Ref ref) async {
  final database = await ref.watch(overlayDatabaseProvider.future);
  return OverlayConversationTagRepository(database: database);
}
