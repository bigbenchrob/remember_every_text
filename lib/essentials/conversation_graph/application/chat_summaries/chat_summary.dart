enum ChatSummaryFilter { all, groupOnly, singleParticipantOnly }

enum ChatSummarySort {
  mostRecentMessage,
  largestMessageCount,
  largestParticipantCount,
}

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

class RecentChatMessage {
  const RecentChatMessage({
    required this.messageSsId,
    required this.dateUtc,
    required this.isFromMe,
    required this.text,
  });

  final int messageSsId;
  final String? dateUtc;
  final bool isFromMe;
  final String? text;
}

class ChatMessageTextStats {
  const ChatMessageTextStats({
    required this.totalMessageCount,
    required this.textMessageCount,
    required this.noTextMessageCount,
  });

  final int totalMessageCount;
  final int textMessageCount;
  final int noTextMessageCount;
}

class ChatSummarySanityCounts {
  const ChatSummarySanityCounts({
    required this.groupChatCount,
    required this.singleParticipantChatCount,
    required this.orphanChatCount,
    required this.zeroHandleChatCount,
    required this.zeroMessageChatCount,
    required this.largestParticipantCount,
    required this.largestMessageCount,
  });

  final int groupChatCount;
  final int singleParticipantChatCount;
  final int orphanChatCount;
  final int zeroHandleChatCount;
  final int zeroMessageChatCount;
  final int largestParticipantCount;
  final int largestMessageCount;
}
