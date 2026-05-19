import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../domain/models/source_identity.dart';
import '../../../infrastructure/import_ledger_chat_message_join_repository.dart';
import '../../importers/importer_descriptor.dart';

class ChatMessageJoinImporter {
  const ChatMessageJoinImporter({
    required String chatDbPath,
    required SqfliteImportDatabase shadowImportDb,
    required ImportLedgerChatMessageJoinRepository importLedgerRepository,
  }) : _chatDbPath = chatDbPath,
       _shadowImportDb = shadowImportDb,
       _importLedgerRepository = importLedgerRepository;

  static const int _sourceReadBatchSize = 1000;

  static const ImporterDescriptor descriptor = ImporterDescriptor(
    importerName: 'chat_message_join_importer',
    sourceTables: <String>['chat_message_join'],
    targetTables: <String>['chat_message_joins'],
    prerequisites: <String>['chat_importer', 'message_importer'],
    continuationStrategy:
        'MAX(chat_message_joins.source_rowid) scoped by source_id',
    idempotenceStrategy:
        'INSERT OR IGNORE / conflict ignore on source-scoped topology rows',
    validationStrategy: 'source-scoped topology cursor/count convergence',
  );

  final String _chatDbPath;
  final SqfliteImportDatabase _shadowImportDb;
  final ImportLedgerChatMessageJoinRepository _importLedgerRepository;

  Future<ChatMessageJoinImportResult> importNewChatMessageJoins() async {
    final ledgerSnapshot = await _importLedgerRepository
        .readChatMessageJoinSnapshot();
    final startedAfterSourceRowId = ledgerSnapshot.maxRowId;
    final startedAtUtc = DateTime.now().toUtc().toIso8601String();
    final batchId = await _shadowImportDb.insertImportBatch(
      startedAtUtc: startedAtUtc,
      sourceChatDb: _chatDbPath,
      notes: 'Shadow incremental_update chat_message_join import.',
    );

    var insertedJoinCount = 0;
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
            chat_id AS source_chat_rowid,
            message_id AS source_message_rowid
          FROM chat_message_join
          WHERE ROWID > ?
          ORDER BY ROWID ASC
          LIMIT ?
          ''',
          <Object?>[lastImportedSourceRowId, _sourceReadBatchSize],
        );

        if (sourceRows.isEmpty) {
          break;
        }

        final destinationDb = await _shadowImportDb.database;

        for (final sourceRow in sourceRows) {
          final sourceRowId = _readRequiredInt(sourceRow, 'source_rowid');
          lastImportedSourceRowId = sourceRowId;

          final insertedId = await destinationDb
              .insert('chat_message_joins', <String, Object?>{
                'source_rowid': sourceRowId,
                'source_id': liveChatDbSourceIdentity.sourceId,
                'source_kind': liveChatDbSourceIdentity.sourceKind,
                'source_chat_rowid': _readRequiredInt(
                  sourceRow,
                  'source_chat_rowid',
                ),
                'source_message_rowid': _readRequiredInt(
                  sourceRow,
                  'source_message_rowid',
                ),
                'batch_id': batchId,
              }, conflictAlgorithm: ConflictAlgorithm.ignore);

          if (insertedId != 0) {
            insertedJoinCount += 1;
          }
        }
      }
    } finally {
      await sourceDb.close();
    }

    final finishedAtUtc = DateTime.now().toUtc().toIso8601String();
    await _shadowImportDb.updateImportBatch(
      id: batchId,
      finishedAtUtc: finishedAtUtc,
      notes:
          'Shadow incremental_update chat_message_join import. '
          'insertedJoinCount=$insertedJoinCount',
    );

    final result = ChatMessageJoinImportResult(
      startedAfterSourceRowId: startedAfterSourceRowId,
      lastImportedSourceRowId: lastImportedSourceRowId,
      insertedJoinCount: insertedJoinCount,
      batchId: batchId,
    );

    debugPrint(
      'Shadow chat_message_join import executed: '
      'startedAfterSourceRowId=${result.startedAfterSourceRowId}, '
      'lastImportedSourceRowId=${result.lastImportedSourceRowId}, '
      'insertedJoinCount=${result.insertedJoinCount}, '
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
}

@immutable
class ChatMessageJoinImportResult {
  const ChatMessageJoinImportResult({
    required this.startedAfterSourceRowId,
    required this.lastImportedSourceRowId,
    required this.insertedJoinCount,
    required this.batchId,
  });

  final int startedAfterSourceRowId;
  final int lastImportedSourceRowId;
  final int insertedJoinCount;
  final int batchId;
}
