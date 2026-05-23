import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/conversation_repository.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../conversation_graph_test_database.dart';

void main() {
  late Directory tempDir;
  late ConversationGraphDatabase workingDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'conversation_reader_test_',
    );
    workingDatabase = await openConversationGraphTestDatabase();
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
    await _insertAttachment(workingDatabase, id: _id(301));
    await _insertMessageAttachment(
      workingDatabase,
      messageId: newerMessageId,
      attachmentId: _id(301),
    );

    final overviews = await _reader(workingDatabase).readOverviews();

    expect(overviews, hasLength(1));
    expect(overviews.single.conversationId, conversationId);
    expect(overviews.single.participantHandles, ['+15551', '+15552']);
    expect(overviews.single.participantCount, 2);
    expect(overviews.single.isGroup, isTrue);
    expect(overviews.single.messageCount, 2);
    expect(overviews.single.attachmentCount, 1);
    expect(overviews.single.lastMessageAtUtc, '2026-05-20T10:00:00.000Z');
    expect(overviews.single.lastMessageText, 'newer');
  });

  test('reads conversation messages newest first', () async {
    final conversationId = _id(7);
    final senderHandleId = _id(101);
    final senderCanonicalHandleId = _id(111);
    final associatedMessageId = _id(201);
    final replyMessageId = _id(202);

    await _insertChat(workingDatabase, id: conversationId);
    await _insertHandle(
      workingDatabase,
      id: senderHandleId,
      handle: '+15550101',
    );
    await _insertCanonicalHandle(
      workingDatabase,
      id: senderCanonicalHandleId,
      displayHandle: '+15550101',
    );
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
      senderHandleId: senderHandleId,
      senderCanonicalHandleId: senderCanonicalHandleId,
      semanticKind: 'reaction',
      itemKind: 'associated',
      hasAttributedBodySource: true,
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

    final messages = await _reader(
      workingDatabase,
    ).readMessages(conversationId: conversationId);

    expect(messages.map((message) => message.messageId), [
      replyMessageId,
      associatedMessageId,
    ]);
    expect(messages.first.isFromMe, isTrue);
    expect(messages.first.text, 'reply');
    expect(messages.first.associatedMessageId, associatedMessageId);
    expect(messages.first.attachmentCount, 0);
    expect(messages.first.senderHandleId, senderHandleId);
    expect(messages.first.senderCanonicalHandleId, senderCanonicalHandleId);
    expect(messages.first.senderDisplayHandle, '+15550101');
    expect(messages.first.semanticKind, 'reaction');
    expect(messages.first.itemKind, 'associated');
    expect(messages.first.hasAttributedBodySource, isTrue);
    expect(messages.first.isSystemMessage, isFalse);
  });

  test('keeps sparse graph messages visible', () async {
    final conversationId = _id(7);
    final sparseMessageId = _id(203);

    await _insertChat(workingDatabase, id: conversationId);
    await _insertMessage(
      workingDatabase,
      id: sparseMessageId,
      dateUtc: '2026-05-21T10:00:00.000Z',
      text: null,
      isSystemMessage: true,
      isSparseArtifact: true,
      hasMessageSummaryInfo: true,
      hasPayloadDataSource: true,
      errorCode: 42,
    );
    await _insertChatMessage(
      workingDatabase,
      conversationId: conversationId,
      messageId: sparseMessageId,
    );

    final messages = await _reader(
      workingDatabase,
    ).readMessages(conversationId: conversationId);

    expect(messages, hasLength(1));
    expect(messages.single.messageId, sparseMessageId);
    expect(messages.single.text, isNull);
    expect(messages.single.isSystemMessage, isTrue);
    expect(messages.single.isSparseArtifact, isTrue);
    expect(messages.single.hasMessageSummaryInfo, isTrue);
    expect(messages.single.hasPayloadDataSource, isTrue);
    expect(messages.single.errorCode, 42);
  });

  test('reads conversation ids matching message text', () async {
    final matchingConversationId = _id(7);
    final otherConversationId = _id(8);
    final matchingMessageId = _id(201);
    final newerMatchingMessageId = _id(203);
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
      id: newerMatchingMessageId,
      dateUtc: '2026-05-20T12:00:00.000Z',
      text: 'The settlement authority came later.',
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
      conversationId: matchingConversationId,
      messageId: newerMatchingMessageId,
    );
    await _insertChatMessage(
      workingDatabase,
      conversationId: otherConversationId,
      messageId: otherMessageId,
    );

    final matchingIds = await _reader(
      workingDatabase,
    ).readConversationIdsMatchingMessageText(query: 'settlement');

    expect(matchingIds, {matchingConversationId});

    final matches = await _reader(
      workingDatabase,
    ).readConversationMessageTextMatches(query: 'settlement');

    expect(matches.keys, {matchingConversationId});
    expect(matches[matchingConversationId]?.matchCount, 2);
    expect(
      matches[matchingConversationId]?.sampleText,
      'The settlement authority came later.',
    );
    expect(
      matches[matchingConversationId]?.snippets.map(
        (snippet) => snippet.messageId,
      ),
      [newerMatchingMessageId, matchingMessageId],
    );
  });
}

