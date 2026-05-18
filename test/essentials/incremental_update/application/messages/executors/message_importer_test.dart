import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/executors/message_importer.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/source_identity.dart';
import 'package:remember_this_text/essentials/incremental_update/infrastructure/import_ledger_message_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late SqfliteImportDatabase shadowImportDb;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('message_importer_test_');
    shadowImportDb = SqfliteImportDatabase(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_shadow.db',
      debugSettings: const ImportDebugSettingsState(),
    );
  });

  tearDown(() async {
    await shadowImportDb.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('preserves sender provenance without inferring chat topology', () async {
    final chatDbPath = '${tempDir.path}/chat.db';
    final sourceDb = await openDatabase(chatDbPath);
    await sourceDb.execute('''
      CREATE TABLE message (
        ROWID INTEGER PRIMARY KEY,
        guid TEXT,
        handle_id INTEGER,
        service TEXT,
        is_from_me INTEGER,
        text TEXT
      )
    ''');
    await sourceDb.insert('message', <String, Object?>{
      'ROWID': 101,
      'guid': 'message-101',
      'handle_id': 42,
      'service': 'iMessage',
      'is_from_me': 0,
      'text': 'hello',
    });
    await sourceDb.close();

    final importer = MessageImporter(
      chatDbPath: chatDbPath,
      shadowImportDb: shadowImportDb,
      importLedgerRepository: ImportLedgerMessageRepository(
        ledgerDb: shadowImportDb,
      ),
    );

    final result = await importer.importNewMessages();

    expect(result.insertedMessageCount, 1);

    final db = await shadowImportDb.database;
    final rows = await db.query(
      'messages',
      columns: <String>[
        'source_rowid',
        'source_id',
        'source_kind',
        'source_chat_rowid',
        'source_sender_handle_rowid',
      ],
      where: 'guid = ?',
      whereArgs: <Object?>['message-101'],
    );

    expect(rows, hasLength(1));
    expect(rows.single['source_rowid'], 101);
    expect(rows.single['source_id'], 'live-chat-db');
    expect(rows.single['source_kind'], 'live_chat_db');
    expect(rows.single['source_chat_rowid'], isNull);
    expect(rows.single['source_sender_handle_rowid'], 42);
  });

  test(
    'continues from live source cursor, not another source cursor',
    () async {
      final chatDbPath = '${tempDir.path}/chat.db';
      final sourceDb = await openDatabase(chatDbPath);
      await sourceDb.execute('''
      CREATE TABLE message (
        ROWID INTEGER PRIMARY KEY,
        guid TEXT,
        handle_id INTEGER,
        service TEXT,
        is_from_me INTEGER,
        text TEXT
      )
    ''');
      await sourceDb.insert('message', <String, Object?>{
        'ROWID': 11,
        'guid': 'message-11',
        'handle_id': 7,
        'service': 'iMessage',
        'is_from_me': 0,
        'text': 'new live message',
      });
      await sourceDb.close();

      final batchId = await shadowImportDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );
      final chatId = await shadowImportDb.insertChat(
        id: 10,
        sourceRowid: 10,
        guid: 'chat-one',
        batchId: batchId,
      );
      await _insertLedgerMessage(
        shadowImportDb,
        id: 10,
        sourceRowid: 10,
        guid: 'live-message-10',
        chatId: chatId,
        batchId: batchId,
        sourceId: liveChatDbSourceIdentity.sourceId,
        sourceKind: liveChatDbSourceIdentity.sourceKind,
      );
      await _insertLedgerMessage(
        shadowImportDb,
        id: 999999,
        sourceRowid: 999999,
        guid: 'archive-message-999999',
        chatId: chatId,
        batchId: batchId,
        sourceId: 'archive-test',
        sourceKind: 'archived_messages_folder',
      );

      final importer = MessageImporter(
        chatDbPath: chatDbPath,
        shadowImportDb: shadowImportDb,
        importLedgerRepository: ImportLedgerMessageRepository(
          ledgerDb: shadowImportDb,
        ),
      );

      final result = await importer.importNewMessages();

      expect(result.startedAfterSourceRowId, 10);
      expect(result.lastImportedSourceRowId, 11);
      expect(result.insertedMessageCount, 1);
    },
  );
}

Future<void> _insertLedgerMessage(
  SqfliteImportDatabase ledgerDb, {
  required int id,
  required int sourceRowid,
  required String guid,
  required int chatId,
  required int batchId,
  required String sourceId,
  required String sourceKind,
}) async {
  await ledgerDb.insertMessage(
    id: id,
    sourceRowid: sourceRowid,
    guid: guid,
    chatId: chatId,
    isFromMe: false,
    hasAttributedBodySource: false,
    hasMessageSummaryInfo: false,
    hasPayloadDataSource: false,
    isSystemMessage: false,
    batchId: batchId,
  );
  final db = await ledgerDb.database;
  await db.update(
    'messages',
    <String, Object?>{'source_id': sourceId, 'source_kind': sourceKind},
    where: 'id = ?',
    whereArgs: <Object?>[id],
  );
}
