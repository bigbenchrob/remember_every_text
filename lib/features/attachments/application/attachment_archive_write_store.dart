import '../domain/entities/attachment_recovery_metadata.dart';

class ArchivedAttachmentWrite {
  const ArchivedAttachmentWrite({
    required this.messageGuid,
    required this.importAttachmentId,
    required this.archiveRelativePath,
    required this.archivedAtUtc,
    required this.fileSizeBytes,
    required this.contentHash,
    required this.originalLocalPath,
  });

  /// Current archive compatibility key for existing overlay archive records.
  ///
  /// These names mirror the retained archive table, but callers must not treat
  /// them as canonical graph identity.
  final String messageGuid;
  final int importAttachmentId;
  final String archiveRelativePath;
  final String archivedAtUtc;
  final int fileSizeBytes;
  final String? contentHash;
  final String? originalLocalPath;
}

class ArchiveIntegrityEntry {
  const ArchiveIntegrityEntry({
    required this.id,
    required this.relativePath,
    required this.contentHash,
  });

  final int id;
  final String relativePath;
  final String? contentHash;
}

abstract interface class AttachmentArchiveWriteStore {
  /// Reads archive storage by the current overlay archive compatibility key.
  Future<bool> hasArchiveRecord({
    required String messageGuid,
    required int importAttachmentId,
  });

  Future<void> writeArchiveRecord(ArchivedAttachmentWrite record);

  Future<List<ArchiveIntegrityEntry>> readIntegrityEntries();

  /// Reads recovery metadata by the current overlay archive compatibility key.
  Future<AttachmentRecoveryMetadata?> readRecoveryHint({
    required String messageGuid,
    required int importAttachmentId,
  });

  /// Writes recovery metadata by the current overlay archive compatibility key.
  Future<void> writeRecoveryHint({
    required String messageGuid,
    required int importAttachmentId,
    required AttachmentRecoveryMetadata metadata,
  });

  /// Clears recovery metadata by the current overlay archive compatibility key.
  Future<void> clearRecoveryHint({
    required String messageGuid,
    required int importAttachmentId,
  });
}
