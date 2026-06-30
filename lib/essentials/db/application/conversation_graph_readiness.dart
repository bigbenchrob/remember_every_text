class ConversationGraphReadiness {
  const ConversationGraphReadiness({
    required this.isReady,
    required this.reason,
    required this.messageCount,
    required this.chatCount,
    required this.chatToMessageEdgeCount,
  });

  final bool isReady;
  final String reason;
  final int messageCount;
  final int chatCount;
  final int chatToMessageEdgeCount;
}

abstract interface class ConversationGraphReadinessChecker {
  ConversationGraphReadiness checkPath(String dbPath);
}
