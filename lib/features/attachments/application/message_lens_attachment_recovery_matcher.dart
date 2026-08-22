import '../../../essentials/source_scoped_import/domain/messages_lineage_admission.dart';
import '../domain/entities/message_lens_attachment_recovery.dart';

/// Pure, fail-closed matching for the dormant MessageLens attachment-recovery
/// arm. It classifies evidence only; it never copies files or mutates stores.
class MessageLensAttachmentRecoveryMatcher {
  const MessageLensAttachmentRecoveryMatcher();

  MessageLensAttachmentRecoveryPreflight inspect({
    required SameMessagesLineageAdmission lineageAdmission,
    required List<MessageLensAttachmentRecoveryInput> inputs,
  }) {
    // Requiring the admitted subtype is the authority boundary. Per-attachment
    // identity remains independently fail-closed after archive admission.
    assert(
      lineageAdmission.status == MessagesLineageAdmissionStatus.sameLineage,
    );

    final classified = inputs.map(_classify).toList(growable: false);
    final candidates = _rejectDuplicateDestinationClaims(classified);

    return MessageLensAttachmentRecoveryPreflight(
      candidates: candidates,
      examinedCount: inputs.length,
      recoverableCount: _count(
        candidates,
        MessageLensAttachmentRecoveryClassification.recoverable,
      ),
      recoverableBytes: candidates
          .where(
            (candidate) =>
                candidate.classification ==
                MessageLensAttachmentRecoveryClassification.recoverable,
          )
          .fold(0, (sum, candidate) => sum + candidate.recoverableBytes),
      alreadyPresentCount: _count(
        candidates,
        MessageLensAttachmentRecoveryClassification.alreadyPresent,
      ),
      donorMissingCount: _count(
        candidates,
        MessageLensAttachmentRecoveryClassification.donorMissing,
      ),
      messageMismatchCount: _count(
        candidates,
        MessageLensAttachmentRecoveryClassification.messageMismatch,
      ),
      attachmentMismatchCount: _count(
        candidates,
        MessageLensAttachmentRecoveryClassification.attachmentMismatch,
      ),
      conflictCount: _count(
        candidates,
        MessageLensAttachmentRecoveryClassification.conflict,
      ),
      ambiguousCount: _count(
        candidates,
        MessageLensAttachmentRecoveryClassification.ambiguous,
      ),
      unsafeDonorPathCount: _count(
        candidates,
        MessageLensAttachmentRecoveryClassification.unsafeDonorPath,
      ),
    );
  }

  MessageLensAttachmentRecoveryCandidate _classify(
    MessageLensAttachmentRecoveryInput input,
  ) {
    final donor = input.donorRelationship;
    var classification = MessageLensAttachmentRecoveryClassification.ambiguous;

    if (!_identityIsInternallyCoherent(donor) ||
        donor.relationshipOccurrenceCount != 1) {
      classification = MessageLensAttachmentRecoveryClassification.ambiguous;
    } else {
      final messageCandidates = input.currentRelationshipCandidates
          .where(
            (candidate) =>
                candidate.originalMessageRowId == donor.originalMessageRowId,
          )
          .toList(growable: false);

      if (messageCandidates.isEmpty) {
        classification =
            MessageLensAttachmentRecoveryClassification.messageMismatch;
      } else {
        final donorMessageGuid = _normalized(donor.messageGuid);
        final messageIdentityMatches =
            donorMessageGuid.isNotEmpty &&
            messageCandidates.every(
              (candidate) =>
                  _normalized(candidate.messageGuid) == donorMessageGuid,
            );
        if (!messageIdentityMatches) {
          classification =
              MessageLensAttachmentRecoveryClassification.messageMismatch;
        } else {
          final attachmentCandidates = messageCandidates
              .where(
                (candidate) =>
                    candidate.originalAttachmentRowId ==
                    donor.originalAttachmentRowId,
              )
              .toList(growable: false);
          if (attachmentCandidates.isEmpty) {
            classification =
                MessageLensAttachmentRecoveryClassification.attachmentMismatch;
          } else if (attachmentCandidates.length != 1 ||
              !_identityIsInternallyCoherent(attachmentCandidates.single) ||
              attachmentCandidates.single.relationshipOccurrenceCount != 1) {
            classification =
                MessageLensAttachmentRecoveryClassification.ambiguous;
          } else if (!_attachmentIdentityMatches(
            donor,
            attachmentCandidates.single,
          )) {
            classification =
                MessageLensAttachmentRecoveryClassification.attachmentMismatch;
          } else {
            classification = _classifyPayload(input);
          }
        }
      }
    }

    final inspection = input.donorPayloadInspection;
    return MessageLensAttachmentRecoveryCandidate(
      archiveCompatibilityKey: donor.archiveCompatibilityKey,
      classification: classification,
      recoverableBytes:
          classification ==
              MessageLensAttachmentRecoveryClassification.recoverable
          ? inspection.actualSizeBytes ?? 0
          : 0,
      donorArchiveRelativePath: input.donorPayload.archiveRelativePath,
      donorPayloadSha256: inspection.actualSha256,
    );
  }

