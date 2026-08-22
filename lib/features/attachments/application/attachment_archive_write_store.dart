import '../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../domain/entities/attachment_recovery_metadata.dart';

class ArchivedAttachmentWrite {
  const ArchivedAttachmentWrite({
    required this.archiveKey,
    required this.archiveRelativePath,
    required this.archivedAtUtc,
    required this.fileSizeBytes,
    required this.contentHash,
    this.provenance = 'archived',
    required this.originalLocalPath,
  });

  /// Current archive compatibility key for existing overlay archive records.
  final ArchiveCompatibilityKey archiveKey;
  final String archiveRelativePath;
  final String archivedAtUtc;
  final int fileSizeBytes;
  final String? contentHash;
  final String provenance;
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
  Future<bool> hasArchiveRecord(ArchiveCompatibilityKey archiveKey);

  Future<void> writeArchiveRecord(ArchivedAttachmentWrite record);

  /// Reconciles metadata after a verified payload exists. This is idempotent
  /// for crash recovery and never precedes physical installation.
  Future<void> reconcileArchiveRecord(ArchivedAttachmentWrite record);

  Future<List<ArchiveIntegrityEntry>> readIntegrityEntries();

  /// Reads recovery metadata by the current overlay archive compatibility key.
  Future<AttachmentRecoveryMetadata?> readRecoveryHint(
    ArchiveCompatibilityKey archiveKey,
  );

  /// Writes recovery metadata by the current overlay archive compatibility key.
  Future<void> writeRecoveryHint({
    required ArchiveCompatibilityKey archiveKey,
    required AttachmentRecoveryMetadata metadata,
  });

  /// Clears recovery metadata by the current overlay archive compatibility key.
  Future<void> clearRecoveryHint(ArchiveCompatibilityKey archiveKey);
}
