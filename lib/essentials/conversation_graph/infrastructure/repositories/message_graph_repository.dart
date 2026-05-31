import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../source_scoped_import/domain/known_sources.dart';
import '../../../source_scoped_import/domain/source_scoped_row_key.dart';
import '../../application/conversations/conversation.dart';
import '../../application/messages/message_graph_repository.dart';

class SqliteMessageGraphRepository implements MessageGraphRepository {
  const SqliteMessageGraphRepository({required this.workingDatabase});

  final ConversationGraphDatabase workingDatabase;

  @override
  Future<List<ConversationMessageTimelineEntry>>
  readGlobalMessageTimeline() async {
    final rows = await workingDatabase.selectRows('''
      SELECT
        m.ss_id AS message_id,
        m.date_utc,
        CASE
          WHEN m.date_utc IS NULL OR m.date_utc = '' THEN NULL
          ELSE strftime('%Y-%m', m.date_utc)
        END AS month_key
      FROM messages m
      ORDER BY COALESCE(m.date_utc, '') ASC, m.ss_id ASC
      ''');

    return [
      for (final row in rows)
        ConversationMessageTimelineEntry(
          messageId: _readInt(row['message_id']),
          dateUtc: row['date_utc'] as String?,
          monthKey: row['month_key'] as String?,
        ),
    ];
  }

  @override
  Future<ConversationMessage?> readGlobalMessageById({
    required int messageId,
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
      LEFT JOIN handles sender_handle ON sender_handle.ss_id =
        m.sender_handle_ss_id
      LEFT JOIN canonical_handles sender_canonical
        ON sender_canonical.canonical_handle_ss_id =
          m.sender_canonical_handle_ss_id
      WHERE m.ss_id = ?
      LIMIT 1
      ''',
      <Object?>[messageId],
    );

    if (rows.isEmpty) {
      return null;
    }

    return _mapConversationMessage(rows.single);
  }

  @override
  Future<List<int>> readGlobalMessageIdsMatchingText({
    required String query,
    bool matchAnyTerm = false,
  }) async {
    final terms = _searchTerms(query);
    if (terms.isEmpty) {
      return const <int>[];
    }

    final clauses = <String>[];
    final variables = <Object?>[];
    for (final term in terms) {
      clauses.add('''
        (
          lower(COALESCE(m.text, '')) LIKE ?
          OR lower(COALESCE(m.guid, '')) LIKE ?
          OR lower(COALESCE(sender_handle.id, '')) LIKE ?
          OR lower(COALESCE(sender_canonical.display_handle, '')) LIKE ?
          OR lower(COALESCE(m.semantic_kind, '')) LIKE ?
          OR lower(COALESCE(m.item_kind, '')) LIKE ?
        )
        ''');
      final pattern = '%$term%';
      variables.addAll([pattern, pattern, pattern, pattern, pattern, pattern]);
    }

    final rows = await workingDatabase.selectRows('''
      SELECT DISTINCT m.ss_id AS message_id
      FROM messages m
      LEFT JOIN handles sender_handle ON sender_handle.ss_id =
        m.sender_handle_ss_id
      LEFT JOIN canonical_handles sender_canonical
        ON sender_canonical.canonical_handle_ss_id =
          m.sender_canonical_handle_ss_id
      WHERE ${clauses.join(matchAnyTerm ? ' OR ' : ' AND ')}
      ORDER BY COALESCE(m.date_utc, '') ASC, m.ss_id ASC
      ''', variables);

    return [for (final row in rows) _readInt(row['message_id'])];
  }

  @override
  Future<List<ConversationMessageTimelineEntry>> readHandleMessageTimeline({
    required int handleId,
  }) async {
    final canonicalHandleIds = await _readGraphCanonicalHandleIdsForHandle(
      handleId,
    );
    if (canonicalHandleIds.isEmpty) {
      return const <ConversationMessageTimelineEntry>[];
    }

    final rows = await workingDatabase.selectRows('''
      SELECT DISTINCT
        m.ss_id AS message_id,
        m.date_utc,
        CASE
          WHEN m.date_utc IS NULL OR m.date_utc = '' THEN NULL
          ELSE strftime('%Y-%m', m.date_utc)
        END AS month_key
      FROM messages m
      JOIN chat_to_message ctm ON ctm.message_ss_id = m.ss_id
      JOIN chat_to_handle cth ON cth.chat_ss_id = ctm.chat_ss_id
      LEFT JOIN handle_aliases ha ON ha.handle_ss_id = cth.handle_ss_id
      WHERE COALESCE(ha.canonical_handle_ss_id, cth.handle_ss_id)
        IN (${_placeholders(canonicalHandleIds.length)})
      ORDER BY COALESCE(m.date_utc, '') ASC, m.ss_id ASC
      ''', canonicalHandleIds);

    return [
      for (final row in rows)
        ConversationMessageTimelineEntry(
          messageId: _readInt(row['message_id']),
          dateUtc: row['date_utc'] as String?,
          monthKey: row['month_key'] as String?,
        ),
    ];
  }

  @override
  Future<ConversationMessage?> readHandleMessageById({
    required int handleId,
    required int messageId,
  }) async {
    final canonicalHandleIds = await _readGraphCanonicalHandleIdsForHandle(
      handleId,
    );
    if (canonicalHandleIds.isEmpty) {
      return null;
    }

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
      JOIN chat_to_handle cth ON cth.chat_ss_id = ctm.chat_ss_id
      LEFT JOIN handle_aliases ha ON ha.handle_ss_id = cth.handle_ss_id
      LEFT JOIN handles sender_handle ON sender_handle.ss_id =
        m.sender_handle_ss_id
      LEFT JOIN canonical_handles sender_canonical
        ON sender_canonical.canonical_handle_ss_id =
          m.sender_canonical_handle_ss_id
      WHERE m.ss_id = ?
        AND COALESCE(ha.canonical_handle_ss_id, cth.handle_ss_id)
          IN (${_placeholders(canonicalHandleIds.length)})
      LIMIT 1
      ''',
      <Object?>[messageId, ...canonicalHandleIds],
    );

    if (rows.isEmpty) {
      return null;
    }

    return _mapConversationMessage(rows.single);
  }

