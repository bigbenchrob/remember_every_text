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

  Future<void> validateCompatibility();
}

abstract interface class CurrentMessageLensAttachmentEvidenceReader
    implements MessageLensAttachmentRelationshipEvidenceReader {
  Future<CurrentAttachmentPayloadStatus> readPayloadStatus(
    ArchiveCompatibilityKey archiveKey,
  );
}
