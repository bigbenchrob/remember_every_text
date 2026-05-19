import 'package:sqflite/sqflite.dart';

import '../domain/models/chat_message_join_snapshot.dart';

class ChatDbChatMessageJoinRepository {
  const ChatDbChatMessageJoinRepository({required String chatDbPath})
    : _chatDbPath = chatDbPath;

  final String _chatDbPath;

  Future<ChatMessageJoinSnapshot> readChatMessageJoinSnapshot() async {
    final db = await openDatabase(
      _chatDbPath,
      readOnly: true,
      singleInstance: false,
    );

    try {
      final maxRowId = await _readMaxInt(
        db,
        'SELECT MAX(ROWID) AS value FROM chat_message_join;',
      );
      final totalJoinCount = await _readMaxInt(
        db,
        'SELECT COUNT(*) AS value FROM chat_message_join;',
      );
      final maxMessageRowId = await _readMaxInt(
        db,
        'SELECT MAX(message_id) AS value FROM chat_message_join;',
      );
      final maxChatRowId = await _readMaxInt(
        db,
        'SELECT MAX(chat_id) AS value FROM chat_message_join;',
      );

      return ChatMessageJoinSnapshot(
        maxRowId: maxRowId,
        totalJoinCount: totalJoinCount,
        maxMessageRowId: maxMessageRowId,
        maxChatRowId: maxChatRowId,
        sourceScopedObservationAvailable: true,
      );
    } finally {
      await db.close();
    }
  }

  Future<int> _readMaxInt(Database db, String sql) async {
    final rows = await db.rawQuery(sql);
    if (rows.isEmpty) {
      throw StateError('Query returned no rows.');
    }

    final value = rows.first['value'];
    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }

    throw FormatException('Expected integer query value, got $value.');
  }
}
