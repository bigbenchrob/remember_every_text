class ConversationOverview {
  const ConversationOverview({
    required this.conversationId,
    required this.participantHandles,
    required this.participantCount,
    required this.isGroup,
    required this.messageCount,
    required this.lastMessageAtUtc,
    required this.lastMessageText,
  });

  final int conversationId;
  final List<String> participantHandles;
  final int participantCount;
  final bool isGroup;
  final int messageCount;
  final String? lastMessageAtUtc;
  final String? lastMessageText;
}

class ConversationMessage {
  const ConversationMessage({
    required this.messageId,
    required this.dateUtc,
    required this.isFromMe,
    required this.text,
    required this.associatedMessageId,
  });

  final int messageId;
  final String? dateUtc;
  final bool isFromMe;
  final String? text;
  final int? associatedMessageId;
}

class ConversationMessageTextMatch {
  const ConversationMessageTextMatch({
    required this.conversationId,
    required this.matchCount,
    required this.sampleText,
  });

  final int conversationId;
  final int matchCount;
  final String? sampleText;
}
