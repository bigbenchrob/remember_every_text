class GraphAttachmentArchiveRecord {
  const GraphAttachmentArchiveRecord({
    required this.archiveRelativePath,
    required this.archiveAbsolutePath,
    required this.archiveFileExists,
    required this.legacyImportAttachmentId,
  });

  final String archiveRelativePath;
  final String archiveAbsolutePath;
  final bool archiveFileExists;
  final int legacyImportAttachmentId;
}

abstract interface class GraphAttachmentArchiveLookup {
  Future<GraphAttachmentArchiveRecord?> readArchiveRecord({
    required int messageSsId,
    required int attachmentSsId,
  });
}
