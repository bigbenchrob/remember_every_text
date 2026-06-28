import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers/persistent_database_providers.dart'
    show
        driftConversationGraphDatabaseProvider,
        sourceScopedImportDatabaseProvider;
import '../../infrastructure/repositories/contact_projection_repository.dart';
import 'contact_projection_repository.dart';

part 'contact_projection_repository_provider.g.dart';

@riverpod
Future<ContactProjectionRepository> contactProjectionRepository(Ref ref) async {
  final importLedgerDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteContactProjectionRepository(
    importLedgerDatabase: importLedgerDatabase,
    graphDatabase: graphDatabase,
  );
}
