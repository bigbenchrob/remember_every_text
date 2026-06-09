import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../application/attachments/attachment_projection_repository.dart';

class SqliteAttachmentProjectionRepository
    implements AttachmentProjectionRepository {
  const SqliteAttachmentProjectionRepository({
    required this.importDatabase,
    required this.graphDatabase,
  });

  final ImportDatabase importDatabase;
  final ConversationGraphDatabase graphDatabase;

  @override
  Future<AttachmentProjectionResult> projectAttachments() async {
    return _projectAttachmentsWhere(
      whereClause: null,
      whereArgs: const <Object?>[],
    );
  }

  @override
  Future<AttachmentProjectionResult> projectAttachmentsAfterSourceRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
  }) {
    return _projectAttachmentsWhere(
      whereClause: 'source_id = ? AND source_rowid > ?',
      whereArgs: <Object?>[sourceId, startedAfterSourceRowId],
    );
  }

  Future<AttachmentProjectionResult> _projectAttachmentsWhere({
    required String? whereClause,
    required List<Object?> whereArgs,
  }) async {
    final rows = await importDatabase.database.query(
      'attachments',
      columns: <String>[
        'ss_id',
        'guid',
        'filename',
        'transfer_name',
        'uti',
        'mime_type',
        'total_bytes',
        'created_at_utc',
      ],
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'ss_id ASC',
    );

    var insertedAttachmentCount = 0;
    await graphDatabase.transaction(() async {
      for (final row in rows) {
        final insertedCount = await graphDatabase.executeAndReadChanges(
          '''
          INSERT OR IGNORE INTO attachments (
            ss_id,
            guid,
            filename,
            transfer_name,
            uti,
            mime_type,
            total_bytes,
            created_at_utc
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          <Object?>[
            row['ss_id'],
            row['guid'],
            row['filename'],
            row['transfer_name'],
            row['uti'],
            row['mime_type'],
            row['total_bytes'],
            row['created_at_utc'],
          ],
        );
        if (insertedCount == 0) {
          await graphDatabase.executeSql(
            '''
            UPDATE attachments
            SET
              guid = ?,
              filename = ?,
              transfer_name = ?,
              uti = ?,
              mime_type = ?,
              total_bytes = ?,
              created_at_utc = ?
            WHERE ss_id = ?
            ''',
            <Object?>[
              row['guid'],
              row['filename'],
              row['transfer_name'],
              row['uti'],
              row['mime_type'],
              row['total_bytes'],
              row['created_at_utc'],
              row['ss_id'],
            ],
          );
        }
        if (insertedCount != 0) {
          insertedAttachmentCount += 1;
        }
      }
    });

    return AttachmentProjectionResult(
      examinedAttachmentCount: rows.length,
      insertedAttachmentCount: insertedAttachmentCount,
    );
  }
}
