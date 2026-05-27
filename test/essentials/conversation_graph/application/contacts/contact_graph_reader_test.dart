import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/contact_graph_repository.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
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
    tempDir = await Directory.systemTemp.createTemp('contact_graph_test_');
    workingDatabase = await openConversationGraphTestDatabase();
  });

  tearDown(() async {
    await workingDatabase.close();
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

      await _insertContact(workingDatabase, contactId: contactId);
      await _insertHandle(
        workingDatabase,
        handleId: canonicalHandleId,
        value: '+16049995969-iMessage',
      );
      await _insertHandle(
        workingDatabase,
        handleId: smsAliasHandleId,
        value: '+16049995969-SMS',
      );
      await _insertCanonicalHandle(
        workingDatabase,
        canonicalHandleId: canonicalHandleId,
      );
      await _insertHandleAlias(
        workingDatabase,
        handleId: canonicalHandleId,
        canonicalHandleId: canonicalHandleId,
      );
      await _insertHandleAlias(
        workingDatabase,
        handleId: smsAliasHandleId,
        canonicalHandleId: canonicalHandleId,
      );
      await _insertContactHandle(
        workingDatabase,
        contactId: contactId,
        handleId: canonicalHandleId,
      );
      await _insertChat(workingDatabase, chatId: chatId);
      await _insertChatHandle(
        workingDatabase,
        chatId: chatId,
        handleId: smsAliasHandleId,
      );
      await _insertMessage(
        workingDatabase,
        messageId: firstMessageId,
        dateUtc: '2026-04-10T10:00:00.000Z',
        text: 'April',
      );
      await _insertMessage(
        workingDatabase,
        messageId: secondMessageId,
        dateUtc: '2026-05-10T10:00:00.000Z',
        text: 'May',
      );
      await _insertChatMessage(
        workingDatabase,
        chatId: chatId,
        messageId: firstMessageId,
      );
      await _insertChatMessage(
        workingDatabase,
        chatId: chatId,
        messageId: secondMessageId,
      );
      await _insertAttachment(workingDatabase, attachmentId: attachmentId);
      await _insertMessageAttachment(
        workingDatabase,
        messageId: secondMessageId,
        attachmentId: attachmentId,
      );

      final snapshot = await _reader(
        workingDatabase,
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
        workingDatabase,
      ).readContactMessages(contactId: contactId);

      expect(messages.map((message) => message.messageId), [
        secondMessageId,
        firstMessageId,
      ]);
      expect(messages.first.text, 'May');
      expect(messages.first.attachmentCount, 1);
      expect(messages.last.text, 'April');
    },
  );

  test(
    'resolves contact page conversations through legacy handle identity',
    () async {
      const legacyContactId = 24;
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: legacyContactId,
      );
      final chatId = _id(7);
      final canonicalHandleId = _id(101);
      final smsAliasHandleId = _id(102);
      final messageId = _id(201);
      final legacyDatabase = WorkingDatabase(NativeDatabase.memory());
      addTearDown(legacyDatabase.close);
      await legacyDatabase.customSelect('SELECT 1').get();
      await _insertLegacyContactHandleLink(
        legacyDatabase,
        contactId: legacyContactId,
      );

      await _insertHandle(
        workingDatabase,
        handleId: canonicalHandleId,
        value: '+16049995969-iMessage',
      );
      await _insertHandle(
        workingDatabase,
        handleId: smsAliasHandleId,
        value: '+16049995969-SMS',
      );
      await _insertCanonicalHandle(
        workingDatabase,
        canonicalHandleId: canonicalHandleId,
      );
      await _insertHandleAlias(
        workingDatabase,
        handleId: canonicalHandleId,
        canonicalHandleId: canonicalHandleId,
      );
      await _insertHandleAlias(
        workingDatabase,
        handleId: smsAliasHandleId,
        canonicalHandleId: canonicalHandleId,
      );
      await _insertChat(workingDatabase, chatId: chatId);
      await _insertChatHandle(
        workingDatabase,
        chatId: chatId,
        handleId: smsAliasHandleId,
      );
      await _insertMessage(
        workingDatabase,
        messageId: messageId,
        dateUtc: '2026-05-10T10:00:00.000Z',
        text: 'May',
      );
      await _insertChatMessage(
        workingDatabase,
        chatId: chatId,
        messageId: messageId,
      );

      final snapshot =
          await ContactGraphReader(
            repository: SqliteContactGraphRepository(
              workingDatabase: workingDatabase,
              legacyDatabase: legacyDatabase,
            ),
          ).readContactPageGraph(
            contactId: legacyContactId,
            graphContactId: graphContactId,
          );

      expect(snapshot.contactId, legacyContactId);
      expect(snapshot.conversations, hasLength(1));
      expect(snapshot.conversations.single.conversationId, chatId);
      expect(snapshot.conversations.single.messageCount, 1);
      expect(
        snapshot.messageActivity?.lastMessageAtUtc,
        '2026-05-10T10:00:00.000Z',
      );

      final messages =
          await ContactGraphReader(
            repository: SqliteContactGraphRepository(
              workingDatabase: workingDatabase,
              legacyDatabase: legacyDatabase,
            ),
          ).readContactPageMessages(
            contactId: legacyContactId,
            graphContactId: graphContactId,
          );

      expect(messages.map((message) => message.messageId), [messageId]);
      expect(messages.single.text, 'May');
    },
  );

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

