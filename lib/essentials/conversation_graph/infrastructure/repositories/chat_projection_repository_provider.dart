import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../../source_scoped_import/feature_level_providers.dart';
import '../../application/chats/chat_projection_repository.dart';
import 'chat_projection_repository.dart';

part 'chat_projection_repository_provider.g.dart';

@riverpod
Future<ChatProjectionRepository> chatProjectionRepository(
  ChatProjectionRepositoryRef ref,
) async {
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteChatProjectionRepository(
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
  );
}
