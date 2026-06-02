class MessageProjectionResult {
  const MessageProjectionResult({
    required this.examinedMessageCount,
    required this.insertedMessageCount,
  });

  final int examinedMessageCount;
  final int insertedMessageCount;
}

abstract interface class MessageProjectionRepository {
  Future<MessageProjectionResult> projectMessages();

  Future<MessageProjectionResult> projectMessagesAfterSourceRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
  });
}
