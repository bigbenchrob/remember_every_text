import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/contact_graph_repository.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
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
    tempDir = await Directory.systemTemp.createTemp('contact_graph_test_');
    graphDatabase = await openConversationGraphTestDatabase();
  });

  tearDown(() async {
    await graphDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'resolves contact conversations through canonical handle aliases',
    () async {
      const contactId = 24;
      final chatId = _id(7);
      final canonicalHandleId = _id(101);
      final smsAliasHandleId = _id(102);
      final firstMessageId = _id(201);
      final secondMessageId = _id(202);
      final attachmentId = _id(301);

      await _insertContact(graphDatabase, contactId: contactId);
      await _insertHandle(
        graphDatabase,
        handleId: canonicalHandleId,
        value: '+16049995969-iMessage',
      );
      await _insertHandle(
        graphDatabase,
        handleId: smsAliasHandleId,
        value: '+16049995969-SMS',
      );
      await _insertCanonicalHandle(
        graphDatabase,
        canonicalHandleId: canonicalHandleId,
      );
      await _insertHandleAlias(
        graphDatabase,
        handleId: canonicalHandleId,
        canonicalHandleId: canonicalHandleId,
      );
      await _insertHandleAlias(
        graphDatabase,
        handleId: smsAliasHandleId,
        canonicalHandleId: canonicalHandleId,
      );
      await _insertContactHandle(
        graphDatabase,
        contactId: contactId,
        handleId: canonicalHandleId,
      );
      await _insertChat(graphDatabase, chatId: chatId);
      await _insertChatHandle(
        graphDatabase,
        chatId: chatId,
        handleId: smsAliasHandleId,
      );
      await _insertMessage(
        graphDatabase,
        messageId: firstMessageId,
        dateUtc: '2026-04-10T10:00:00.000Z',
        text: 'April',
      );
      await _insertMessage(
        graphDatabase,
        messageId: secondMessageId,
        dateUtc: '2026-05-10T10:00:00.000Z',
        text: 'May',
      );
      await _insertChatMessage(
        graphDatabase,
        chatId: chatId,
        messageId: firstMessageId,
      );
      await _insertChatMessage(
        graphDatabase,
        chatId: chatId,
        messageId: secondMessageId,
      );
      await _insertAttachment(graphDatabase, attachmentId: attachmentId);
      await _insertMessageAttachment(
        graphDatabase,
        messageId: secondMessageId,
        attachmentId: attachmentId,
      );

      final snapshot = await _reader(
        graphDatabase,
      ).readContactGraph(contactId: contactId);

      expect(snapshot.contactId, contactId);
      expect(snapshot.conversations, hasLength(1));
      expect(snapshot.conversations.single.conversationId, chatId);
      expect(snapshot.conversations.single.messageCount, 2);
      expect(snapshot.conversations.single.attachmentCount, 1);
      expect(snapshot.conversations.single.participantHandles, [
        '+16049995969',
      ]);
      expect(
        snapshot.messageActivity?.firstMessageAtUtc,
        '2026-04-10T10:00:00.000Z',
      );
      expect(
        snapshot.messageActivity?.lastMessageAtUtc,
        '2026-05-10T10:00:00.000Z',
      );
      expect(
        snapshot.messageActivity?.monthCounts.map(
          (month) => '${month.year}-${month.month}:${month.messageCount}',
        ),
        ['2026-4:1', '2026-5:1'],
      );

      final messages = await _reader(
        graphDatabase,
      ).readContactMessages(contactId: contactId);

      expect(messages.map((message) => message.messageId), [
        secondMessageId,
        firstMessageId,
      ]);
      expect(messages.first.text, 'May');
      expect(messages.first.attachmentCount, 1);
      expect(messages.last.text, 'April');

      final aprilMessages = await _reader(graphDatabase).readContactMessages(
        contactId: contactId,
        monthAnchor: DateTime.utc(2026, 4),
      );

      expect(aprilMessages.map((message) => message.messageId), [
        firstMessageId,
      ]);

      final timeline = await _reader(graphDatabase)
          .readContactPageMessageTimeline(
            contactId: contactId,
            graphContactId: contactId,
          );

      expect(timeline.map((entry) => entry.messageId), [
        firstMessageId,
        secondMessageId,
      ]);
      expect(timeline.map((entry) => entry.monthKey), ['2026-04', '2026-05']);

      final hydratedMessage = await _reader(graphDatabase)
          .readContactPageMessageById(
            contactId: contactId,
            graphContactId: contactId,
            messageId: secondMessageId,
          );

      expect(hydratedMessage?.text, 'May');
      expect(hydratedMessage?.attachmentCount, 1);
    },
  );

  test(
    'reads contact handle timeline through canonical graph handles',
    () async {
      const contactId = 24;
      final selectedChatId = _id(7);
      final otherChatId = _id(8);
      final selectedHandleId = _id(101);
      final selectedAliasHandleId = _id(102);
      final otherHandleId = _id(103);
      final selectedMessageId = _id(201);
      final otherMessageId = _id(202);

      await _insertContact(graphDatabase, contactId: contactId);
      await _insertHandle(
        graphDatabase,
        handleId: selectedHandleId,
        value: '+16049995969-iMessage',
      );
      await _insertHandle(
        graphDatabase,
        handleId: selectedAliasHandleId,
        value: '+16049995969-SMS',
      );
      await _insertHandle(
        graphDatabase,
        handleId: otherHandleId,
        value: '+17789908506-iMessage',
      );
      await _insertCanonicalHandle(
        graphDatabase,
        canonicalHandleId: selectedHandleId,
      );
      await _insertCanonicalHandle(
        graphDatabase,
        canonicalHandleId: otherHandleId,
        displayHandle: '+17789908506',
        normalizedIdentifier: '17789908506',
      );
      await _insertHandleAlias(
        graphDatabase,
        handleId: selectedHandleId,
        canonicalHandleId: selectedHandleId,
      );
      await _insertHandleAlias(
        graphDatabase,
        handleId: selectedAliasHandleId,
        canonicalHandleId: selectedHandleId,
      );
      await _insertHandleAlias(
        graphDatabase,
        handleId: otherHandleId,
        canonicalHandleId: otherHandleId,
        normalizedIdentifier: '17789908506',
      );
      await _insertContactHandle(
        graphDatabase,
        contactId: contactId,
        handleId: selectedHandleId,
      );
      await _insertContactHandle(
        graphDatabase,
        contactId: contactId,
        handleId: otherHandleId,
      );
      await _insertChat(graphDatabase, chatId: selectedChatId);
      await _insertChat(graphDatabase, chatId: otherChatId);
      await _insertChatHandle(
        graphDatabase,
        chatId: selectedChatId,
        handleId: selectedAliasHandleId,
      );
      await _insertChatHandle(
        graphDatabase,
        chatId: otherChatId,
        handleId: otherHandleId,
      );
      await _insertMessage(
        graphDatabase,
        messageId: selectedMessageId,
        dateUtc: '2026-05-10T10:00:00.000Z',
        text: 'selected handle message',
      );
      await _insertMessage(
        graphDatabase,
        messageId: otherMessageId,
        dateUtc: '2026-05-11T10:00:00.000Z',
        text: 'other handle message',
      );
      await _insertChatMessage(
        graphDatabase,
        chatId: selectedChatId,
        messageId: selectedMessageId,
      );
      await _insertChatMessage(
        graphDatabase,
        chatId: otherChatId,
        messageId: otherMessageId,
      );

      final timeline = await _reader(graphDatabase)
          .readContactPageHandleMessageTimeline(
            contactId: contactId,
            graphContactId: contactId,
            handleId: selectedHandleId,
          );
      final selectedMessage = await _reader(graphDatabase)
          .readContactPageHandleMessageById(
            contactId: contactId,
            graphContactId: contactId,
            handleId: selectedHandleId,
            messageId: selectedMessageId,
          );
      final otherMessage = await _reader(graphDatabase)
          .readContactPageHandleMessageById(
            contactId: contactId,
            graphContactId: contactId,
            handleId: selectedHandleId,
            messageId: otherMessageId,
          );

      expect(timeline.map((entry) => entry.messageId), [selectedMessageId]);
      expect(selectedMessage?.text, 'selected handle message');
      expect(otherMessage, isNull);
    },
  );

  test(
    'reads contact message ids matching text through canonical graph handles',
    () async {
      const contactId = 24;
      final chatId = _id(7);
      final canonicalHandleId = _id(101);
      final aliasHandleId = _id(102);
      final olderMessageId = _id(201);
      final newerMessageId = _id(202);
      final nonMatchingMessageId = _id(203);

      await _insertContact(graphDatabase, contactId: contactId);
      await _insertHandle(
        graphDatabase,
        handleId: canonicalHandleId,
        value: '+16049995969-iMessage',
      );
      await _insertHandle(
        graphDatabase,
        handleId: aliasHandleId,
        value: '+16049995969-SMS',
      );
      await _insertCanonicalHandle(
        graphDatabase,
        canonicalHandleId: canonicalHandleId,
      );
      await _insertHandleAlias(
        graphDatabase,
        handleId: canonicalHandleId,
        canonicalHandleId: canonicalHandleId,
      );
      await _insertHandleAlias(
        graphDatabase,
        handleId: aliasHandleId,
        canonicalHandleId: canonicalHandleId,
      );
      await _insertContactHandle(
        graphDatabase,
        contactId: contactId,
        handleId: canonicalHandleId,
      );
      await _insertChat(graphDatabase, chatId: chatId);
      await _insertChatHandle(
        graphDatabase,
        chatId: chatId,
        handleId: aliasHandleId,
      );
      await _insertMessage(
        graphDatabase,
        messageId: newerMessageId,
        dateUtc: '2026-05-10T10:00:00.000Z',
        text: 'newer settlement message',
      );
      await _insertMessage(
        graphDatabase,
        messageId: olderMessageId,
        dateUtc: '2026-04-10T10:00:00.000Z',
        text: 'older settlement message',
      );
      await _insertMessage(
        graphDatabase,
        messageId: nonMatchingMessageId,
        dateUtc: '2026-03-10T10:00:00.000Z',
        text: 'unrelated message',
      );
      await _insertChatMessage(
        graphDatabase,
        chatId: chatId,
        messageId: newerMessageId,
      );
      await _insertChatMessage(
        graphDatabase,
        chatId: chatId,
        messageId: olderMessageId,
      );
      await _insertChatMessage(
        graphDatabase,
        chatId: chatId,
        messageId: nonMatchingMessageId,
      );

      final matches = await _reader(graphDatabase)
          .readContactPageMessageIdsMatchingText(
            contactId: contactId,
            graphContactId: contactId,
            query: 'settlement',
          );

      expect(matches, [olderMessageId, newerMessageId]);
    },
  );

  test('reads handle-filtered contact message ids matching text', () async {
    const contactId = 24;
    final selectedChatId = _id(7);
    final otherChatId = _id(8);
    final selectedHandleId = _id(101);
    final selectedAliasHandleId = _id(102);
    final otherHandleId = _id(103);
    final selectedMessageId = _id(201);
    final otherMessageId = _id(202);

    await _insertContact(graphDatabase, contactId: contactId);
    await _insertHandle(
      graphDatabase,
      handleId: selectedHandleId,
      value: '+16049995969-iMessage',
    );
    await _insertHandle(
      graphDatabase,
      handleId: selectedAliasHandleId,
      value: '+16049995969-SMS',
    );
    await _insertHandle(
      graphDatabase,
      handleId: otherHandleId,
      value: '+17789908506-iMessage',
    );
    await _insertCanonicalHandle(
      graphDatabase,
      canonicalHandleId: selectedHandleId,
    );
    await _insertCanonicalHandle(
      graphDatabase,
      canonicalHandleId: otherHandleId,
      displayHandle: '+17789908506',
      normalizedIdentifier: '17789908506',
    );
    await _insertHandleAlias(
      graphDatabase,
      handleId: selectedHandleId,
      canonicalHandleId: selectedHandleId,
    );
    await _insertHandleAlias(
      graphDatabase,
      handleId: selectedAliasHandleId,
      canonicalHandleId: selectedHandleId,
    );
    await _insertHandleAlias(
      graphDatabase,
      handleId: otherHandleId,
      canonicalHandleId: otherHandleId,
      normalizedIdentifier: '17789908506',
    );
    await _insertContactHandle(
      graphDatabase,
      contactId: contactId,
      handleId: selectedHandleId,
    );
    await _insertContactHandle(
      graphDatabase,
      contactId: contactId,
      handleId: otherHandleId,
    );
    await _insertChat(graphDatabase, chatId: selectedChatId);
    await _insertChat(graphDatabase, chatId: otherChatId);
    await _insertChatHandle(
      graphDatabase,
      chatId: selectedChatId,
      handleId: selectedAliasHandleId,
    );
    await _insertChatHandle(
      graphDatabase,
      chatId: otherChatId,
      handleId: otherHandleId,
    );
    await _insertMessage(
      graphDatabase,
      messageId: selectedMessageId,
      dateUtc: '2026-05-10T10:00:00.000Z',
      text: 'settlement from selected handle',
    );
    await _insertMessage(
      graphDatabase,
      messageId: otherMessageId,
      dateUtc: '2026-05-11T10:00:00.000Z',
      text: 'settlement from other handle',
    );
    await _insertChatMessage(
      graphDatabase,
      chatId: selectedChatId,
      messageId: selectedMessageId,
    );
    await _insertChatMessage(
      graphDatabase,
      chatId: otherChatId,
      messageId: otherMessageId,
    );

    final matches = await _reader(graphDatabase)
        .readContactPageMessageIdsMatchingText(
          contactId: contactId,
          graphContactId: contactId,
          query: 'settlement',
          handleId: selectedHandleId,
        );

    expect(matches, [selectedMessageId]);
  });

  test('maps legacy AddressBook contact ids to graph contact ids', () {
    expect(
      graphContactIdForContactPage(24),
      SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: 24,
      ),
    );
    expect(graphContactIdForContactPage(1000000000), 1000000000);
  });
}

