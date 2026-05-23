class ChatToMessageProjectionResult {
  const ChatToMessageProjectionResult({
    required this.examinedEdgeCount,
    required this.insertedEdgeCount,
  });

  final int examinedEdgeCount;
  final int insertedEdgeCount;
}

abstract interface class ChatToMessageProjectionRepository {
  Future<ChatToMessageProjectionResult> projectEdges();
}
