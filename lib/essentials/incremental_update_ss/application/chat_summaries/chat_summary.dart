class ChatSummary {
  const ChatSummary({
    required this.chatSsId,
    required this.participantHandles,
    required this.participantCount,
    required this.isGroup,
    required this.messageCount,
    required this.lastMessageAtUtc,
    required this.lastMessageText,
  });

  final int chatSsId;
  final List<String> participantHandles;
  final int participantCount;
  final bool isGroup;
  final int messageCount;
  final String? lastMessageAtUtc;
  final String? lastMessageText;
}

class ChatSummarySanityCounts {
  const ChatSummarySanityCounts({
    required this.groupChatCount,
    required this.singleParticipantChatCount,
    required this.largestParticipantCount,
    required this.largestMessageCount,
  });

  final int groupChatCount;
  final int singleParticipantChatCount;
  final int largestParticipantCount;
  final int largestMessageCount;
}
