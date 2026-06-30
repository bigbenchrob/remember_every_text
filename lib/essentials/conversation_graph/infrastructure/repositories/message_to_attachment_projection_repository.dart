import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../source_scoped_import/domain/ports/import_ledger_port.dart';
import '../../application/message_attachment_joins/message_to_attachment_projection_repository.dart';

class SqliteMessageToAttachmentProjectionRepository
    implements MessageToAttachmentProjectionRepository {
  const SqliteMessageToAttachmentProjectionRepository({
    required this.importLedgerDatabase,
    required this.graphDatabase,
  });

  final ImportLedger importLedgerDatabase;
  final ConversationGraphDatabase graphDatabase;

  @override
  Future<MessageToAttachmentProjectionResult> projectEdges() async {
    return _projectEdgesWhere(whereClause: null, whereArgs: const <Object?>[]);
  }

  @override
  Future<MessageToAttachmentProjectionResult>
  projectEdgesAfterSourceMessageRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
  }) {
    return _projectEdgesWhere(
      whereClause: 'message_source_id = ? AND source_message_rowid > ?',
      whereArgs: <Object?>[sourceId, startedAfterSourceRowId],
    );
  }

  Future<MessageToAttachmentProjectionResult> _projectEdgesWhere({
    required String? whereClause,
    required List<Object?> whereArgs,
  }) async {
    final rows = await importLedgerDatabase.queryTable(
      'message_to_attachment',
      columns: <String>['message_ss_id', 'attachment_ss_id'],
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'message_ss_id ASC, attachment_ss_id ASC',
    );

    var insertedEdgeCount = 0;
    await graphDatabase.transaction(() async {
      for (final row in rows) {
        final insertedCount = await graphDatabase.executeAndReadChanges(
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
