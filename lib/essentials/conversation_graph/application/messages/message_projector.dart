import 'message_projection_repository.dart';

class MessageProjector {
  const MessageProjector({required this.repository});

  final MessageProjectionRepository repository;

  Future<MessageProjectionResult> projectMessages() =>
      repository.projectMessages();

  Future<MessageProjectionResult> projectMessagesAfterSourceRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
  }) {
    return repository.projectMessagesAfterSourceRowId(
      sourceId: sourceId,
      startedAfterSourceRowId: startedAfterSourceRowId,
    );
  }
}
