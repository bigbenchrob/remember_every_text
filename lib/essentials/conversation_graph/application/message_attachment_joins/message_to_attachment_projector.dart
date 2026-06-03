import 'message_to_attachment_projection_repository.dart';

class MessageToAttachmentProjector {
  const MessageToAttachmentProjector({required this.repository});

  final MessageToAttachmentProjectionRepository repository;

  Future<MessageToAttachmentProjectionResult> projectEdges() =>
      repository.projectEdges();

  Future<MessageToAttachmentProjectionResult>
  projectEdgesAfterSourceMessageRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
  }) {
    return repository.projectEdgesAfterSourceMessageRowId(
      sourceId: sourceId,
      startedAfterSourceRowId: startedAfterSourceRowId,
    );
  }
}
