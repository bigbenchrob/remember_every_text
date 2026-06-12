import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../../source_scoped_import/feature_level_providers.dart';
import '../../application/messages/message_projection_repository.dart';
import 'message_projection_repository.dart';

part 'message_projection_repository_provider.g.dart';

@riverpod
Future<MessageProjectionRepository> messageProjectionRepository(
  MessageProjectionRepositoryRef ref,
) async {
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return SqliteMessageProjectionRepository(
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
  );
}
