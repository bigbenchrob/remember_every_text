import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/importers/handle_importer.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/source_identity.dart';
import 'package:remember_this_text/essentials/incremental_update/infrastructure/import_ledger_handle_repository.dart';
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
    tempDir = await Directory.systemTemp.createTemp('handle_importer_test_');
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
    'imports source handles with provenance and app-relevant fields',
    () async {
      final chatDbPath = '${tempDir.path}/chat.db';
      final sourceDb = await openDatabase(chatDbPath);
      await sourceDb.execute('''
      CREATE TABLE handle (
        ROWID INTEGER PRIMARY KEY,
        id TEXT,
        service TEXT,
        country TEXT
      )
    ''');
      await sourceDb.insert('handle', <String, Object?>{
        'ROWID': 42,
        'id': '+1 (555) 000-0001',
        'service': 'iMessage',
        'country': 'US',
      });
      await sourceDb.close();

      final importer = HandleImporter(
        chatDbPath: chatDbPath,
        shadowImportDb: shadowImportDb,
        importLedgerRepository: ImportLedgerHandleRepository(
          ledgerDb: shadowImportDb,
        ),
      );

      final result = await importer.importNewHandles();

      expect(result.insertedHandleCount, 1);
      expect(result.lastImportedSourceRowId, 42);

      final db = await shadowImportDb.database;
      final rows = await db.query(
        'handles',
        columns: <String>[
          'source_rowid',
          'source_id',
          'source_kind',
          'raw_identifier',
          'normalized_identifier',
          'service',
          'country',
        ],
        where: 'source_rowid = ?',
        whereArgs: <Object?>[42],
      );

      expect(rows, hasLength(1));
      expect(rows.single['source_rowid'], 42);
      expect(rows.single['source_id'], 'live-chat-db');
      expect(rows.single['source_kind'], 'live_chat_db');
      expect(rows.single['raw_identifier'], '+1 (555) 000-0001');
      expect(rows.single['normalized_identifier'], '5550000001');
      expect(rows.single['service'], 'iMessage');
      expect(rows.single['country'], 'US');
    },
  );

  test('handles missing optional service and country safely', () async {
    final chatDbPath = '${tempDir.path}/chat.db';
    final sourceDb = await openDatabase(chatDbPath);
    await sourceDb.execute('''
      CREATE TABLE handle (
        ROWID INTEGER PRIMARY KEY,
        id TEXT
      )
    ''');
    await sourceDb.insert('handle', <String, Object?>{
      'ROWID': 7,
      'id': 'mailto:person@example.com',
    });
    await sourceDb.close();

    final importer = HandleImporter(
      chatDbPath: chatDbPath,
      shadowImportDb: shadowImportDb,
      importLedgerRepository: ImportLedgerHandleRepository(
        ledgerDb: shadowImportDb,
      ),
    );

    final result = await importer.importNewHandles();

    expect(result.insertedHandleCount, 1);

    final db = await shadowImportDb.database;
    final rows = await db.query(
      'handles',
      columns: <String>[
        'raw_identifier',
        'normalized_identifier',
        'service',
        'country',
      ],
      where: 'source_rowid = ?',
      whereArgs: <Object?>[7],
    );

    expect(rows.single['raw_identifier'], 'person@example.com');
    expect(rows.single['normalized_identifier'], 'person@example.com');
    expect(rows.single['service'], 'Unknown');
    expect(rows.single['country'], isNull);
  });

  test('is idempotent across repeated imports', () async {
    final chatDbPath = '${tempDir.path}/chat.db';
    final sourceDb = await openDatabase(chatDbPath);
    await sourceDb.execute('''
      CREATE TABLE handle (
        ROWID INTEGER PRIMARY KEY,
        id TEXT,
        service TEXT
      )
    ''');
    await sourceDb.insert('handle', <String, Object?>{
      'ROWID': 1,
      'id': '+15550000001',
      'service': 'SMS',
    });
    await sourceDb.close();

    final importer = HandleImporter(
      chatDbPath: chatDbPath,
      shadowImportDb: shadowImportDb,
      importLedgerRepository: ImportLedgerHandleRepository(
        ledgerDb: shadowImportDb,
      ),
    );

    final first = await importer.importNewHandles();
    final second = await importer.importNewHandles();

    final db = await shadowImportDb.database;
    final countRows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM handles',
    );

    expect(first.insertedHandleCount, 1);
    expect(second.insertedHandleCount, 0);
    expect(countRows.single['count'], 1);
  });

  test(
    'continues from live source cursor, not another source cursor',
    () async {
      final chatDbPath = '${tempDir.path}/chat.db';
      final sourceDb = await openDatabase(chatDbPath);
      await sourceDb.execute('''
      CREATE TABLE handle (
        ROWID INTEGER PRIMARY KEY,
        id TEXT,
        service TEXT
      )
    ''');
      await sourceDb.insert('handle', <String, Object?>{
        'ROWID': 11,
        'id': '+15550000011',
        'service': 'iMessage',
      });
      await sourceDb.close();

      final batchId = await shadowImportDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );
      final db = await shadowImportDb.database;
      await _insertLedgerHandle(
        db,
        id: 10,
        sourceRowid: 10,
        rawIdentifier: '+15550000010',
        batchId: batchId,
        sourceId: liveChatDbSourceIdentity.sourceId,
        sourceKind: liveChatDbSourceIdentity.sourceKind,
      );
      await _insertLedgerHandle(
        db,
        id: 999999,
        sourceRowid: 999999,
        rawIdentifier: '+15559999999',
        batchId: batchId,
        sourceId: 'archive-test',
        sourceKind: 'archived_messages_folder',
      );

      final importer = HandleImporter(
        chatDbPath: chatDbPath,
        shadowImportDb: shadowImportDb,
        importLedgerRepository: ImportLedgerHandleRepository(
          ledgerDb: shadowImportDb,
        ),
      );

      final result = await importer.importNewHandles();

      expect(result.startedAfterSourceRowId, 10);
      expect(result.lastImportedSourceRowId, 11);
      expect(result.insertedHandleCount, 1);
    },
  );
}

Future<void> _insertLedgerHandle(
  Database db, {
  required int id,
  required int sourceRowid,
  required String rawIdentifier,
  required int batchId,
  required String sourceId,
  required String sourceKind,
}) async {
  await db.insert('handles', <String, Object?>{
    'id': id,
    'source_rowid': sourceRowid,
    'source_id': sourceId,
    'source_kind': sourceKind,
    'service': 'iMessage',
    'raw_identifier': rawIdentifier,
    'compound_identifier': 'iMessage:$rawIdentifier',
    'batch_id': batchId,
  });
}