ConversationReader _reader(ConversationGraphDatabase workingDatabase) {
  return ConversationReader(
    repository: SqliteConversationRepository(workingDatabase: workingDatabase),
  );
}

int _id(int sourceRowId) {
  return SourceScopedRowKey.pack(sourceId: 1, sourceRowId: sourceRowId);
}

Future<void> _insertChat(
  ConversationGraphDatabase workingDatabase, {
  required int id,
}) {
  return workingDatabase.database.insert('chats', <String, Object?>{
    'ss_id': id,
    'guid': 'chat-$id',
    'is_group': 0,
  });
}

Future<void> _insertHandle(
  ConversationGraphDatabase workingDatabase, {
  required int id,
  required String handle,
}) {
  return workingDatabase.database.insert('handles', <String, Object?>{
    'ss_id': id,
    'id': handle,
  });
}

Future<void> _insertCanonicalHandle(
  ConversationGraphDatabase workingDatabase, {
  required int id,
  required String displayHandle,
}) {
  return workingDatabase.database.insert('canonical_handles', <String, Object?>{
    'canonical_handle_ss_id': id,
    'display_handle': displayHandle,
    'normalized_identifier': displayHandle,
    'alias_count': 1,
  });
}

Future<void> _insertMessage(
  ConversationGraphDatabase workingDatabase, {
  required int id,
  required String dateUtc,
  required String? text,
  bool isFromMe = false,
  int? associatedMessageId,
  int? senderHandleId,
  int? senderCanonicalHandleId,
  String? semanticKind,
  String? itemKind,
  bool isSystemMessage = false,
  bool isSparseArtifact = false,
  bool hasAttributedBodySource = false,
  bool hasMessageSummaryInfo = false,
  bool hasPayloadDataSource = false,
  int? errorCode,
}) {
  return workingDatabase.database.insert('messages', <String, Object?>{
    'ss_id': id,
    'guid': 'message-$id',
    'sender_handle_ss_id': senderHandleId,
    'is_from_me': isFromMe ? 1 : 0,
    'date_utc': dateUtc,
    'text': text,
    'associated_message_ss_id': associatedMessageId,
    'sender_canonical_handle_ss_id': senderCanonicalHandleId,
    'semantic_kind': semanticKind,
    'item_kind': itemKind,
    'is_system_message': isSystemMessage ? 1 : 0,
    'is_sparse_artifact': isSparseArtifact ? 1 : 0,
    'has_attributed_body_source': hasAttributedBodySource ? 1 : 0,
    'has_message_summary_info': hasMessageSummaryInfo ? 1 : 0,
    'has_payload_data_source': hasPayloadDataSource ? 1 : 0,
    'error_code': errorCode,
  });
}

Future<void> _insertChatHandle(
  ConversationGraphDatabase workingDatabase, {
  required int conversationId,
  required int handleId,
}) {
  return workingDatabase.database.insert('chat_to_handle', <String, Object?>{
    'chat_ss_id': conversationId,
    'handle_ss_id': handleId,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
}

Future<void> _insertChatMessage(
  ConversationGraphDatabase workingDatabase, {
  required int conversationId,
  required int messageId,
}) {
  return workingDatabase.database.insert('chat_to_message', <String, Object?>{
    'chat_ss_id': conversationId,
    'message_ss_id': messageId,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
}

Future<void> _insertAttachment(
  ConversationGraphDatabase workingDatabase, {
  required int id,
}) {
  return workingDatabase.database.insert('attachments', <String, Object?>{
    'ss_id': id,
    'guid': 'attachment-$id',
  });
}

Future<void> _insertMessageAttachment(
  ConversationGraphDatabase workingDatabase, {
  required int messageId,
  required int attachmentId,
}) {
  return workingDatabase.database.insert(
    'message_to_attachment',
    <String, Object?>{
      'message_ss_id': messageId,
      'attachment_ss_id': attachmentId,
    },
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}
