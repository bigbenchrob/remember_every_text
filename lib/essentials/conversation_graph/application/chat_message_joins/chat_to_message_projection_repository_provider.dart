import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers/persistent_database_providers.dart'
    show
        driftConversationGraphDatabaseProvider,
        sourceScopedImportDatabaseProvider;
import '../../infrastructure/repositories/chat_to_message_projection_repository.dart';
import 'chat_to_message_projection_repository.dart';

part 'chat_to_message_projection_repository_provider.g.dart';

@riverpod
Future<ChatToMessageProjectionRepository> chatToMessageProjectionRepository(
  Ref ref,
) async {
  final importLedgerDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteChatToMessageProjectionRepository(
    importLedgerDatabase: importLedgerDatabase,
    graphDatabase: graphDatabase,
  );
}
