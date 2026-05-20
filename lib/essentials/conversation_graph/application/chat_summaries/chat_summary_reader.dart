import '../../infrastructure/working_database_provider.dart';
import 'chat_summary.dart';

class ChatSummaryReader {
  const ChatSummaryReader({required this.workingDatabase});

  final WorkingDatabase workingDatabase;

  Future<List<ChatSummary>> readSummaries({
    ChatSummaryFilter filter = ChatSummaryFilter.all,
    ChatSummarySort sort = ChatSummarySort.mostRecentMessage,
    int limit = 50,
  }) async {
    final rows = await workingDatabase.database.rawQuery('''
      SELECT
        c.ss_id AS chat_ss_id,
        COUNT(DISTINCT cth.handle_ss_id) AS participant_count,
        COUNT(DISTINCT ctm.message_ss_id) AS message_count,
        MAX(m.date_utc) AS last_message_at_utc,
        (
          SELECT m2.text
          FROM chat_to_message ctm2
          JOIN messages m2 ON m2.ss_id = ctm2.message_ss_id
          WHERE ctm2.chat_ss_id = c.ss_id
            AND m2.text IS NOT NULL
          ORDER BY m2.date_utc DESC, m2.ss_id DESC
          LIMIT 1
        ) AS last_message_text
      FROM chats c
      LEFT JOIN chat_to_handle cth ON cth.chat_ss_id = c.ss_id
      LEFT JOIN chat_to_message ctm ON ctm.chat_ss_id = c.ss_id
      LEFT JOIN messages m ON m.ss_id = ctm.message_ss_id
      GROUP BY c.ss_id
      ORDER BY COALESCE(last_message_at_utc, '') DESC, c.ss_id ASC
      ''');

    final summaries = <ChatSummary>[];
    for (final row in rows) {
      final chatSsId = _readInt(row['chat_ss_id']);
      final participantHandles = await _readParticipantHandles(chatSsId);
      final participantCount = _readInt(row['participant_count']);
      summaries.add(
        ChatSummary(
          chatSsId: chatSsId,
          participantHandles: participantHandles,
          participantCount: participantCount,
          isGroup: participantCount > 1,
          messageCount: _readInt(row['message_count']),
          lastMessageAtUtc: row['last_message_at_utc'] as String?,
          lastMessageText: row['last_message_text'] as String?,
        ),
      );
    }

    final filtered = _applyFilter(summaries, filter);
    _applySort(filtered, sort);
    return filtered.take(limit).toList(growable: false);
  }

  Future<ChatSummarySanityCounts> readSanityCounts() async {
    final summaries = await readSummaries(limit: 1000000);
    var groupChatCount = 0;
    var singleParticipantChatCount = 0;
    var orphanChatCount = 0;
    var zeroHandleChatCount = 0;
    var zeroMessageChatCount = 0;
    var largestParticipantCount = 0;
    var largestMessageCount = 0;

    for (final summary in summaries) {
      if (summary.isGroup) {
        groupChatCount += 1;
      }
      if (summary.participantCount == 1) {
        singleParticipantChatCount += 1;
      }
      if (summary.participantCount == 0 && summary.messageCount == 0) {
        orphanChatCount += 1;
      }
      if (summary.participantCount == 0) {
        zeroHandleChatCount += 1;
      }
      if (summary.messageCount == 0) {
        zeroMessageChatCount += 1;
      }
      if (summary.participantCount > largestParticipantCount) {
        largestParticipantCount = summary.participantCount;
      }
      if (summary.messageCount > largestMessageCount) {
        largestMessageCount = summary.messageCount;
      }
    }

    return ChatSummarySanityCounts(
      groupChatCount: groupChatCount,
      singleParticipantChatCount: singleParticipantChatCount,
      orphanChatCount: orphanChatCount,
      zeroHandleChatCount: zeroHandleChatCount,
      zeroMessageChatCount: zeroMessageChatCount,
      largestParticipantCount: largestParticipantCount,
      largestMessageCount: largestMessageCount,
    );
  }

