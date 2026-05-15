import 'package:sqflite/sqflite.dart';

import '../domain/models/chat_snapshot.dart';

class ChatDbChatRepository {
  const ChatDbChatRepository({required String chatDbPath})
    : _chatDbPath = chatDbPath;

  final String _chatDbPath;

  Future<ChatSnapshot> readChatSnapshot() async {
    final db = await openDatabase(
      _chatDbPath,
      readOnly: true,
      singleInstance: false,
    );

    try {
      final maxRowId = await _readMaxChatRowId(db);
      final totalChatCount = await _readTotalChatCount(db);

      return ChatSnapshot(maxRowId: maxRowId, totalChatCount: totalChatCount);
    } finally {
      await db.close();
    }
  }

  Future<int> _readMaxChatRowId(Database db) async {
    final rows = await db.rawQuery('SELECT MAX(ROWID) AS max_rowid FROM chat;');
    return _readInt(rows, 'max_rowid', nullValue: 0);
  }

  Future<int> _readTotalChatCount(Database db) async {
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total_chat_count FROM chat;',
    );
    return _readInt(rows, 'total_chat_count');
  }

  int _readInt(
    List<Map<String, Object?>> rows,
    String column, {
    int? nullValue,
  }) {
    if (rows.isEmpty) {
      throw StateError('Query returned no rows for $column.');
    }

    final value = rows.first[column];
    if (value == null && nullValue != null) {
      return nullValue;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }

    throw FormatException('Expected integer value for $column, got $value.');
  }
}
