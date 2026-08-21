import '../domain/entities/message_lens_archive_lineage_evidence.dart';
import 'message_lens_archive_lineage_evidence_repository.dart';

/// Fail-closed admission gate for future MessageLens attachment recovery.
///
/// The current Messages database path is fixed when this service is composed.
/// A folder chooser supplies only the donor path and therefore cannot replace
/// the authoritative current Mac Messages source for one verification call.
final class MessageLensAttachmentRecoveryLineageVerifier {
  const MessageLensAttachmentRecoveryLineageVerifier({
    required MessageLensArchiveLineageEvidenceRepository evidenceRepository,
    required String authoritativeCurrentMessagesDatabasePath,
  }) : _evidenceRepository = evidenceRepository,
       _authoritativeCurrentMessagesDatabasePath =
           authoritativeCurrentMessagesDatabasePath;

  /// A fixed safety threshold, not a sample size.
  ///
  /// The repository compares every overlapping ROWID. This threshold only
  /// prevents a very small number of coincidental matches from authorizing a
  /// donor automatically.
  static const int minimumMatchingAnchorCount = 64;
  static const int minimumMatchingRowIdBandCount = 3;

  final MessageLensArchiveLineageEvidenceRepository _evidenceRepository;
  final String _authoritativeCurrentMessagesDatabasePath;

  Future<MessageLensArchiveLineageAdmission> verifyDonor({
    required String donorImportDatabasePath,
  }) async {
    final evidence = await _evidenceRepository.compareExactly(
      donorImportDatabasePath: donorImportDatabasePath,
      authoritativeCurrentMessagesDatabasePath:
          _authoritativeCurrentMessagesDatabasePath,
    );

    return MessageLensArchiveLineageAdmission(
      status: classify(evidence),
      evidence: evidence,
    );
  }

  static MessageLensArchiveLineageAdmissionStatus classify(
    MessageLensArchiveLineageEvidence evidence,
  ) {
    if (evidence.contradictionCount > 0) {
      return MessageLensArchiveLineageAdmissionStatus.contradictoryLineage;
    }

    final donorEvidenceIsCoherent =
        evidence.donorLiveSourceCount == 1 &&
        evidence.inconsistentScopedIdentityCount == 0 &&
        evidence.duplicateDonorRowIdCount == 0;
    final evidenceIsSufficient =
        evidence.matchingCount >= minimumMatchingAnchorCount &&
        evidence.matchingRowIdBandCount >= minimumMatchingRowIdBandCount;

    if (donorEvidenceIsCoherent && evidenceIsSufficient) {
      return MessageLensArchiveLineageAdmissionStatus.sameLineage;
    }

    return MessageLensArchiveLineageAdmissionStatus.insufficientEvidence;
  }
}
