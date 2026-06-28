import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers/persistent_database_providers.dart'
    show
        driftConversationGraphDatabaseProvider,
        sourceScopedImportDatabaseProvider;
import '../../infrastructure/repositories/message_to_attachment_projection_repository.dart';
import 'message_to_attachment_projection_repository.dart';

part 'message_to_attachment_projection_repository_provider.g.dart';

@riverpod
Future<MessageToAttachmentProjectionRepository>
messageToAttachmentProjectionRepository(Ref ref) async {
  final importLedgerDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteMessageToAttachmentProjectionRepository(
    importLedgerDatabase: importLedgerDatabase,
    graphDatabase: graphDatabase,
  );
}
