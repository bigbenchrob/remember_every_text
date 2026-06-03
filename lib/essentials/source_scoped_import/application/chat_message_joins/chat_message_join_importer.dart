import 'package:sqflite/sqflite.dart';

import '../../domain/known_sources.dart';
import '../../domain/source_scoped_row_key.dart';
import '../../infrastructure/import_database_provider.dart';

class ChatMessageJoinImportResult {
  const ChatMessageJoinImportResult({
    required this.examinedJoinCount,
    required this.insertedJoinCount,
  });

  final int examinedJoinCount;
  final int insertedJoinCount;
}

class ChatMessageJoinImporter {
  const ChatMessageJoinImporter({
    required this.chatDbPath,
    required this.importDatabase,
    this.sourceId = liveChatDbSourceId,
  });

  final String chatDbPath;
  final ImportDatabase importDatabase;
  final int sourceId;

  Future<ChatMessageJoinImportResult> importJoins() async {
    return _importJoinsWhere(whereClause: null, whereArgs: const <Object?>[]);
  }

  Future<ChatMessageJoinImportResult> importJoinsAfterSourceMessageRowId({
    required int startedAfterSourceRowId,
  }) {
    return _importJoinsWhere(
      whereClause: 'WHERE message_id > ?',
      whereArgs: <Object?>[startedAfterSourceRowId],
    );
  }

  Future<ChatMessageJoinImportResult> _importJoinsWhere({
    required String? whereClause,
    required List<Object?> whereArgs,
  }) async {
    final sourceDb = await openDatabase(
      chatDbPath,
      readOnly: true,
      singleInstance: false,
    );

    try {
      final rows = await sourceDb.rawQuery(
        'SELECT ROWID AS source_rowid, chat_id, message_id '
        'FROM chat_message_join '
        '${whereClause ?? ''} '
        'ORDER BY ROWID ASC',
        whereArgs,
      );

      var insertedJoinCount = 0;
      await importDatabase.database.transaction((txn) async {
        for (final row in rows) {
          final sourceRowId = _requiredInt(row, 'source_rowid');
          final sourceChatRowId = _requiredInt(row, 'chat_id');
          final sourceMessageRowId = _requiredInt(row, 'message_id');
          final insertedId = await txn
              .insert('chat_to_message', <String, Object?>{
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
              }, conflictAlgorithm: ConflictAlgorithm.ignore);

          if (insertedId != 0) {
            insertedJoinCount += 1;
          }
        }
      });

      return ChatMessageJoinImportResult(
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
    throw StateError('chat_message_join.$field is required');
  }
}
