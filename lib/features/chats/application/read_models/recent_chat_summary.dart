/// Lightweight read model describing the data needed for conversation lists.
class RecentChatSummary {
  const RecentChatSummary({
    required this.chatId,
    required this.title,
    required this.messageCount,
    required this.attachmentCount,
    required this.firstMessageDate,
    required this.lastMessageDate,
    required this.isGroup,
    required this.participants,
    required this.handles,
    this.lastMessagePreview,
  });

  final int chatId;
  final String title;
  final int messageCount;
  final int attachmentCount;
  final DateTime? firstMessageDate;
  final DateTime? lastMessageDate;
  final bool isGroup;
  final List<String> participants;
  final List<String> handles;
  final String? lastMessagePreview;
}
