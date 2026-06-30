class ConversationSignature {
  const ConversationSignature({
    required this.conversationId,
    required this.title,
    required this.participantLabels,
    required this.participantCount,
    required this.isGroup,
    required this.messageCount,
    required this.attachmentCount,
    required this.firstMessageAtUtc,
    required this.lastMessageAtUtc,
    required this.lastMessageText,
    required this.activityMonths,
  });

  final int conversationId;
  final String title;
  final List<String> participantLabels;
  final int participantCount;
  final bool isGroup;
  final int messageCount;
  final int attachmentCount;
  final String? firstMessageAtUtc;
  final String? lastMessageAtUtc;
  final String? lastMessageText;
  final List<ConversationSignatureMonth> activityMonths;
}

class ConversationSignatureMonth {
  const ConversationSignatureMonth({
    required this.year,
    required this.month,
    required this.messageCount,
  });

  final int year;
  final int month;
  final int messageCount;
}
