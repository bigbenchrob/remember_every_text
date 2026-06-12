import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../providers.dart';
import '../../../db/feature_level_providers.dart';
import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../source_scoped_import/domain/known_sources.dart';
import '../../../source_scoped_import/feature_level_providers.dart';
import '../../domain/status/conversation_graph_status.dart';
import 'conversation_graph_status_repository.dart';

part 'conversation_graph_status_repository_provider.g.dart';

@riverpod
Future<ConversationGraphStatus> conversationGraphStatusSnapshot(
  ConversationGraphStatusSnapshotRef ref,
) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return const ConversationGraphStatusRepository().readStatus(
    chatDbPath: pathsHelper.chatDBPath,
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
    importDatabaseName: sourceScopedImportDatabaseFileName,
    graphDatabaseName: conversationGraphDatabaseFileName,
    sourceId: liveChatDbSourceId,
  );
}