  @override
  Future<List<int>> readHandleMessageIdsMatchingText({
    required int handleId,
    required String query,
    bool matchAnyTerm = false,
  }) async {
    final canonicalHandleIds = await _readGraphCanonicalHandleIdsForHandle(
      handleId,
    );
    final terms = _searchTerms(query);
    if (canonicalHandleIds.isEmpty || terms.isEmpty) {
      return const <int>[];
    }

    final clauses = <String>[];
    final variables = <Object?>[];
    for (final term in terms) {
      clauses.add('''
        (
          lower(COALESCE(m.text, '')) LIKE ?
          OR lower(COALESCE(m.guid, '')) LIKE ?
          OR lower(COALESCE(sender_handle.id, '')) LIKE ?
          OR lower(COALESCE(sender_canonical.display_handle, '')) LIKE ?
          OR lower(COALESCE(m.semantic_kind, '')) LIKE ?
          OR lower(COALESCE(m.item_kind, '')) LIKE ?
        )
        ''');
      final pattern = '%$term%';
      variables.addAll([pattern, pattern, pattern, pattern, pattern, pattern]);
    }

    final rows = await workingDatabase.selectRows(
      '''
      SELECT DISTINCT m.ss_id AS message_id
      FROM messages m
      JOIN chat_to_message ctm ON ctm.message_ss_id = m.ss_id
      JOIN chat_to_handle cth ON cth.chat_ss_id = ctm.chat_ss_id
      LEFT JOIN handle_aliases ha ON ha.handle_ss_id = cth.handle_ss_id
      LEFT JOIN handles sender_handle ON sender_handle.ss_id =
        m.sender_handle_ss_id
      LEFT JOIN canonical_handles sender_canonical
        ON sender_canonical.canonical_handle_ss_id =
          m.sender_canonical_handle_ss_id
      WHERE COALESCE(ha.canonical_handle_ss_id, cth.handle_ss_id)
          IN (${_placeholders(canonicalHandleIds.length)})
        AND (${clauses.join(matchAnyTerm ? ' OR ' : ' AND ')})
      ORDER BY COALESCE(m.date_utc, '') ASC, m.ss_id ASC
      ''',
      <Object?>[...canonicalHandleIds, ...variables],
    );

    return [for (final row in rows) _readInt(row['message_id'])];
  }

  @override
  Future<List<ConversationMessageTimelineEntry>> readMessageContextTimeline({
    required int messageId,
    required int chatId,
    required int beforeCount,
    required int afterCount,
  }) async {
    final graphMessageId = _liveChatGraphId(messageId);
    final graphChatId = _liveChatGraphId(chatId);

    final selectedRows = await workingDatabase.selectRows(
      '''
      SELECT 1
      FROM chat_to_message
      WHERE chat_ss_id = ?
        AND message_ss_id = ?
      LIMIT 1
      ''',
      <Object?>[graphChatId, graphMessageId],
    );
    if (selectedRows.isEmpty) {
      return const <ConversationMessageTimelineEntry>[];
    }

    final beforeRows = await _readContextRows(
      chatId: graphChatId,
      messageId: graphMessageId,
      operator: '<',
      orderDirection: 'DESC',
      limit: beforeCount,
    );
    final selectedEntryRows = await _readContextSelectedRow(
      chatId: graphChatId,
      messageId: graphMessageId,
    );
    final afterRows = await _readContextRows(
      chatId: graphChatId,
      messageId: graphMessageId,
      operator: '>',
      orderDirection: 'ASC',
      limit: afterCount,
    );

    return [
      for (final row in beforeRows.reversed) _mapTimelineEntry(row),
      for (final row in selectedEntryRows) _mapTimelineEntry(row),
      for (final row in afterRows) _mapTimelineEntry(row),
    ];
  }

