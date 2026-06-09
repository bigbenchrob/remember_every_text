import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../infrastructure/repositories/chat_to_handle_projection_repository.dart';
import 'chat_to_handle_projector.dart';

part 'chat_to_handle_projector_provider.g.dart';

@riverpod
Future<ChatToHandleProjector> chatToHandleProjector(Ref ref) async {
  final importDatabase = await ref.watch(importDatabaseProvider.future);
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return ChatToHandleProjector(
    repository: SqliteChatToHandleProjectionRepository(
      importDatabase: importDatabase,
      graphDatabase: graphDatabase,
    ),
  );
}
