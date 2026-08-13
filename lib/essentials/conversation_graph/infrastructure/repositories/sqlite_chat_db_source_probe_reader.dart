import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../../../db/application/read_only_sql_guard.dart';
import '../../application/monitor/chat_db_source_probe_reader.dart';

final class SqliteChatDbSourceProbeReader implements ChatDbSourceProbeReader {
  const SqliteChatDbSourceProbeReader();

  @override
  int readMaxRowId(String chatDbPath) {
    const sql = 'SELECT MAX(ROWID) as max_rowid FROM message;';
    final result = _read(
      chatDbPath: chatDbPath,
      sql: sql,
      boundary: 'Chat DB source max rowid query',
    );
    if (result.isEmpty || result.first.values.isEmpty) {
      throw ChatDbSourceProbeException(
        kind: ChatDbSourceProbeFailureKind.queryFailed,
        databasePath: chatDbPath,
        operation: 'MAX(ROWID) result validation',
        cause: const FormatException('MAX(ROWID) query returned no rows'),
      );
    }
    final value = result.first.values.first;
    if (value == null) {
      return 0;
    }
    return _readInt(value);
  }

  @override
  int readImportableMessageCount(String chatDbPath) {
    const sql = '''
SELECT COUNT(*) AS importable_message_count
FROM message
WHERE guid IS NOT NULL AND LENGTH(TRIM(guid)) > 0;
''';
    final result = _read(
      chatDbPath: chatDbPath,
      sql: sql,
      boundary: 'Chat DB source importable message count query',
    );
    if (result.isEmpty || result.first.values.isEmpty) {
      throw ChatDbSourceProbeException(
        kind: ChatDbSourceProbeFailureKind.queryFailed,
        databasePath: chatDbPath,
        operation: 'importable message count result validation',
        cause: const FormatException(
          'importable message count query returned no rows',
        ),
      );
    }
    final value = result.first.values.first;
    if (value == null) {
      return 0;
    }
    return _readInt(value);
  }

  ResultSet _read({
    required String chatDbPath,
    required String sql,
    required String boundary,
  }) {
    if (!File(chatDbPath).existsSync()) {
      throw ChatDbSourceProbeException(
        kind: ChatDbSourceProbeFailureKind.databaseMissing,
        databasePath: chatDbPath,
        operation: 'source discovery',
      );
    }

    Database database;
    try {
      database = sqlite3.open(chatDbPath, mode: OpenMode.readOnly);
    } on Object catch (error) {
      throw ChatDbSourceProbeException(
        kind: ChatDbSourceProbeFailureKind.sqliteOpenFailed,
        databasePath: chatDbPath,
        operation: 'read-only SQLite open',
        cause: error,
      );
    }

    try {
      database.execute('PRAGMA query_only = ON;');
      database.execute('PRAGMA busy_timeout = 3000;');
      assertReadOnlySql(sql, boundary: boundary);
      return database.select(sql);
    } on ChatDbSourceProbeException {
      rethrow;
    } on Object catch (error) {
      final kind =
          error is SqliteException &&
              error.message.toLowerCase().contains('no such table: message')
          ? ChatDbSourceProbeFailureKind.expectedSchemaUnavailable
          : ChatDbSourceProbeFailureKind.queryFailed;
      throw ChatDbSourceProbeException(
        kind: kind,
        databasePath: chatDbPath,
        operation: boundary,
        cause: error,
      );
    } finally {
      database.dispose();
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
