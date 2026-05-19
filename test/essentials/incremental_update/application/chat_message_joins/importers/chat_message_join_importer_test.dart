import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chat_message_joins/importers/chat_message_join_importer.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/source_identity.dart';
import 'package:remember_this_text/essentials/incremental_update/infrastructure/import_ledger_chat_message_join_repository.dart';
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
    tempDir = await Directory.systemTemp.createTemp(
      'chat_message_join_importer_test_',
    );
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

  test('imports source topology rows with source-scoped provenance', () async {
    final chatDbPath = '${tempDir.path}/chat.db';
    final sourceDb = await _createSourceChatDb(chatDbPath);
    await sourceDb.insert('chat_message_join', <String, Object?>{
      'ROWID': 12,
      'chat_id': 3,
      'message_id': 30,
    });
    await sourceDb.close();

    final importer = ChatMessageJoinImporter(
      chatDbPath: chatDbPath,
      shadowImportDb: shadowImportDb,
      importLedgerRepository: ImportLedgerChatMessageJoinRepository(
        ledgerDb: shadowImportDb,
      ),
    );

    final result = await importer.importNewChatMessageJoins();

    expect(result.startedAfterSourceRowId, 0);
    expect(result.lastImportedSourceRowId, 12);
    expect(result.insertedJoinCount, 1);

    final db = await shadowImportDb.database;
    final rows = await db.query(
      'chat_message_joins',
      columns: <String>[
        'source_rowid',
        'source_id',
        'source_kind',
        'source_chat_rowid',
        'source_message_rowid',
      ],
    );

    expect(rows, hasLength(1));
    expect(rows.single['source_rowid'], 12);
    expect(rows.single['source_id'], liveChatDbSourceIdentity.sourceId);
    expect(rows.single['source_kind'], liveChatDbSourceIdentity.sourceKind);
    expect(rows.single['source_chat_rowid'], 3);
    expect(rows.single['source_message_rowid'], 30);
  });

  test('is idempotent across repeated imports', () async {
    final chatDbPath = '${tempDir.path}/chat.db';
    final sourceDb = await _createSourceChatDb(chatDbPath);
    await sourceDb.insert('chat_message_join', <String, Object?>{
      'ROWID': 1,
      'chat_id': 2,
      'message_id': 3,
    });
    await sourceDb.close();

    final importer = ChatMessageJoinImporter(
      chatDbPath: chatDbPath,
      shadowImportDb: shadowImportDb,
      importLedgerRepository: ImportLedgerChatMessageJoinRepository(
        ledgerDb: shadowImportDb,
      ),
    );

    final first = await importer.importNewChatMessageJoins();
    final second = await importer.importNewChatMessageJoins();

    final db = await shadowImportDb.database;
    final countRows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM chat_message_joins',
    );

    expect(first.insertedJoinCount, 1);
    expect(second.insertedJoinCount, 0);
    expect(countRows.single['count'], 1);
  });

  test(
    'continues from live source cursor, not another source cursor',
    () async {
      final chatDbPath = '${tempDir.path}/chat.db';
      final sourceDb = await _createSourceChatDb(chatDbPath);
      await sourceDb.insert('chat_message_join', <String, Object?>{
        'ROWID': 11,
        'chat_id': 4,
        'message_id': 40,
      });
      await sourceDb.close();

      final batchId = await shadowImportDb.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );
      final db = await shadowImportDb.database;
      await _insertLedgerTopology(
        db,
        sourceRowid: 10,
        sourceId: liveChatDbSourceIdentity.sourceId,
        sourceKind: liveChatDbSourceIdentity.sourceKind,
        sourceChatRowid: 3,
        sourceMessageRowid: 30,
        batchId: batchId,
      );
      await _insertLedgerTopology(
        db,
        sourceRowid: 999999,
        sourceId: 'archive-test',
        sourceKind: 'archived_messages_folder',
        sourceChatRowid: 99,
        sourceMessageRowid: 999,
        batchId: batchId,
      );

      final importer = ChatMessageJoinImporter(
        chatDbPath: chatDbPath,
        shadowImportDb: shadowImportDb,
        importLedgerRepository: ImportLedgerChatMessageJoinRepository(
          ledgerDb: shadowImportDb,
        ),
      );

      final result = await importer.importNewChatMessageJoins();

      expect(result.startedAfterSourceRowId, 10);
      expect(result.lastImportedSourceRowId, 11);
      expect(result.insertedJoinCount, 1);
    },
  );

  test('descriptor documents topology importer metadata', () {
    const descriptor = ChatMessageJoinImporter.descriptor;

    expect(descriptor.importerName, 'chat_message_join_importer');
    expect(descriptor.sourceTables, <String>['chat_message_join']);
    expect(descriptor.targetTables, <String>['chat_message_joins']);
    expect(descriptor.prerequisites, <String>[
      'chat_importer',
      'message_importer',
    ]);
    expect(
      descriptor.continuationStrategy,
      'MAX(chat_message_joins.source_rowid) scoped by source_id',
    );
  });
}

Future<Database> _createSourceChatDb(String chatDbPath) async {
  final db = await openDatabase(chatDbPath);
  await db.execute('''
    CREATE TABLE chat_message_join (
      chat_id INTEGER NOT NULL,
      message_id INTEGER NOT NULL
    )
  ''');
  return db;
}

Future<void> _insertLedgerTopology(
  Database db, {
  required int sourceRowid,
  required String sourceId,
  required String sourceKind,
  required int sourceChatRowid,
  required int sourceMessageRowid,
  required int batchId,
}) async {
  await db.insert('chat_message_joins', <String, Object?>{
    'source_rowid': sourceRowid,
    'source_id': sourceId,
    'source_kind': sourceKind,
    'source_chat_rowid': sourceChatRowid,
    'source_message_rowid': sourceMessageRowid,
    'batch_id': batchId,
  });
}
