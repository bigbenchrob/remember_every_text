class ConversationGraphStatus {
  const ConversationGraphStatus({
    required this.chatDbPath,
    required this.importDatabaseName,
    required this.graphDatabaseName,
    required this.sourceId,
    required this.sourceMessageCount,
    required this.sourceMaxRowId,
    required this.ledgerMessageCount,
    required this.ledgerMaxSourceRowId,
    required this.ledgerMessagesNeedingEnrichment,
    required this.ledgerMessagesStillWithoutText,
    required this.graphMessageCount,
    required this.associatedMessageEdgeCount,
    required this.sourceChatCount,
    required this.importChatCount,
    required this.graphChatCount,
    required this.sourceHandleCount,
    required this.importHandleCount,
    required this.graphHandleCount,
    required this.importTopologyEdgeCount,
    required this.graphTopologyEdgeCount,
    required this.duplicateGraphTopologyEdgeCount,
    required this.importChatToHandleEdgeCount,
    required this.graphChatToHandleEdgeCount,
    required this.duplicateGraphChatToHandleEdgeCount,
    required this.sourceAttachmentCount,
    required this.importAttachmentCount,
    required this.graphAttachmentCount,
    required this.importMessageToAttachmentEdgeCount,
    required this.graphMessageToAttachmentEdgeCount,
    required this.duplicateGraphMessageToAttachmentEdgeCount,
  });

  final String chatDbPath;
  final String importDatabaseName;
  final String graphDatabaseName;
  final int sourceId;
  final int sourceMessageCount;
  final int sourceMaxRowId;
  final int ledgerMessageCount;
  final int ledgerMaxSourceRowId;
  final int ledgerMessagesNeedingEnrichment;
  final int ledgerMessagesStillWithoutText;
  final int graphMessageCount;
  final int associatedMessageEdgeCount;
  final int sourceChatCount;
  final int importChatCount;
  final int graphChatCount;
  final int sourceHandleCount;
  final int importHandleCount;
  final int graphHandleCount;
  final int importTopologyEdgeCount;
  final int graphTopologyEdgeCount;
  final int duplicateGraphTopologyEdgeCount;
  final int importChatToHandleEdgeCount;
  final int graphChatToHandleEdgeCount;
  final int duplicateGraphChatToHandleEdgeCount;
  final int sourceAttachmentCount;
  final int importAttachmentCount;
  final int graphAttachmentCount;
  final int importMessageToAttachmentEdgeCount;
  final int graphMessageToAttachmentEdgeCount;
  final int duplicateGraphMessageToAttachmentEdgeCount;

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
