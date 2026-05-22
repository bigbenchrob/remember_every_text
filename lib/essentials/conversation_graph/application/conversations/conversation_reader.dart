import '../../infrastructure/working_database_provider.dart';
import 'conversation.dart';

class ConversationReader {
  const ConversationReader({required this.workingDatabase});

  final WorkingDatabase workingDatabase;

  Future<List<ConversationOverview>> readOverviews({int limit = 100}) async {
    final rows = await workingDatabase.database.rawQuery(
      '''
      SELECT
        c.ss_id AS conversation_id,
        COUNT(DISTINCT COALESCE(ha.canonical_handle_ss_id, cth.handle_ss_id))
          AS participant_count,
        COUNT(DISTINCT ctm.message_ss_id) AS message_count,
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
          lastMessageAtUtc: row['last_message_at_utc'] as String?,
          lastMessageText: row['last_message_text'] as String?,
        ),
      );
    }

    return overviews;
  }

  Future<List<ConversationMessage>> readMessages({
    required int conversationId,
    int limit = 100,
  }) async {
    final rows = await workingDatabase.database.rawQuery(
      '''
      SELECT
        m.ss_id AS message_id,
        m.date_utc,
        m.is_from_me,
        m.text,
        m.associated_message_ss_id
      FROM chat_to_message ctm
      JOIN messages m ON m.ss_id = ctm.message_ss_id
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
        ),
    ];
  }

  Future<Set<int>> readConversationIdsMatchingMessageText({
    required String query,
    int limit = 500,
  }) async {
    final matches = await readConversationMessageTextMatches(
      query: query,
      limit: limit,
    );
    return matches.keys.toSet();
  }

  Future<Map<int, ConversationMessageTextMatch>>
  readConversationMessageTextMatches({
    required String query,
    int limit = 500,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return <int, ConversationMessageTextMatch>{};
    }

    final rows = await workingDatabase.database.rawQuery(
      '''
      SELECT
        ctm.chat_ss_id AS conversation_id,
        COUNT(*) AS match_count,
        (
          SELECT m2.text
          FROM chat_to_message ctm2
          JOIN messages m2 ON m2.ss_id = ctm2.message_ss_id
          WHERE ctm2.chat_ss_id = ctm.chat_ss_id
            AND m2.text IS NOT NULL
            AND m2.text != ''
            AND lower(m2.text) LIKE ?
          ORDER BY COALESCE(m2.date_utc, '') DESC, m2.ss_id DESC
          LIMIT 1
        ) AS sample_text
      FROM chat_to_message ctm
      JOIN messages m ON m.ss_id = ctm.message_ss_id
      WHERE m.text IS NOT NULL
        AND m.text != ''
        AND lower(m.text) LIKE ?
      GROUP BY ctm.chat_ss_id
      ORDER BY ctm.chat_ss_id ASC
      LIMIT ?
      ''',
      <Object?>[
        '%${trimmedQuery.toLowerCase()}%',
        '%${trimmedQuery.toLowerCase()}%',
        limit,
      ],
    );

    return {
      for (final row in rows)
        _readInt(row['conversation_id']): ConversationMessageTextMatch(
          conversationId: _readInt(row['conversation_id']),
          matchCount: _readInt(row['match_count']),
          sampleText: row['sample_text'] as String?,
        ),
    };
  }

  Future<List<String>> _readParticipantHandles(int conversationId) async {
    final rows = await workingDatabase.database.rawQuery(
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
