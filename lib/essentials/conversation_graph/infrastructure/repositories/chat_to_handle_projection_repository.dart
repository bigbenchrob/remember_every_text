import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../application/chat_handle_joins/chat_to_handle_projection_repository.dart';

class SqliteChatToHandleProjectionRepository
    implements ChatToHandleProjectionRepository {
  const SqliteChatToHandleProjectionRepository({
    required this.importLedgerDatabase,
    required this.graphDatabase,
  });

  final ImportDatabase importLedgerDatabase;
  final ConversationGraphDatabase graphDatabase;

  @override
  Future<ChatToHandleProjectionResult> projectEdges() async {
    final rows = await importLedgerDatabase.database.query(
      'chat_to_handle',
      columns: <String>['chat_ss_id', 'handle_ss_id'],
      orderBy: 'chat_ss_id ASC, handle_ss_id ASC',
    );

    var insertedEdgeCount = 0;
    await graphDatabase.transaction(() async {
      for (final row in rows) {
        final insertedCount = await graphDatabase.executeAndReadChanges(
          '''
          INSERT OR IGNORE INTO chat_to_handle (
            chat_ss_id,
            handle_ss_id
          ) VALUES (?, ?)
          ''',
          <Object?>[row['chat_ss_id'], row['handle_ss_id']],
        );
        if (insertedCount != 0) {
          insertedEdgeCount += 1;
        }
      }
    });

    return ChatToHandleProjectionResult(
      examinedEdgeCount: rows.length,
      insertedEdgeCount: insertedEdgeCount,
    );
  }
}
