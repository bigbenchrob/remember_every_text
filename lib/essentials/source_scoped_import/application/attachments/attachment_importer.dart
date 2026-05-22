import 'package:sqflite/sqflite.dart';

import '../../../../core/util/date_converter.dart';
import '../../domain/known_sources.dart';
import '../../domain/source_scoped_row_key.dart';
import '../../infrastructure/import_database_provider.dart';

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
    required this.importDatabase,
    this.sourceId = liveChatDbSourceId,
  });

  final String chatDbPath;
  final ImportDatabase importDatabase;
  final int sourceId;

  Future<AttachmentImportResult> importAttachments() async {
    final startedAfterSourceRowId =
        await importDatabase.maxAttachmentSourceRowIdForSource(sourceId) ?? 0;

    final sourceDb = await openDatabase(
      chatDbPath,
      readOnly: true,
      singleInstance: false,
    );

    try {
      final rows = await sourceDb.rawQuery(
        'SELECT ROWID AS source_rowid, * FROM attachment '
        'WHERE ROWID > ? ORDER BY ROWID ASC',
        <Object?>[startedAfterSourceRowId],
      );

      if (rows.isEmpty) {
        return AttachmentImportResult(
          startedAfterSourceRowId: startedAfterSourceRowId,
          examinedAttachmentCount: 0,
          insertedAttachmentCount: 0,
          lastImportedSourceRowId: null,
        );
      }

      final batchId = await importDatabase.insertImportBatch(
        sourceId: sourceId,
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      var insertedAttachmentCount = 0;
      int? lastImportedSourceRowId;
      await importDatabase.database.transaction((txn) async {
        for (final row in rows) {
          final sourceRowId = _requiredInt(row, 'source_rowid');
          lastImportedSourceRowId = sourceRowId;
          final insertedId = await txn.insert('attachments', <String, Object?>{
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
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          if (insertedId != 0) {
            insertedAttachmentCount += 1;
          }
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
