import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../infrastructure/import_ledger_message_repository.dart';
import '../../importers/importer_descriptor.dart';

class MessageImporter {
  const MessageImporter({
    required String chatDbPath,
    required SqfliteImportDatabase shadowImportDb,
    required ImportLedgerMessageRepository importLedgerRepository,
  }) : _chatDbPath = chatDbPath,
       _shadowImportDb = shadowImportDb,
       _importLedgerRepository = importLedgerRepository;

  static const int _sourceReadBatchSize = 1000;
  static const int _shadowPlaceholderChatId = -1;
  static const String _shadowPlaceholderChatGuid =
      '__shadow_incremental_update_placeholder_chat__';
  static const String _sourceId = 'live-chat-db';
  static const String _sourceKind = 'live_chat_db';
  static const ImporterDescriptor descriptor = ImporterDescriptor(
    importerName: 'message_importer',
    sourceTables: <String>['message'],
    targetTables: <String>['messages'],
    prerequisites: <String>[],
    continuationStrategy: 'MAX(messages.source_rowid)',
    idempotenceStrategy:
        'INSERT OR IGNORE / conflict ignore on already-imported rows',
    validationStrategy: 'cursor/count convergence validation',
  );

  final String _chatDbPath;
  final SqfliteImportDatabase _shadowImportDb;
  final ImportLedgerMessageRepository _importLedgerRepository;

  Future<MessageImportResult> importNewMessages() async {
    final ledgerSnapshot = await _importLedgerRepository.readMessageSnapshot();
    final startedAfterSourceRowId = ledgerSnapshot.maxRowId;
    final startedAtUtc = DateTime.now().toUtc().toIso8601String();
    final batchId = await _shadowImportDb.insertImportBatch(
      startedAtUtc: startedAtUtc,
      sourceChatDb: _chatDbPath,
      notes: 'Shadow incremental_update message import.',
    );

    await _ensureShadowPlaceholderChat(batchId: batchId);

    var insertedMessageCount = 0;
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
            handle_id AS source_sender_handle_rowid,
            guid,
            service,
            is_from_me,
            text
          FROM message
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

          destinationBatch.insert('messages', <String, Object?>{
            'id': sourceRowId,
            'source_rowid': sourceRowId,
            'source_id': _sourceId,
            'source_kind': _sourceKind,
            'source_chat_rowid': _readNullableInt(
              sourceRow,
              'source_chat_rowid',
            ),
            'source_sender_handle_rowid': _readNullableInt(
              sourceRow,
              'source_sender_handle_rowid',
            ),
            'guid':
                _readNullableString(sourceRow, 'guid') ??
                'shadow-message-source-rowid-$sourceRowId',
            'chat_id': _shadowPlaceholderChatId,
            'service': _readNullableString(sourceRow, 'service'),
            'is_from_me': _readBoolAsInt(sourceRow, 'is_from_me'),
            'text': _readNullableString(sourceRow, 'text'),
            'has_attributed_body_source': 0,
            'has_message_summary_info': 0,
            'has_payload_data_source': 0,
            'is_system_message': 0,
            'batch_id': batchId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
          insertedMessageCount += 1;
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
          'Shadow incremental_update message import. '
          'insertedMessageCount=$insertedMessageCount',
    );

    final result = MessageImportResult(
      startedAfterSourceRowId: startedAfterSourceRowId,
      lastImportedSourceRowId: lastImportedSourceRowId,
      insertedMessageCount: insertedMessageCount,
      batchId: batchId,
    );

    debugPrint(
      'Shadow message import executed: '
      'startedAfterSourceRowId=${result.startedAfterSourceRowId}, '
      'lastImportedSourceRowId=${result.lastImportedSourceRowId}, '
      'insertedMessageCount=${result.insertedMessageCount}, '
      'batchId=${result.batchId}',
    );

    return result;
  }

  Future<void> _ensureShadowPlaceholderChat({required int batchId}) async {
    final db = await _shadowImportDb.database;
    await db.insert('chats', <String, Object?>{
      'id': _shadowPlaceholderChatId,
      'guid': _shadowPlaceholderChatGuid,
      'display_name': 'Shadow incremental update placeholder chat',
      'is_group': 0,
      'is_ignored': 0,
      'batch_id': batchId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
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

  int? _readNullableInt(Map<String, Object?> row, String column) {
    final value = row[column];
    if (value == null) {
      return null;
    }
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

  int _readBoolAsInt(Map<String, Object?> row, String column) {
    final value = row[column];
    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value == 0 ? 0 : 1;
    }
    if (value is num) {
      return value == 0 ? 0 : 1;
    }
    if (value is bool) {
      return value ? 1 : 0;
    }

    throw FormatException(
      'Expected boolean-like value for $column, got $value.',
    );
  }
}

@immutable
class MessageImportResult {
  const MessageImportResult({
    required this.startedAfterSourceRowId,
    required this.lastImportedSourceRowId,
    required this.insertedMessageCount,
    required this.batchId,
  });

  final int startedAfterSourceRowId;
  final int lastImportedSourceRowId;
  final int insertedMessageCount;
  final int batchId;
}
