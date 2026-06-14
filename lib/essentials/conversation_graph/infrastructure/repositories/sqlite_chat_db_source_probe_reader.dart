import 'package:sqlite3/sqlite3.dart';

import '../../application/monitor/chat_db_source_probe_reader.dart';

final class SqliteChatDbSourceProbeReader implements ChatDbSourceProbeReader {
  const SqliteChatDbSourceProbeReader();

  @override
  int readMaxRowId(String chatDbPath) {
    try {
      final db = sqlite3.open(chatDbPath, mode: OpenMode.readOnly);
      try {
        db.execute('PRAGMA query_only = ON;');
        db.execute('PRAGMA busy_timeout = 3000;');
        final result = db.select(
          'SELECT MAX(ROWID) as max_rowid FROM message;',
        );
        if (result.isEmpty || result.first.values.isEmpty) {
          throw const FormatException('MAX(ROWID) query returned no rows');
        }
        final value = result.first.values.first;
        if (value == null) {
          return 0;
        }
        return _readInt(value);
      } finally {
        db.dispose();
      }
    } on SqliteException catch (error) {
      throw StateError('SQLite error (${error.extendedResultCode}): $error');
    }
  }

  @override
  int readImportableMessageCount(String chatDbPath) {
    try {
      final db = sqlite3.open(chatDbPath, mode: OpenMode.readOnly);
      try {
        db.execute('PRAGMA query_only = ON;');
        db.execute('PRAGMA busy_timeout = 3000;');
        final result = db.select('''
SELECT COUNT(*) AS importable_message_count
FROM message
WHERE guid IS NOT NULL AND LENGTH(TRIM(guid)) > 0;
''');
        if (result.isEmpty || result.first.values.isEmpty) {
          throw const FormatException(
            'importable message count query returned no rows',
          );
        }
        final value = result.first.values.first;
        if (value == null) {
          return 0;
        }
        return _readInt(value);
      } finally {
        db.dispose();
      }
    } on SqliteException catch (error) {
      throw StateError(
        'SQLite error while counting importable messages '
        '(${error.extendedResultCode}): $error',
      );
    }
  }

  static int _readInt(Object value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.parse('$value');
  }
}
