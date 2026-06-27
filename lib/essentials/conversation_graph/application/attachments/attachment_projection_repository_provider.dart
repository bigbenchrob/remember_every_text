import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart'
    show
        driftConversationGraphDatabaseProvider,
        sourceScopedImportDatabaseProvider;
import '../../infrastructure/repositories/attachment_projection_repository.dart';
import 'attachment_projection_repository.dart';

part 'attachment_projection_repository_provider.g.dart';

@riverpod
Future<AttachmentProjectionRepository> attachmentProjectionRepository(
  Ref ref,
) async {
  final importLedgerDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteAttachmentProjectionRepository(
    importLedgerDatabase: importLedgerDatabase,
    graphDatabase: graphDatabase,
  );
}
