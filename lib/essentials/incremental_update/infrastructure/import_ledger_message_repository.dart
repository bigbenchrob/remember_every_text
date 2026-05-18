import '../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../domain/models/import_ledger_message_snapshot.dart';
import '../domain/models/source_identity.dart';

class ImportLedgerMessageRepository {
  const ImportLedgerMessageRepository({
    required SqfliteImportDatabase ledgerDb,
    SourceIdentity source = liveChatDbSourceIdentity,
  }) : _ledgerDb = ledgerDb,
       _source = source;

  final SqfliteImportDatabase _ledgerDb;
  final SourceIdentity _source;

  Future<ImportLedgerMessageSnapshot> readMessageSnapshot() async {
    final maxRowId = await _readMaxMessageRowId();
    final totalMessageCount = await _readTotalMessageCount();

    return ImportLedgerMessageSnapshot(
      maxRowId: maxRowId,
      totalMessageCount: totalMessageCount,
    );
  }

  Future<int> _readMaxMessageRowId() async {
    final rows = await _ledgerDb.rawQuery(
      '''
      SELECT MAX(source_rowid) AS max_rowid
      FROM messages
      WHERE source_id = ?;
      ''',
      <Object?>[_source.sourceId],
    );
    return _readInt(rows, 'max_rowid', nullValue: 0);
  }

  Future<int> _readTotalMessageCount() async {
    final rows = await _ledgerDb.rawQuery(
      '''
      SELECT COUNT(*) AS total_message_count
      FROM messages
      WHERE source_id = ?;
      ''',
      <Object?>[_source.sourceId],
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
