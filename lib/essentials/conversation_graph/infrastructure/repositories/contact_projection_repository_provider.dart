import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../../source_scoped_import/feature_level_providers.dart';
import '../../application/contacts/contact_projection_repository.dart';
import 'contact_projection_repository.dart';

part 'contact_projection_repository_provider.g.dart';

@riverpod
Future<ContactProjectionRepository> contactProjectionRepository(
  ContactProjectionRepositoryRef ref,
) async {
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteContactProjectionRepository(
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
  );
}
