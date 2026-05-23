class ChatProjectionResult {
  const ChatProjectionResult({
    required this.examinedChatCount,
    required this.insertedChatCount,
  });

  final int examinedChatCount;
  final int insertedChatCount;
}

abstract interface class ChatProjectionRepository {
  Future<ChatProjectionResult> projectChats();
}
