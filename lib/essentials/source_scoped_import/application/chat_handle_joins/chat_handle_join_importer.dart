import 'package:sqflite/sqflite.dart';

import '../../domain/known_sources.dart';
import '../../domain/source_scoped_row_key.dart';
import '../../infrastructure/import_database_provider.dart';

class ChatHandleJoinImportResult {
  const ChatHandleJoinImportResult({
    required this.examinedJoinCount,
    required this.insertedJoinCount,
  });

  final int examinedJoinCount;
  final int insertedJoinCount;
}

class ChatHandleJoinImporter {
  const ChatHandleJoinImporter({
    required this.chatDbPath,
    required this.importDatabase,
    this.sourceId = liveChatDbSourceId,
  });

  final String chatDbPath;
  final ImportDatabase importDatabase;
  final int sourceId;

  Future<ChatHandleJoinImportResult> importJoins() async {
    final batchId = await importDatabase.insertImportBatch(
      sourceId: sourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    final sourceDb = await openDatabase(
      chatDbPath,
      readOnly: true,
      singleInstance: false,
    );

    try {
      final rows = await sourceDb.rawQuery(
        'SELECT chat_id, handle_id FROM chat_handle_join '
        'ORDER BY chat_id ASC, handle_id ASC',
      );

      var insertedJoinCount = 0;
      await importDatabase.database.transaction((txn) async {
        for (final row in rows) {
          final sourceChatRowId = _requiredInt(row, 'chat_id');
          final sourceHandleRowId = _requiredInt(row, 'handle_id');
          final insertedId = await txn
              .insert('chat_to_handle', <String, Object?>{
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
              }, conflictAlgorithm: ConflictAlgorithm.ignore);

          if (insertedId != 0) {
            insertedJoinCount += 1;
          }
        }
      });

      return ChatHandleJoinImportResult(
        examinedJoinCount: rows.length,
        insertedJoinCount: insertedJoinCount,
      );
    } finally {
      await sourceDb.close();
    }
  }

  static int _requiredInt(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    throw StateError('chat_handle_join.$field is required');
  }
}
