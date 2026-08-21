import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../app_database_files.dart';
import '../application/conversation_graph_readiness.dart';
import '../infrastructure/repositories/sqlite_conversation_graph_readiness_checker.dart';
import 'db_maintenance_lock_provider.dart';
import 'message_data_version_provider.dart';

part 'conversation_graph_readiness_provider.g.dart';

@Riverpod(keepAlive: true)
Future<ConversationGraphReadiness> conversationGraphReadiness(
  ConversationGraphReadinessRef ref,
) async {
  ref.watch(messageDataVersionProvider);
  if (ref.watch(dbMaintenanceLockProvider)) {
    return const ConversationGraphReadiness(
      isReady: false,
      reason: 'database maintenance is active',
      messageCount: 0,
      chatCount: 0,
      chatToMessageEdgeCount: 0,
    );
  }
  final authority = ref.watch(archiveAccessAuthorityProvider);
  final dbPath = appDatabasePath(
    AppDatabaseFile.conversationGraph,
    databaseDirectory: authority.rootPath,
  );
  return const SqliteConversationGraphReadinessChecker().checkPath(dbPath);
}

@Riverpod(keepAlive: true)
class ConversationGraphPopulated extends _$ConversationGraphPopulated {
  @override
  bool build() {
    ref.watch(messageDataVersionProvider);
    final readiness = ref.watch(conversationGraphReadinessProvider);

    return readiness.valueOrNull?.isReady ?? false;
  }
}
