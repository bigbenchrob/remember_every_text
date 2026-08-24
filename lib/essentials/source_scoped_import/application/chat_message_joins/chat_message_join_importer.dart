import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../../domain/source_import_anomaly_counts.dart';
import '../../domain/source_scoped_row_key.dart';
import '../source_import_work_progress.dart';

class ChatMessageJoinImportResult {
  const ChatMessageJoinImportResult({
    required this.examinedJoinCount,
    required this.insertedJoinCount,
    this.omittedJoinCount = 0,
  });

  final int examinedJoinCount;
  final int insertedJoinCount;
  final int omittedJoinCount;
}

class ChatMessageJoinImporter {
  const ChatMessageJoinImporter({
    required this.chatDbPath,
    required this.importLedger,
    required this.sourceDatabaseOpener,
    this.sourceId = liveChatDbSourceId,
  });

  final String chatDbPath;
  final ImportLedger importLedger;
  final SourceDatabaseOpener sourceDatabaseOpener;
  final int sourceId;

  Future<ChatMessageJoinImportResult> importJoins({
    SourceImportWorkObserver? onProgress,
  }) async {
    return _importJoinsWhere(
      whereClause: null,
      whereArgs: const <Object?>[],
      onProgress: onProgress,
    );
  }

  Future<ChatMessageJoinImportResult> importJoinsAfterSourceMessageRowId({
    required int startedAfterSourceRowId,
    SourceImportWorkObserver? onProgress,
  }) {
    return _importJoinsWhere(
      whereClause: 'WHERE cmj.message_id > ?',
      whereArgs: <Object?>[startedAfterSourceRowId],
      onProgress: onProgress,
    );
  }

  Future<ChatMessageJoinImportResult> _importJoinsWhere({
    required String? whereClause,
    required List<Object?> whereArgs,
    required SourceImportWorkObserver? onProgress,
  }) async {
    final sourceDb = await sourceDatabaseOpener.openReadOnly(chatDbPath);

    try {
      final rows = await sourceDb.rawQuery(
        'SELECT cmj.ROWID AS source_rowid, cmj.chat_id, cmj.message_id, '
        'c.ROWID AS existing_chat_rowid, '
        'm.ROWID AS existing_message_rowid '
        'FROM chat_message_join cmj '
        'LEFT JOIN chat c ON c.ROWID = cmj.chat_id '
        'LEFT JOIN message m ON m.ROWID = cmj.message_id '
        '${whereClause ?? ''} '
        'ORDER BY cmj.ROWID ASC',
        whereArgs,
      );

      var insertedJoinCount = 0;
      var completedJoinCount = 0;
      var omittedJoinCount = 0;
      publishSourceImportProgress(
        observer: onProgress,
        unit: SourceImportWorkUnit.chatMessageRelationships,
        completedWorkCount: 0,
        totalWorkCount: rows.length,
      );
      await importLedger.writeTransaction((txn) async {
        for (final row in rows) {
          final sourceRowId = _requiredInt(row, 'source_rowid');
          final sourceChatRowId = _nullableInt(row, 'chat_id');
          final sourceMessageRowId = _nullableInt(row, 'message_id');
          final hasEndpoints =
              sourceChatRowId != null &&
              sourceMessageRowId != null &&
              _nullableInt(row, 'existing_chat_rowid') != null &&
              _nullableInt(row, 'existing_message_rowid') != null;
          if (!hasEndpoints) {
            omittedJoinCount += 1;
            completedJoinCount += 1;
            publishSourceImportProgress(
              observer: onProgress,
              unit: SourceImportWorkUnit.chatMessageRelationships,
              completedWorkCount: completedJoinCount,
              totalWorkCount: rows.length,
              lastCompletedSourceRowId: sourceRowId,
              anomalyCounts: SourceImportAnomalyCounts(
                omittedChatMessageRelationshipCount: omittedJoinCount,
              ),
            );
            continue;
          }
          final insertedId = await txn
              .insertIgnore('chat_to_message', <String, Object?>{
                'ss_id': SourceScopedRowKey.pack(
                  sourceId: sourceId,
                  sourceRowId: sourceRowId,
                ),
                'source_id': sourceId,
                'source_rowid': sourceRowId,
                'source_chat_rowid': sourceChatRowId,
                'source_message_rowid': sourceMessageRowId,
                'chat_ss_id': SourceScopedRowKey.pack(
                  sourceId: sourceId,
                  sourceRowId: sourceChatRowId,
                ),
                'message_ss_id': SourceScopedRowKey.pack(
                  sourceId: sourceId,
                  sourceRowId: sourceMessageRowId,
                ),
              });

          if (insertedId != 0) {
            insertedJoinCount += 1;
          }
          completedJoinCount += 1;
          publishSourceImportProgress(
            observer: onProgress,
            unit: SourceImportWorkUnit.chatMessageRelationships,
            completedWorkCount: completedJoinCount,
            totalWorkCount: rows.length,
            lastCompletedSourceRowId: sourceRowId,
            anomalyCounts: SourceImportAnomalyCounts(
              omittedChatMessageRelationshipCount: omittedJoinCount,
            ),
          );
        }
      });

      return ChatMessageJoinImportResult(
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
    throw StateError('chat_message_join.$field is required');
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
