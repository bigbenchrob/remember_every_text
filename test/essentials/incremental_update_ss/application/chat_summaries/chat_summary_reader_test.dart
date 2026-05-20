import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update_ss/application/chat_summaries/chat_summary_reader.dart';
import 'package:remember_this_text/essentials/incremental_update_ss/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/incremental_update_ss/infrastructure/working_database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late WorkingDatabase workingDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ss_chat_summary_test_');
    workingDatabase = await WorkingDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'working_ss_test.db',
    );
  });

  tearDown(() async {
    await workingDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('summarizes participant and message topology', () async {
    final chatSsId = _ss(7);
    final firstHandleSsId = _ss(101);
    final secondHandleSsId = _ss(102);
    final firstMessageSsId = _ss(201);
    final secondMessageSsId = _ss(202);

    await _insertChat(workingDatabase, ssId: chatSsId);
    await _insertHandle(
      workingDatabase,
      ssId: firstHandleSsId,
      id: '+15550000101',
    );
    await _insertHandle(
      workingDatabase,
      ssId: secondHandleSsId,
      id: '+15550000102',
    );
    await _insertChatHandle(
      workingDatabase,
      chatSsId: chatSsId,
      handleSsId: firstHandleSsId,
    );
    await _insertChatHandle(
      workingDatabase,
      chatSsId: chatSsId,
      handleSsId: secondHandleSsId,
    );
    await _insertMessage(
      workingDatabase,
      ssId: firstMessageSsId,
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'older',
    );
    await _insertMessage(
      workingDatabase,
      ssId: secondMessageSsId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'newer',
    );
    await _insertChatMessage(
      workingDatabase,
      chatSsId: chatSsId,
      messageSsId: firstMessageSsId,
    );
    await _insertChatMessage(
      workingDatabase,
      chatSsId: chatSsId,
      messageSsId: secondMessageSsId,
    );

    final summaries = await ChatSummaryReader(
      workingDatabase: workingDatabase,
    ).readSummaries();

    expect(summaries, hasLength(1));
    expect(summaries.single.chatSsId, chatSsId);
    expect(summaries.single.participantHandles, [
      '+15550000101',
      '+15550000102',
    ]);
    expect(summaries.single.participantCount, 2);
    expect(summaries.single.isGroup, isTrue);
    expect(summaries.single.messageCount, 2);
    expect(summaries.single.lastMessageAtUtc, '2026-05-20T10:00:00.000Z');
    expect(summaries.single.lastMessageText, 'newer');
  });

  test('uses latest non-null message text', () async {
    final chatSsId = _ss(7);
    final olderMessageSsId = _ss(201);
    final newerMessageSsId = _ss(202);

    await _insertChat(workingDatabase, ssId: chatSsId);
    await _insertMessage(
      workingDatabase,
      ssId: olderMessageSsId,
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'visible',
    );
    await _insertMessage(
      workingDatabase,
      ssId: newerMessageSsId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: null,
    );
    await _insertChatMessage(
      workingDatabase,
      chatSsId: chatSsId,
      messageSsId: olderMessageSsId,
    );
    await _insertChatMessage(
      workingDatabase,
      chatSsId: chatSsId,
      messageSsId: newerMessageSsId,
    );

    final summaries = await ChatSummaryReader(
      workingDatabase: workingDatabase,
    ).readSummaries();

    expect(summaries.single.lastMessageAtUtc, '2026-05-20T10:00:00.000Z');
    expect(summaries.single.lastMessageText, 'visible');
  });

  test('handles chats with no text messages', () async {
    final chatSsId = _ss(7);
    final messageSsId = _ss(201);

    await _insertChat(workingDatabase, ssId: chatSsId);
    await _insertMessage(
      workingDatabase,
      ssId: messageSsId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: null,
    );
    await _insertChatMessage(
      workingDatabase,
      chatSsId: chatSsId,
      messageSsId: messageSsId,
    );

    final summaries = await ChatSummaryReader(
      workingDatabase: workingDatabase,
    ).readSummaries();

    expect(summaries.single.messageCount, 1);
    expect(summaries.single.lastMessageText, isNull);
  });

  test('deduplicates participant rows and reports sanity counts', () async {
    final groupChatSsId = _ss(7);
    final singleChatSsId = _ss(8);
    final firstHandleSsId = _ss(101);
    final secondHandleSsId = _ss(102);

    await _insertChat(workingDatabase, ssId: groupChatSsId);
    await _insertChat(workingDatabase, ssId: singleChatSsId);
    await _insertHandle(
      workingDatabase,
      ssId: firstHandleSsId,
      id: '+15550000101',
    );
    await _insertHandle(
      workingDatabase,
      ssId: secondHandleSsId,
      id: '+15550000102',
    );
    await _insertChatHandle(
      workingDatabase,
      chatSsId: groupChatSsId,
      handleSsId: firstHandleSsId,
    );
    await _insertChatHandle(
      workingDatabase,
      chatSsId: groupChatSsId,
      handleSsId: firstHandleSsId,
    );
    await _insertChatHandle(
      workingDatabase,
      chatSsId: groupChatSsId,
      handleSsId: secondHandleSsId,
    );
    await _insertChatHandle(
      workingDatabase,
      chatSsId: singleChatSsId,
      handleSsId: firstHandleSsId,
    );

    final reader = ChatSummaryReader(workingDatabase: workingDatabase);
    final summaries = await reader.readSummaries();
    final sanityCounts = await reader.readSanityCounts();

    expect(
      summaries
          .singleWhere((summary) => summary.chatSsId == groupChatSsId)
          .participantCount,
      2,
    );
    expect(sanityCounts.groupChatCount, 1);
    expect(sanityCounts.singleParticipantChatCount, 1);
    expect(sanityCounts.largestParticipantCount, 2);
  });
}

int _ss(int sourceRowId) {
  return SourceScopedRowKey.pack(sourceId: 1, sourceRowId: sourceRowId);
}

Future<void> _insertChat(
  WorkingDatabase workingDatabase, {
  required int ssId,
}) async {
  await workingDatabase.database.insert('chats', <String, Object?>{
    'ss_id': ssId,
    'guid': 'chat-$ssId',
    'is_group': 0,
  });
}

Future<void> _insertHandle(
  WorkingDatabase workingDatabase, {
  required int ssId,
  required String id,
}) async {
  await workingDatabase.database.insert('handles', <String, Object?>{
    'ss_id': ssId,
    'id': id,
  });
}

Future<void> _insertMessage(
  WorkingDatabase workingDatabase, {
  required int ssId,
  required String dateUtc,
  required String? text,
}) async {
  await workingDatabase.database.insert('messages', <String, Object?>{
    'ss_id': ssId,
    'guid': 'message-$ssId',
    'is_from_me': 0,
    'date_utc': dateUtc,
    'text': text,
  });
}

Future<void> _insertChatHandle(
  WorkingDatabase workingDatabase, {
  required int chatSsId,
  required int handleSsId,
}) async {
  await workingDatabase.database.insert('chat_to_handle', <String, Object?>{
    'chat_ss_id': chatSsId,
    'handle_ss_id': handleSsId,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
}

Future<void> _insertChatMessage(
  WorkingDatabase workingDatabase, {
  required int chatSsId,
  required int messageSsId,
}) async {
  await workingDatabase.database.insert('chat_to_message', <String, Object?>{
    'chat_ss_id': chatSsId,
    'message_ss_id': messageSsId,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
}
