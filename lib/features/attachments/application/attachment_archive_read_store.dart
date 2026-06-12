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
  Future<AttachmentArchiveLookupRecord?> readArchiveRecord({
    required String messageGuid,
    required int importAttachmentId,
  });

  Future<AttachmentRecoveryMetadata?> readRecoveryHint({
    required String messageGuid,
    required int importAttachmentId,
  });
}
