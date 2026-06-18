import '../../../essentials/retained_archive/domain/archive_compatibility_key.dart';
import '../domain/entities/attachment_recovery_metadata.dart';

class AttachmentArchiveLookupRecord {
  const AttachmentArchiveLookupRecord({
    required this.archiveRelativePath,
    required this.archiveAbsolutePath,
    required this.archiveFileExists,
    required this.provenance,
  });

  final String archiveRelativePath;
  final String archiveAbsolutePath;
  final bool archiveFileExists;
  final String? provenance;
}

abstract interface class AttachmentArchiveReadStore {
  /// Reads an archive record by the current overlay archive compatibility key.
  Future<AttachmentArchiveLookupRecord?> readArchiveRecord(
    ArchiveCompatibilityKey archiveKey,
  );

  /// Reads recovery metadata by the current overlay archive compatibility key.
  Future<AttachmentRecoveryMetadata?> readRecoveryHint(
    ArchiveCompatibilityKey archiveKey,
  );
}
