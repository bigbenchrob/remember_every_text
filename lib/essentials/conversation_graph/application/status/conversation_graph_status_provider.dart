import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../providers.dart';
import '../../../db/feature_level_providers.dart';
import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../source_scoped_import/domain/known_sources.dart';
import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../domain/status/conversation_graph_status.dart';
import '../../infrastructure/repositories/conversation_graph_status_repository.dart';

export '../../domain/status/conversation_graph_status.dart';

part 'conversation_graph_status_provider.g.dart';

@riverpod
Future<ConversationGraphStatus> conversationGraphStatus(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importDatabase = await ref.watch(importDatabaseProvider.future);
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return const ConversationGraphStatusRepository().readStatus(
    chatDbPath: pathsHelper.chatDBPath,
    importDatabase: importDatabase,
    graphDatabase: graphDatabase,
    importDatabaseName: importDatabaseFileName,
    graphDatabaseName: conversationGraphDatabaseFileName,
    sourceId: liveChatDbSourceId,
  );
}
