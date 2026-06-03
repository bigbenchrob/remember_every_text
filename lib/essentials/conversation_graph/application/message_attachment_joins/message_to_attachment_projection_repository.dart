class MessageToAttachmentProjectionResult {
  const MessageToAttachmentProjectionResult({
    required this.examinedEdgeCount,
    required this.insertedEdgeCount,
  });

  final int examinedEdgeCount;
  final int insertedEdgeCount;
}

abstract interface class MessageToAttachmentProjectionRepository {
  Future<MessageToAttachmentProjectionResult> projectEdges();

  Future<MessageToAttachmentProjectionResult>
  projectEdgesAfterSourceMessageRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
  });
}
