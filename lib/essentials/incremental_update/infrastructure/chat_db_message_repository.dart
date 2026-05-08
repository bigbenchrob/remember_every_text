import 'package:sqflite/sqflite.dart';

import '../application/messages/models/live_chat_db_message_snapshot.dart';

class ChatDbMessageRepository {
  const ChatDbMessageRepository({required String chatDbPath})
    : _chatDbPath = chatDbPath;

  final String _chatDbPath;

  Future<LiveChatDbMessageSnapshot> readMessageSnapshot() async {
    final db = await openDatabase(
      _chatDbPath,
      readOnly: true,
      singleInstance: false,
    );

    try {
      final maxRowId = await _readMaxMessageRowId(db);
      final totalMessageCount = await _readTotalMessageCount(db);

      return LiveChatDbMessageSnapshot(
        maxRowId: maxRowId,
        totalMessageCount: totalMessageCount,
      );
    } finally {
      await db.close();
    }
  }

  Future<int> _readMaxMessageRowId(Database db) async {
    final rows = await db.rawQuery(
      'SELECT MAX(ROWID) AS max_rowid FROM message;',
    );
    return _readInt(rows, 'max_rowid', nullValue: 0);
  }

  Future<int> _readTotalMessageCount(Database db) async {
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total_message_count FROM message;',
    );
    return _readInt(rows, 'total_message_count');
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