ContactGraphReader _reader(ConversationGraphDatabase graphDatabase) {
  return ContactGraphReader(
    repository: SqliteContactGraphRepository(graphDatabase: graphDatabase),
  );
}

int _id(int sourceRowId) {
  return SourceScopedRowKey.pack(sourceId: 1, sourceRowId: sourceRowId);
}

Future<void> _insertContact(
  ConversationGraphDatabase graphDatabase, {
  required int contactId,
}) {
  return graphDatabase.database.insert('contacts', <String, Object?>{
    'contact_id': contactId,
    'display_name': 'Cathie Campbell',
  });
}

Future<void> _insertHandle(
  ConversationGraphDatabase graphDatabase, {
  required int handleId,
  required String value,
}) {
  return graphDatabase.database.insert('handles', <String, Object?>{
    'ss_id': handleId,
    'id': value,
  });
}

Future<void> _insertCanonicalHandle(
  ConversationGraphDatabase graphDatabase, {
  required int canonicalHandleId,
  String displayHandle = '+16049995969',
  String normalizedIdentifier = '16049995969',
}) {
  return graphDatabase.database.insert('canonical_handles', <String, Object?>{
    'canonical_handle_ss_id': canonicalHandleId,
    'display_handle': displayHandle,
    'normalized_identifier': normalizedIdentifier,
    'alias_count': 2,
  });
}

