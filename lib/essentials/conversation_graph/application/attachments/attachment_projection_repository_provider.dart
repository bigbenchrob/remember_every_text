import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider;
import '../../../source_scoped_import/application/source_scoped_import_ledger_provider.dart'
    show sourceScopedImportLedgerProvider;
import '../../infrastructure/repositories/attachment_projection_repository.dart';
import 'attachment_projection_repository.dart';

part 'attachment_projection_repository_provider.g.dart';

@riverpod
Future<AttachmentProjectionRepository> attachmentProjectionRepository(
  Ref ref,
) async {
  final importLedgerDatabase = await ref.watch(
    sourceScopedImportLedgerProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteAttachmentProjectionRepository(
    importLedgerDatabase: importLedgerDatabase,
    graphDatabase: graphDatabase,
  );
}
