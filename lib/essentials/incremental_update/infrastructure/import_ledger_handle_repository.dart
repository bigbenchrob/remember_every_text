import '../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../domain/models/handle_snapshot.dart';
import '../domain/models/source_identity.dart';

class ImportLedgerHandleRepository {
  const ImportLedgerHandleRepository({
    required SqfliteImportDatabase ledgerDb,
    SourceIdentity source = liveChatDbSourceIdentity,
  }) : _ledgerDb = ledgerDb,
       _source = source;

  final SqfliteImportDatabase _ledgerDb;
  final SourceIdentity _source;

  Future<HandleSnapshot> readHandleSnapshot() async {
    final maxRowId = await _readMaxHandleRowId();
    final totalHandleCount = await _readTotalHandleCount();

    return HandleSnapshot(
      maxRowId: maxRowId,
      totalHandleCount: totalHandleCount,
    );
  }

  Future<int> _readMaxHandleRowId() async {
    final rows = await _ledgerDb.rawQuery(
      '''
      SELECT MAX(source_rowid) AS max_rowid
      FROM handles
      WHERE source_id = ?;
      ''',
      <Object?>[_source.sourceId],
    );
    return _readInt(rows, 'max_rowid', nullValue: 0);
  }

  Future<int> _readTotalHandleCount() async {
    final rows = await _ledgerDb.rawQuery(
      '''
      SELECT COUNT(*) AS total_handle_count
      FROM handles
      WHERE source_id = ?;
      ''',
      <Object?>[_source.sourceId],
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
