import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/working_database_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
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
    tempDir = await Directory.systemTemp.createTemp(
      'conversation_reader_test_',
    );
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

  test('reads conversation overviews from canonical graph topology', () async {
    final conversationId = _id(7);
    final firstHandleId = _id(101);
    final secondHandleId = _id(102);
    final olderMessageId = _id(201);
    final newerMessageId = _id(202);

    await _insertChat(workingDatabase, id: conversationId);
    await _insertHandle(workingDatabase, id: firstHandleId, handle: '+15551');
    await _insertHandle(workingDatabase, id: secondHandleId, handle: '+15552');
    await _insertChatHandle(
      workingDatabase,
      conversationId: conversationId,
      handleId: firstHandleId,
    );
    await _insertChatHandle(
      workingDatabase,
      conversationId: conversationId,
      handleId: secondHandleId,
    );
    await _insertMessage(
      workingDatabase,
      id: olderMessageId,
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'older',
    );
    await _insertMessage(
      workingDatabase,
      id: newerMessageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'newer',
    );
    await _insertChatMessage(
      workingDatabase,
      conversationId: conversationId,
      messageId: olderMessageId,
    );
    await _insertChatMessage(
      workingDatabase,
      conversationId: conversationId,
      messageId: newerMessageId,
    );

    final overviews = await ConversationReader(
      workingDatabase: workingDatabase,
    ).readOverviews();

    expect(overviews, hasLength(1));
    expect(overviews.single.conversationId, conversationId);
    expect(overviews.single.participantHandles, ['+15551', '+15552']);
    expect(overviews.single.participantCount, 2);
    expect(overviews.single.isGroup, isTrue);
    expect(overviews.single.messageCount, 2);
    expect(overviews.single.lastMessageAtUtc, '2026-05-20T10:00:00.000Z');
    expect(overviews.single.lastMessageText, 'newer');
  });

  test('reads conversation messages newest first', () async {
    final conversationId = _id(7);
    final associatedMessageId = _id(201);
    final replyMessageId = _id(202);

    await _insertChat(workingDatabase, id: conversationId);
    await _insertMessage(
      workingDatabase,
      id: associatedMessageId,
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'origin',
    );
    await _insertMessage(
      workingDatabase,
      id: replyMessageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'reply',
      isFromMe: true,
      associatedMessageId: associatedMessageId,
    );
    await _insertChatMessage(
      workingDatabase,
      conversationId: conversationId,
      messageId: associatedMessageId,
    );
    await _insertChatMessage(
      workingDatabase,
      conversationId: conversationId,
      messageId: replyMessageId,
    );

    final messages = await ConversationReader(
      workingDatabase: workingDatabase,
    ).readMessages(conversationId: conversationId);

    expect(messages.map((message) => message.messageId), [
      replyMessageId,
      associatedMessageId,
    ]);
    expect(messages.first.isFromMe, isTrue);
    expect(messages.first.text, 'reply');
    expect(messages.first.associatedMessageId, associatedMessageId);
  });

  test('reads conversation ids matching message text', () async {
    final matchingConversationId = _id(7);
    final otherConversationId = _id(8);
    final matchingMessageId = _id(201);
    final otherMessageId = _id(202);

    await _insertChat(workingDatabase, id: matchingConversationId);
    await _insertChat(workingDatabase, id: otherConversationId);
    await _insertMessage(
      workingDatabase,
      id: matchingMessageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'We discussed settlement timing.',
    );
    await _insertMessage(
      workingDatabase,
      id: otherMessageId,
      dateUtc: '2026-05-20T11:00:00.000Z',
      text: 'Different topic.',
    );
    await _insertChatMessage(
      workingDatabase,
      conversationId: matchingConversationId,
      messageId: matchingMessageId,
    );
    await _insertChatMessage(
      workingDatabase,
      conversationId: otherConversationId,
      messageId: otherMessageId,
    );

    final matchingIds = await ConversationReader(
      workingDatabase: workingDatabase,
    ).readConversationIdsMatchingMessageText(query: 'settlement');

    expect(matchingIds, {matchingConversationId});

    final matches = await ConversationReader(
      workingDatabase: workingDatabase,
    ).readConversationMessageTextMatches(query: 'settlement');

    expect(matches.keys, {matchingConversationId});
    expect(matches[matchingConversationId]?.matchCount, 1);
    expect(
      matches[matchingConversationId]?.sampleText,
      'We discussed settlement timing.',
    );
  });
}

int _id(int sourceRowId) {
  return SourceScopedRowKey.pack(sourceId: 1, sourceRowId: sourceRowId);
}

Future<void> _insertChat(WorkingDatabase workingDatabase, {required int id}) {
  return workingDatabase.database.insert('chats', <String, Object?>{
    'ss_id': id,
    'guid': 'chat-$id',
    'is_group': 0,
  });
}

Future<void> _insertHandle(
  WorkingDatabase workingDatabase, {
  required int id,
  required String handle,
}) {
  return workingDatabase.database.insert('handles', <String, Object?>{
    'ss_id': id,
    'id': handle,
  });
}

Future<void> _insertMessage(
  WorkingDatabase workingDatabase, {
  required int id,
  required String dateUtc,
  required String text,
  bool isFromMe = false,
  int? associatedMessageId,
}) {
  return workingDatabase.database.insert('messages', <String, Object?>{
    'ss_id': id,
    'guid': 'message-$id',
    'is_from_me': isFromMe ? 1 : 0,
    'date_utc': dateUtc,
    'text': text,
    'associated_message_ss_id': associatedMessageId,
  });
}

Future<void> _insertChatHandle(
  WorkingDatabase workingDatabase, {
  required int conversationId,
  required int handleId,
}) {
  return workingDatabase.database.insert('chat_to_handle', <String, Object?>{
    'chat_ss_id': conversationId,
    'handle_ss_id': handleId,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
}

Future<void> _insertChatMessage(
  WorkingDatabase workingDatabase, {
  required int conversationId,
  required int messageId,
}) {
  return workingDatabase.database.insert('chat_to_message', <String, Object?>{
    'chat_ss_id': conversationId,
    'message_ss_id': messageId,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
}