  Future<List<RecentChatMessage>> readRecentMessages({
    required int chatSsId,
    int limit = 20,
  }) async {
    final rows = await workingDatabase.database.rawQuery(
      '''
      SELECT
        m.ss_id AS message_ss_id,
        m.date_utc,
        m.is_from_me,
        m.text
      FROM chat_to_message ctm
      JOIN messages m ON m.ss_id = ctm.message_ss_id
      WHERE ctm.chat_ss_id = ?
      ORDER BY COALESCE(m.date_utc, '') DESC, m.ss_id DESC
      LIMIT ?
      ''',
      <Object?>[chatSsId, limit],
    );

    return [
      for (final row in rows)
        RecentChatMessage(
          messageSsId: _readInt(row['message_ss_id']),
          dateUtc: row['date_utc'] as String?,
          isFromMe: _readInt(row['is_from_me']) == 1,
          text: row['text'] as String?,
        ),
    ];
  }

  Future<List<RecentChatMessage>> readRecentTextMessages({
    required int chatSsId,
    int limit = 20,
  }) async {
    final rows = await workingDatabase.database.rawQuery(
      '''
      SELECT
        m.ss_id AS message_ss_id,
        m.date_utc,
        m.is_from_me,
        m.text
      FROM chat_to_message ctm
      JOIN messages m ON m.ss_id = ctm.message_ss_id
      WHERE ctm.chat_ss_id = ?
        AND m.text IS NOT NULL
        AND m.text != ''
      ORDER BY COALESCE(m.date_utc, '') DESC, m.ss_id DESC
      LIMIT ?
      ''',
      <Object?>[chatSsId, limit],
    );

    return [
      for (final row in rows)
        RecentChatMessage(
          messageSsId: _readInt(row['message_ss_id']),
          dateUtc: row['date_utc'] as String?,
          isFromMe: _readInt(row['is_from_me']) == 1,
          text: row['text'] as String?,
        ),
    ];
  }

  Future<ChatMessageTextStats> readMessageTextStats({
    required int chatSsId,
  }) async {
    final rows = await workingDatabase.database.rawQuery(
      '''
      SELECT
        COUNT(*) AS total_message_count,
        SUM(CASE WHEN m.text IS NOT NULL AND m.text != '' THEN 1 ELSE 0 END)
          AS text_message_count
      FROM chat_to_message ctm
      JOIN messages m ON m.ss_id = ctm.message_ss_id
      WHERE ctm.chat_ss_id = ?
      ''',
      <Object?>[chatSsId],
    );
    final row = rows.single;
    final totalMessageCount = _readInt(row['total_message_count']);
    final textMessageCount = _readInt(row['text_message_count']);
    return ChatMessageTextStats(
      totalMessageCount: totalMessageCount,
      textMessageCount: textMessageCount,
      noTextMessageCount: totalMessageCount - textMessageCount,
    );
  }

  Future<List<String>> _readParticipantHandles(int chatSsId) async {
    final rows = await workingDatabase.database.rawQuery(
      '''
      SELECT DISTINCT h.id AS handle_id
      FROM chat_to_handle cth
      JOIN handles h ON h.ss_id = cth.handle_ss_id
      WHERE cth.chat_ss_id = ?
      ORDER BY h.id ASC
      ''',
      <Object?>[chatSsId],
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

  static List<ChatSummary> _applyFilter(
    List<ChatSummary> summaries,
    ChatSummaryFilter filter,
  ) {
    return switch (filter) {
      ChatSummaryFilter.all => summaries,
      ChatSummaryFilter.groupOnly =>
        summaries.where((summary) => summary.isGroup).toList(growable: false),
      ChatSummaryFilter.singleParticipantOnly =>
        summaries
            .where((summary) => summary.participantCount == 1)
            .toList(growable: false),
    };
  }

  static void _applySort(List<ChatSummary> summaries, ChatSummarySort sort) {
    summaries.sort((left, right) {
      final comparison = switch (sort) {
        ChatSummarySort.mostRecentMessage => _compareNullableTextDescending(
          left.lastMessageAtUtc,
          right.lastMessageAtUtc,
        ),
        ChatSummarySort.largestMessageCount => right.messageCount.compareTo(
          left.messageCount,
        ),
        ChatSummarySort.largestParticipantCount =>
          right.participantCount.compareTo(left.participantCount),
      };
      if (comparison != 0) {
        return comparison;
      }
      return left.chatSsId.compareTo(right.chatSsId);
    });
  }

  static int _compareNullableTextDescending(String? left, String? right) {
    final leftValue = left ?? '';
    final rightValue = right ?? '';
    return rightValue.compareTo(leftValue);
  }
}
