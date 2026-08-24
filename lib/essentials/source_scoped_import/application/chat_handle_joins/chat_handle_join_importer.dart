import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../../domain/source_import_anomaly_counts.dart';
import '../../domain/source_scoped_row_key.dart';
import '../source_import_work_progress.dart';

class ChatHandleJoinImportResult {
  const ChatHandleJoinImportResult({
    required this.examinedJoinCount,
    required this.insertedJoinCount,
    this.omittedJoinCount = 0,
  });

  final int examinedJoinCount;
  final int insertedJoinCount;
  final int omittedJoinCount;
}

class ChatHandleJoinImporter {
  const ChatHandleJoinImporter({
    required this.chatDbPath,
    required this.importLedger,
    required this.sourceDatabaseOpener,
    this.sourceId = liveChatDbSourceId,
  });

  final String chatDbPath;
  final ImportLedger importLedger;
  final SourceDatabaseOpener sourceDatabaseOpener;
  final int sourceId;

  Future<ChatHandleJoinImportResult> importJoins({
    SourceImportWorkObserver? onProgress,
  }) async {
    final batchId = await importLedger.insertImportBatch(
      sourceId: sourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    final sourceDb = await sourceDatabaseOpener.openReadOnly(chatDbPath);

    try {
      final rows = await sourceDb.rawQuery(
        'SELECT chj.ROWID AS source_rowid, chj.chat_id, chj.handle_id, '
        'c.ROWID AS existing_chat_rowid, h.ROWID AS existing_handle_rowid '
        'FROM chat_handle_join chj '
        'LEFT JOIN chat c ON c.ROWID = chj.chat_id '
        'LEFT JOIN handle h ON h.ROWID = chj.handle_id '
        'ORDER BY chj.ROWID ASC',
      );

      var insertedJoinCount = 0;
      var completedJoinCount = 0;
      var omittedJoinCount = 0;
      publishSourceImportProgress(
        observer: onProgress,
        unit: SourceImportWorkUnit.chatHandleRelationships,
        completedWorkCount: 0,
        totalWorkCount: rows.length,
      );
      await importLedger.writeTransaction((txn) async {
        for (final row in rows) {
          final sourceRowId = _requiredInt(row, 'source_rowid');
          final sourceChatRowId = _nullableInt(row, 'chat_id');
          final sourceHandleRowId = _nullableInt(row, 'handle_id');
          final hasEndpoints =
              sourceChatRowId != null &&
              sourceHandleRowId != null &&
              _nullableInt(row, 'existing_chat_rowid') != null &&
              _nullableInt(row, 'existing_handle_rowid') != null;
          if (!hasEndpoints) {
            omittedJoinCount += 1;
            completedJoinCount += 1;
            publishSourceImportProgress(
              observer: onProgress,
              unit: SourceImportWorkUnit.chatHandleRelationships,
              completedWorkCount: completedJoinCount,
              totalWorkCount: rows.length,
              lastCompletedSourceRowId: sourceRowId,
              anomalyCounts: SourceImportAnomalyCounts(
                omittedChatHandleRelationshipCount: omittedJoinCount,
              ),
            );
            continue;
          }
          final insertedId = await txn
              .insertIgnore('chat_to_handle', <String, Object?>{
                'source_id': sourceId,
                'source_chat_rowid': sourceChatRowId,
                'source_handle_rowid': sourceHandleRowId,
                'chat_ss_id': SourceScopedRowKey.pack(
                  sourceId: sourceId,
                  sourceRowId: sourceChatRowId,
                ),
                'handle_ss_id': SourceScopedRowKey.pack(
                  sourceId: sourceId,
                  sourceRowId: sourceHandleRowId,
                ),
                'batch_id': batchId,
              });

          if (insertedId != 0) {
            insertedJoinCount += 1;
          }
          completedJoinCount += 1;
          publishSourceImportProgress(
            observer: onProgress,
            unit: SourceImportWorkUnit.chatHandleRelationships,
            completedWorkCount: completedJoinCount,
            totalWorkCount: rows.length,
            lastCompletedSourceRowId: sourceRowId,
            anomalyCounts: SourceImportAnomalyCounts(
              omittedChatHandleRelationshipCount: omittedJoinCount,
            ),
          );
        }
      });

      return ChatHandleJoinImportResult(
        examinedJoinCount: rows.length,
        insertedJoinCount: insertedJoinCount,
        omittedJoinCount: omittedJoinCount,
      );
    } finally {
      await sourceDb.close();
    }
  }

  static int _requiredInt(Map<String, Object?> row, String field) {
    final value = _nullableInt(row, field);
    if (value != null) {
      return value;
    }
    throw StateError('chat_handle_join.$field is required');
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
}
