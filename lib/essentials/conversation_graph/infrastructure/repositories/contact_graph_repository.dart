import 'package:drift/drift.dart';

import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../../application/contacts/contact_graph.dart';
import '../../application/contacts/contact_graph_repository.dart';
import '../../application/conversations/conversation.dart';

class SqliteContactGraphRepository implements ContactGraphRepository {
  const SqliteContactGraphRepository({
    required this.workingDatabase,
    this.legacyDatabase,
  });

  final ConversationGraphDatabase workingDatabase;
  final WorkingDatabase? legacyDatabase;

  @override
  Future<ContactGraphSnapshot> readContactGraph({
    required int contactId,
  }) async {
    return ContactGraphSnapshot(
      contactId: contactId,
      conversations: await _readContactConversations(contactId),
      messageActivity: await _readContactMessageActivity(contactId),
    );
  }

  @override
  Future<ContactGraphSnapshot> readContactPageGraph({
    required int contactId,
    required int graphContactId,
  }) async {
    final graphSnapshot = await readContactGraph(contactId: graphContactId);
    if (_hasGraphEvidence(graphSnapshot)) {
      return ContactGraphSnapshot(
        contactId: contactId,
        conversations: graphSnapshot.conversations,
        messageActivity: graphSnapshot.messageActivity,
      );
    }

    if (graphContactId != contactId) {
      final directSnapshot = await readContactGraph(contactId: contactId);
      if (_hasGraphEvidence(directSnapshot)) {
        return directSnapshot;
      }
    }

    final canonicalHandleIds =
        await _readGraphCanonicalHandleIdsForLegacyContact(contactId);
    if (canonicalHandleIds.isEmpty) {
      return ContactGraphSnapshot(
        contactId: contactId,
        conversations: const <ConversationOverview>[],
        messageActivity: null,
      );
    }

    return ContactGraphSnapshot(
      contactId: contactId,
      conversations: await _readContactConversationsForCanonicalHandles(
        canonicalHandleIds,
      ),
      messageActivity: await _readContactMessageActivityForCanonicalHandles(
        canonicalHandleIds,
      ),
    );
  }

  Future<List<ConversationOverview>> _readContactConversations(int contactId) {
    return _readContactConversationsWhere(
      '''
      EXISTS (
        SELECT 1
        FROM chat_to_handle contact_chat_handle
        JOIN handle_aliases contact_alias
          ON contact_alias.handle_ss_id = contact_chat_handle.handle_ss_id
        JOIN contact_to_handle contact_handle
          ON contact_handle.handle_ss_id =
            contact_alias.canonical_handle_ss_id
        WHERE contact_chat_handle.chat_ss_id = c.ss_id
          AND contact_handle.contact_id = ?
      )
      ''',
      <Object?>[contactId],
    );
  }

  @override
  Future<List<ConversationMessage>> readContactMessages({
    required int contactId,
    int limit = 500,
  }) {
    return _readContactMessagesWhere(
      '''
      contact_handle.contact_id = ?
      ''',
      '''
      JOIN contact_to_handle contact_handle
        ON contact_handle.handle_ss_id = COALESCE(
          contact_alias.canonical_handle_ss_id,
          contact_chat_handle.handle_ss_id
        )
      ''',
      <Object?>[contactId],
      limit: limit,
    );
  }

  @override
  Future<List<ConversationMessage>> readContactPageMessages({
    required int contactId,
    required int graphContactId,
    int limit = 500,
  }) async {
    final graphMessages = await readContactMessages(
      contactId: graphContactId,
      limit: limit,
    );
    if (graphMessages.isNotEmpty) {
      return graphMessages;
    }

    if (graphContactId != contactId) {
      final directMessages = await readContactMessages(
        contactId: contactId,
        limit: limit,
      );
      if (directMessages.isNotEmpty) {
        return directMessages;
      }
    }

    final canonicalHandleIds =
        await _readGraphCanonicalHandleIdsForLegacyContact(contactId);
    if (canonicalHandleIds.isEmpty) {
      return const <ConversationMessage>[];
    }

    return _readContactMessagesForCanonicalHandles(
      canonicalHandleIds,
      limit: limit,
    );
  }

