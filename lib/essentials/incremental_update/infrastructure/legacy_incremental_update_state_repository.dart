import 'package:sqlite3/sqlite3.dart';

import '../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../domain/models/legacy_incremental_update_snapshot.dart';

class LegacyIncrementalUpdateStateRepository {
  const LegacyIncrementalUpdateStateRepository({
    required String chatDbPath,
    required SqfliteImportDatabase importDb,
    required WorkingDatabase workingDb,
  }) : _chatDbPath = chatDbPath,
       _importDb = importDb,
       _workingDb = workingDb;

  final String _chatDbPath;
  final SqfliteImportDatabase _importDb;
  final WorkingDatabase _workingDb;

  Future<LegacyIncrementalUpdateSnapshot> readSnapshot() async {
    final liveMaxRowId = _readLiveMaxRowId();
    final liveImportableMessageCount = _readLiveImportableMessageCount();
    final importedMaxSourceRowId = await _importDb.getMaxImportedMessageRowId();
    final importedMessageCount = await _importDb.getImportedMessageCount();
    final productionImportProjectionSnapshot = await _readImportProjection();
    final productionWorkingProjectionSnapshot = await _readWorkingProjection();

    final importProbeDecision = _resolveLegacyImportProbeDecision(
      liveMaxRowId: liveMaxRowId,
      importedMaxSourceRowId: importedMaxSourceRowId,
      liveImportableMessageCount: liveImportableMessageCount,
      importedMessageCount: importedMessageCount,
    );

    return LegacyIncrementalUpdateSnapshot(
      liveMaxRowId: liveMaxRowId,
      importedMaxSourceRowId: importedMaxSourceRowId,
      liveImportableMessageCount: liveImportableMessageCount,
      importedMessageCount: importedMessageCount,
      importProbeDecision: importProbeDecision,
      productionImportMaxMessageId: productionImportProjectionSnapshot.maxId,
      productionWorkingMaxMessageId: productionWorkingProjectionSnapshot.maxId,
      productionImportMessageCount: productionImportProjectionSnapshot.count,
      productionWorkingMessageCount: productionWorkingProjectionSnapshot.count,
    );
  }

  LegacyImportProbeDecision _resolveLegacyImportProbeDecision({
    required int liveMaxRowId,
    required int? importedMaxSourceRowId,
    required int liveImportableMessageCount,
    required int importedMessageCount,
  }) {
    if (importedMaxSourceRowId == null) {
      return const LegacyImportProbeDecision(
        shouldSchedule: false,
        reason: 'no imported cursor available',
      );
    }

    if (liveMaxRowId > importedMaxSourceRowId) {
      return const LegacyImportProbeDecision(
        shouldSchedule: true,
        reason: 'live MAX(ROWID) is ahead of imported MAX(source_rowid)',
      );
    }

    if (liveImportableMessageCount > importedMessageCount) {
      return const LegacyImportProbeDecision(
        shouldSchedule: true,
        reason: 'live importable message count exceeds imported message count',
      );
    }

    return const LegacyImportProbeDecision(
      shouldSchedule: false,
      reason: 'ledger cursor and importable message count are current',
    );
  }

  int _readLiveMaxRowId() {
    final db = sqlite3.open(_chatDbPath, mode: OpenMode.readOnly);
    try {
      db.execute('PRAGMA query_only = ON;');
      db.execute('PRAGMA busy_timeout = 3000;');
      final result = db.select('SELECT MAX(ROWID) AS max_rowid FROM message;');
      return _readSqliteInt(result, 'max_rowid');
    } finally {
      db.dispose();
    }
  }

  int _readLiveImportableMessageCount() {
    final db = sqlite3.open(_chatDbPath, mode: OpenMode.readOnly);
    try {
      db.execute('PRAGMA query_only = ON;');
      db.execute('PRAGMA busy_timeout = 3000;');
      final result = db.select('''
        SELECT COUNT(*) AS importable_message_count
        FROM message
        WHERE guid IS NOT NULL AND LENGTH(TRIM(guid)) > 0;
      ''');
      return _readSqliteInt(result, 'importable_message_count');
    } finally {
      db.dispose();
    }
  }

  Future<_ProjectionSnapshot> _readImportProjection() async {
    final rows = await _importDb.rawQuery(
      'SELECT COALESCE(MAX(id), 0) AS max_id, COUNT(*) AS count '
      'FROM messages;',
    );

    return _ProjectionSnapshot(
      maxId: _readSqfliteInt(rows, 'max_id'),
      count: _readSqfliteInt(rows, 'count'),
    );
  }

  Future<_ProjectionSnapshot> _readWorkingProjection() async {
    final row = await _workingDb
        .customSelect(
          'SELECT COALESCE(MAX(id), 0) AS max_id, COUNT(*) AS count '
          'FROM messages;',
        )
        .getSingle();

    return _ProjectionSnapshot(
      maxId: _readMapInt(row.data, 'max_id'),
      count: _readMapInt(row.data, 'count'),
    );
  }

  int _readSqliteInt(ResultSet rows, String column) {
    if (rows.isEmpty) {
      return 0;
    }
    return _coerceInt(rows.first[column]);
  }

  int _readSqfliteInt(List<Map<String, Object?>> rows, String column) {
    if (rows.isEmpty) {
      return 0;
    }
    return _coerceInt(rows.first[column]);
  }

  int _readMapInt(Map<String, Object?> row, String column) {
    return _coerceInt(row[column]);
  }

  int _coerceInt(Object? value) {
    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.parse('$value');
  }
}

class _ProjectionSnapshot {
  const _ProjectionSnapshot({required this.maxId, required this.count});

  final int maxId;
  final int count;
}
