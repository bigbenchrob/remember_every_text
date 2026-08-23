import '../projection_work_progress.dart';
import 'attachment_projection_repository.dart';

class AttachmentProjector {
  const AttachmentProjector({required this.repository});

  final AttachmentProjectionRepository repository;

  Future<AttachmentProjectionResult> projectAttachments({
    GraphProjectionWorkObserver? onProgress,
  }) => repository.projectAttachments(onProgress: onProgress);

  Future<AttachmentProjectionResult> projectAttachmentsAfterSourceRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
    GraphProjectionWorkObserver? onProgress,
  }) {
    return repository.projectAttachmentsAfterSourceRowId(
      sourceId: sourceId,
      startedAfterSourceRowId: startedAfterSourceRowId,
      onProgress: onProgress,
    );
  }
}