  Future<List<Map<String, Object?>>> _readContextRows({
    required int chatId,
    required int messageId,
    required String operator,
    required String orderDirection,
    required int limit,
  }) {
    if (limit <= 0) {
      return Future.value(const <Map<String, Object?>>[]);
    }
    return workingDatabase.selectRows(
      '''
      SELECT
        m.ss_id AS message_id,
        m.date_utc,
        CASE
          WHEN m.date_utc IS NULL OR m.date_utc = '' THEN NULL
          ELSE strftime('%Y-%m', m.date_utc)
        END AS month_key
      FROM messages m
      JOIN chat_to_message ctm ON ctm.message_ss_id = m.ss_id
      WHERE ctm.chat_ss_id = ?
        AND m.ss_id $operator ?
      ORDER BY m.ss_id $orderDirection
      LIMIT ?
      ''',
      <Object?>[chatId, messageId, limit],
    );
  }

  Future<List<Map<String, Object?>>> _readContextSelectedRow({
    required int chatId,
    required int messageId,
  }) {
    return workingDatabase.selectRows(
      '''
      SELECT
        m.ss_id AS message_id,
        m.date_utc,
        CASE
          WHEN m.date_utc IS NULL OR m.date_utc = '' THEN NULL
          ELSE strftime('%Y-%m', m.date_utc)
        END AS month_key
      FROM messages m
      JOIN chat_to_message ctm ON ctm.message_ss_id = m.ss_id
      WHERE ctm.chat_ss_id = ?
        AND m.ss_id = ?
      LIMIT 1
      ''',
      <Object?>[chatId, messageId],
    );
  }

  Future<List<int>> _readGraphCanonicalHandleIdsForHandle(int handleId) async {
    final directIds = await _readDirectGraphCanonicalHandleIds(handleId);
    if (directIds.isNotEmpty) {
      return directIds;
    }

    return const <int>[];
  }

  Future<List<int>> _readDirectGraphCanonicalHandleIds(int handleId) async {
    final rows = await workingDatabase.selectRows(
      '''
      SELECT DISTINCT canonical_handle_id
      FROM (
        SELECT canonical_handle_ss_id AS canonical_handle_id
        FROM handle_aliases
        WHERE handle_ss_id = ?
           OR canonical_handle_ss_id = ?
        UNION
        SELECT canonical_handle_ss_id AS canonical_handle_id
        FROM canonical_handles
        WHERE canonical_handle_ss_id = ?
        UNION
        SELECT ss_id AS canonical_handle_id
        FROM handles
        WHERE ss_id = ?
      )
      WHERE canonical_handle_id IS NOT NULL
      ORDER BY canonical_handle_id ASC
      ''',
      <Object?>[handleId, handleId, handleId, handleId],
    );

    return [
      for (final row in rows)
        if (_readNullableInt(row['canonical_handle_id']) case final int id) id,
    ];
  }

  static ConversationMessage _mapConversationMessage(Map<String, Object?> row) {
    return ConversationMessage(
      messageId: _readInt(row['message_id']),
      dateUtc: row['date_utc'] as String?,
      isFromMe: _readInt(row['is_from_me']) == 1,
      text: row['text'] as String?,
      associatedMessageId: _readNullableInt(row['associated_message_ss_id']),
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
      hasAttributedBodySource: _readInt(row['has_attributed_body_source']) == 1,
      hasMessageSummaryInfo: _readInt(row['has_message_summary_info']) == 1,
      hasPayloadDataSource: _readInt(row['has_payload_data_source']) == 1,
      errorCode: _readNullableInt(row['error_code']),
    );
  }

  static ConversationMessageTimelineEntry _mapTimelineEntry(
    Map<String, Object?> row,
  ) {
    return ConversationMessageTimelineEntry(
      messageId: _readInt(row['message_id']),
      dateUtc: row['date_utc'] as String?,
      monthKey: row['month_key'] as String?,
    );
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

  static String _placeholders(int count) {
    return List.filled(count, '?').join(', ');
  }

  static List<String> _searchTerms(String query) {
    return query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((term) {
          return term.isNotEmpty;
        })
        .toList(growable: false);
  }

  static int _liveChatGraphId(int value) {
    if (value > SourceScopedRowKey.maxSourceRowId) {
      return value;
    }
    return SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: value,
    );
  }
}