  static MessageLensAttachmentRecoveryClassification _classifyPayload(
    MessageLensAttachmentRecoveryInput input,
  ) {
    switch (input.currentPayloadStatus) {
      case CurrentAttachmentPayloadStatus.presentValid:
        return MessageLensAttachmentRecoveryClassification.alreadyPresent;
      case CurrentAttachmentPayloadStatus.presentConflict:
      case CurrentAttachmentPayloadStatus.inaccessible:
        return MessageLensAttachmentRecoveryClassification.conflict;
      case CurrentAttachmentPayloadStatus.missing:
        break;
    }

    switch (input.donorPayloadInspection.status) {
      case AttachmentPayloadInspectionStatus.valid:
        return MessageLensAttachmentRecoveryClassification.recoverable;
      case AttachmentPayloadInspectionStatus.missing:
        return MessageLensAttachmentRecoveryClassification.donorMissing;
      case AttachmentPayloadInspectionStatus.invalid:
        return MessageLensAttachmentRecoveryClassification.conflict;
      case AttachmentPayloadInspectionStatus.unsafePath:
        return MessageLensAttachmentRecoveryClassification.unsafeDonorPath;
    }
  }

  static bool _attachmentIdentityMatches(
    MessageLensAttachmentRelationshipEvidence donor,
    MessageLensAttachmentRelationshipEvidence current,
  ) {
    if (donor.originalAttachmentRowId != current.originalAttachmentRowId) {
      return false;
    }

    final donorGuid = _normalized(donor.attachmentGuid);
    final currentGuid = _normalized(current.attachmentGuid);
    if (donorGuid.isNotEmpty && currentGuid.isNotEmpty) {
      return donorGuid == currentGuid;
    }

    // Within an admitted continuation of the same chat.db lineage, the exact
    // message ROWID -> attachment ROWID relationship is the stable identity.
    // A GUID corroborates that relationship when both snapshots retain it;
    // absence of a GUID does not make filename or path into identity.
    return true;
  }

  static bool _identityIsInternallyCoherent(
    MessageLensAttachmentRelationshipEvidence evidence,
  ) {
    return evidence.sourceScopedIdentityIsCoherent;
  }

  static List<MessageLensAttachmentRecoveryCandidate>
  _rejectDuplicateDestinationClaims(
    List<MessageLensAttachmentRecoveryCandidate> candidates,
  ) {
    final groups = <String, List<MessageLensAttachmentRecoveryCandidate>>{};
    for (final candidate in candidates) {
      final key = candidate.archiveCompatibilityKey.storageKeySegment;
      groups.putIfAbsent(key, () => []).add(candidate);
    }

    return groups.values
        .map((group) {
          final first = group.first;
          if (group.length == 1) {
            return first;
          }

          final firstHash = first.donorPayloadSha256;
          final claimsAreByteIdentical =
              firstHash != null &&
              firstHash.isNotEmpty &&
              group.every(
                (candidate) =>
                    candidate.donorPayloadSha256 == firstHash &&
                    candidate.classification == first.classification,
              );
          if (claimsAreByteIdentical) {
            return first;
          }

          return MessageLensAttachmentRecoveryCandidate(
            archiveCompatibilityKey: first.archiveCompatibilityKey,
            classification:
                MessageLensAttachmentRecoveryClassification.ambiguous,
            recoverableBytes: 0,
            donorArchiveRelativePath: first.donorArchiveRelativePath,
            donorPayloadSha256: first.donorPayloadSha256,
          );
        })
        .toList(growable: false);
  }

  static int _count(
    List<MessageLensAttachmentRecoveryCandidate> candidates,
    MessageLensAttachmentRecoveryClassification classification,
  ) {
    return candidates
        .where((candidate) => candidate.classification == classification)
        .length;
  }

  static String _normalized(String? value) => value?.trim() ?? '';
}
