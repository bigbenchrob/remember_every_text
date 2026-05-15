import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/infrastructure/chat_db_handle_repository.dart';
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
      'chat_db_handle_repository_test_',
    );
    chatDbPath = '${tempDir.path}/chat.db';
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('returns zero snapshot for an empty handle table', () async {
    final db = await openDatabase(chatDbPath);
    await db.execute('CREATE TABLE handle (id TEXT);');
    await db.close();

    final repository = ChatDbHandleRepository(chatDbPath: chatDbPath);
    final snapshot = await repository.readHandleSnapshot();

    expect(snapshot.maxRowId, 0);
    expect(snapshot.totalHandleCount, 0);
  });

  test('returns max ROWID and total count for live handle table', () async {
    final db = await openDatabase(chatDbPath);
    await db.execute('CREATE TABLE handle (id TEXT);');
    await db.insert('handle', <String, Object?>{'id': '+15550000001'});
    await db.insert('handle', <String, Object?>{'id': '+15550000002'});
    await db.close();

    final repository = ChatDbHandleRepository(chatDbPath: chatDbPath);
    final snapshot = await repository.readHandleSnapshot();

    expect(snapshot.maxRowId, 2);
    expect(snapshot.totalHandleCount, 2);
  });
}
