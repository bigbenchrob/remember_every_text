import 'attachment_projection_repository.dart';

class AttachmentProjector {
  const AttachmentProjector({required this.repository});

  final AttachmentProjectionRepository repository;

  Future<AttachmentProjectionResult> projectAttachments() =>
      repository.projectAttachments();

  Future<AttachmentProjectionResult> projectAttachmentsAfterSourceRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
  }) {
    return repository.projectAttachmentsAfterSourceRowId(
      sourceId: sourceId,
      startedAfterSourceRowId: startedAfterSourceRowId,
    );
  }
}
