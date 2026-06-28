import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider;
import '../../infrastructure/repositories/conversation_repository.dart';
import 'conversation_repository.dart';

part 'conversation_repository_provider.g.dart';

@riverpod
Future<ConversationRepository> conversationRepository(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return SqliteConversationRepository(graphDatabase: graphDatabase);
}
