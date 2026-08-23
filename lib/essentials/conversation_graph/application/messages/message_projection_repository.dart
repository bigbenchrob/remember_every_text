import '../projection_work_progress.dart';

class MessageProjectionResult {
  const MessageProjectionResult({
    required this.examinedMessageCount,
    required this.insertedMessageCount,
  });

  final int examinedMessageCount;
  final int insertedMessageCount;
}

abstract interface class MessageProjectionRepository {
  Future<MessageProjectionResult> projectMessages({
    GraphProjectionWorkObserver? onProgress,
  });

  Future<MessageProjectionResult> projectMessagesAfterSourceRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
    GraphProjectionWorkObserver? onProgress,
  });
}
