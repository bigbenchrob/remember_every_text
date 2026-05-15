import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/infrastructure/chat_db_chat_repository.dart';
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
      'chat_db_chat_repository_test_',
    );
    chatDbPath = '${tempDir.path}/chat.db';
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('returns zero snapshot for an empty chat table', () async {
    final db = await openDatabase(chatDbPath);
    await db.execute('CREATE TABLE chat (guid TEXT);');
    await db.close();

    final repository = ChatDbChatRepository(chatDbPath: chatDbPath);
    final snapshot = await repository.readChatSnapshot();

    expect(snapshot.maxRowId, 0);
    expect(snapshot.totalChatCount, 0);
  });

  test('returns max ROWID and total count for live chat table', () async {
    final db = await openDatabase(chatDbPath);
    await db.execute('CREATE TABLE chat (guid TEXT);');
    await db.insert('chat', <String, Object?>{'guid': 'chat-one'});
    await db.insert('chat', <String, Object?>{'guid': 'chat-two'});
    await db.close();

    final repository = ChatDbChatRepository(chatDbPath: chatDbPath);
    final snapshot = await repository.readChatSnapshot();

    expect(snapshot.maxRowId, 2);
    expect(snapshot.totalChatCount, 2);
  });
}
