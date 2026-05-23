import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../application/message_attachment_joins/message_to_attachment_projection_repository.dart';

class SqliteMessageToAttachmentProjectionRepository
    implements MessageToAttachmentProjectionRepository {
  const SqliteMessageToAttachmentProjectionRepository({
    required this.importDatabase,
    required this.workingDatabase,
  });

  final ImportDatabase importDatabase;
  final ConversationGraphDatabase workingDatabase;

  @override
  Future<MessageToAttachmentProjectionResult> projectEdges() async {
    final rows = await importDatabase.database.query(
      'message_to_attachment',
      columns: <String>['message_ss_id', 'attachment_ss_id'],
      orderBy: 'message_ss_id ASC, attachment_ss_id ASC',
    );

    var insertedEdgeCount = 0;
    await workingDatabase.transaction(() async {
      for (final row in rows) {
        final insertedCount = await workingDatabase.executeAndReadChanges(
          '''
          INSERT OR IGNORE INTO message_to_attachment (
            message_ss_id,
            attachment_ss_id
          ) VALUES (?, ?)
          ''',
          <Object?>[row['message_ss_id'], row['attachment_ss_id']],
        );
        if (insertedCount != 0) {
          insertedEdgeCount += 1;
        }
      }
    });

    return MessageToAttachmentProjectionResult(
      examinedEdgeCount: rows.length,
      insertedEdgeCount: insertedEdgeCount,
    );
  }
}
