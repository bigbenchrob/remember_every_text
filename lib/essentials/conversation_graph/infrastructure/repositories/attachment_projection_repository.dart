import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../source_scoped_import/domain/ports/import_ledger_port.dart';
import '../../application/attachments/attachment_projection_repository.dart';
import '../../application/projection_work_progress.dart';

class SqliteAttachmentProjectionRepository
    implements AttachmentProjectionRepository {
  const SqliteAttachmentProjectionRepository({
    required this.importLedgerDatabase,
    required this.graphDatabase,
  });

  final ImportLedger importLedgerDatabase;
  final ConversationGraphDatabase graphDatabase;

  @override
  Future<AttachmentProjectionResult> projectAttachments({
    GraphProjectionWorkObserver? onProgress,
  }) async {
    return _projectAttachmentsWhere(
      whereClause: null,
      whereArgs: const <Object?>[],
      onProgress: onProgress,
    );
  }

  @override
  Future<AttachmentProjectionResult> projectAttachmentsAfterSourceRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
    GraphProjectionWorkObserver? onProgress,
  }) {
    return _projectAttachmentsWhere(
      whereClause: 'source_id = ? AND source_rowid > ?',
      whereArgs: <Object?>[sourceId, startedAfterSourceRowId],
      onProgress: onProgress,
    );
  }

  Future<AttachmentProjectionResult> _projectAttachmentsWhere({
    required String? whereClause,
    required List<Object?> whereArgs,
    required GraphProjectionWorkObserver? onProgress,
  }) async {
    final rows = await importLedgerDatabase.queryTable(
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

    onProgress?.call(
      GraphProjectionWorkProgress(
        completedWorkCount: 0,
        totalWorkCount: rows.length,
      ),
    );
    var insertedAttachmentCount = 0;
    await graphDatabase.transaction(() async {
      for (var index = 0; index < rows.length; index++) {
        final row = rows[index];
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
        final completedWorkCount = index + 1;
        if (shouldPublishGraphProjectionProgress(
          completedWorkCount: completedWorkCount,
          totalWorkCount: rows.length,
        )) {
          onProgress?.call(
            GraphProjectionWorkProgress(
              completedWorkCount: completedWorkCount,
              totalWorkCount: rows.length,
            ),
          );
        }
      }
    });

    return AttachmentProjectionResult(
      examinedAttachmentCount: rows.length,
      insertedAttachmentCount: insertedAttachmentCount,
    );
  }
}
