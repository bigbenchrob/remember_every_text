import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider;
import '../../../source_scoped_import/feature_level_providers.dart'
    show sourceScopedImportLedgerProvider;
import '../../infrastructure/repositories/message_projection_repository.dart';
import 'message_projection_repository.dart';

part 'message_projection_repository_provider.g.dart';

@riverpod
Future<MessageProjectionRepository> messageProjectionRepository(Ref ref) async {
  final importLedgerDatabase = await ref.watch(
    sourceScopedImportLedgerProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteMessageProjectionRepository(
    importLedgerDatabase: importLedgerDatabase,
    graphDatabase: graphDatabase,
  );
}
