class GraphAttachmentArchiveRecord {
  const GraphAttachmentArchiveRecord({
    required this.archiveRelativePath,
    required this.archiveAbsolutePath,
    required this.archiveFileExists,
    required this.archiveCompatibilityAttachmentId,
  });

  final String archiveRelativePath;
  final String archiveAbsolutePath;
  final bool archiveFileExists;

  /// Attachment key used by the retained archive overlay table.
  ///
  /// The current archive table is compatibility storage keyed by
  /// `(message_guid, import_attachment_id)`. Graph callers should treat this
  /// value as an archive lookup key, not as canonical attachment identity.
  final int archiveCompatibilityAttachmentId;
}

abstract interface class GraphAttachmentArchiveLookup {
  Future<GraphAttachmentArchiveRecord?> readArchiveRecord({
    required int messageSsId,
    required int attachmentSsId,
  });
}