  Future<List<ConversationOverview>>
  _readContactConversationsForCanonicalHandles(List<int> canonicalHandleIds) {
    return _readContactConversationsWhere('''
      EXISTS (
        SELECT 1
        FROM chat_to_handle contact_chat_handle
        LEFT JOIN handle_aliases contact_alias
          ON contact_alias.handle_ss_id = contact_chat_handle.handle_ss_id
        WHERE contact_chat_handle.chat_ss_id = c.ss_id
          AND COALESCE(
            contact_alias.canonical_handle_ss_id,
            contact_chat_handle.handle_ss_id
          ) IN (${_placeholders(canonicalHandleIds.length)})
      )
      ''', canonicalHandleIds);
  }

  Future<List<ConversationMessage>> _readContactMessagesForCanonicalHandles(
    List<int> canonicalHandleIds, {
    required int limit,
  }) {
    return _readContactMessagesWhere(
      '''
      COALESCE(
        contact_alias.canonical_handle_ss_id,
        contact_chat_handle.handle_ss_id
      ) IN (${_placeholders(canonicalHandleIds.length)})
      ''',
      '',
      canonicalHandleIds,
      limit: limit,
    );
  }

  Future<List<ConversationOverview>> _readContactConversationsWhere(
    String whereClause,
    List<Object?> args,
  ) async {
    final rows = await workingDatabase.selectRows('''
      SELECT
        c.ss_id AS conversation_id,
        COUNT(DISTINCT COALESCE(ha.canonical_handle_ss_id, cth.handle_ss_id))
          AS participant_count,
        COUNT(DISTINCT ctm.message_ss_id) AS message_count,
        COUNT(DISTINCT mta.attachment_ss_id) AS attachment_count,
        MIN(m.date_utc) AS first_message_at_utc,
        MAX(m.date_utc) AS last_message_at_utc,
        (
          SELECT m2.text
          FROM chat_to_message ctm2
          JOIN messages m2 ON m2.ss_id = ctm2.message_ss_id
          WHERE ctm2.chat_ss_id = c.ss_id
            AND m2.text IS NOT NULL
            AND m2.text != ''
          ORDER BY COALESCE(m2.date_utc, '') DESC, m2.ss_id DESC
          LIMIT 1
        ) AS last_message_text
      FROM chats c
      LEFT JOIN chat_to_handle cth ON cth.chat_ss_id = c.ss_id
      LEFT JOIN handle_aliases ha ON ha.handle_ss_id = cth.handle_ss_id
      LEFT JOIN chat_to_message ctm ON ctm.chat_ss_id = c.ss_id
      LEFT JOIN messages m ON m.ss_id = ctm.message_ss_id
      LEFT JOIN message_to_attachment mta ON mta.message_ss_id = m.ss_id
      WHERE $whereClause
      GROUP BY c.ss_id
      ORDER BY COALESCE(last_message_at_utc, '') DESC, c.ss_id ASC
      ''', args);

    return [
      for (final row in rows)
        ConversationOverview(
          conversationId: _readInt(row['conversation_id']),
          participantHandles: await _readParticipantHandles(
            _readInt(row['conversation_id']),
          ),
          participantCount: _readInt(row['participant_count']),
          isGroup: _readInt(row['participant_count']) > 1,
          messageCount: _readInt(row['message_count']),
          attachmentCount: _readInt(row['attachment_count']),
          firstMessageAtUtc: row['first_message_at_utc'] as String?,
          lastMessageAtUtc: row['last_message_at_utc'] as String?,
          lastMessageText: row['last_message_text'] as String?,
        ),
    ];
  }

