class ArchivedAttachmentFileWrite {
  const ArchivedAttachmentFileWrite({
    required this.sourcePath,
    required this.relativePath,
    required this.fileSizeBytes,
    required this.contentHash,
  });

  final String sourcePath;
  final String relativePath;
  final int fileSizeBytes;
  final String? contentHash;
}

class ArchiveIntegrityFileCheck {
  const ArchiveIntegrityFileCheck({
    required this.fileExists,
    required this.hashMatches,
    required this.actualHash,
  });

  final bool fileExists;
  final bool? hashMatches;
  final String? actualHash;
}

abstract interface class AttachmentArchiveFileStore {
  String expandHomePath(String rawPath);

  bool fileExists(String path);

  Future<void> ensureArchiveDirectory(String archiveDirectoryPath);

  Future<ArchivedAttachmentFileWrite?> writeArchiveEntry({
    required String archiveDirectoryPath,
    required String sourcePath,
    required int importAttachmentId,
    required String? sha256Hex,
  });

  Future<ArchiveIntegrityFileCheck> checkIntegrity({
    required String archiveDirectoryPath,
    required String relativePath,
    required String? storedHash,
  });
}
