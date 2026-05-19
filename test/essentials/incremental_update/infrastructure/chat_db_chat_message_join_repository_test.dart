import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/infrastructure/chat_db_chat_message_join_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'chat_db_chat_message_join_repository_test_',
    );
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('observes source chat_message_join topology facts', () async {
    final chatDbPath = '${tempDir.path}/chat.db';
    final db = await openDatabase(chatDbPath);
    await db.execute('''
      CREATE TABLE chat_message_join (
        chat_id INTEGER NOT NULL,
        message_id INTEGER NOT NULL
      )
    ''');
    await db.insert('chat_message_join', <String, Object?>{
      'chat_id': 3,
      'message_id': 10,
    });
    await db.insert('chat_message_join', <String, Object?>{
      'chat_id': 5,
      'message_id': 20,
    });
    await db.close();

    final repository = ChatDbChatMessageJoinRepository(chatDbPath: chatDbPath);

    final snapshot = await repository.readChatMessageJoinSnapshot();

    expect(snapshot.maxRowId, 2);
    expect(snapshot.totalJoinCount, 2);
    expect(snapshot.maxMessageRowId, 20);
    expect(snapshot.maxChatRowId, 5);
    expect(snapshot.sourceScopedObservationAvailable, isTrue);
  });
}
