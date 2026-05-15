import 'package:sqflite/sqflite.dart';

import '../domain/models/handle_snapshot.dart';

class ChatDbHandleRepository {
  const ChatDbHandleRepository({required String chatDbPath})
    : _chatDbPath = chatDbPath;

  final String _chatDbPath;

  Future<HandleSnapshot> readHandleSnapshot() async {
    final db = await openDatabase(
      _chatDbPath,
      readOnly: true,
      singleInstance: false,
    );

    try {
      final maxRowId = await _readMaxHandleRowId(db);
      final totalHandleCount = await _readTotalHandleCount(db);

      return HandleSnapshot(
        maxRowId: maxRowId,
        totalHandleCount: totalHandleCount,
      );
    } finally {
      await db.close();
    }
  }

  Future<int> _readMaxHandleRowId(Database db) async {
    final rows = await db.rawQuery(
      'SELECT MAX(ROWID) AS max_rowid FROM handle;',
    );
    return _readInt(rows, 'max_rowid', nullValue: 0);
  }

  Future<int> _readTotalHandleCount(Database db) async {
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total_handle_count FROM handle;',
    );
    return _readInt(rows, 'total_handle_count');
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
