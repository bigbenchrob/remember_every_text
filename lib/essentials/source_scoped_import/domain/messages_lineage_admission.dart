import 'package:flutter/foundation.dart';

enum MessagesLineageAdmissionStatus {
  sameLineage,
  contradictoryLineage,
  insufficientEvidence,
}

@immutable
final class MessagesLineageEvidence {
  const MessagesLineageEvidence({
    required this.candidateRecordCount,
    required this.usableCandidateIdentityCount,
    required this.blankCandidateGuidCount,
    required this.inconsistentCandidateIdentityCount,
    required this.duplicateCandidateRowIdCount,
    required this.currentRowsInCandidateRangeCount,
    required this.comparableCount,
    required this.matchingCount,
    required this.contradictionCount,
    required this.missingCurrentRowCount,
    required this.unusableCurrentGuidCount,
    required this.matchingRowIdBandCount,
    required this.candidateSourceShapeIsCoherent,
    required this.currentSourceShapeIsCoherent,
  });

  static const String methodVersion = 'exact-rowid-guid-v1';

  final int candidateRecordCount;
  final int usableCandidateIdentityCount;
  final int blankCandidateGuidCount;
  final int inconsistentCandidateIdentityCount;
  final int duplicateCandidateRowIdCount;
  final int currentRowsInCandidateRangeCount;
  final int comparableCount;
  final int matchingCount;
  final int contradictionCount;
  final int missingCurrentRowCount;
  final int unusableCurrentGuidCount;
  final int matchingRowIdBandCount;
  final bool candidateSourceShapeIsCoherent;
  final bool currentSourceShapeIsCoherent;
}

sealed class MessagesLineageAdmission {
  const MessagesLineageAdmission._({required this.evidence});

  factory MessagesLineageAdmission.fromEvidence(
    MessagesLineageEvidence evidence,
  ) {
    if (evidence.contradictionCount > 0) {
      return ContradictoryMessagesLineageAdmission._(evidence: evidence);
    }

    final evidenceIsCoherent =
        evidence.candidateSourceShapeIsCoherent &&
        evidence.currentSourceShapeIsCoherent &&
        evidence.inconsistentCandidateIdentityCount == 0 &&
        evidence.duplicateCandidateRowIdCount == 0;
    final evidenceIsSufficient =
        evidence.matchingCount >= minimumMatchingAnchorCount &&
        evidence.matchingRowIdBandCount >= minimumMatchingRowIdBandCount;

    if (evidenceIsCoherent && evidenceIsSufficient) {
      return SameMessagesLineageAdmission._(evidence: evidence);
    }

    return InsufficientMessagesLineageAdmission._(evidence: evidence);
  }

  static const int minimumMatchingAnchorCount = 64;
  static const int minimumMatchingRowIdBandCount = 3;

  final MessagesLineageEvidence evidence;
  MessagesLineageAdmissionStatus get status;
}

final class SameMessagesLineageAdmission extends MessagesLineageAdmission {
  const SameMessagesLineageAdmission._({
    required MessagesLineageEvidence evidence,
  }) : super._(evidence: evidence);

  @override
  MessagesLineageAdmissionStatus get status =>
      MessagesLineageAdmissionStatus.sameLineage;
}

final class ContradictoryMessagesLineageAdmission
    extends MessagesLineageAdmission {
  const ContradictoryMessagesLineageAdmission._({
    required MessagesLineageEvidence evidence,
  }) : super._(evidence: evidence);

  @override
  MessagesLineageAdmissionStatus get status =>
      MessagesLineageAdmissionStatus.contradictoryLineage;
}

final class InsufficientMessagesLineageAdmission
    extends MessagesLineageAdmission {
  const InsufficientMessagesLineageAdmission._({
    required MessagesLineageEvidence evidence,
  }) : super._(evidence: evidence);

  @override
  MessagesLineageAdmissionStatus get status =>
      MessagesLineageAdmissionStatus.insufficientEvidence;
}
