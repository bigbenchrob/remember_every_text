import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity.dart';
import 'package:remember_this_text/features/messages/infrastructure/repositories/graph_recovered_message_evidence_repository.dart';

void main() {
  group('GraphRecoveredMessageEvidenceRepository', () {
    late ConversationGraphDatabase graphDb;
    late GraphRecoveredMessageEvidenceRepository repository;

    setUp(() async {
      graphDb = ConversationGraphDatabase(NativeDatabase.memory());
      await graphDb.selectRows('SELECT COUNT(*) AS c FROM messages');
      repository = GraphRecoveredMessageEvidenceRepository(
        graphDb: graphDb,
        displayIdentityResolver: const DisplayIdentityResolver(
          identitiesByHandleKey: <String, ParticipantDisplayIdentity>{},
        ),
      );
    });

    tearDown(() async {
      await graphDb.close();
    });

    test('returns only graph messages without conversation topology', () async {
      final recoveredMessageId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 42,
      );
      final projectableMessageId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 43,
      );

      await _insertMessage(
        graphDb,
        messageId: recoveredMessageId,
        guid: 'recovered-guid',
        text: 'orphan row',
      );
      await _insertMessage(
        graphDb,
        messageId: projectableMessageId,
        guid: 'ordinary-guid',
        text: 'ordinary graph row',
      );
      await _insertChatTopology(
        graphDb,
        chatId: SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: 7,
        ),
        messageId: projectableMessageId,
      );

      final messages = await repository.watchMessages().first;

      expect(messages.map((message) => message.id), [recoveredMessageId]);
      expect(messages.single.text, 'orphan row');
    });

    test(
      'keeps duplicate GUID and overlapping ROWID occurrences distinct',
      () async {
        const archiveSourceId = 101;
        final liveMessageId = SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: 42,
        );
        final archiveMessageId = SourceScopedRowKey.pack(
          sourceId: archiveSourceId,
          sourceRowId: 42,
        );

        await _insertMessage(
          graphDb,
          messageId: liveMessageId,
          guid: 'same-guid',
          text: 'live occurrence',
        );
        await _insertMessage(
          graphDb,
          messageId: archiveMessageId,
          guid: 'same-guid',
          text: 'archive occurrence',
          dateUtc: '2012-05-20T10:00:00.000Z',
        );

        final messages = await repository.watchMessages().first;

        expect(messages, hasLength(2));
        expect(messages.map((message) => message.guid).toSet(), {'same-guid'});
        expect(messages.map((message) => message.id).toSet(), {
          liveMessageId,
          archiveMessageId,
        });
        expect(
          messages.map((message) {
            return SourceScopedRowKey.unpackSourceRowId(message.id);
          }).toSet(),
          {42},
        );
      },
    );

    test(
      'scopes direct and nearby no-handle outgoing rows to a contact',
      () async {
        final canonicalHandleId = SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: 5,
        );
        final rawHandleId = SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: 42,
        );
        await _insertHandle(
          graphDb,
          handleId: rawHandleId,
          canonicalHandleId: canonicalHandleId,
          rawIdentifier: '+16045550101',
          displayHandle: '1 (604) 555-0101',
        );
        await _insertContactHandle(
          graphDb,
          contactId: 24,
          handleId: canonicalHandleId,
          displayName: 'Cathie Campbell',
          handleValue: '1 (604) 555-0101',
        );

        await _insertMessage(
          graphDb,
          messageId: SourceScopedRowKey.pack(
            sourceId: liveChatDbSourceId,
            sourceRowId: 10,
          ),
          guid: 'direct',
          senderHandleId: rawHandleId,
          senderCanonicalHandleId: canonicalHandleId,
          text: 'direct incoming',
          isFromMe: false,
          dateUtc: '2026-05-20T10:00:00.000Z',
        );
        await _insertMessage(
          graphDb,
          messageId: SourceScopedRowKey.pack(
            sourceId: liveChatDbSourceId,
            sourceRowId: 11,
          ),
          guid: 'inferred',
          text: 'nearby outgoing',
          isFromMe: true,
          dateUtc: '2026-05-20T10:03:00.000Z',
        );
        await _insertMessage(
          graphDb,
          messageId: SourceScopedRowKey.pack(
            sourceId: liveChatDbSourceId,
            sourceRowId: 12,
          ),
          guid: 'too-late',
          text: 'outside inference window',
          isFromMe: true,
          dateUtc: '2026-05-20T10:30:00.000Z',
        );

        final messages = await repository
            .watchMessages(contactId: 24, scopedHandleIds: {canonicalHandleId})
            .first;

        expect(messages.map((message) => message.guid), ['direct', 'inferred']);
        expect(messages.first.contactName, 'Cathie Campbell');
        expect(messages.first.senderLabel, '1 (604) 555-0101');
        expect(messages.first.isInferred, isFalse);
        expect(messages.last.isInferred, isTrue);
      },
    );

    test(
      'uses display identity resolver for recovered contact labels',
      () async {
        const contactId = 24;
        final canonicalHandleId = SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: 5,
        );
        final rawHandleId = SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: 42,
        );
        repository = GraphRecoveredMessageEvidenceRepository(
          graphDb: graphDb,
          displayIdentityResolver: const DisplayIdentityResolver(
            identitiesByHandleKey: <String, ParticipantDisplayIdentity>{},
            identitiesByContactId: <int, ParticipantDisplayIdentity>{
              contactId: ParticipantDisplayIdentity(
                primaryLabel: 'Claire',
                source: DisplayIdentitySource.userOverride,
                isKnownContact: true,
                contactId: contactId,
              ),
            },
          ),
        );
        await _insertHandle(
          graphDb,
          handleId: rawHandleId,
          canonicalHandleId: canonicalHandleId,
          rawIdentifier: '+17789908506',
          displayHandle: '1 (778) 990-8506',
        );
        await _insertContactHandle(
          graphDb,
          contactId: contactId,
          handleId: canonicalHandleId,
          displayName: 'Claire Merriman Campbell',
          handleValue: '1 (778) 990-8506',
        );
        await _insertMessage(
          graphDb,
          messageId: SourceScopedRowKey.pack(
            sourceId: liveChatDbSourceId,
            sourceRowId: 60,
          ),
          guid: 'display-name',
          senderHandleId: rawHandleId,
          senderCanonicalHandleId: canonicalHandleId,
          text: 'recovered text',
          isFromMe: false,
        );

        final messages = await repository.watchMessages().first;

        expect(messages.single.contactName, 'Claire');
      },
    );

    test('preserves sparse and attachment-only evidence', () async {
      final sparseMessageId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 50,
      );
      final attachmentMessageId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 51,
      );
      final attachmentId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 88,
      );

      await _insertMessage(
        graphDb,
        messageId: sparseMessageId,
        guid: 'sparse',
        text: null,
        semanticKind: 'sparse-artifact',
        itemKind: 'unknown',
        isSparseArtifact: true,
      );
      await _insertMessage(
        graphDb,
        messageId: attachmentMessageId,
        guid: 'attachment-only',
        text: null,
        semanticKind: 'attachment-only',
        itemKind: 'attachment-only',
      );
      await _insertAttachment(
        graphDb,
        attachmentId: attachmentId,
        messageId: attachmentMessageId,
        filename: '~/Library/Messages/Attachments/photo.jpg',
        transferName: 'photo.jpg',
        mimeType: 'image/jpeg',
      );

      final messages = await repository.watchMessages().first;

      expect(messages.map((message) => message.guid), [
        'sparse',
        'attachment-only',
      ]);
      expect(
        messages.first.text,
        '(Sparse artifact: no preserved text or payload)',
      );
      expect(messages.last.text, '(No text content)');
      expect(messages.last.attachmentCount, 1);
      expect(messages.last.attachments.single.id, attachmentId);
      expect(messages.last.attachments.single.transferName, 'photo.jpg');
      expect(messages.last.attachments.single.localPath, contains('photo.jpg'));
    });
  });
}

