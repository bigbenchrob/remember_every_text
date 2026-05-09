import 'package:sqflite/sqflite.dart';

import '../domain/models/import_ledger_message_snapshot.dart';

class ImportLedgeressageRepository {
  const ImportLedgeressageRepository({required String ledgerPath})
    : _ledgerPath = ledgerPath;

  final String _ledgerPath;

  Future<ImportLedgerMessageSnapshot> readMessageSnapshot() async {
    final db = await openDatabase(
      _ledgerPath,
      readOnly: true,
      singleInstance: false,
    );

    try {
      final maxRowId = await _readMaxMessageRowId(db);
      final totalMessageCount = await _readTotalMessageCount(db);

      return ImportLedgerMessageSnapshot(
        maxRowId: maxRowId,
        totalMessageCount: totalMessageCount,
      );
    } finally {
      await db.close();
    }
  }

  Future<int> _readMaxMessageRowId(Database db) async {
    final rows = await db.rawQuery(
      'SELECT MAX(ROWID) AS max_rowid FROM messages;',
    );
    return _readInt(rows, 'max_rowid', nullValue: 0);
  }

  Future<int> _readTotalMessageCount(Database db) async {
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total_message_count FROM messages;',
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
