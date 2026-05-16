import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../../db/shared/handle_identifier_utils.dart';
import '../../../infrastructure/import_ledger_handle_repository.dart';
import '../../importers/importer_descriptor.dart';

class HandleImporter {
  const HandleImporter({
    required String chatDbPath,
    required SqfliteImportDatabase shadowImportDb,
    required ImportLedgerHandleRepository importLedgerRepository,
  }) : _chatDbPath = chatDbPath,
       _shadowImportDb = shadowImportDb,
       _importLedgerRepository = importLedgerRepository;

  static const int _sourceReadBatchSize = 1000;
  static const String _sourceId = 'live-chat-db';
  static const String _sourceKind = 'live_chat_db';

  static const ImporterDescriptor descriptor = ImporterDescriptor(
    importerName: 'handle_importer',
    sourceTables: <String>['handle'],
    targetTables: <String>['handles'],
    prerequisites: <String>[],
    continuationStrategy: 'MAX(handles.source_rowid)',
    idempotenceStrategy:
        'INSERT OR IGNORE / conflict ignore on already-imported source rows',
    validationStrategy: 'cursor/count convergence validation',
  );

  final String _chatDbPath;
  final SqfliteImportDatabase _shadowImportDb;
  final ImportLedgerHandleRepository _importLedgerRepository;

  Future<HandleImportResult> importNewHandles() async {
    final ledgerSnapshot = await _importLedgerRepository.readHandleSnapshot();
    final startedAfterSourceRowId = ledgerSnapshot.maxRowId;
    final startedAtUtc = DateTime.now().toUtc().toIso8601String();
    final batchId = await _shadowImportDb.insertImportBatch(
      startedAtUtc: startedAtUtc,
      sourceChatDb: _chatDbPath,
      notes: 'Shadow incremental_update handle import.',
    );

    var insertedHandleCount = 0;
    var lastImportedSourceRowId = startedAfterSourceRowId;

    final sourceDb = await openDatabase(
      _chatDbPath,
      readOnly: true,
      singleInstance: false,
    );

    try {
      while (true) {
        final sourceRows = await sourceDb.rawQuery(
          '''
          SELECT
            ROWID AS source_rowid,
            *
          FROM handle
          WHERE ROWID > ?
          ORDER BY ROWID ASC
          LIMIT ?
          ''',
          [lastImportedSourceRowId, _sourceReadBatchSize],
        );

        if (sourceRows.isEmpty) {
          break;
        }

        final destinationDb = await _shadowImportDb.database;
        final destinationBatch = destinationDb.batch();

        for (final sourceRow in sourceRows) {
          final sourceRowId = _readRequiredInt(sourceRow, 'source_rowid');
          lastImportedSourceRowId = sourceRowId;

          final rawIdentifier =
              stripMeaninglessHandlePrefix(
                _readNullableString(sourceRow, 'id'),
              ) ??
              'unknown';
          final normalizedIdentifier = normalizeHandleIdentifier(rawIdentifier);
          final service = sanitizeHandleService(
            _readNullableString(sourceRow, 'service'),
          );
          final compoundIdentifier = buildCompoundIdentifier(
            normalizedIdentifier: normalizedIdentifier,
            rawIdentifier: rawIdentifier,
            service: service,
          );

          destinationBatch.insert('handles', <String, Object?>{
            'id': sourceRowId,
            'source_rowid': sourceRowId,
            'source_id': _sourceId,
            'source_kind': _sourceKind,
            'service': service,
            'raw_identifier': rawIdentifier,
            'normalized_identifier': normalizedIdentifier,
            'compound_identifier': compoundIdentifier,
            'country': _readNullableString(sourceRow, 'country')?.trim(),
            'batch_id': batchId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
          insertedHandleCount += 1;
        }

        await destinationBatch.commit(noResult: true);
      }
    } finally {
      await sourceDb.close();
    }

    final finishedAtUtc = DateTime.now().toUtc().toIso8601String();
    await _shadowImportDb.updateImportBatch(
      id: batchId,
      finishedAtUtc: finishedAtUtc,
      notes:
          'Shadow incremental_update handle import. '
          'insertedHandleCount=$insertedHandleCount',
    );

    final result = HandleImportResult(
      startedAfterSourceRowId: startedAfterSourceRowId,
      lastImportedSourceRowId: lastImportedSourceRowId,
      insertedHandleCount: insertedHandleCount,
      batchId: batchId,
    );

    debugPrint(
      'Shadow handle import executed: '
      'startedAfterSourceRowId=${result.startedAfterSourceRowId}, '
      'lastImportedSourceRowId=${result.lastImportedSourceRowId}, '
      'insertedHandleCount=${result.insertedHandleCount}, '
      'batchId=${result.batchId}',
    );

    return result;
  }

  int _readRequiredInt(Map<String, Object?> row, String column) {
    final value = row[column];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }

    throw FormatException('Expected integer value for $column, got $value.');
  }

  String? _readNullableString(Map<String, Object?> row, String column) {
    final value = row[column];
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }

    return value.toString();
  }
}

@immutable
class HandleImportResult {
  const HandleImportResult({
    required this.startedAfterSourceRowId,
    required this.lastImportedSourceRowId,
    required this.insertedHandleCount,
    required this.batchId,
  });

  final int startedAfterSourceRowId;
  final int lastImportedSourceRowId;
  final int insertedHandleCount;
  final int batchId;
}
