import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/message_graph_repository.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

import '../../conversation_graph_test_database.dart';

void main() {
  late ConversationGraphDatabase graphDatabase;

  setUp(() async {
    graphDatabase = await openConversationGraphTestDatabase();
  });

  tearDown(() async {
    await graphDatabase.close();
  });

  test('reads full global message timeline oldest first', () async {
    final olderMessageId = _id(201);
    final newerMessageId = _id(202);

    await _insertMessage(
      graphDatabase,
      messageId: newerMessageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'newer',
    );
    await _insertMessage(
      graphDatabase,
      messageId: olderMessageId,
      dateUtc: '2026-04-19T10:00:00.000Z',
      text: 'older',
    );

    final timeline = await _reader(graphDatabase).readGlobalMessageTimeline();

    expect(timeline.map((entry) => entry.messageId), [
      olderMessageId,
      newerMessageId,
    ]);
    expect(timeline.map((entry) => entry.monthKey), ['2026-04', '2026-05']);
  });

  test('hydrates one global message by scoped message id', () async {
    final messageId = _id(201);
    final attachmentId = _id(301);

    await _insertMessage(
      graphDatabase,
      messageId: messageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'global message',
    );
    await _insertAttachment(graphDatabase, attachmentId: attachmentId);
    await _insertMessageAttachment(
      graphDatabase,
      messageId: messageId,
      attachmentId: attachmentId,
    );

    final message = await _reader(
      graphDatabase,
    ).readGlobalMessageById(messageId: messageId);
    final missing = await _reader(
      graphDatabase,
    ).readGlobalMessageById(messageId: _id(999));

    expect(message?.messageId, messageId);
    expect(message?.text, 'global message');
    expect(message?.attachmentCount, 1);
    expect(missing, isNull);
  });

  test('reads global message ids matching text terms oldest first', () async {
    final olderMessageId = _id(201);
    final newerMessageId = _id(202);
    final nonMatchingMessageId = _id(203);

    await _insertMessage(
      graphDatabase,
      messageId: newerMessageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'settlement offer follow up',
    );
    await _insertMessage(
      graphDatabase,
      messageId: olderMessageId,
      dateUtc: '2026-04-19T10:00:00.000Z',
      text: 'draft settlement terms',
    );
    await _insertMessage(
      graphDatabase,
      messageId: nonMatchingMessageId,
      dateUtc: '2026-03-18T10:00:00.000Z',
      text: 'unrelated message',
    );

    final matches = await _reader(
      graphDatabase,
    ).readGlobalMessageIdsMatchingText(query: 'settlement');

    expect(matches, [olderMessageId, newerMessageId]);
  });

  test('reads handle message timeline through canonical aliases', () async {
    final canonicalHandleId = _id(5);
    final aliasHandleId = _id(42);
    final otherHandleId = _id(77);
    final chatId = _id(301);
    final otherChatId = _id(302);
    final olderMessageId = _id(201);
    final newerMessageId = _id(202);
    final otherMessageId = _id(203);

    await _insertHandle(
      graphDatabase,
      handleId: canonicalHandleId,
      rawIdentifier: '+16049995969',
    );
    await _insertHandle(
      graphDatabase,
      handleId: aliasHandleId,
      rawIdentifier: '6049995969',
    );
    await _insertHandle(
      graphDatabase,
      handleId: otherHandleId,
      rawIdentifier: '+17789908506',
    );
    await _insertCanonicalHandle(
      graphDatabase,
      canonicalHandleId: canonicalHandleId,
    );
    await _insertHandleAlias(
      graphDatabase,
      handleId: canonicalHandleId,
      canonicalHandleId: canonicalHandleId,
      rawIdentifier: '+16049995969',
    );
    await _insertHandleAlias(
      graphDatabase,
      handleId: aliasHandleId,
      canonicalHandleId: canonicalHandleId,
      rawIdentifier: '6049995969',
    );
    await _insertMessage(
      graphDatabase,
      messageId: newerMessageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'newer alias chat',
    );
    await _insertMessage(
      graphDatabase,
      messageId: olderMessageId,
      dateUtc: '2026-04-19T10:00:00.000Z',
      text: 'older alias chat',
    );
    await _insertMessage(
      graphDatabase,
      messageId: otherMessageId,
      dateUtc: '2026-03-18T10:00:00.000Z',
      text: 'other chat',
    );
    await _insertChatToMessage(
      graphDatabase,
      chatId: chatId,
      messageId: newerMessageId,
    );
    await _insertChatToMessage(
      graphDatabase,
      chatId: chatId,
      messageId: olderMessageId,
    );
    await _insertChatToMessage(
      graphDatabase,
      chatId: otherChatId,
      messageId: otherMessageId,
    );
    await _insertChatToHandle(
      graphDatabase,
      chatId: chatId,
      handleId: aliasHandleId,
    );
    await _insertChatToHandle(
      graphDatabase,
      chatId: otherChatId,
      handleId: otherHandleId,
    );

    final timeline = await _reader(
      graphDatabase,
    ).readHandleMessageTimeline(handleId: canonicalHandleId);

    expect(timeline.map((entry) => entry.messageId), [
      olderMessageId,
      newerMessageId,
    ]);
    expect(timeline.map((entry) => entry.monthKey), ['2026-04', '2026-05']);
  });

  test('hydrates only messages inside the requested handle scope', () async {
    final handleId = _id(5);
    final chatId = _id(301);
    final inScopeMessageId = _id(201);
    final outOfScopeMessageId = _id(202);

    await _insertHandle(
      graphDatabase,
      handleId: handleId,
      rawIdentifier: '+16049995969',
    );
    await _insertMessage(
      graphDatabase,
      messageId: inScopeMessageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'in handle scope',
    );
    await _insertMessage(
      graphDatabase,
      messageId: outOfScopeMessageId,
      dateUtc: '2026-05-21T10:00:00.000Z',
      text: 'out of handle scope',
    );
    await _insertChatToMessage(
      graphDatabase,
      chatId: chatId,
      messageId: inScopeMessageId,
    );
    await _insertChatToHandle(
      graphDatabase,
      chatId: chatId,
      handleId: handleId,
    );

    final message = await _reader(
      graphDatabase,
    ).readHandleMessageById(handleId: handleId, messageId: inScopeMessageId);
    final missing = await _reader(
      graphDatabase,
    ).readHandleMessageById(handleId: handleId, messageId: outOfScopeMessageId);

    expect(message?.text, 'in handle scope');
    expect(missing, isNull);
  });

  test(
    'reads bounded conversation excerpt around graph message and conversation ids',
    () async {
      const sourceChatRowId = 301;
      const sourceMessageRowId = 202;
      final chatId = _id(sourceChatRowId);
      final beforeMessageId = _id(201);
      final selectedMessageId = _id(sourceMessageRowId);
      final afterMessageId = _id(203);
      final otherChatMessageId = _id(204);

      await _insertMessage(
        graphDatabase,
        messageId: beforeMessageId,
        dateUtc: '2026-05-20T10:00:00.000Z',
        text: 'before context',
      );
      await _insertMessage(
        graphDatabase,
        messageId: selectedMessageId,
        dateUtc: '2026-05-20T10:01:00.000Z',
        text: 'selected context',
      );
      await _insertMessage(
        graphDatabase,
        messageId: afterMessageId,
        dateUtc: '2026-05-20T10:02:00.000Z',
        text: 'after context',
      );
      await _insertMessage(
        graphDatabase,
        messageId: otherChatMessageId,
        dateUtc: '2026-05-20T10:03:00.000Z',
        text: 'other chat',
      );
      await _insertChatToMessage(
        graphDatabase,
        chatId: chatId,
        messageId: beforeMessageId,
      );
      await _insertChatToMessage(
        graphDatabase,
        chatId: chatId,
        messageId: selectedMessageId,
      );
      await _insertChatToMessage(
        graphDatabase,
        chatId: chatId,
        messageId: afterMessageId,
      );
      await _insertChatToMessage(
        graphDatabase,
        chatId: _id(302),
        messageId: otherChatMessageId,
      );

      final timeline = await _reader(graphDatabase)
          .readConversationExcerptTimeline(
            conversationId: chatId,
            anchorMessageId: selectedMessageId,
            beforeCount: 1,
            afterCount: 1,
          );
      final missing = await _reader(graphDatabase)
          .readConversationExcerptTimeline(
            conversationId: _id(999),
            anchorMessageId: selectedMessageId,
            beforeCount: 1,
            afterCount: 1,
          );

      expect(timeline.map((entry) => entry.messageId), [
        beforeMessageId,
        selectedMessageId,
        afterMessageId,
      ]);
      expect(missing, isEmpty);
    },
  );
}

