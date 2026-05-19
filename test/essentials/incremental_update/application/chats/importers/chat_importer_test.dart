import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/core/util/date_converter.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/importers/chat_importer.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/source_identity.dart';
import 'package:remember_this_text/essentials/incremental_update/infrastructure/import_ledger_chat_repository.dart';
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
    tempDir = await Directory.systemTemp.createTemp('chat_importer_test_');
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

  test(
    'imports source chats with provenance and app-relevant fields',
    () async {
      final chatDbPath = '${tempDir.path}/chat.db';
      final sourceDb = await openDatabase(chatDbPath);
      await sourceDb.execute('''
      CREATE TABLE chat (
        ROWID INTEGER PRIMARY KEY,
        guid TEXT,
        chat_identifier TEXT,
        service_name TEXT,
        display_name TEXT,
        creation_date INTEGER,
        last_read_message_timestamp INTEGER
      )
    ''');
      await sourceDb.insert('chat', <String, Object?>{
        'ROWID': 12,
        'guid': 'iMessage;-;+15550000001',
        'chat_identifier': '+15550000001',
        'service_name': 'iMessage',
        'display_name': 'Test Chat',
        'creation_date': 762307200000000000,
        'last_read_message_timestamp': 762307260000000000,
      });
      await sourceDb.close();

      final importer = ChatImporter(
        chatDbPath: chatDbPath,
        shadowImportDb: shadowImportDb,
        importLedgerRepository: ImportLedgerChatRepository(
          ledgerDb: shadowImportDb,
        ),
      );

      final result = await importer.importNewChats();

      expect(result.insertedChatCount, 1);
      expect(result.lastImportedSourceRowId, 12);

      final db = await shadowImportDb.database;
      final rows = await db.query(
        'chats',
        columns: <String>[
          'source_rowid',
          'source_id',
          'source_kind',
          'guid',
          'service',
          'display_name',
          'created_at_utc',
          'updated_at_utc',
        ],
        where: 'source_rowid = ?',
        whereArgs: <Object?>[12],
      );

      expect(rows, hasLength(1));
      expect(rows.single['source_rowid'], 12);
      expect(rows.single['source_id'], 'live-chat-db');
      expect(rows.single['source_kind'], 'live_chat_db');
      expect(rows.single['guid'], 'iMessage;-;+15550000001');
      expect(rows.single['service'], 'iMessage');
      expect(rows.single['display_name'], 'Test Chat');
      expect(
        rows.single['created_at_utc'],
        DateConverter.appleToIsoString(762307200000000000),
      );
      expect(
        rows.single['updated_at_utc'],
        DateConverter.appleToIsoString(762307260000000000),
      );
    },
  );

  test('does not synthesize display name from chat identifier', () async {
    final chatDbPath = '${tempDir.path}/chat.db';
    final sourceDb = await openDatabase(chatDbPath);
    await sourceDb.execute('''
      CREATE TABLE chat (
        ROWID INTEGER PRIMARY KEY,
        guid TEXT,
        chat_identifier TEXT
      )
    ''');
    await sourceDb.insert('chat', <String, Object?>{
      'ROWID': 4,
      'guid': 'SMS;-;+15550000002',
      'chat_identifier': '+15550000002',
    });
    await sourceDb.close();

    final importer = ChatImporter(
      chatDbPath: chatDbPath,
      shadowImportDb: shadowImportDb,
      importLedgerRepository: ImportLedgerChatRepository(
        ledgerDb: shadowImportDb,
      ),
    );

    final result = await importer.importNewChats();

    expect(result.insertedChatCount, 1);

    final db = await shadowImportDb.database;
    final rows = await db.query(
      'chats',
      columns: <String>[
        'guid',
        'service',
        'display_name',
        'created_at_utc',
        'updated_at_utc',
      ],
      where: 'source_rowid = ?',
      whereArgs: <Object?>[4],
    );

    expect(rows.single['guid'], 'SMS;-;+15550000002');
    expect(rows.single['service'], isNull);
    expect(rows.single['display_name'], isNull);
    expect(rows.single['created_at_utc'], isNull);
    expect(rows.single['updated_at_utc'], isNull);
  });

  test('is idempotent across repeated imports', () async {
    final chatDbPath = '${tempDir.path}/chat.db';
    final sourceDb = await openDatabase(chatDbPath);
    await sourceDb.execute('''
      CREATE TABLE chat (
        ROWID INTEGER PRIMARY KEY,
        guid TEXT,
        service_name TEXT
      )
    ''');
    await sourceDb.insert('chat', <String, Object?>{
      'ROWID': 1,
      'guid': 'iMessage;-;chat-1',
      'service_name': 'iMessage',
    });
    await sourceDb.close();

    final importer = ChatImporter(
      chatDbPath: chatDbPath,
      shadowImportDb: shadowImportDb,
      importLedgerRepository: ImportLedgerChatRepository(
        ledgerDb: shadowImportDb,
      ),
    );

    final first = await importer.importNewChats();
    final second = await importer.importNewChats();

    final db = await shadowImportDb.database;
    final countRows = await db.rawQuery('SELECT COUNT(*) AS count FROM chats');

    expect(first.insertedChatCount, 1);
    expect(second.insertedChatCount, 0);
    expect(countRows.single['count'], 1);
  });

  test(
    'continues from live source cursor, not another source cursor',
    () async {
      final chatDbPath = '${tempDir.path}/chat.db';
      final sourceDb = await openDatabase(chatDbPath);
      await sourceDb.execute('''
      CREATE TABLE chat (
        ROWID INTEGER PRIMARY KEY,
        guid TEXT,
        service_name TEXT
      )
    ''');
      await sourceDb.insert('chat', <String, Object?>{
        'ROWID': 11,
        'guid': 'iMessage;-;chat-11',
        'service_name': 'iMessage',
      });
      await sourceDb.close();

      final batchId = await shadowImportDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );
      await _insertLedgerChat(
        shadowImportDb,
        id: 10,
        sourceRowid: 10,
        guid: 'iMessage;-;chat-10',
        batchId: batchId,
        sourceId: liveChatDbSourceIdentity.sourceId,
        sourceKind: liveChatDbSourceIdentity.sourceKind,
      );
      await _insertLedgerChat(
        shadowImportDb,
        id: 999999,
        sourceRowid: 999999,
        guid: 'archive-chat-999999',
        batchId: batchId,
        sourceId: 'archive-test',
        sourceKind: 'archived_messages_folder',
      );

      final importer = ChatImporter(
        chatDbPath: chatDbPath,
        shadowImportDb: shadowImportDb,
        importLedgerRepository: ImportLedgerChatRepository(
          ledgerDb: shadowImportDb,
        ),
      );

      final result = await importer.importNewChats();

      expect(result.startedAfterSourceRowId, 10);
      expect(result.lastImportedSourceRowId, 11);
      expect(result.insertedChatCount, 1);
    },
  );
}

Future<void> _insertLedgerChat(
  SqfliteImportDatabase ledgerDb, {
  required int id,
  required int sourceRowid,
  required String guid,
  required int batchId,
  required String sourceId,
  required String sourceKind,
}) async {
  await ledgerDb.insertChat(
    id: id,
    sourceRowid: sourceRowid,
    guid: guid,
    batchId: batchId,
  );
  final db = await ledgerDb.database;
  await db.update(
    'chats',
    <String, Object?>{'source_id': sourceId, 'source_kind': sourceKind},
    where: 'id = ?',
    whereArgs: <Object?>[id],
  );
}
