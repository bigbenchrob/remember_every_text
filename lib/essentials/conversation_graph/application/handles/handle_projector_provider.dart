import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../infrastructure/repositories/handle_projection_repository.dart';
import 'handle_projector.dart';

part 'handle_projector_provider.g.dart';

@riverpod
Future<HandleProjector> handleProjector(Ref ref) async {
  final importDatabase = await ref.watch(importDatabaseProvider.future);
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return HandleProjector(
    repository: SqliteHandleProjectionRepository(
      importDatabase: importDatabase,
      graphDatabase: graphDatabase,
    ),
  );
}
