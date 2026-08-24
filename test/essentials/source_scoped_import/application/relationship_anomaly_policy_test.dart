import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_handle_joins/chat_handle_join_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_message_joins/chat_message_join_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late String sourcePath;
  late ImportDatabase importDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'relationship_anomaly_policy_',
    );
    sourcePath = '${tempDir.path}/chat.db';
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    final source = await openDatabase(sourcePath);
    await source.execute('CREATE TABLE chat (ROWID INTEGER PRIMARY KEY)');
    await source.execute('CREATE TABLE message (ROWID INTEGER PRIMARY KEY)');
    await source.execute('CREATE TABLE handle (ROWID INTEGER PRIMARY KEY)');
    await source.execute('''
      CREATE TABLE chat_message_join (
        chat_id INTEGER,
        message_id INTEGER
      )
    ''');
    await source.execute('''
      CREATE TABLE chat_handle_join (
        chat_id INTEGER,
        handle_id INTEGER
      )
    ''');
    await source.insert('chat', <String, Object?>{'ROWID': 1});
    await source.insert('message', <String, Object?>{'ROWID': 2});
    await source.insert('handle', <String, Object?>{'ROWID': 3});
    await source.close();
  });

  tearDown(() async {
    await importDatabase.close();
    await tempDir.delete(recursive: true);
  });

  test('chat-message importer omits only a broken relationship', () async {
    final source = await openDatabase(sourcePath);
    await source.insert('chat_message_join', <String, Object?>{
      'chat_id': 1,
      'message_id': 2,
    });
    await source.insert('chat_message_join', <String, Object?>{
      'chat_id': 999,
      'message_id': 2,
    });
    await source.close();

    final result = await ChatMessageJoinImporter(
      chatDbPath: sourcePath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importJoins();

    expect(result.examinedJoinCount, 2);
    expect(result.insertedJoinCount, 1);
    expect(result.omittedJoinCount, 1);
    expect(
      await importDatabase.database.query('chat_to_message'),
      hasLength(1),
    );
  });

  test('chat-handle importer omits only a broken relationship', () async {
    final source = await openDatabase(sourcePath);
    await source.insert('chat_handle_join', <String, Object?>{
      'chat_id': 1,
      'handle_id': 3,
    });
    await source.insert('chat_handle_join', <String, Object?>{
      'chat_id': 1,
      'handle_id': 999,
    });
    await source.close();

    final result = await ChatHandleJoinImporter(
      chatDbPath: sourcePath,
      importLedger: importDatabase,
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    ).importJoins();

    expect(result.examinedJoinCount, 2);
    expect(result.insertedJoinCount, 1);
    expect(result.omittedJoinCount, 1);
    expect(await importDatabase.database.query('chat_to_handle'), hasLength(1));
  });
}
