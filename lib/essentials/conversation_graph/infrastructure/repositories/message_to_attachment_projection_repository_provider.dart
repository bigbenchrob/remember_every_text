import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../../source_scoped_import/feature_level_providers.dart';
import '../../application/message_attachment_joins/message_to_attachment_projection_repository.dart';
import 'message_to_attachment_projection_repository.dart';

part 'message_to_attachment_projection_repository_provider.g.dart';

@riverpod
Future<MessageToAttachmentProjectionRepository>
messageToAttachmentProjectionRepository(
  MessageToAttachmentProjectionRepositoryRef ref,
) async {
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteMessageToAttachmentProjectionRepository(
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
  );
}
