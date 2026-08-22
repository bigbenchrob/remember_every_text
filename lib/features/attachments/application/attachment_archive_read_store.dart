import '../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../domain/entities/attachment_recovery_metadata.dart';

class AttachmentArchiveLookupRecord {
  const AttachmentArchiveLookupRecord({
    required this.archiveRelativePath,
    required this.archiveAbsolutePath,
    required this.archiveFileExists,
    required this.fileSizeBytes,
    required this.contentHash,
    required this.provenance,
  });

  final String archiveRelativePath;
  final String archiveAbsolutePath;
  final bool archiveFileExists;
  final int? fileSizeBytes;
  final String? contentHash;
  final String? provenance;
}

class AttachmentArchiveMetadataRecord {
  const AttachmentArchiveMetadataRecord({
    required this.archiveRelativePath,
    required this.fileSizeBytes,
    required this.contentHash,
  });

  final String archiveRelativePath;
  final int? fileSizeBytes;
  final String? contentHash;
}

abstract interface class AttachmentArchiveReadStore {
  /// Reads the current archive metadata in one snapshot for bounded comparison
  /// work. Physical payloads are inspected separately in one filesystem pass.
  Future<Map<ArchiveCompatibilityKey, AttachmentArchiveMetadataRecord>>
  readAllArchiveMetadata();

  /// Reads an archive record by the current overlay archive compatibility key.
  Future<AttachmentArchiveLookupRecord?> readArchiveRecord(
    ArchiveCompatibilityKey archiveKey,
  );

  /// Reads recovery metadata by the current overlay archive compatibility key.
  Future<AttachmentRecoveryMetadata?> readRecoveryHint(
    ArchiveCompatibilityKey archiveKey,
  );
}