MessageGraphReader _reader(ConversationGraphDatabase graphDatabase) {
  return MessageGraphReader(
    repository: SqliteMessageGraphRepository(graphDatabase: graphDatabase),
  );
}

int _id(int sourceRowId) {
  return SourceScopedRowKey.pack(sourceId: 1, sourceRowId: sourceRowId);
}

Future<void> _insertMessage(
  ConversationGraphDatabase graphDatabase, {
  required int messageId,
  required String dateUtc,
  required String text,
}) {
  return graphDatabase.database.insert('messages', <String, Object?>{
    'ss_id': messageId,
    'guid': 'message-$messageId',
    'is_from_me': 0,
    'date_utc': dateUtc,
    'text': text,
  });
}

Future<void> _insertAttachment(
  ConversationGraphDatabase graphDatabase, {
  required int attachmentId,
}) {
  return graphDatabase.database.insert('attachments', <String, Object?>{
    'ss_id': attachmentId,
    'guid': 'attachment-$attachmentId',
  });
}

Future<void> _insertMessageAttachment(
  ConversationGraphDatabase graphDatabase, {
  required int messageId,
  required int attachmentId,
}) {
  return graphDatabase.database.insert('message_to_attachment', {
    'message_ss_id': messageId,
    'attachment_ss_id': attachmentId,
  });
}

