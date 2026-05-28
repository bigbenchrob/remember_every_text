import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/message_graph_repository.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

import '../../conversation_graph_test_database.dart';

void main() {
  late ConversationGraphDatabase workingDatabase;

  setUp(() async {
    workingDatabase = await openConversationGraphTestDatabase();
  });

  tearDown(() async {
    await workingDatabase.close();
  });

  test('reads full global message timeline oldest first', () async {
    final olderMessageId = _id(201);
    final newerMessageId = _id(202);

    await _insertMessage(
      workingDatabase,
      messageId: newerMessageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'newer',
    );
    await _insertMessage(
      workingDatabase,
      messageId: olderMessageId,
      dateUtc: '2026-04-19T10:00:00.000Z',
      text: 'older',
    );

    final timeline = await _reader(workingDatabase).readGlobalMessageTimeline();

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
      workingDatabase,
      messageId: messageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'global message',
    );
    await _insertAttachment(workingDatabase, attachmentId: attachmentId);
    await _insertMessageAttachment(
      workingDatabase,
      messageId: messageId,
      attachmentId: attachmentId,
    );

    final message = await _reader(
      workingDatabase,
    ).readGlobalMessageById(messageId: messageId);
    final missing = await _reader(
      workingDatabase,
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
      workingDatabase,
      messageId: newerMessageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'settlement offer follow up',
    );
    await _insertMessage(
      workingDatabase,
      messageId: olderMessageId,
      dateUtc: '2026-04-19T10:00:00.000Z',
      text: 'draft settlement terms',
    );
    await _insertMessage(
      workingDatabase,
      messageId: nonMatchingMessageId,
      dateUtc: '2026-03-18T10:00:00.000Z',
      text: 'unrelated message',
    );

    final matches = await _reader(
      workingDatabase,
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
      workingDatabase,
      handleId: canonicalHandleId,
      rawIdentifier: '+16049995969',
    );
    await _insertHandle(
      workingDatabase,
      handleId: aliasHandleId,
      rawIdentifier: '6049995969',
    );
    await _insertHandle(
      workingDatabase,
      handleId: otherHandleId,
      rawIdentifier: '+17789908506',
    );
    await _insertCanonicalHandle(
      workingDatabase,
      canonicalHandleId: canonicalHandleId,
    );
    await _insertHandleAlias(
      workingDatabase,
      handleId: canonicalHandleId,
      canonicalHandleId: canonicalHandleId,
      rawIdentifier: '+16049995969',
    );
    await _insertHandleAlias(
      workingDatabase,
      handleId: aliasHandleId,
      canonicalHandleId: canonicalHandleId,
      rawIdentifier: '6049995969',
    );
    await _insertMessage(
      workingDatabase,
      messageId: newerMessageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'newer alias chat',
    );
    await _insertMessage(
      workingDatabase,
      messageId: olderMessageId,
      dateUtc: '2026-04-19T10:00:00.000Z',
      text: 'older alias chat',
    );
    await _insertMessage(
      workingDatabase,
      messageId: otherMessageId,
      dateUtc: '2026-03-18T10:00:00.000Z',
      text: 'other chat',
    );
    await _insertChatToMessage(
      workingDatabase,
      chatId: chatId,
      messageId: newerMessageId,
    );
    await _insertChatToMessage(
      workingDatabase,
      chatId: chatId,
      messageId: olderMessageId,
    );
    await _insertChatToMessage(
      workingDatabase,
      chatId: otherChatId,
      messageId: otherMessageId,
    );
    await _insertChatToHandle(
      workingDatabase,
      chatId: chatId,
      handleId: aliasHandleId,
    );
    await _insertChatToHandle(
      workingDatabase,
      chatId: otherChatId,
      handleId: otherHandleId,
    );

    final timeline = await _reader(
      workingDatabase,
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
      workingDatabase,
      handleId: handleId,
      rawIdentifier: '+16049995969',
    );
    await _insertMessage(
      workingDatabase,
      messageId: inScopeMessageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'in handle scope',
    );
    await _insertMessage(
      workingDatabase,
      messageId: outOfScopeMessageId,
      dateUtc: '2026-05-21T10:00:00.000Z',
      text: 'out of handle scope',
    );
    await _insertChatToMessage(
      workingDatabase,
      chatId: chatId,
      messageId: inScopeMessageId,
    );
    await _insertChatToHandle(
      workingDatabase,
      chatId: chatId,
      handleId: handleId,
    );

    final message = await _reader(
      workingDatabase,
    ).readHandleMessageById(handleId: handleId, messageId: inScopeMessageId);
    final missing = await _reader(
      workingDatabase,
    ).readHandleMessageById(handleId: handleId, messageId: outOfScopeMessageId);

    expect(message?.text, 'in handle scope');
    expect(missing, isNull);
  });

  test('bridges legacy handle id to graph canonical handle identity', () async {
    const legacyHandleId = 38;
    final canonicalHandleId = _id(38);
    final aliasHandleId = _id(88);
    final chatId = _id(301);
    final messageId = _id(201);
    final legacyDatabase = WorkingDatabase(NativeDatabase.memory());
    addTearDown(legacyDatabase.close);
    await legacyDatabase.customSelect('SELECT 1').get();
    await legacyDatabase.customStatement(
      '''
      INSERT INTO handles_canonical_to_alias (
        source_handle_id,
        canonical_handle_id,
        raw_identifier,
        compound_identifier,
        normalized_identifier,
        service,
        alias_kind
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
      <Object?>[
        legacyHandleId,
        legacyHandleId,
        '+16048173537',
        '6048173537-iMessage',
        '6048173537',
        'iMessage',
        'canonical',
      ],
    );

    await _insertHandle(
      workingDatabase,
      handleId: canonicalHandleId,
      rawIdentifier: '+16048173537',
    );
    await _insertHandle(
      workingDatabase,
      handleId: aliasHandleId,
      rawIdentifier: '+16048173537',
    );
    await _insertCanonicalHandle(
      workingDatabase,
      canonicalHandleId: canonicalHandleId,
      normalizedIdentifier: '6048173537',
    );
    await _insertHandleAlias(
      workingDatabase,
      handleId: aliasHandleId,
      canonicalHandleId: canonicalHandleId,
      rawIdentifier: '+16048173537',
      normalizedIdentifier: '6048173537',
    );
    await _insertMessage(
      workingDatabase,
      messageId: messageId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'legacy bridged handle row',
    );
    await _insertChatToMessage(
      workingDatabase,
      chatId: chatId,
      messageId: messageId,
    );
    await _insertChatToHandle(
      workingDatabase,
      chatId: chatId,
      handleId: aliasHandleId,
    );

    final reader = MessageGraphReader(
      repository: SqliteMessageGraphRepository(
        workingDatabase: workingDatabase,
        legacyDatabase: legacyDatabase,
      ),
    );

    final timeline = await reader.readHandleMessageTimeline(
      handleId: legacyHandleId,
    );
    final message = await reader.readHandleMessageById(
      handleId: legacyHandleId,
      messageId: messageId,
    );

    expect(timeline.map((entry) => entry.messageId), [messageId]);
    expect(message?.text, 'legacy bridged handle row');
  });

  test(
    'reads bounded search context around legacy message and chat ids',
    () async {
      const legacyChatId = 301;
      const legacyMessageId = 202;
      final chatId = _id(legacyChatId);
      final beforeMessageId = _id(201);
      final selectedMessageId = _id(legacyMessageId);
      final afterMessageId = _id(203);
      final otherChatMessageId = _id(204);

      await _insertMessage(
        workingDatabase,
        messageId: beforeMessageId,
        dateUtc: '2026-05-20T10:00:00.000Z',
        text: 'before context',
      );
      await _insertMessage(
        workingDatabase,
        messageId: selectedMessageId,
        dateUtc: '2026-05-20T10:01:00.000Z',
        text: 'selected context',
      );
      await _insertMessage(
        workingDatabase,
        messageId: afterMessageId,
        dateUtc: '2026-05-20T10:02:00.000Z',
        text: 'after context',
      );
      await _insertMessage(
        workingDatabase,
        messageId: otherChatMessageId,
        dateUtc: '2026-05-20T10:03:00.000Z',
        text: 'other chat',
      );
      await _insertChatToMessage(
        workingDatabase,
        chatId: chatId,
        messageId: beforeMessageId,
      );
      await _insertChatToMessage(
        workingDatabase,
        chatId: chatId,
        messageId: selectedMessageId,
      );
      await _insertChatToMessage(
        workingDatabase,
        chatId: chatId,
        messageId: afterMessageId,
      );
      await _insertChatToMessage(
        workingDatabase,
        chatId: _id(302),
        messageId: otherChatMessageId,
      );

      final timeline = await _reader(workingDatabase)
          .readMessageContextTimeline(
            messageId: legacyMessageId,
            chatId: legacyChatId,
            beforeCount: 1,
            afterCount: 1,
          );
      final missing = await _reader(workingDatabase).readMessageContextTimeline(
        messageId: legacyMessageId,
        chatId: 999,
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

MessageGraphReader _reader(ConversationGraphDatabase workingDatabase) {
  return MessageGraphReader(
    repository: SqliteMessageGraphRepository(workingDatabase: workingDatabase),
  );
}

int _id(int sourceRowId) {
  return SourceScopedRowKey.pack(sourceId: 1, sourceRowId: sourceRowId);
}

Future<void> _insertMessage(
  ConversationGraphDatabase workingDatabase, {
  required int messageId,
  required String dateUtc,
  required String text,
}) {
  return workingDatabase.database.insert('messages', <String, Object?>{
    'ss_id': messageId,
    'guid': 'message-$messageId',
    'is_from_me': 0,
    'date_utc': dateUtc,
    'text': text,
  });
}

Future<void> _insertAttachment(
  ConversationGraphDatabase workingDatabase, {
  required int attachmentId,
}) {
  return workingDatabase.database.insert('attachments', <String, Object?>{
    'ss_id': attachmentId,
    'guid': 'attachment-$attachmentId',
  });
}

Future<void> _insertMessageAttachment(
  ConversationGraphDatabase workingDatabase, {
  required int messageId,
  required int attachmentId,
}) {
  return workingDatabase.database.insert('message_to_attachment', {
    'message_ss_id': messageId,
    'attachment_ss_id': attachmentId,
  });
}

Future<void> _insertHandle(
  ConversationGraphDatabase workingDatabase, {
  required int handleId,
  required String rawIdentifier,
}) {
  return workingDatabase.database.insert('handles', <String, Object?>{
    'ss_id': handleId,
    'id': rawIdentifier,
  });
}

Future<void> _insertCanonicalHandle(
  ConversationGraphDatabase workingDatabase, {
  required int canonicalHandleId,
  String normalizedIdentifier = '16049995969',
}) {
  return workingDatabase.database.insert('canonical_handles', <String, Object?>{
    'canonical_handle_ss_id': canonicalHandleId,
    'display_handle': '+16049995969',
    'normalized_identifier': normalizedIdentifier,
    'alias_count': 2,
  });
}

Future<void> _insertHandleAlias(
  ConversationGraphDatabase workingDatabase, {
  required int handleId,
  required int canonicalHandleId,
  required String rawIdentifier,
  String normalizedIdentifier = '16049995969',
}) {
  return workingDatabase.database.insert('handle_aliases', <String, Object?>{
    'handle_ss_id': handleId,
    'canonical_handle_ss_id': canonicalHandleId,
    'raw_identifier': rawIdentifier,
    'normalized_identifier': normalizedIdentifier,
    'alias_kind': 'phone',
  });
}

Future<void> _insertChatToMessage(
  ConversationGraphDatabase workingDatabase, {
  required int chatId,
  required int messageId,
}) {
  return workingDatabase.database.insert('chat_to_message', <String, Object?>{
    'chat_ss_id': chatId,
    'message_ss_id': messageId,
  });
}

Future<void> _insertChatToHandle(
  ConversationGraphDatabase workingDatabase, {
  required int chatId,
  required int handleId,
}) {
  return workingDatabase.database.insert('chat_to_handle', <String, Object?>{
    'chat_ss_id': chatId,
    'handle_ss_id': handleId,
  });
}
