import '../conversations/conversation.dart';

class ContactMessageMonthCount {
  const ContactMessageMonthCount({
    required this.year,
    required this.month,
    required this.messageCount,
  });

  final int year;
  final int month;
  final int messageCount;
}

class ContactMessageActivity {
  const ContactMessageActivity({
    required this.firstMessageAtUtc,
    required this.lastMessageAtUtc,
    required this.monthCounts,
  });

  final String firstMessageAtUtc;
  final String lastMessageAtUtc;
  final List<ContactMessageMonthCount> monthCounts;

  int get totalMessageCount =>
      monthCounts.fold<int>(0, (total, month) => total + month.messageCount);

  int get maxMonthCount => monthCounts.fold<int>(
    0,
    (max, month) => month.messageCount > max ? month.messageCount : max,
  );
}

class ContactGraphSnapshot {
  const ContactGraphSnapshot({
    required this.contactId,
    required this.conversations,
    required this.messageActivity,
  });

  final int contactId;
  final List<ConversationOverview> conversations;
  final ContactMessageActivity? messageActivity;
}
