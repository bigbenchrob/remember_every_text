import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../../../../core/util/date_converter.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';

class MessageHistoryCoverageRepository {
  const MessageHistoryCoverageRepository();

  MessageHistorySourceSummary? readChatDbSummary(String dbPath) {
    final file = File(dbPath);
    if (!file.existsSync()) {
      return null;
    }

    try {
      final database = sqlite3.open(dbPath, mode: OpenMode.readOnly);
      try {
        database.execute('PRAGMA query_only = ON;');
        database.execute('PRAGMA busy_timeout = 3000;');

        final result = database.select('''
          SELECT
            COUNT(*) AS total_count,
            MIN(CASE WHEN date IS NOT NULL AND date != 0 THEN date END) AS first_date,
            MAX(CASE WHEN date IS NOT NULL AND date != 0 THEN date END) AS last_date
          FROM message
        ''');
        if (result.isEmpty) {
          return null;
        }

        final row = result.first;
        final totalCount = _asInt(row['total_count']);
        if (totalCount == null) {
          return null;
        }

        return MessageHistorySourceSummary(
          totalCount: totalCount,
          earliestMessageDate: DateConverter.appleToDateTime(
            row['first_date'],
          )?.toUtc(),
          latestMessageDate: DateConverter.appleToDateTime(
            row['last_date'],
          )?.toUtc(),
        );
      } finally {
        database.dispose();
      }
    } catch (_) {
      return null;
    }
  }

  Future<MessageHistoryGraphSummary> readGraphSummary(
    ConversationGraphDatabase graphDb,
  ) async {
    final rows = await graphDb.selectRows('''
      SELECT
        (
          SELECT COUNT(*)
          FROM messages AS m
          WHERE EXISTS (
            SELECT 1
            FROM chat_to_message AS ctm
            WHERE ctm.message_ss_id = m.ss_id
          )
        ) AS conversation_linked_count,
        (
          SELECT COUNT(*)
          FROM messages AS m
          WHERE NOT EXISTS (
            SELECT 1
            FROM chat_to_message AS ctm
            WHERE ctm.message_ss_id = m.ss_id
          )
        ) AS recovered_orphan_count
    ''');

    final row = rows.single;
    return MessageHistoryGraphSummary(
      conversationLinkedCount: _asInt(row['conversation_linked_count']) ?? 0,
      recoveredOrphanCount: _asInt(row['recovered_orphan_count']) ?? 0,
    );
  }
}

final class MessageHistorySourceSummary {
  const MessageHistorySourceSummary({
    required this.totalCount,
    required this.earliestMessageDate,
    required this.latestMessageDate,
  });

  final int totalCount;
  final DateTime? earliestMessageDate;
  final DateTime? latestMessageDate;
}

final class MessageHistoryGraphSummary {
  const MessageHistoryGraphSummary({
    required this.conversationLinkedCount,
    required this.recoveredOrphanCount,
  });

  final int conversationLinkedCount;
  final int recoveredOrphanCount;

  int get totalAccountedCount => conversationLinkedCount + recoveredOrphanCount;
}

int? _asInt(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse('$value');
}
