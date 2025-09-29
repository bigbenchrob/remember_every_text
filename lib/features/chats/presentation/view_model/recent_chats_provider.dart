import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';

part 'recent_chats_provider.g.dart';

/// Lightweight view model describing the data needed for the recent chats list.
class RecentChatSummary {
  const RecentChatSummary({
    required this.chatId,
    required this.title,
    required this.messageCount,
    required this.firstMessageDate,
    required this.lastMessageDate,
    required this.isGroup,
  });

  final int chatId;
  final String title;
  final int messageCount;
  final DateTime? firstMessageDate;
  final DateTime? lastMessageDate;
  final bool isGroup;
}

@riverpod
Future<List<RecentChatSummary>> recentChats(Ref ref, {int limit = 5}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  List<WorkingChat> chatRows;
  final chatsQuery = db.select(db.workingChats)
    ..orderBy([
      (tbl) => drift.OrderingTerm(
        expression: tbl.lastMessageAtUtc,
        mode: drift.OrderingMode.desc,
      ),
      (tbl) => drift.OrderingTerm(
        expression: tbl.updatedAtUtc,
        mode: drift.OrderingMode.desc,
      ),
      (tbl) => drift.OrderingTerm(expression: tbl.id),
    ])
    ..limit(limit);

  chatRows = await chatsQuery.get();

  final messageCountExpression = db.workingMessages.id.count();
  final firstSentExpression = db.workingMessages.sentAtUtc.min();
  final lastSentExpression = db.workingMessages.sentAtUtc.max();

  DateTime? parseUtc(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(value);
    return parsed?.toLocal();
  }

  String deriveTitle(WorkingChat chat) {
    return chat.displayName ??
        chat.computedName ??
        chat.userCustomName ??
        'Unnamed Conversation';
  }

  final results = <RecentChatSummary>[];

  for (final chat in chatRows) {
    final stats =
        await (db.selectOnly(db.workingMessages)
              ..where(db.workingMessages.chatId.equals(chat.id))
              ..addColumns([
                messageCountExpression,
                firstSentExpression,
                lastSentExpression,
              ]))
            .getSingleOrNull();

    final messageCount = stats?.read(messageCountExpression) ?? 0;
    final firstSentUtc = stats?.read(firstSentExpression);
    final lastSentUtc = stats?.read(lastSentExpression);

    final lastMessageDate = parseUtc(lastSentUtc ?? chat.lastMessageAtUtc);

    results.add(
      RecentChatSummary(
        chatId: chat.id,
        title: deriveTitle(chat),
        messageCount: messageCount,
        firstMessageDate: parseUtc(firstSentUtc ?? chat.createdAtUtc),
        lastMessageDate: lastMessageDate,
        isGroup: chat.isGroup,
      ),
    );
  }

  return results;
}
