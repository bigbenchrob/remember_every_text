import '../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../domain/entities/message_lens_attachment_recovery.dart';

abstract interface class MessageLensAttachmentRelationshipEvidenceReader {
  Future<List<MessageLensAttachmentRelationshipEvidence>> readRelationships({
    required int sourceId,
    required int originalMessageRowId,
    required int originalAttachmentRowId,
  });

  Future<List<MessageLensAttachmentRelationshipEvidence>>
  readLiveSourceRelationships();
}

abstract interface class MessageLensDonorAttachmentEvidenceReader
    implements MessageLensAttachmentRelationshipEvidenceReader {
  Future<MessageLensArchivedPayloadEvidence?> readArchivedPayload(
    ArchiveCompatibilityKey archiveKey,
  );

  Future<List<MessageLensArchivedPayloadClaim>> readArchivedPayloadClaims();

  /// Proves that the stores expose the exact read-only evidence needed by
  /// preflight. It deliberately does not perform exhaustive database scans.
  Future<void> validateCompatibility();

  /// Performs exhaustive donor database integrity checks immediately before
  /// a future recovery execution is authorized.
  Future<void> validateExecutionIntegrity();
}

abstract interface class CurrentMessageLensAttachmentEvidenceReader
    implements MessageLensAttachmentRelationshipEvidenceReader {
  Future<Map<ArchiveCompatibilityKey, CurrentAttachmentPayloadStatus>>
  readPayloadStatuses(
    List<ArchiveCompatibilityKey> archiveKeys, {
    void Function(int completed, int total)? onProgress,
  });
}