  Future<List<ConversationMessage>> _readContactMessagesWhere(
    String whereClause,
    String extraJoin,
    List<Object?> args, {
    required int limit,
  }) async {
    final rows = await workingDatabase.selectRows(
      '''
      SELECT DISTINCT
        m.ss_id AS message_id,
        m.date_utc,
        m.is_from_me,
        m.text,
        m.associated_message_ss_id,
        m.sender_handle_ss_id,
        m.sender_canonical_handle_ss_id,
        COALESCE(sender_canonical.display_handle, sender_handle.id)
          AS sender_display_handle,
        m.semantic_kind,
        m.item_kind,
        m.is_system_message,
        m.is_sparse_artifact,
        m.has_attributed_body_source,
        m.has_message_summary_info,
        m.has_payload_data_source,
        m.error_code,
        (
          SELECT COUNT(*)
          FROM message_to_attachment mta
          WHERE mta.message_ss_id = m.ss_id
        ) AS attachment_count
      FROM messages m
      JOIN chat_to_message ctm ON ctm.message_ss_id = m.ss_id
      JOIN chat_to_handle contact_chat_handle
        ON contact_chat_handle.chat_ss_id = ctm.chat_ss_id
      LEFT JOIN handle_aliases contact_alias
        ON contact_alias.handle_ss_id = contact_chat_handle.handle_ss_id
      $extraJoin
      LEFT JOIN handles sender_handle ON sender_handle.ss_id =
        m.sender_handle_ss_id
      LEFT JOIN canonical_handles sender_canonical
        ON sender_canonical.canonical_handle_ss_id =
          m.sender_canonical_handle_ss_id
      WHERE $whereClause
      ORDER BY COALESCE(m.date_utc, '') DESC, m.ss_id DESC
      LIMIT ?
      ''',
      <Object?>[...args, limit],
    );

    return [
      for (final row in rows)
        ConversationMessage(
          messageId: _readInt(row['message_id']),
          dateUtc: row['date_utc'] as String?,
          isFromMe: _readInt(row['is_from_me']) == 1,
          text: row['text'] as String?,
          associatedMessageId: _readNullableInt(
            row['associated_message_ss_id'],
          ),
          attachmentCount: _readInt(row['attachment_count']),
          senderHandleId: _readNullableInt(row['sender_handle_ss_id']),
          senderCanonicalHandleId: _readNullableInt(
            row['sender_canonical_handle_ss_id'],
          ),
          senderDisplayHandle: row['sender_display_handle'] as String?,
          semanticKind: row['semantic_kind'] as String?,
          itemKind: row['item_kind'] as String?,
          isSystemMessage: _readInt(row['is_system_message']) == 1,
          isSparseArtifact: _readInt(row['is_sparse_artifact']) == 1,
          hasAttributedBodySource:
              _readInt(row['has_attributed_body_source']) == 1,
          hasMessageSummaryInfo: _readInt(row['has_message_summary_info']) == 1,
          hasPayloadDataSource: _readInt(row['has_payload_data_source']) == 1,
          errorCode: _readNullableInt(row['error_code']),
        ),
    ];
  }

  Future<ContactMessageActivity?> _readContactMessageActivity(int contactId) {
    return _readContactMessageActivityWhere(
      '''
      contact_handle.contact_id = ?
      ''',
      '''
      JOIN contact_to_handle contact_handle
        ON contact_handle.handle_ss_id = ha.canonical_handle_ss_id
      ''',
      <Object?>[contactId],
    );
  }

  Future<ContactMessageActivity?>
  _readContactMessageActivityForCanonicalHandles(List<int> canonicalHandleIds) {
    return _readContactMessageActivityWhere(
      '''
      COALESCE(ha.canonical_handle_ss_id, ch.handle_ss_id)
        IN (${_placeholders(canonicalHandleIds.length)})
      ''',
      '',
      canonicalHandleIds,
    );
  }