ContactGraphReader _reader(ConversationGraphDatabase workingDatabase) {
  return ContactGraphReader(
    repository: SqliteContactGraphRepository(workingDatabase: workingDatabase),
  );
}

int _id(int sourceRowId) {
  return SourceScopedRowKey.pack(sourceId: 1, sourceRowId: sourceRowId);
}

Future<void> _insertContact(
  ConversationGraphDatabase workingDatabase, {
  required int contactId,
}) {
  return workingDatabase.database.insert('contacts', <String, Object?>{
    'contact_id': contactId,
    'display_name': 'Cathie Campbell',
  });
}

Future<void> _insertHandle(
  ConversationGraphDatabase workingDatabase, {
  required int handleId,
  required String value,
}) {
  return workingDatabase.database.insert('handles', <String, Object?>{
    'ss_id': handleId,
    'id': value,
  });
}

Future<void> _insertCanonicalHandle(
  ConversationGraphDatabase workingDatabase, {
  required int canonicalHandleId,
}) {
  return workingDatabase.database.insert('canonical_handles', <String, Object?>{
    'canonical_handle_ss_id': canonicalHandleId,
    'display_handle': '+16049995969',
    'normalized_identifier': '16049995969',
    'alias_count': 2,
  });
}

Future<void> _insertHandleAlias(
  ConversationGraphDatabase workingDatabase, {
  required int handleId,
  required int canonicalHandleId,
}) {
  return workingDatabase.database.insert('handle_aliases', <String, Object?>{
    'handle_ss_id': handleId,
    'canonical_handle_ss_id': canonicalHandleId,
    'raw_identifier': '$handleId',
    'normalized_identifier': '6049995969',
    'alias_kind': handleId == canonicalHandleId ? 'canonical' : 'variant',
  });
}

Future<void> _insertContactHandle(
  ConversationGraphDatabase workingDatabase, {
  required int contactId,
  required int handleId,
}) {
  return workingDatabase.database.insert('contact_to_handle', <String, Object?>{
    'contact_id': contactId,
    'handle_ss_id': handleId,
    'handle_value': '+16049995969',
  });
}

Future<void> _insertChat(
  ConversationGraphDatabase workingDatabase, {
  required int chatId,
}) {
  return workingDatabase.database.insert('chats', <String, Object?>{
    'ss_id': chatId,
    'guid': 'chat-$chatId',
    'is_group': 0,
  });
}

Future<void> _insertChatHandle(
  ConversationGraphDatabase workingDatabase, {
  required int chatId,
  required int handleId,
}) {
  return workingDatabase.database.insert('chat_to_handle', <String, Object?>{
    'chat_ss_id': chatId,
    'handle_ss_id': handleId,
  });
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

Future<void> _insertChatMessage(
  ConversationGraphDatabase workingDatabase, {
  required int chatId,
  required int messageId,
}) {
  return workingDatabase.database.insert('chat_to_message', <String, Object?>{
    'chat_ss_id': chatId,
    'message_ss_id': messageId,
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

Future<void> _insertLegacyContactHandleLink(
  WorkingDatabase database, {
  required int contactId,
}) async {
  await database.customStatement(
    '''
    INSERT INTO participants (
      id,
      original_name,
      display_name,
      short_name
    ) VALUES (?, ?, ?, ?)
    ''',
    <Object?>[contactId, 'Cathie Campbell', 'Cathie Campbell', 'Cathie'],
  );
  await database.customStatement(
    '''
    INSERT INTO handles_canonical (
      id,
      raw_identifier,
      display_name,
      compound_identifier,
      service
    ) VALUES (?, ?, ?, ?, ?)
    ''',
    <Object?>[
      12,
      '+16049995969',
      '+16049995969',
      '6049995969-iMessage',
      'iMessage',
    ],
  );
  await database.customStatement(
    '''
    INSERT INTO handle_to_participant (
      handle_id,
      participant_id
    ) VALUES (?, ?)
    ''',
    <Object?>[12, contactId],
  );
  await database.customStatement(
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
      13,
      12,
      '+16049995969',
      '6049995969-SMS',
      '6049995969',
      'SMS',
      'normalized_variant',
    ],
  );
}
