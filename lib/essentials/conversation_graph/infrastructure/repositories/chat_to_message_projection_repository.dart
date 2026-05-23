import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../application/chat_message_joins/chat_to_message_projection_repository.dart';

class SqliteChatToMessageProjectionRepository
    implements ChatToMessageProjectionRepository {
  const SqliteChatToMessageProjectionRepository({
    required this.importDatabase,
    required this.workingDatabase,
  });

  final ImportDatabase importDatabase;
  final ConversationGraphDatabase workingDatabase;

  @override
  Future<ChatToMessageProjectionResult> projectEdges() async {
    final rows = await importDatabase.database.query(
      'chat_to_message',
      columns: <String>['chat_ss_id', 'message_ss_id'],
      orderBy: 'ss_id ASC',
    );

    var insertedEdgeCount = 0;
    await workingDatabase.transaction(() async {
      for (final row in rows) {
        final insertedCount = await workingDatabase.executeAndReadChanges(
          '''
          INSERT OR IGNORE INTO chat_to_message (
            chat_ss_id,
            message_ss_id
          ) VALUES (?, ?)
          ''',
          <Object?>[row['chat_ss_id'], row['message_ss_id']],
        );
        if (insertedCount != 0) {
          insertedEdgeCount += 1;
        }
      }
    });

    return ChatToMessageProjectionResult(
      examinedEdgeCount: rows.length,
      insertedEdgeCount: insertedEdgeCount,
    );
  }
}