  Future<ContactMessageActivity?> _readContactMessageActivityWhere(
    String whereClause,
    String extraJoin,
    List<Object?> args,
  ) async {
    final dateRows = await workingDatabase.selectRows('''
      WITH contact_messages AS (
        SELECT DISTINCT m.ss_id, m.date_utc
        FROM messages m
        JOIN chat_to_message ctm ON ctm.message_ss_id = m.ss_id
        JOIN chat_to_handle ch ON ch.chat_ss_id = ctm.chat_ss_id
        LEFT JOIN handle_aliases ha ON ha.handle_ss_id = ch.handle_ss_id
        $extraJoin
        WHERE $whereClause
          AND m.date_utc IS NOT NULL
          AND m.date_utc != ''
      )
      SELECT
        MIN(date_utc) AS first_message_at_utc,
        MAX(date_utc) AS last_message_at_utc
      FROM contact_messages
      ''', args);
    final firstMessageAtUtc =
        dateRows.single['first_message_at_utc'] as String?;
    final lastMessageAtUtc = dateRows.single['last_message_at_utc'] as String?;
    if (firstMessageAtUtc == null ||
        firstMessageAtUtc.isEmpty ||
        lastMessageAtUtc == null ||
        lastMessageAtUtc.isEmpty) {
      return null;
    }

    final monthRows = await workingDatabase.selectRows('''
      WITH contact_messages AS (
        SELECT DISTINCT m.ss_id, m.date_utc
        FROM messages m
        JOIN chat_to_message ctm ON ctm.message_ss_id = m.ss_id
        JOIN chat_to_handle ch ON ch.chat_ss_id = ctm.chat_ss_id
        LEFT JOIN handle_aliases ha ON ha.handle_ss_id = ch.handle_ss_id
        $extraJoin
        WHERE $whereClause
          AND m.date_utc IS NOT NULL
          AND m.date_utc != ''
      )
      SELECT
        strftime('%Y', date_utc) AS year,
        strftime('%m', date_utc) AS month,
        COUNT(*) AS message_count
      FROM contact_messages
      GROUP BY year, month
      ORDER BY year ASC, month ASC
      ''', args);

    return ContactMessageActivity(
      firstMessageAtUtc: firstMessageAtUtc,
      lastMessageAtUtc: lastMessageAtUtc,
      monthCounts: [
        for (final row in monthRows)
          ContactMessageMonthCount(
            year: int.parse(row['year']! as String),
            month: int.parse(row['month']! as String),
            messageCount: _readInt(row['message_count']),
          ),
      ],
    );
  }

  Future<List<String>> _readParticipantHandles(int conversationId) async {
    final rows = await workingDatabase.selectRows(
      '''
      SELECT DISTINCT
        COALESCE(ch.display_handle, h.id) AS handle_id,
        COALESCE(ha.canonical_handle_ss_id, h.ss_id) AS sort_id
      FROM chat_to_handle cth
      JOIN handles h ON h.ss_id = cth.handle_ss_id
      LEFT JOIN handle_aliases ha ON ha.handle_ss_id = cth.handle_ss_id
      LEFT JOIN canonical_handles ch
        ON ch.canonical_handle_ss_id = ha.canonical_handle_ss_id
      WHERE cth.chat_ss_id = ?
      ORDER BY sort_id ASC, handle_id ASC
      ''',
      <Object?>[conversationId],
    );

    return [
      for (final row in rows)
        if (row['handle_id'] case final String handle) handle,
    ];
  }

  Future<List<int>> _readGraphCanonicalHandleIdsForLegacyContact(
    int contactId,
  ) async {
    final legacyIdentifiers = await _readLegacyContactNormalizedIdentifiers(
      contactId,
    );
    if (legacyIdentifiers.isEmpty) {
      return const <int>[];
    }

    final rows = await workingDatabase.selectRows('''
      SELECT DISTINCT canonical_handle_ss_id
      FROM handle_aliases
      WHERE lower(normalized_identifier)
        IN (${_placeholders(legacyIdentifiers.length)})
      ORDER BY canonical_handle_ss_id ASC
      ''', legacyIdentifiers);

    return [
      for (final row in rows)
        if (_readNullableInt(row['canonical_handle_ss_id']) case final int id)
          id,
    ];
  }

  Future<List<String>> _readLegacyContactNormalizedIdentifiers(
    int contactId,
  ) async {
    final database = legacyDatabase;
    if (database == null) {
      return const <String>[];
    }

    final rows = await database
        .customSelect(
          '''
          SELECT DISTINCT lower(map.normalized_identifier) AS identifier
          FROM handle_to_participant htp
          JOIN handles_canonical_to_alias map
            ON map.canonical_handle_id = htp.handle_id
          WHERE htp.participant_id = ?
            AND map.normalized_identifier IS NOT NULL
            AND map.normalized_identifier != ''
          ORDER BY identifier ASC
          ''',
          variables: [Variable.withInt(contactId)],
        )
        .get();

    return [
      for (final row in rows)
        if (row.data['identifier'] case final String identifier) identifier,
    ];
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return 0;
  }

  static int? _readNullableInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return null;
  }

  static bool _hasGraphEvidence(ContactGraphSnapshot snapshot) {
    return snapshot.conversations.isNotEmpty ||
        snapshot.messageActivity != null;
  }

  static String _placeholders(int count) {
    return List.filled(count, '?').join(', ');
  }
}
