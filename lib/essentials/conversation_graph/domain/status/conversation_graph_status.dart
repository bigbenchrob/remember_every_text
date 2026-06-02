class ConversationGraphStatus {
  const ConversationGraphStatus({
    required this.chatDbPath,
    required this.importDatabaseName,
    required this.workingDatabaseName,
    required this.sourceId,
    required this.sourceMessageCount,
    required this.sourceMaxRowId,
    required this.ledgerMessageCount,
    required this.ledgerMaxSourceRowId,
    required this.ledgerMessagesNeedingEnrichment,
    required this.ledgerMessagesStillWithoutText,
    required this.workingMessageCount,
    required this.associatedMessageEdgeCount,
    required this.sourceChatCount,
    required this.importChatCount,
    required this.workingChatCount,
    required this.sourceHandleCount,
    required this.importHandleCount,
    required this.workingHandleCount,
    required this.importTopologyEdgeCount,
    required this.workingTopologyEdgeCount,
    required this.duplicateWorkingTopologyEdgeCount,
    required this.importChatToHandleEdgeCount,
    required this.workingChatToHandleEdgeCount,
    required this.duplicateWorkingChatToHandleEdgeCount,
    required this.sourceAttachmentCount,
    required this.importAttachmentCount,
    required this.workingAttachmentCount,
    required this.importMessageToAttachmentEdgeCount,
    required this.workingMessageToAttachmentEdgeCount,
    required this.duplicateWorkingMessageToAttachmentEdgeCount,
  });

  final String chatDbPath;
  final String importDatabaseName;
  final String workingDatabaseName;
  final int sourceId;
  final int sourceMessageCount;
  final int sourceMaxRowId;
  final int ledgerMessageCount;
  final int ledgerMaxSourceRowId;
  final int ledgerMessagesNeedingEnrichment;
  final int ledgerMessagesStillWithoutText;
  final int workingMessageCount;
  final int associatedMessageEdgeCount;
  final int sourceChatCount;
  final int importChatCount;
  final int workingChatCount;
  final int sourceHandleCount;
  final int importHandleCount;
  final int workingHandleCount;
  final int importTopologyEdgeCount;
  final int workingTopologyEdgeCount;
  final int duplicateWorkingTopologyEdgeCount;
  final int importChatToHandleEdgeCount;
  final int workingChatToHandleEdgeCount;
  final int duplicateWorkingChatToHandleEdgeCount;
  final int sourceAttachmentCount;
  final int importAttachmentCount;
  final int workingAttachmentCount;
  final int importMessageToAttachmentEdgeCount;
  final int workingMessageToAttachmentEdgeCount;
  final int duplicateWorkingMessageToAttachmentEdgeCount;

  int get rowIdDelta => sourceMaxRowId - ledgerMaxSourceRowId;
  int get messageCountDelta => sourceMessageCount - ledgerMessageCount;

  String get cursorState {
    if (rowIdDelta == 0) {
      return 'current';
    }
    if (rowIdDelta > 0) {
      return 'source ahead';
    }
    return 'ledger ahead';
  }
}
