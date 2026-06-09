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
  late ConversationGraphDatabase graphDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'conversation_reader_test_',
    );
    graphDatabase = await openConversationGraphTestDatabase();
  });

  tearDown(() async {
    await graphDatabase.close();
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

    await _insertChat(graphDatabase, id: conversationId);
    await _insertHandle(graphDatabase, id: firstHandleId, handle: '+15551');
    await _insertHandle(graphDatabase, id: secondHandleId, handle: '+15552');
    await _insertChatHandle(
      graphDatabase,
      conversationId: conversationId,
      handleId: firstHandleId,
    );
    await _insertChatHandle(
      graphDatabase,
      conversationId: conversationId,
      handleId: secondHandleId,
    );
    await _insertMessage(
      graphDatabase,
      id: olderMessageId,
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'older',
    );
    await _insertMessage(
      graphDatabase,
      id: newerMessageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'newer',
    );
    await _insertChatMessage(
      graphDatabase,
      conversationId: conversationId,
      messageId: olderMessageId,
    );
    await _insertChatMessage(
      graphDatabase,
      conversationId: conversationId,
      messageId: newerMessageId,
    );
    await _insertAttachment(graphDatabase, id: _id(301));
    await _insertMessageAttachment(
      graphDatabase,
      messageId: newerMessageId,
      attachmentId: _id(301),
    );

    final overviews = await _reader(graphDatabase).readOverviews();

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

    await _insertChat(graphDatabase, id: conversationId);
    await _insertHandle(graphDatabase, id: senderHandleId, handle: '+15550101');
    await _insertCanonicalHandle(
      graphDatabase,
      id: senderCanonicalHandleId,
      displayHandle: '+15550101',
    );
    await _insertMessage(
      graphDatabase,
      id: associatedMessageId,
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'origin',
    );
    await _insertMessage(
      graphDatabase,
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
      graphDatabase,
      conversationId: conversationId,
      messageId: associatedMessageId,
    );
    await _insertChatMessage(
      graphDatabase,
      conversationId: conversationId,
      messageId: replyMessageId,
    );

    final messages = await _reader(
      graphDatabase,
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

  test('reads full conversation message timeline oldest first', () async {
    final conversationId = _id(7);
    final olderMessageId = _id(201);
    final newerMessageId = _id(202);

    await _insertChat(graphDatabase, id: conversationId);
    await _insertMessage(
      graphDatabase,
      id: newerMessageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'newer',
    );
    await _insertMessage(
      graphDatabase,
      id: olderMessageId,
      dateUtc: '2026-04-19T10:00:00.000Z',
      text: 'older',
    );
    await _insertChatMessage(
      graphDatabase,
      conversationId: conversationId,
      messageId: newerMessageId,
    );
    await _insertChatMessage(
      graphDatabase,
      conversationId: conversationId,
      messageId: olderMessageId,
    );

    final timeline = await _reader(
      graphDatabase,
    ).readMessageTimeline(conversationId: conversationId);

    expect(timeline.map((entry) => entry.messageId), [
      olderMessageId,
      newerMessageId,
    ]);
    expect(timeline.map((entry) => entry.monthKey), ['2026-04', '2026-05']);
  });

  test('hydrates one conversation message by scoped message id', () async {
    final conversationId = _id(7);
    final otherConversationId = _id(8);
    final messageId = _id(201);

    await _insertChat(graphDatabase, id: conversationId);
    await _insertChat(graphDatabase, id: otherConversationId);
    await _insertMessage(
      graphDatabase,
      id: messageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'scoped message',
    );
    await _insertChatMessage(
      graphDatabase,
      conversationId: conversationId,
      messageId: messageId,
    );

    final message = await _reader(
      graphDatabase,
    ).readMessageById(conversationId: conversationId, messageId: messageId);
    final missing = await _reader(graphDatabase).readMessageById(
      conversationId: otherConversationId,
      messageId: messageId,
    );

    expect(message?.messageId, messageId);
    expect(message?.text, 'scoped message');
    expect(missing, isNull);
  });

  test('reads full-scope conversation message ids matching text', () async {
    final conversationId = _id(7);
    final otherConversationId = _id(8);
    final olderMatchId = _id(201);
    final nonMatchId = _id(202);
    final newerMatchId = _id(203);
    final otherConversationMatchId = _id(204);

    await _insertChat(graphDatabase, id: conversationId);
    await _insertChat(graphDatabase, id: otherConversationId);
    await _insertMessage(
      graphDatabase,
      id: newerMatchId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'Settlement authority came later.',
    );
    await _insertMessage(
      graphDatabase,
      id: nonMatchId,
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'Different topic.',
    );
    await _insertMessage(
      graphDatabase,
      id: olderMatchId,
      dateUtc: '2026-05-18T10:00:00.000Z',
      text: 'Discussed settlement timing.',
    );
    await _insertMessage(
      graphDatabase,
      id: otherConversationMatchId,
      dateUtc: '2026-05-21T10:00:00.000Z',
      text: 'Settlement elsewhere.',
    );
    await _insertChatMessage(
      graphDatabase,
      conversationId: conversationId,
      messageId: newerMatchId,
    );
    await _insertChatMessage(
      graphDatabase,
      conversationId: conversationId,
      messageId: nonMatchId,
    );
    await _insertChatMessage(
      graphDatabase,
      conversationId: conversationId,
      messageId: olderMatchId,
    );
    await _insertChatMessage(
      graphDatabase,
      conversationId: otherConversationId,
      messageId: otherConversationMatchId,
    );

    final matches = await _reader(graphDatabase).readMessageIdsMatchingText(
      conversationId: conversationId,
      query: 'settlement',
    );

    expect(matches, [olderMatchId, newerMatchId]);
  });

  test('reads monthly activity traces with absolute message counts', () async {
    final conversationId = _id(7);
    final januaryMessageId = _id(201);
    final marchMessageId = _id(202);
    final secondMarchMessageId = _id(203);

    await _insertChat(graphDatabase, id: conversationId);
    await _insertMessage(
      graphDatabase,
      id: januaryMessageId,
      dateUtc: '2026-01-12T10:00:00.000Z',
      text: 'january',
    );
    await _insertMessage(
      graphDatabase,
      id: marchMessageId,
      dateUtc: '2026-03-01T10:00:00.000Z',
      text: 'march',
    );
    await _insertMessage(
      graphDatabase,
      id: secondMarchMessageId,
      dateUtc: '2026-03-20T10:00:00.000Z',
      text: 'later march',
    );
    await _insertChatMessage(
      graphDatabase,
      conversationId: conversationId,
      messageId: januaryMessageId,
    );
    await _insertChatMessage(
      graphDatabase,
      conversationId: conversationId,
      messageId: marchMessageId,
    );
    await _insertChatMessage(
      graphDatabase,
      conversationId: conversationId,
      messageId: secondMarchMessageId,
    );

    final traces = await _reader(
      graphDatabase,
    ).readActivityTraces(conversationIds: [conversationId]);

    final months = traces[conversationId]?.months;
    expect(months, isNotNull);
    expect(
      months!.map((month) => (month.year, month.month, month.messageCount)),
      [(2026, 1, 1), (2026, 2, 0), (2026, 3, 2)],
    );
  });

  test('keeps sparse graph messages visible', () async {
    final conversationId = _id(7);
    final sparseMessageId = _id(203);

    await _insertChat(graphDatabase, id: conversationId);
    await _insertMessage(
      graphDatabase,
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
      graphDatabase,
      conversationId: conversationId,
      messageId: sparseMessageId,
    );

    final messages = await _reader(
      graphDatabase,
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

    await _insertChat(graphDatabase, id: matchingConversationId);
    await _insertChat(graphDatabase, id: otherConversationId);
    await _insertMessage(
      graphDatabase,
      id: matchingMessageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'We discussed settlement timing.',
    );
    await _insertMessage(
      graphDatabase,
      id: newerMatchingMessageId,
      dateUtc: '2026-05-20T12:00:00.000Z',
      text: 'The settlement authority came later.',
    );
    await _insertMessage(
      graphDatabase,
      id: otherMessageId,
      dateUtc: '2026-05-20T11:00:00.000Z',
      text: 'Different topic.',
    );
    await _insertChatMessage(
      graphDatabase,
      conversationId: matchingConversationId,
      messageId: matchingMessageId,
    );
    await _insertChatMessage(
      graphDatabase,
      conversationId: matchingConversationId,
      messageId: newerMatchingMessageId,
    );
    await _insertChatMessage(
      graphDatabase,
      conversationId: otherConversationId,
      messageId: otherMessageId,
    );

    final matchingIds = await _reader(
      graphDatabase,
    ).readConversationIdsMatchingMessageText(query: 'settlement');

    expect(matchingIds, {matchingConversationId});

    final matches = await _reader(
      graphDatabase,
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

ConversationReader _reader(ConversationGraphDatabase graphDatabase) {
  return ConversationReader(
    repository: SqliteConversationRepository(graphDatabase: graphDatabase),
  );
}

int _id(int sourceRowId) {
  return SourceScopedRowKey.pack(sourceId: 1, sourceRowId: sourceRowId);
}

Future<void> _insertChat(
  ConversationGraphDatabase graphDatabase, {
  required int id,
}) {
  return graphDatabase.database.insert('chats', <String, Object?>{
    'ss_id': id,
    'guid': 'chat-$id',
    'is_group': 0,
  });
}

Future<void> _insertHandle(
  ConversationGraphDatabase graphDatabase, {
  required int id,
  required String handle,
}) {
  return graphDatabase.database.insert('handles', <String, Object?>{
    'ss_id': id,
    'id': handle,
  });
}

Future<void> _insertCanonicalHandle(
  ConversationGraphDatabase graphDatabase, {
  required int id,
  required String displayHandle,
}) {
  return graphDatabase.database.insert('canonical_handles', <String, Object?>{
    'canonical_handle_ss_id': id,
    'display_handle': displayHandle,
    'normalized_identifier': displayHandle,
    'alias_count': 1,
  });
}

Future<void> _insertMessage(
  ConversationGraphDatabase graphDatabase, {
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
  return graphDatabase.database.insert('messages', <String, Object?>{
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
  ConversationGraphDatabase graphDatabase, {
  required int conversationId,
  required int handleId,
}) {
  return graphDatabase.database.insert('chat_to_handle', <String, Object?>{
    'chat_ss_id': conversationId,
    'handle_ss_id': handleId,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
}

Future<void> _insertChatMessage(
  ConversationGraphDatabase graphDatabase, {
  required int conversationId,
  required int messageId,
}) {
  return graphDatabase.database.insert('chat_to_message', <String, Object?>{
    'chat_ss_id': conversationId,
    'message_ss_id': messageId,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
}

Future<void> _insertAttachment(
  ConversationGraphDatabase graphDatabase, {
  required int id,
}) {
  return graphDatabase.database.insert('attachments', <String, Object?>{
    'ss_id': id,
    'guid': 'attachment-$id',
  });
}

Future<void> _insertMessageAttachment(
  ConversationGraphDatabase graphDatabase, {
  required int messageId,
  required int attachmentId,
}) {
  return graphDatabase.database.insert(
    'message_to_attachment',
    <String, Object?>{
      'message_ss_id': messageId,
      'attachment_ss_id': attachmentId,
    },
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}
