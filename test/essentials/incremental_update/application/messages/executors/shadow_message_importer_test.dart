import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/executors/shadow_message_importer.dart';
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
    tempDir = await Directory.systemTemp.createTemp(
      'shadow_message_importer_test_',
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

  test('preserves source-scoped message relationship row ids', () async {
    final chatDbPath = '${tempDir.path}/chat.db';
    final sourceDb = await openDatabase(chatDbPath);
    await sourceDb.execute('''
      CREATE TABLE message (
        ROWID INTEGER PRIMARY KEY,
        guid TEXT,
        chat_id INTEGER,
        handle_id INTEGER,
        service TEXT,
        is_from_me INTEGER,
        text TEXT
      )
    ''');
    await sourceDb.insert('message', <String, Object?>{
      'ROWID': 101,
      'guid': 'message-101',
      'chat_id': 17,
      'handle_id': 42,
      'service': 'iMessage',
      'is_from_me': 0,
      'text': 'hello',
    });
    await sourceDb.close();

    final importer = ShadowMessageImporter(
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
    expect(rows.single['source_chat_rowid'], 17);
    expect(rows.single['source_sender_handle_rowid'], 42);
  });
}
