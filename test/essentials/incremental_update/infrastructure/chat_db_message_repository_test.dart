import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/infrastructure/chat_db_message_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late String chatDbPath;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'chat_db_message_repository_test_',
    );
    chatDbPath = '${tempDir.path}/chat.db';
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('returns zero snapshot for an empty message table', () async {
    final db = await openDatabase(chatDbPath);
    await db.execute('CREATE TABLE message (guid TEXT);');
    await db.close();

    final repository = ChatDbMessageRepository(chatDbPath: chatDbPath);
    final snapshot = await repository.readMessageSnapshot();

    expect(snapshot.maxRowId, 0);
    expect(snapshot.totalMessageCount, 0);
  });

  test('returns max ROWID and total count for live message table', () async {
    final db = await openDatabase(chatDbPath);
    await db.execute('CREATE TABLE message (guid TEXT);');
    await db.insert('message', <String, Object?>{'guid': 'one'});
    await db.insert('message', <String, Object?>{'guid': 'two'});
    await db.insert('message', <String, Object?>{'guid': 'three'});
    await db.close();

    final repository = ChatDbMessageRepository(chatDbPath: chatDbPath);
    final snapshot = await repository.readMessageSnapshot();

    expect(snapshot.maxRowId, 3);
    expect(snapshot.totalMessageCount, 3);
  });
}
