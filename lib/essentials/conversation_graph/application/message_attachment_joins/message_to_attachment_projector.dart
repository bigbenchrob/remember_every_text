import 'message_to_attachment_projection_repository.dart';

class MessageToAttachmentProjector {
  const MessageToAttachmentProjector({required this.repository});

  final MessageToAttachmentProjectionRepository repository;

  Future<MessageToAttachmentProjectionResult> projectEdges() =>
      repository.projectEdges();
}
