import '../../../../core/util/date_converter.dart';
import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../../domain/source_scoped_row_key.dart';
import '../source_import_work_progress.dart';

class AttachmentImportResult {
  const AttachmentImportResult({
    required this.startedAfterSourceRowId,
    required this.examinedAttachmentCount,
    required this.insertedAttachmentCount,
    required this.lastImportedSourceRowId,
  });

  final int startedAfterSourceRowId;
  final int examinedAttachmentCount;
  final int insertedAttachmentCount;
  final int? lastImportedSourceRowId;
}

class AttachmentImporter {
  const AttachmentImporter({
    required this.chatDbPath,
    required this.importLedger,
    required this.sourceDatabaseOpener,
    this.sourceId = liveChatDbSourceId,
  });

  final String chatDbPath;
  final ImportLedger importLedger;
  final SourceDatabaseOpener sourceDatabaseOpener;
  final int sourceId;

  Future<AttachmentImportResult> importAttachments({
    SourceImportWorkObserver? onProgress,
  }) async {
    final startedAfterSourceRowId =
        await importLedger.maxAttachmentSourceRowIdForSource(sourceId) ?? 0;

    final sourceDb = await sourceDatabaseOpener.openReadOnly(chatDbPath);

    try {
      final rows = await sourceDb.rawQuery(
        'SELECT ROWID AS source_rowid, * FROM attachment '
        'WHERE ROWID > ? ORDER BY ROWID ASC',
        <Object?>[startedAfterSourceRowId],
      );

      if (rows.isEmpty) {
        publishSourceImportProgress(
          observer: onProgress,
          unit: SourceImportWorkUnit.attachments,
          completedWorkCount: 0,
          totalWorkCount: 0,
        );
        return AttachmentImportResult(
          startedAfterSourceRowId: startedAfterSourceRowId,
          examinedAttachmentCount: 0,
          insertedAttachmentCount: 0,
          lastImportedSourceRowId: null,
        );
      }

      final batchId = await importLedger.insertImportBatch(
        sourceId: sourceId,
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      var insertedAttachmentCount = 0;
      var completedAttachmentCount = 0;
      int? lastImportedSourceRowId;
      publishSourceImportProgress(
        observer: onProgress,
        unit: SourceImportWorkUnit.attachments,
        completedWorkCount: 0,
        totalWorkCount: rows.length,
      );
      await importLedger.writeTransaction((txn) async {
        for (final row in rows) {
          final sourceRowId = _requiredInt(row, 'source_rowid');
          lastImportedSourceRowId = sourceRowId;
          final insertedId = await txn
              .insertIgnore('attachments', <String, Object?>{
                'ss_id': SourceScopedRowKey.pack(
                  sourceId: sourceId,
                  sourceRowId: sourceRowId,
                ),
                'source_id': sourceId,
                'source_rowid': sourceRowId,
                'guid': _nullableString(row, 'guid'),
                'filename': _nullableString(row, 'filename'),
                'transfer_name': _nullableString(row, 'transfer_name'),
                'uti': _nullableString(row, 'uti'),
                'mime_type': _nullableString(row, 'mime_type'),
                'total_bytes': _nullableInt(row, 'total_bytes'),
                'created_at_utc':
                    DateConverter.appleToIsoString(row['created_date']) ??
                    DateConverter.appleToIsoString(row['created_at']),
                'batch_id': batchId,
              });

          if (insertedId != 0) {
            insertedAttachmentCount += 1;
          }
          completedAttachmentCount += 1;
          publishSourceImportProgress(
            observer: onProgress,
            unit: SourceImportWorkUnit.attachments,
            completedWorkCount: completedAttachmentCount,
            totalWorkCount: rows.length,
            lastCompletedSourceRowId: sourceRowId,
          );
        }
      });

      return AttachmentImportResult(
        startedAfterSourceRowId: startedAfterSourceRowId,
        examinedAttachmentCount: rows.length,
        insertedAttachmentCount: insertedAttachmentCount,
        lastImportedSourceRowId: lastImportedSourceRowId,
      );
    } finally {
      await sourceDb.close();
    }
  }

  static int _requiredInt(Map<String, Object?> row, String field) {
    final value = _nullableInt(row, field);
    if (value == null) {
      throw StateError('attachment.$field is required');
    }
    return value;
  }

  static int? _nullableInt(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return null;
  }

  static String? _nullableString(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }
}
