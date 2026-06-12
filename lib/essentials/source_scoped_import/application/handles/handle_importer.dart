import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../../domain/source_scoped_row_key.dart';

class HandleImportResult {
  const HandleImportResult({
    required this.startedAfterSourceRowId,
    required this.insertedHandleCount,
    required this.lastImportedSourceRowId,
  });

  final int startedAfterSourceRowId;
  final int insertedHandleCount;
  final int? lastImportedSourceRowId;
}

class HandleImporter {
  const HandleImporter({
    required this.chatDbPath,
    required this.importLedger,
    required this.sourceDatabaseOpener,
    this.sourceId = liveChatDbSourceId,
  });

  final String chatDbPath;
  final ImportLedger importLedger;
  final SourceDatabaseOpener sourceDatabaseOpener;
  final int sourceId;

  Future<HandleImportResult> importNewHandles() async {
    final startedAfterSourceRowId =
        await importLedger.maxHandleSourceRowIdForSource(sourceId) ?? 0;
    final batchId = await importLedger.insertImportBatch(
      sourceId: sourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    final sourceDb = await sourceDatabaseOpener.openReadOnly(chatDbPath);

    var insertedHandleCount = 0;
    int? lastImportedSourceRowId;
    try {
      final rows = await sourceDb.rawQuery(
        'SELECT ROWID AS source_rowid, id, service '
        'FROM handle WHERE ROWID > ? ORDER BY ROWID ASC',
        <Object?>[startedAfterSourceRowId],
      );

      await importLedger.writeTransaction((txn) async {
        for (final row in rows) {
          final sourceRowId = _requiredInt(row, 'source_rowid');
          lastImportedSourceRowId = sourceRowId;
          final insertedId = await txn
              .insertIgnore('handles', <String, Object?>{
                'ss_id': SourceScopedRowKey.pack(
                  sourceId: sourceId,
                  sourceRowId: sourceRowId,
                ),
                'source_id': sourceId,
                'source_rowid': sourceRowId,
                'id': _requiredString(row, 'id'),
                'service': _nullableString(row, 'service'),
                'batch_id': batchId,
              });

          if (insertedId != 0) {
            insertedHandleCount += 1;
          }
        }
      });
    } finally {
      await sourceDb.close();
    }

    return HandleImportResult(
      startedAfterSourceRowId: startedAfterSourceRowId,
      insertedHandleCount: insertedHandleCount,
      lastImportedSourceRowId: lastImportedSourceRowId,
    );
  }

  static int _requiredInt(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    throw StateError('handle.$field is required');
  }

  static String _requiredString(Map<String, Object?> row, String field) {
    final value = _nullableString(row, field);
    if (value == null) {
      throw StateError('handle.$field is required');
    }
    return value;
  }

  static String? _nullableString(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }
}
