class ConversationOverview {
  const ConversationOverview({
    required this.conversationId,
    required this.participantHandles,
    required this.participantCount,
    required this.isGroup,
    required this.messageCount,
    required this.attachmentCount,
    required this.firstMessageAtUtc,
    required this.lastMessageAtUtc,
    required this.lastMessageText,
  });

  final int conversationId;
  final List<String> participantHandles;
  final int participantCount;
  final bool isGroup;
  final int messageCount;
  final int attachmentCount;
  final String? firstMessageAtUtc;
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
    required this.attachmentCount,
    this.senderHandleId,
    this.senderCanonicalHandleId,
    this.senderDisplayHandle,
    this.semanticKind,
    this.itemKind,
    this.isSystemMessage = false,
    this.isSparseArtifact = false,
    this.hasAttributedBodySource = false,
    this.hasMessageSummaryInfo = false,
    this.hasPayloadDataSource = false,
    this.errorCode,
  });

  final int messageId;
  final String? dateUtc;
  final bool isFromMe;
  final String? text;
  final int? associatedMessageId;
  final int attachmentCount;
  final int? senderHandleId;
  final int? senderCanonicalHandleId;
  final String? senderDisplayHandle;
  final String? semanticKind;
  final String? itemKind;
  final bool isSystemMessage;
  final bool isSparseArtifact;
  final bool hasAttributedBodySource;
  final bool hasMessageSummaryInfo;
  final bool hasPayloadDataSource;
  final int? errorCode;
}

class ConversationMessageTimelineEntry {
  const ConversationMessageTimelineEntry({
    required this.messageId,
    required this.dateUtc,
    required this.monthKey,
  });

  final int messageId;
  final String? dateUtc;
  final String? monthKey;
}

class ConversationMessageTextMatch {
  const ConversationMessageTextMatch({
    required this.conversationId,
    required this.matchCount,
    required this.sampleText,
    this.snippets = const <ConversationMessageTextSnippet>[],
  });

  final int conversationId;
  final int matchCount;
  final String? sampleText;
  final List<ConversationMessageTextSnippet> snippets;
}

class ConversationMessageTextSnippet {
  const ConversationMessageTextSnippet({
    required this.messageId,
    required this.dateUtc,
    required this.text,
  });

  final int messageId;
  final String? dateUtc;
  final String text;
}

class ConversationActivityTrace {
  const ConversationActivityTrace({
    required this.conversationId,
    required this.months,
  });

  final int conversationId;
  final List<ConversationActivityMonth> months;
}

class ConversationActivityMonth {
  const ConversationActivityMonth({
    required this.year,
    required this.month,
    required this.messageCount,
  });

  final int year;
  final int month;
  final int messageCount;
}
