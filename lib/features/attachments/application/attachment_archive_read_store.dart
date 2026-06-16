import '../domain/entities/attachment_recovery_metadata.dart';
import 'archive_compatibility_key.dart';

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
  ///
  /// `messageGuid` / `importAttachmentId` mirror the retained archive table
  /// key. They are not canonical graph identity and should stay behind archive
  /// read/write boundaries until archive rows become graph-keyed or permanently
  /// bridged.
  Future<AttachmentArchiveLookupRecord?> readArchiveRecord({
    required String messageGuid,
    required int importAttachmentId,
  });

  /// Reads recovery metadata by the current overlay archive compatibility key.
  Future<AttachmentRecoveryMetadata?> readRecoveryHint(
    ArchiveCompatibilityKey archiveKey,
  );
}
