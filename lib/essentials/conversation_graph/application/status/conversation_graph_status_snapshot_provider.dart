import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/app_database_files.dart';
import '../../../db/feature_level_providers.dart'
    show
        driftConversationGraphDatabaseProvider,
        sourceScopedImportDatabaseProvider;
import '../../../paths/feature_level_providers.dart';
import '../../../source_scoped_import/domain/known_sources.dart';
import '../../domain/status/conversation_graph_status.dart';
import '../../infrastructure/repositories/conversation_graph_status_repository.dart';

part 'conversation_graph_status_snapshot_provider.g.dart';

@riverpod
Future<ConversationGraphStatus> conversationGraphStatusSnapshot(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importLedgerDatabase = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return const ConversationGraphStatusRepository().readStatus(
    chatDbPath: pathsHelper.chatDBPath,
    importLedgerDatabase: importLedgerDatabase,
    graphDatabase: graphDatabase,
    importLedgerDatabaseLabel: appDatabaseFileName(
      AppDatabaseFile.sourceScopedImport,
    ),
    graphDatabaseLabel: appDatabaseFileName(AppDatabaseFile.conversationGraph),
    sourceId: liveChatDbSourceId,
  );
}
