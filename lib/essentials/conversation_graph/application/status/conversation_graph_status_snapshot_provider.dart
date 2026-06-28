import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart'
    show appDatabaseLabels, driftConversationGraphDatabaseProvider;
import '../../../paths/feature_level_providers.dart' show pathsHelperProvider;
import '../../../source_scoped_import/application/source_scoped_import_ledger_provider.dart'
    show sourceScopedImportLedgerProvider;
import '../../../source_scoped_import/domain/known_sources.dart';
import '../../domain/status/conversation_graph_status.dart';
import '../../infrastructure/repositories/conversation_graph_status_repository.dart';

part 'conversation_graph_status_snapshot_provider.g.dart';

@riverpod
Future<ConversationGraphStatus> conversationGraphStatusSnapshot(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importLedger = await ref.watch(sourceScopedImportLedgerProvider.future);
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return const ConversationGraphStatusRepository().readStatus(
    chatDbPath: pathsHelper.chatDBPath,
    importLedger: importLedger,
    graphDatabase: graphDatabase,
    importLedgerDatabaseLabel: appDatabaseLabels.sourceScopedImport,
    graphDatabaseLabel: appDatabaseLabels.conversationGraph,
    sourceId: liveChatDbSourceId,
  );
}
