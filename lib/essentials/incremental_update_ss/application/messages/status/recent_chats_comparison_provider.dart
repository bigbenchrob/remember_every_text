import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../features/chats/presentation/view_model/recent_chats_provider.dart';
import '../../../../db/feature_level_providers.dart';

part 'recent_chats_comparison_provider.g.dart';

class RecentChatsComparison {
  const RecentChatsComparison({
    required this.legacyCount,
    required this.graphCount,
    required this.legacyRows,
    required this.graphRows,
  });

  final int legacyCount;
  final int graphCount;
  final List<RecentChatsComparisonRow> legacyRows;
  final List<RecentChatsComparisonRow> graphRows;
}

class RecentChatsComparisonRow {
  const RecentChatsComparisonRow({
    required this.chatId,
    required this.title,
    required this.messageCount,
    required this.lastMessageDate,
    required this.isGroup,
    required this.participantCount,
  });

  final int chatId;
  final String title;
  final int messageCount;
  final DateTime? lastMessageDate;
  final bool isGroup;
  final int participantCount;
}

@riverpod
Future<RecentChatsComparison> recentChatsComparison(
  Ref ref, {
  int sampleLimit = 8,
}) async {
  final legacyRows = await readLegacyRecentChats(ref, limit: sampleLimit);
  final graphRows = await readGraphRecentChats(ref, limit: sampleLimit);
  final legacyCount = await _readLegacyChatCount(ref);
  final graphCount = await _readGraphChatCount(ref);

  return RecentChatsComparison(
    legacyCount: legacyCount,
    graphCount: graphCount,
    legacyRows: legacyRows.map(_toComparisonRow).toList(growable: false),
    graphRows: graphRows.map(_toComparisonRow).toList(growable: false),
  );
}

Future<int> _readLegacyChatCount(Ref ref) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final countExpression = db.workingChats.id.count();
  final row = await (db.selectOnly(
    db.workingChats,
  )..addColumns([countExpression])).getSingle();
  return row.read(countExpression) ?? 0;
}

Future<int> _readGraphChatCount(Ref ref) async {
  final workingDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final rows = await workingDatabase.selectRows(
    'SELECT COUNT(*) AS chat_count FROM chats',
  );
  final value = rows.single['chat_count'];
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  return 0;
}

RecentChatsComparisonRow _toComparisonRow(RecentChatSummary summary) {
  return RecentChatsComparisonRow(
    chatId: summary.chatId,
    title: summary.title,
    messageCount: summary.messageCount,
    lastMessageDate: summary.lastMessageDate,
    isGroup: summary.isGroup,
    participantCount: summary.participants.length,
  );
}
