import '../projection_work_progress.dart';

class AttachmentProjectionResult {
  const AttachmentProjectionResult({
    required this.examinedAttachmentCount,
    required this.insertedAttachmentCount,
  });

  final int examinedAttachmentCount;
  final int insertedAttachmentCount;
}

abstract interface class AttachmentProjectionRepository {
  Future<AttachmentProjectionResult> projectAttachments({
    GraphProjectionWorkObserver? onProgress,
  });

  Future<AttachmentProjectionResult> projectAttachmentsAfterSourceRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
    GraphProjectionWorkObserver? onProgress,
  });
}
