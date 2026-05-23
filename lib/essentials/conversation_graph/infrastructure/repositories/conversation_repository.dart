import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../application/conversations/conversation.dart';
import '../../application/conversations/conversation_repository.dart';

class SqliteConversationRepository implements ConversationRepository {
  const SqliteConversationRepository({required this.workingDatabase});

  final ConversationGraphDatabase workingDatabase;

  @override
  Future<List<ConversationOverview>> readOverviews({int limit = 100}) async {
    final rows = await workingDatabase.selectRows(
      '''
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
      GROUP BY c.ss_id
      ORDER BY COALESCE(last_message_at_utc, '') DESC, c.ss_id ASC
      LIMIT ?
      ''',
      <Object?>[limit],
    );

    final overviews = <ConversationOverview>[];
    for (final row in rows) {
      final conversationId = _readInt(row['conversation_id']);
      final participantHandles = await _readParticipantHandles(conversationId);
      final participantCount = _readInt(row['participant_count']);
      overviews.add(
        ConversationOverview(
          conversationId: conversationId,
          participantHandles: participantHandles,
          participantCount: participantCount,
          isGroup: participantCount > 1,
          messageCount: _readInt(row['message_count']),
          attachmentCount: _readInt(row['attachment_count']),
          firstMessageAtUtc: row['first_message_at_utc'] as String?,
          lastMessageAtUtc: row['last_message_at_utc'] as String?,
          lastMessageText: row['last_message_text'] as String?,
        ),
      );
    }

    return overviews;
  }

  @override
  Future<List<ConversationMessage>> readMessages({
    required int conversationId,
    int limit = 100,
  }) async {
    final rows = await workingDatabase.selectRows(
      '''
      SELECT
        m.ss_id AS message_id,
        m.date_utc,
        m.is_from_me,
        m.text,
        m.associated_message_ss_id,
        m.sender_handle_ss_id,
        m.sender_canonical_handle_ss_id,
        COALESCE(ch.display_handle, h.id) AS sender_display_handle,
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
      FROM chat_to_message ctm
      JOIN messages m ON m.ss_id = ctm.message_ss_id
      LEFT JOIN handles h ON h.ss_id = m.sender_handle_ss_id
      LEFT JOIN canonical_handles ch
        ON ch.canonical_handle_ss_id = m.sender_canonical_handle_ss_id
      WHERE ctm.chat_ss_id = ?
      ORDER BY COALESCE(m.date_utc, '') DESC, m.ss_id DESC
      LIMIT ?
      ''',
      <Object?>[conversationId, limit],
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

  @override
  Future<Map<int, ConversationMessageTextMatch>>
  readConversationMessageTextMatches({
    required String query,
    int limit = 500,
    int snippetsPerConversation = 3,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return <int, ConversationMessageTextMatch>{};
    }

    final rows = await workingDatabase.selectRows(
      '''
      WITH matching AS (
        SELECT
          ctm.chat_ss_id AS conversation_id,
          m.ss_id AS message_id,
          m.date_utc,
          m.text
        FROM chat_to_message ctm
        JOIN messages m ON m.ss_id = ctm.message_ss_id
        WHERE m.text IS NOT NULL
          AND m.text != ''
          AND lower(m.text) LIKE ?
      ),
      ranked AS (
        SELECT
          conversation_id,
          message_id,
          date_utc,
          text,
          COUNT(*) OVER (PARTITION BY conversation_id) AS match_count,
          ROW_NUMBER() OVER (
            PARTITION BY conversation_id
            ORDER BY COALESCE(date_utc, '') DESC, message_id DESC
          ) AS snippet_rank
        FROM matching
      )
      SELECT
        conversation_id,
        message_id,
        date_utc,
        text,
        match_count
      FROM ranked
      WHERE snippet_rank <= ?
      ORDER BY conversation_id ASC, snippet_rank ASC
      ''',
      <Object?>['%${trimmedQuery.toLowerCase()}%', snippetsPerConversation],
    );

    final matches = <int, ConversationMessageTextMatch>{};
    for (final row in rows) {
      final conversationId = _readInt(row['conversation_id']);
      if (!matches.containsKey(conversationId) && matches.length >= limit) {
        continue;
      }

      final snippet = ConversationMessageTextSnippet(
        messageId: _readInt(row['message_id']),
        dateUtc: row['date_utc'] as String?,
        text: row['text'] as String? ?? '',
      );
      final existing = matches[conversationId];
      matches[conversationId] = ConversationMessageTextMatch(
        conversationId: conversationId,
        matchCount: _readInt(row['match_count']),
        sampleText: existing?.sampleText ?? snippet.text,
        snippets: [...?existing?.snippets, snippet],
      );
    }

    return matches;
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
    if (value == null) {
      return null;
    }
    return _readInt(value);
  }
}