Future<void> _insertMessage(
  ConversationGraphDatabase db, {
  required int messageId,
  required String guid,
  String? text = 'hello',
  String dateUtc = '2026-05-20T10:00:00.000Z',
  bool isFromMe = false,
  int? senderHandleId,
  int? senderCanonicalHandleId,
  String semanticKind = 'plain-text',
  String itemKind = 'text',
  bool isSparseArtifact = false,
}) {
  return db.executeSql(
    '''
    INSERT INTO messages (
      ss_id,
      guid,
      sender_handle_ss_id,
      sender_canonical_handle_ss_id,
      is_from_me,
      date_utc,
      text,
      semantic_kind,
      item_kind,
      is_sparse_artifact
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
    <Object?>[
      messageId,
      guid,
      senderHandleId,
      senderCanonicalHandleId,
      if (isFromMe) 1 else 0,
      dateUtc,
      text,
      semanticKind,
      itemKind,
      if (isSparseArtifact) 1 else 0,
    ],
  );
}

Future<void> _insertChatTopology(
  ConversationGraphDatabase db, {
  required int chatId,
  required int messageId,
}) async {
  await db.executeSql(
    '''
    INSERT INTO chats (
      ss_id,
      guid,
      is_group
    )
    VALUES (?, ?, 0)
    ''',
    <Object?>[chatId, 'chat-guid-$chatId'],
  );
  await db.executeSql(
    '''
    INSERT INTO chat_to_message (
      chat_ss_id,
      message_ss_id
    )
    VALUES (?, ?)
    ''',
    <Object?>[chatId, messageId],
  );
}

Future<void> _insertHandle(
  ConversationGraphDatabase db, {
  required int handleId,
  required int canonicalHandleId,
  required String rawIdentifier,
  required String displayHandle,
}) async {
  await db.executeSql(
    '''
    INSERT INTO handles (
      ss_id,
      id,
      service
    )
    VALUES (?, ?, 'iMessage')
    ''',
    <Object?>[handleId, rawIdentifier],
  );
  await db.executeSql(
    '''
    INSERT INTO canonical_handles (
      canonical_handle_ss_id,
      display_handle,
      normalized_identifier,
      service,
      alias_count
    )
    VALUES (?, ?, ?, 'iMessage', 1)
    ''',
    <Object?>[canonicalHandleId, displayHandle, rawIdentifier],
  );
  await db.executeSql(
    '''
    INSERT INTO handle_aliases (
      handle_ss_id,
      canonical_handle_ss_id,
      raw_identifier,
      normalized_identifier,
      alias_kind
    )
    VALUES (?, ?, ?, ?, 'exact')
    ''',
    <Object?>[handleId, canonicalHandleId, rawIdentifier, rawIdentifier],
  );
}

Future<void> _insertContactHandle(
  ConversationGraphDatabase db, {
  required int contactId,
  required int handleId,
  required String displayName,
  required String handleValue,
}) async {
  await db.executeSql(
    '''
    INSERT INTO contacts (
      contact_id,
      display_name
    )
    VALUES (?, ?)
    ''',
    <Object?>[contactId, displayName],
  );
  await db.executeSql(
    '''
    INSERT INTO contact_to_handle (
      contact_id,
      handle_ss_id,
      handle_value
    )
    VALUES (?, ?, ?)
    ''',
    <Object?>[contactId, handleId, handleValue],
  );
}

Future<void> _insertAttachment(
  ConversationGraphDatabase db, {
  required int attachmentId,
  required int messageId,
  required String filename,
  required String transferName,
  required String mimeType,
}) async {
  await db.executeSql(
    '''
    INSERT INTO attachments (
      ss_id,
      guid,
      filename,
      transfer_name,
      mime_type
    )
    VALUES (?, ?, ?, ?, ?)
    ''',
    <Object?>[
      attachmentId,
      'attachment-guid-$attachmentId',
      filename,
      transferName,
      mimeType,
    ],
  );
  await db.executeSql(
    '''
    INSERT INTO message_to_attachment (
      message_ss_id,
      attachment_ss_id
    )
    VALUES (?, ?)
    ''',
    <Object?>[messageId, attachmentId],
  );
}
