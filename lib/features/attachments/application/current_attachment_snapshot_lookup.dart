abstract interface class CurrentAttachmentSnapshotLookup {
  Future<bool> hasAttachmentsForSource(int sourceId);

  Future<List<int>> attachmentSsIdsForGuid({
    required int sourceId,
    required String guid,
  });
}
