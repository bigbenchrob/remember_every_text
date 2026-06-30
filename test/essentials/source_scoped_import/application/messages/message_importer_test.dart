import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/core/util/date_converter.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late String chatDbPath;
  late ImportDatabase importDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('message_import_ss_test_');
    chatDbPath = '${tempDir.path}/chat.db';
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    await _createSourceMessageTable(chatDbPath);
  });

  tearDown(() async {
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('imports messages into source-scoped ledger schema', () async {
    final appleDate = DateConverter.dateString2Apple('2026-05-19');
    await _insertSourceMessage(
      chatDbPath,
      rowId: 101,
      guid: 'message-101',
      handleId: 42,
      isFromMe: 0,
      date: appleDate,
      text: 'hello',
      associatedMessageGuid: 'associated-1',
      itemType: 1,
      associatedMessageType: 2000,
      threadOriginatorGuid: 'thread-originator-1',
      error: 404,
      isSystemMessage: 1,
      attributedBody: Uint8List.fromList(<int>[1, 2, 3]),
      messageSummaryInfo: Uint8List.fromList(<int>[4, 5, 6]),
      payloadData: Uint8List.fromList(<int>[7, 8, 9]),
    );

    final importer = MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );

    final result = await importer.importNewMessages();

    expect(result.startedAfterSourceRowId, 0);
    expect(result.insertedMessageCount, 1);
    expect(result.lastImportedSourceRowId, 101);

    final rows = await importDatabase.database.query('messages');

    expect(rows, hasLength(1));
    expect(
      rows.single['ss_id'],
      SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 101),
    );
    expect(rows.single['source_id'], liveChatDbSourceId);
    expect(rows.single['source_rowid'], 101);
    expect(rows.single['guid'], 'message-101');
    expect(
      rows.single['sender_handle_ss_id'],
      SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 42),
    );
    expect(rows.single['is_from_me'], 0);
    expect(rows.single['date_utc'], DateConverter.appleToIsoString(appleDate));
    expect(rows.single['text'], 'hello');
    expect(rows.single['associated_message_guid'], 'associated-1');
    expect(rows.single['raw_item_type'], 1);
    expect(rows.single['raw_associated_message_type'], 2000);
    expect(rows.single['thread_originator_guid'], 'thread-originator-1');
    expect(rows.single['error_code'], 404);
    expect(rows.single['is_system_message'], 1);
    expect(rows.single['has_attributed_body_source'], 1);
    expect(rows.single['has_message_summary_info'], 1);
    expect(rows.single['has_payload_data_source'], 1);
  });

  test('is idempotent on repeated imports', () async {
    await _insertSourceMessage(
      chatDbPath,
      rowId: 1,
      guid: 'message-1',
      handleId: 2,
      isFromMe: 1,
      text: 'one',
    );

    final importer = MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );

    final firstResult = await importer.importNewMessages();
    final secondResult = await importer.importNewMessages();
    final rows = await importDatabase.database.query('messages');

    expect(firstResult.insertedMessageCount, 1);
    expect(secondResult.startedAfterSourceRowId, 1);
    expect(secondResult.insertedMessageCount, 0);
    expect(rows, hasLength(1));
  });

  test('source-scoped continuation ignores rows from another source', () async {
    final batchId = await importDatabase.insertImportBatch(
      sourceId: liveChatDbSourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    await _insertLedgerMessage(
      importDatabase,
      sourceId: 3,
      sourceRowId: 999999,
      guid: 'archive-message-999999',
      batchId: batchId,
    );

    await _insertSourceMessage(
      chatDbPath,
      rowId: 10,
      guid: 'live-message-10',
      handleId: 0,
      isFromMe: 0,
      text: 'live',
    );

    final importer = MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );

    final result = await importer.importNewMessages();

    expect(result.startedAfterSourceRowId, 0);
    expect(result.insertedMessageCount, 1);
    expect(result.lastImportedSourceRowId, 10);
  });

  test('sender_handle_ss_id is null when handle_id is zero', () async {
    await _insertSourceMessage(
      chatDbPath,
      rowId: 12,
      guid: 'message-12',
      handleId: 0,
      isFromMe: 0,
      text: 'no handle',
    );

    final importer = MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );

    await importer.importNewMessages();
    final rows = await importDatabase.database.query('messages');

    expect(rows.single['sender_handle_ss_id'], isNull);
  });
}

Future<void> _createSourceMessageTable(String chatDbPath) async {
  final db = await openDatabase(chatDbPath);
  await db.execute('''
    CREATE TABLE message (
      ROWID INTEGER PRIMARY KEY,
      guid TEXT NOT NULL,
      handle_id INTEGER,
      is_from_me INTEGER NOT NULL,
      date INTEGER,
      date_read INTEGER,
      date_delivered INTEGER,
      text TEXT,
      attributedBody BLOB,
      associated_message_guid TEXT,
      item_type INTEGER,
      associated_message_type INTEGER,
      thread_originator_guid TEXT,
      error INTEGER,
      is_system_message INTEGER,
      message_summary_info BLOB,
      payload_data BLOB
    )
  ''');
  await db.close();
}

Future<void> _insertSourceMessage(
  String chatDbPath, {
  required int rowId,
  required String guid,
  required int handleId,
  required int isFromMe,
  int? date,
  String? text,
  String? associatedMessageGuid,
  int? itemType,
  int? associatedMessageType,
  String? threadOriginatorGuid,
  int? error,
  int? isSystemMessage,
  Uint8List? attributedBody,
  Uint8List? messageSummaryInfo,
  Uint8List? payloadData,
}) async {
  final db = await openDatabase(chatDbPath);
  await db.insert('message', <String, Object?>{
    'ROWID': rowId,
    'guid': guid,
    'handle_id': handleId,
    'is_from_me': isFromMe,
    'date': date,
    'text': text,
    'attributedBody': attributedBody,
    'associated_message_guid': associatedMessageGuid,
    'item_type': itemType,
    'associated_message_type': associatedMessageType,
    'thread_originator_guid': threadOriginatorGuid,
    'error': error,
    'is_system_message': isSystemMessage,
    'message_summary_info': messageSummaryInfo,
    'payload_data': payloadData,
  });
  await db.close();
}

Future<void> _insertLedgerMessage(
  ImportDatabase importDatabase, {
  required int sourceId,
  required int sourceRowId,
  required String guid,
  required int batchId,
}) async {
  await importDatabase.database.insert('source_registry', <String, Object?>{
    'source_id': sourceId,
    'source_key': 'archive-test',
    'source_kind': 'archive_chat_db',
    'created_at_utc': DateTime.now().toUtc().toIso8601String(),
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
  await importDatabase.database.insert('messages', <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceRowId,
    ),
    'source_id': sourceId,
    'source_rowid': sourceRowId,
    'guid': guid,
    'is_from_me': 0,
    'batch_id': batchId,
  });
}
