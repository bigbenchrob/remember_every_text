import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../infrastructure/repositories/contact_projection_repository.dart';
import 'contact_projector.dart';

part 'contact_projector_provider.g.dart';

@riverpod
Future<ContactProjector> contactProjector(Ref ref) async {
  final importDatabase = await ref.watch(importDatabaseProvider.future);
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return ContactProjector(
    repository: SqliteContactProjectionRepository(
      importDatabase: importDatabase,
      graphDatabase: graphDatabase,
    ),
  );
}
