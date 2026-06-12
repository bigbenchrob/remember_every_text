import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../../source_scoped_import/feature_level_providers.dart';
import '../../application/handles/handle_projection_repository.dart';
import 'handle_projection_repository.dart';

part 'handle_projection_repository_provider.g.dart';

@riverpod
Future<HandleProjectionRepository> handleProjectionRepository(
  HandleProjectionRepositoryRef ref,
) async {
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteHandleProjectionRepository(
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
  );
}
