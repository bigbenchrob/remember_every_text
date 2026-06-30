class AttachmentProjectionResult {
  const AttachmentProjectionResult({
    required this.examinedAttachmentCount,
    required this.insertedAttachmentCount,
  });

  final int examinedAttachmentCount;
  final int insertedAttachmentCount;
}

abstract interface class AttachmentProjectionRepository {
  Future<AttachmentProjectionResult> projectAttachments();

  Future<AttachmentProjectionResult> projectAttachmentsAfterSourceRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
  });
}
