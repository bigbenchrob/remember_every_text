class ChatToHandleProjectionResult {
  const ChatToHandleProjectionResult({
    required this.examinedEdgeCount,
    required this.insertedEdgeCount,
  });

  final int examinedEdgeCount;
  final int insertedEdgeCount;
}

abstract interface class ChatToHandleProjectionRepository {
  Future<ChatToHandleProjectionResult> projectEdges();
}