Future<void> _insertHandleAlias(
  ConversationGraphDatabase graphDatabase, {
  required int handleId,
  required int canonicalHandleId,
  String normalizedIdentifier = '6049995969',
}) {
  return graphDatabase.database.insert('handle_aliases', <String, Object?>{
    'handle_ss_id': handleId,
    'canonical_handle_ss_id': canonicalHandleId,
    'raw_identifier': '$handleId',
    'normalized_identifier': normalizedIdentifier,
    'alias_kind': handleId == canonicalHandleId ? 'canonical' : 'variant',
  });
}

Future<void> _insertContactHandle(
  ConversationGraphDatabase graphDatabase, {
  required int contactId,
  required int handleId,
}) {
  return graphDatabase.database.insert('contact_to_handle', <String, Object?>{
    'contact_id': contactId,
    'handle_ss_id': handleId,
    'handle_value': '+16049995969',
  });
}

Future<void> _insertChat(
  ConversationGraphDatabase graphDatabase, {
  required int chatId,
}) {
  return graphDatabase.database.insert('chats', <String, Object?>{
    'ss_id': chatId,
    'guid': 'chat-$chatId',
    'is_group': 0,
  });
}

Future<void> _insertChatHandle(
  ConversationGraphDatabase graphDatabase, {
  required int chatId,
  required int handleId,
}) {
  return graphDatabase.database.insert('chat_to_handle', <String, Object?>{
    'chat_ss_id': chatId,
    'handle_ss_id': handleId,
  });
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

Future<void> _insertChatMessage(
  ConversationGraphDatabase graphDatabase, {
  required int chatId,
  required int messageId,
}) {
  return graphDatabase.database.insert('chat_to_message', <String, Object?>{
    'chat_ss_id': chatId,
    'message_ss_id': messageId,
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
