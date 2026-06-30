import '../domain/entities/attachment_recovery_metadata.dart';

AttachmentRecoveryMetadata mergeAttachmentRecoveryMetadata({
  required AttachmentRecoveryMetadata base,
  AttachmentRecoveryMetadata? persistedHint,
}) {
  if (persistedHint == null) {
    return base;
  }

  return AttachmentRecoveryMetadata(
    lastRecoveryAttemptAt:
        base.lastRecoveryAttemptAt ?? persistedHint.lastRecoveryAttemptAt,
    nextRecoveryAttemptAt:
        base.nextRecoveryAttemptAt ?? persistedHint.nextRecoveryAttemptAt,
    recoveryAttemptCount:
        base.recoveryAttemptCount >= persistedHint.recoveryAttemptCount
        ? base.recoveryAttemptCount
        : persistedHint.recoveryAttemptCount,
    recoveryPriority: base.recoveryPriority >= persistedHint.recoveryPriority
        ? base.recoveryPriority
        : persistedHint.recoveryPriority,
    userInterestRaisedAt:
        persistedHint.userInterestRaisedAt ?? base.userInterestRaisedAt,
    lastRecoveryErrorSummary:
        base.lastRecoveryErrorSummary ?? persistedHint.lastRecoveryErrorSummary,
    isNonRecoverable: base.isNonRecoverable || persistedHint.isNonRecoverable,
  );
}
