import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../../source_scoped_import/feature_level_providers.dart';
import '../../application/attachments/attachment_projection_repository.dart';
import 'attachment_projection_repository.dart';

part 'attachment_projection_repository_provider.g.dart';

@riverpod
Future<AttachmentProjectionRepository> attachmentProjectionRepository(
  AttachmentProjectionRepositoryRef ref,
) async {
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteAttachmentProjectionRepository(
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
  );
}
