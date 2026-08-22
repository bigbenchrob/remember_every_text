import '../../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';

/// One Apple Messages message-to-attachment relationship observed in a
/// MessageLens source-scoped import ledger.
class MessageLensAttachmentRelationshipEvidence {
  const MessageLensAttachmentRelationshipEvidence({
    required this.messageSsId,
    required this.messageSourceId,
    required this.originalMessageRowId,
    required this.messageGuid,
    required this.attachmentSsId,
    required this.attachmentSourceId,
    required this.originalAttachmentRowId,
    required this.attachmentGuid,
    required this.relationshipOccurrenceCount,
    required this.sourceScopedIdentityIsCoherent,
    this.filename,
    this.transferName,
    this.mimeType,
    this.uti,
    this.totalBytes,
  });

  final int messageSsId;
  final int messageSourceId;
  final int originalMessageRowId;
  final String messageGuid;
  final int attachmentSsId;
  final int attachmentSourceId;
  final int originalAttachmentRowId;
  final String? attachmentGuid;
  final int relationshipOccurrenceCount;
  final bool sourceScopedIdentityIsCoherent;
  final String? filename;
  final String? transferName;
  final String? mimeType;
  final String? uti;
  final int? totalBytes;

  ArchiveCompatibilityKey get archiveCompatibilityKey {
    return ArchiveCompatibilityKey.fromStoredTuple(
      messageGuid: messageGuid,
      importAttachmentId: originalAttachmentRowId,
    );
  }
}

/// Preservation metadata stored beside one archived MessageLens payload.
class MessageLensArchivedPayloadEvidence {
  const MessageLensArchivedPayloadEvidence({
    required this.archiveRelativePath,
    required this.recordedSizeBytes,
    required this.recordedSha256,
  });

  final String archiveRelativePath;
  final int recordedSizeBytes;
  final String? recordedSha256;
}

class MessageLensArchivedPayloadClaim {
  const MessageLensArchivedPayloadClaim({
    required this.archiveCompatibilityKey,
    required this.payload,
  });

  final ArchiveCompatibilityKey archiveCompatibilityKey;
  final MessageLensArchivedPayloadEvidence payload;
}

enum AttachmentPayloadInspectionStatus { valid, missing, invalid, unsafePath }

/// Read-only physical evidence for one archived payload.
class AttachmentPayloadInspection {
  const AttachmentPayloadInspection({
    required this.status,
    required this.actualSizeBytes,
    required this.actualSha256,
  });

  const AttachmentPayloadInspection.missing()
    : status = AttachmentPayloadInspectionStatus.missing,
      actualSizeBytes = null,
      actualSha256 = null;

  const AttachmentPayloadInspection.unsafePath()
    : status = AttachmentPayloadInspectionStatus.unsafePath,
      actualSizeBytes = null,
      actualSha256 = null;

  final AttachmentPayloadInspectionStatus status;
  final int? actualSizeBytes;
  final String? actualSha256;
}

enum CurrentAttachmentPayloadStatus {
  missing,
  presentValid,
  presentConflict,
  inaccessible,
}

enum MessageLensAttachmentRecoveryClassification {
  recoverable,
  alreadyPresent,
  donorMissing,
  messageMismatch,
  attachmentMismatch,
  conflict,
  ambiguous,
  unsafeDonorPath,
}

class MessageLensAttachmentRecoveryInput {
  const MessageLensAttachmentRecoveryInput({
    required this.donorRelationship,
    required this.currentRelationshipCandidates,
    required this.donorPayload,
    required this.donorPayloadInspection,
    required this.currentPayloadStatus,
  });

  final MessageLensAttachmentRelationshipEvidence donorRelationship;
  final List<MessageLensAttachmentRelationshipEvidence>
  currentRelationshipCandidates;
  final MessageLensArchivedPayloadEvidence donorPayload;
  final AttachmentPayloadInspection donorPayloadInspection;
  final CurrentAttachmentPayloadStatus currentPayloadStatus;
}

class MessageLensAttachmentRecoveryCandidate {
  const MessageLensAttachmentRecoveryCandidate({
    required this.archiveCompatibilityKey,
    required this.classification,
    required this.recoverableBytes,
    required this.donorArchiveRelativePath,
    required this.donorPayloadSha256,
  });

  final ArchiveCompatibilityKey archiveCompatibilityKey;
  final MessageLensAttachmentRecoveryClassification classification;
  final int recoverableBytes;
  final String donorArchiveRelativePath;
  final String? donorPayloadSha256;
}

/// Read-only evidence funnel behind one attachment-recovery preflight.
///
/// These counts explain where claims stop progressing without changing any
/// matching or recovery authority. The terminal classifications remain the
/// product decision; this object is diagnostic evidence only.
class MessageLensAttachmentRecoveryFunnel {
  const MessageLensAttachmentRecoveryFunnel({
    required this.donorPayloadClaimCount,
    required this.donorRelationshipEvidenceCount,
    required this.currentRelationshipEvidenceCount,
    required this.donorRelationshipUnmatchedCount,
    required this.messageMatchedCount,
    required this.attachmentMatchedCount,
    required this.donorPayloadPresentCount,
    required this.currentPayloadPresentCount,
    required this.duplicateClaimsCollapsedCount,
  });

  final int donorPayloadClaimCount;
  final int donorRelationshipEvidenceCount;
  final int currentRelationshipEvidenceCount;
  final int donorRelationshipUnmatchedCount;
  final int messageMatchedCount;
  final int attachmentMatchedCount;
  final int donorPayloadPresentCount;
  final int currentPayloadPresentCount;
  final int duplicateClaimsCollapsedCount;
}

class MessageLensAttachmentRecoveryPreflight {
  const MessageLensAttachmentRecoveryPreflight({
    required this.candidates,
    required this.funnel,
    required this.examinedCount,
    required this.recoverableCount,
    required this.recoverableBytes,
    required this.alreadyPresentCount,
    required this.donorMissingCount,
    required this.messageMismatchCount,
    required this.attachmentMismatchCount,
    required this.conflictCount,
    required this.ambiguousCount,
    required this.unsafeDonorPathCount,
  });

  final List<MessageLensAttachmentRecoveryCandidate> candidates;
  final MessageLensAttachmentRecoveryFunnel funnel;
  final int examinedCount;
  final int recoverableCount;
  final int recoverableBytes;
  final int alreadyPresentCount;
  final int donorMissingCount;
  final int messageMismatchCount;
  final int attachmentMismatchCount;
  final int conflictCount;
  final int ambiguousCount;
  final int unsafeDonorPathCount;

  int get terminalClassificationCount {
    return recoverableCount +
        alreadyPresentCount +
        donorMissingCount +
        messageMismatchCount +
        attachmentMismatchCount +
        conflictCount +
        ambiguousCount +
        unsafeDonorPathCount;
  }

  bool get classificationCountsReconcile {
    return terminalClassificationCount + funnel.duplicateClaimsCollapsedCount ==
        examinedCount;
  }
}
