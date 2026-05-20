import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update_ss/application/chat_handle_joins/chat_handle_join_importer.dart';
import 'package:remember_this_text/essentials/incremental_update_ss/application/chat_handle_joins/chat_to_handle_projector.dart';
import 'package:remember_this_text/essentials/incremental_update_ss/application/handles/handle_importer.dart';
import 'package:remember_this_text/essentials/incremental_update_ss/application/handles/handle_projector.dart';
import 'package:remember_this_text/essentials/incremental_update_ss/domain/known_sources.dart';
import 'package:remember_this_text/essentials/incremental_update_ss/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/incremental_update_ss/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/essentials/incremental_update_ss/infrastructure/working_database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late String chatDbPath;
  late ImportDatabase importDatabase;
  late WorkingDatabase workingDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ss_handle_test_');
    chatDbPath = '${tempDir.path}/chat.db';
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    workingDatabase = await WorkingDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'working_ss_test.db',
    );
    await _createSourceTables(chatDbPath);
  });

  tearDown(() async {
    await workingDatabase.close();
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('imports and projects handles with stable ss_id', () async {
    await _insertSourceHandle(
      chatDbPath,
      rowId: 12,
      id: '+15550000012',
      service: 'iMessage',
    );

    final importResult = await HandleImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
    ).importNewHandles();
    final projectionResult = await HandleProjector(
      importDatabase: importDatabase,
      workingDatabase: workingDatabase,
    ).projectHandles();

    final expectedSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 12,
    );
    final importRows = await importDatabase.database.query('handles');
    final workingRows = await workingDatabase.database.query('handles');

    expect(importResult.startedAfterSourceRowId, 0);
    expect(importResult.insertedHandleCount, 1);
    expect(projectionResult.insertedHandleCount, 1);
    expect(importRows.single['ss_id'], expectedSsId);
    expect(importRows.single['source_id'], liveChatDbSourceId);
    expect(importRows.single['source_rowid'], 12);
    expect(importRows.single['id'], '+15550000012');
    expect(workingRows.single['ss_id'], expectedSsId);
    expect(workingRows.single['id'], '+15550000012');
    expect(workingRows.single.keys, isNot(contains('source_id')));
    expect(workingRows.single.keys, isNot(contains('source_rowid')));
    expect(workingRows.single.keys, isNot(contains('batch_id')));
  });

  test('handle import is idempotent and source-scoped', () async {
    await _insertLedgerHandle(importDatabase, sourceId: 2, sourceRowId: 999999);
    await _insertSourceHandle(
      chatDbPath,
      rowId: 5,
      id: '+15550000005',
      service: 'SMS',
    );

    final importer = HandleImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
    );
    final first = await importer.importNewHandles();
    final second = await importer.importNewHandles();

    expect(first.startedAfterSourceRowId, 0);
    expect(first.insertedHandleCount, 1);
    expect(second.startedAfterSourceRowId, 5);
    expect(second.insertedHandleCount, 0);
  });

  test('imports and projects chat-to-handle topology idempotently', () async {
    await _insertSourceChatHandle(chatDbPath, chatId: 7, handleId: 12);

    final importResult = await ChatHandleJoinImporter(
      chatDbPath: chatDbPath,
      importDatabase: importDatabase,
    ).importJoins();
    final projector = ChatToHandleProjector(
      importDatabase: importDatabase,
      workingDatabase: workingDatabase,
    );
    final firstProjection = await projector.projectEdges();
    final secondProjection = await projector.projectEdges();
    final importRows = await importDatabase.database.query('chat_to_handle');
    final workingRows = await workingDatabase.database.query('chat_to_handle');

    final chatSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 7,
    );
    final handleSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 12,
    );

    expect(importResult.insertedJoinCount, 1);
    expect(firstProjection.insertedEdgeCount, 1);
    expect(secondProjection.insertedEdgeCount, 0);
    expect(importRows.single['source_chat_rowid'], 7);
    expect(importRows.single['source_handle_rowid'], 12);
    expect(importRows.single['chat_ss_id'], chatSsId);
    expect(importRows.single['handle_ss_id'], handleSsId);
    expect(workingRows.single['chat_ss_id'], chatSsId);
    expect(workingRows.single['handle_ss_id'], handleSsId);
  });
}

Future<void> _createSourceTables(String chatDbPath) async {
  final db = await openDatabase(chatDbPath);
  await db.execute('''
    CREATE TABLE handle (
      ROWID INTEGER PRIMARY KEY,
      id TEXT NOT NULL,
      service TEXT
    )
  ''');
  await db.execute('''
    CREATE TABLE chat_handle_join (
      chat_id INTEGER NOT NULL,
      handle_id INTEGER NOT NULL
    )
  ''');
  await db.close();
}

Future<void> _insertSourceHandle(
  String chatDbPath, {
  required int rowId,
  required String id,
  required String service,
}) async {
  final db = await openDatabase(chatDbPath);
  await db.insert('handle', <String, Object?>{
    'ROWID': rowId,
    'id': id,
    'service': service,
  });
  await db.close();
}

Future<void> _insertSourceChatHandle(
  String chatDbPath, {
  required int chatId,
  required int handleId,
}) async {
  final db = await openDatabase(chatDbPath);
  await db.insert('chat_handle_join', <String, Object?>{
    'chat_id': chatId,
    'handle_id': handleId,
  });
  await db.close();
}

Future<void> _insertLedgerHandle(
  ImportDatabase importDatabase, {
  required int sourceId,
  required int sourceRowId,
}) async {
  await importDatabase.database.insert('source_registry', <String, Object?>{
    'source_id': sourceId,
    'source_key': 'source-$sourceId',
    'source_kind': 'archive_chat_db',
    'created_at_utc': DateTime.now().toUtc().toIso8601String(),
  });
  final batchId = await importDatabase.insertImportBatch(
    sourceId: sourceId,
    startedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );
  await importDatabase.database.insert('handles', <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceRowId,
    ),
    'source_id': sourceId,
    'source_rowid': sourceRowId,
    'id': 'archive-handle',
    'batch_id': batchId,
  });
}
