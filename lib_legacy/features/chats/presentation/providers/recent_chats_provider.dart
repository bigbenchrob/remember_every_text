import 'package:drift/drift.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/databases/feature_level_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_chats_provider.g.dart';

/// Data model for recent chat information displayed in sidebar cards
class RecentChatInfo {
  const RecentChatInfo({
    required this.chatId,
    required this.contactId,
    required this.contactDisplayName,
    required this.messageCount,
    required this.firstMessageDate,
    required this.lastMessageDate,
  });

  final int chatId;
  final int? contactId;
  final String contactDisplayName;
  final int messageCount;
  final DateTime? firstMessageDate;
  final DateTime? lastMessageDate;
}

/// Provides the 5 most recent chats with contact information for the sidebar
@riverpod
Future<List<RecentChatInfo>> recentChats(Ref ref) async {
  // ignore: avoid_manual_providers_as_generated_provider_dependency
  final database = await ref.watch(workingDatabaseProvider.future);

  // Query to get the 5 most recent chats with their contact information
  // Order by endDate (most recent message date) descending
  final query =
      database.select(database.chats).join([
          leftOuterJoin(
            database.contacts,
            database.contacts.id.equalsExp(database.chats.contactId),
          ),
        ])
        ..where(database.chats.messageCount.isBiggerThanValue(0))
        ..orderBy([OrderingTerm.desc(database.chats.endDate)])
        ..limit(5);

  final results = await query.get();

  return results.map((row) {
    final chat = row.readTable(database.chats);
    final contact = row.readTableOrNull(database.contacts);

    // Convert Apple timestamps (nanoseconds since 2001-01-01) to DateTime
    DateTime? firstMessageDate;
    DateTime? lastMessageDate;
    if (chat.startDate != null) {
      firstMessageDate = _convertAppleTimestamp(chat.startDate!);
    }

    if (chat.endDate != null) {
      lastMessageDate = _convertAppleTimestamp(chat.endDate!);
    }

    return RecentChatInfo(
      chatId: chat.id,
      contactId: chat.contactId,
      contactDisplayName:
          contact?.displayName ?? chat.displayName ?? 'Unknown Contact',
      messageCount: chat.messageCount,
      firstMessageDate: firstMessageDate,
      lastMessageDate: lastMessageDate,
    );
  }).toList();
}

/// Convert Apple timestamp (nanoseconds since 2001-01-01) to DateTime
DateTime _convertAppleTimestamp(int appleTimestamp) {
  // Apple epoch starts at 2001-01-01 00:00:00 UTC
  final microseconds = appleTimestamp ~/ 1000;
  return DateTime(2001).add(Duration(microseconds: microseconds));
}
