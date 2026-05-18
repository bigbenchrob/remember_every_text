import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../domain/models/source_identity.dart';
import '../../../infrastructure/import_ledger_chat_repository.dart';
import '../../importers/importer_descriptor.dart';

class ChatImporter {
  const ChatImporter({
    required String chatDbPath,
    required SqfliteImportDatabase shadowImportDb,
    required ImportLedgerChatRepository importLedgerRepository,
  }) : _chatDbPath = chatDbPath,
       _shadowImportDb = shadowImportDb,
       _importLedgerRepository = importLedgerRepository;

  static const int _sourceReadBatchSize = 1000;

  static const ImporterDescriptor descriptor = ImporterDescriptor(
    importerName: 'chat_importer',
    sourceTables: <String>['chat'],
    targetTables: <String>['chats'],
    prerequisites: <String>[],
    continuationStrategy: 'MAX(chats.source_rowid) scoped by source_id',
    idempotenceStrategy: 'INSERT OR IGNORE / conflict ignore',
    validationStrategy: 'cursor/count convergence validation',
  );

  final String _chatDbPath;
  final SqfliteImportDatabase _shadowImportDb;
  final ImportLedgerChatRepository _importLedgerRepository;

  Future<ChatImportResult> importNewChats() async {
    final ledgerSnapshot = await _importLedgerRepository.readChatSnapshot();
    final startedAfterSourceRowId = ledgerSnapshot.maxRowId;
    final startedAtUtc = DateTime.now().toUtc().toIso8601String();
    final batchId = await _shadowImportDb.insertImportBatch(
      startedAtUtc: startedAtUtc,
      sourceChatDb: _chatDbPath,
      notes: 'Shadow incremental_update chat import.',
    );

    var insertedChatCount = 0;
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
          FROM chat
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

          final guid = _readRequiredString(sourceRow, 'guid');
          final service =
              _readNullableString(sourceRow, 'service_name') ??
              _readNullableString(sourceRow, 'service');
          final displayName =
              _readNullableString(sourceRow, 'display_name') ??
              _readNullableString(sourceRow, 'chat_identifier');

          destinationBatch.insert('chats', <String, Object?>{
            'id': sourceRowId,
            'source_rowid': sourceRowId,
            'source_id': liveChatDbSourceIdentity.sourceId,
            'source_kind': liveChatDbSourceIdentity.sourceKind,
            'guid': guid,
            'service': service?.trim(),
            'display_name': displayName?.trim(),
            'is_group': 0,
            'batch_id': batchId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
          insertedChatCount += 1;
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
          'Shadow incremental_update chat import. '
          'insertedChatCount=$insertedChatCount',
    );

    final result = ChatImportResult(
      startedAfterSourceRowId: startedAfterSourceRowId,
      lastImportedSourceRowId: lastImportedSourceRowId,
      insertedChatCount: insertedChatCount,
      batchId: batchId,
    );

    debugPrint(
      'Shadow chat import executed: '
      'startedAfterSourceRowId=${result.startedAfterSourceRowId}, '
      'lastImportedSourceRowId=${result.lastImportedSourceRowId}, '
      'insertedChatCount=${result.insertedChatCount}, '
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

  String _readRequiredString(Map<String, Object?> row, String column) {
    final value = _readNullableString(row, column);
    if (value == null || value.isEmpty) {
      throw FormatException('Expected non-empty string value for $column.');
    }

    return value;
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
class ChatImportResult {
  const ChatImportResult({
    required this.startedAfterSourceRowId,
    required this.lastImportedSourceRowId,
    required this.insertedChatCount,
    required this.batchId,
  });

  final int startedAfterSourceRowId;
  final int lastImportedSourceRowId;
  final int insertedChatCount;
  final int batchId;
}
