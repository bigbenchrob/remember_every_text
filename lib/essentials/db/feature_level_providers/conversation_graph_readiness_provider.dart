import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../application/conversation_graph_readiness.dart';
import '../feature_level_providers.dart' show databaseDirectoryPath;
import '../infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../infrastructure/repositories/sqlite_conversation_graph_readiness_checker.dart';
import 'message_data_version_provider.dart';

export '../application/conversation_graph_readiness.dart';
export '../infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart'
    show conversationGraphDatabaseFileName;

part 'conversation_graph_readiness_provider.g.dart';

@Riverpod(keepAlive: true)
Future<ConversationGraphReadiness> conversationGraphReadiness(
  ConversationGraphReadinessRef ref,
) async {
  ref.watch(messageDataVersionProvider);
  final dbPath = path.join(
    databaseDirectoryPath,
    conversationGraphDatabaseFileName,
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
