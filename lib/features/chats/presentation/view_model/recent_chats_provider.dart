import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/databases/feature_level_providers.dart';

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
Future<List<RecentChatSummary>> recentChats(
  Ref ref, {
  int limit = 5,
}) async {
  final db = await ref.watch(workingDatabaseProvider.future);

  final chatsAlias = db.chats;
  final contactsAlias = db.contacts;

  final query = db.select(chatsAlias).join([
    drift.leftOuterJoin(
      contactsAlias,
      contactsAlias.id.equalsExp(chatsAlias.contactId),
    ),
  ]);

  query.orderBy([
    drift.OrderingTerm.desc(chatsAlias.endDate),
    drift.OrderingTerm.desc(chatsAlias.startDate),
    drift.OrderingTerm.asc(chatsAlias.id),
  ]);

  query.limit(limit);

  final rows = await query.get();
  final results = <RecentChatSummary>[];

  for (final row in rows) {
    final chatRow = row.readTable(chatsAlias);
    final contactRow = row.readTableOrNull(contactsAlias);

    String? normalizeOrNull(String? value) {
      if (value == null) {
        return null;
      }
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    final normalizedContactName = normalizeOrNull(contactRow?.displayName);
    final normalizedChatName = normalizeOrNull(chatRow.displayName);
    final title =
        normalizedContactName ?? normalizedChatName ?? 'Unnamed Conversation';

    DateTime? toDateTime(int? raw) {
      if (raw == null) {
        return null;
      }
      return DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true).toLocal();
    }

    results.add(
      RecentChatSummary(
        chatId: chatRow.id,
        title: title,
        messageCount: chatRow.messageCount,
        firstMessageDate: toDateTime(chatRow.startDate),
        lastMessageDate: toDateTime(chatRow.endDate),
        isGroup: contactRow?.isGroup ?? false,
      ),
    );
  }

  return results;
}
