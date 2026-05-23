import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../application/attachments/attachment_projection_repository.dart';

class SqliteAttachmentProjectionRepository
    implements AttachmentProjectionRepository {
  const SqliteAttachmentProjectionRepository({
    required this.importDatabase,
    required this.workingDatabase,
  });

  final ImportDatabase importDatabase;
  final ConversationGraphDatabase workingDatabase;

  @override
  Future<AttachmentProjectionResult> projectAttachments() async {
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
      orderBy: 'ss_id ASC',
    );

    var insertedAttachmentCount = 0;
    await workingDatabase.transaction(() async {
      for (final row in rows) {
        final insertedCount = await workingDatabase.executeAndReadChanges(
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
          await workingDatabase.executeSql(
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
