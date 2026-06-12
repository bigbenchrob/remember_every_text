import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../../source_scoped_import/feature_level_providers.dart';
import '../../application/chat_message_joins/chat_to_message_projection_repository.dart';
import 'chat_to_message_projection_repository.dart';

part 'chat_to_message_projection_repository_provider.g.dart';

@riverpod
Future<ChatToMessageProjectionRepository> chatToMessageProjectionRepository(
  ChatToMessageProjectionRepositoryRef ref,
) async {
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteChatToMessageProjectionRepository(
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
  );
}