Future<void> _insertHandle(
  ConversationGraphDatabase graphDatabase, {
  required int handleId,
  required String rawIdentifier,
}) {
  return graphDatabase.database.insert('handles', <String, Object?>{
    'ss_id': handleId,
    'id': rawIdentifier,
  });
}

Future<void> _insertCanonicalHandle(
  ConversationGraphDatabase graphDatabase, {
  required int canonicalHandleId,
  String normalizedIdentifier = '16049995969',
}) {
  return graphDatabase.database.insert('canonical_handles', <String, Object?>{
    'canonical_handle_ss_id': canonicalHandleId,
    'display_handle': '+16049995969',
    'normalized_identifier': normalizedIdentifier,
    'alias_count': 2,
  });
}

Future<void> _insertHandleAlias(
  ConversationGraphDatabase graphDatabase, {
  required int handleId,
  required int canonicalHandleId,
  required String rawIdentifier,
  String normalizedIdentifier = '16049995969',
}) {
  return graphDatabase.database.insert('handle_aliases', <String, Object?>{
    'handle_ss_id': handleId,
    'canonical_handle_ss_id': canonicalHandleId,
    'raw_identifier': rawIdentifier,
    'normalized_identifier': normalizedIdentifier,
    'alias_kind': 'phone',
  });
}

Future<void> _insertChatToMessage(
  ConversationGraphDatabase graphDatabase, {
  required int chatId,
  required int messageId,
}) {
  return graphDatabase.database.insert('chat_to_message', <String, Object?>{
    'chat_ss_id': chatId,
    'message_ss_id': messageId,
  });
}

Future<void> _insertChatToHandle(
  ConversationGraphDatabase graphDatabase, {
  required int chatId,
  required int handleId,
}) {
  return graphDatabase.database.insert('chat_to_handle', <String, Object?>{
    'chat_ss_id': chatId,
    'handle_ss_id': handleId,
  });
}
