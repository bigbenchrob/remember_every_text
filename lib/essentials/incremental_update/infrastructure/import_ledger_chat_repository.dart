import '../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../domain/models/chat_snapshot.dart';

class ImportLedgerChatRepository {
  const ImportLedgerChatRepository({required SqfliteImportDatabase ledgerDb})
    : _ledgerDb = ledgerDb;

  final SqfliteImportDatabase _ledgerDb;

  Future<ChatSnapshot> readChatSnapshot() async {
    final maxRowId = await _readMaxChatRowId();
    final totalChatCount = await _readTotalChatCount();

    return ChatSnapshot(maxRowId: maxRowId, totalChatCount: totalChatCount);
  }

  Future<int> _readMaxChatRowId() async {
    final rows = await _ledgerDb.rawQuery(
      'SELECT MAX(source_rowid) AS max_rowid FROM chats;',
    );
    return _readInt(rows, 'max_rowid', nullValue: 0);
  }

  Future<int> _readTotalChatCount() async {
    final rows = await _ledgerDb.rawQuery(
      'SELECT COUNT(*) AS total_chat_count FROM chats;',
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
