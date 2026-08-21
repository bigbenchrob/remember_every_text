import 'package:flutter/foundation.dart';

enum MessageLensArchiveLineageAdmissionStatus {
  sameLineage,
  contradictoryLineage,
  insufficientEvidence,
}

/// Exact ROWID/GUID comparison facts for one MessageLens donor archive.
///
/// These facts do not identify the donor archive and do not authorize payload
/// copying. A future recovery operation must still prove every candidate
/// payload belongs to the same current message before copying it.
@immutable
final class MessageLensArchiveLineageEvidence {
  const MessageLensArchiveLineageEvidence({
    required this.donorRegisteredSourceCount,
    required this.donorLiveSourceCount,
    required this.donorMessageCount,
    required this.usableDonorIdentityCount,
    required this.blankDonorGuidCount,
    required this.inconsistentScopedIdentityCount,
    required this.duplicateDonorRowIdCount,
    required this.currentRowsInDonorRangeCount,
    required this.comparableCount,
    required this.matchingCount,
    required this.contradictionCount,
    required this.missingCurrentRowCount,
    required this.unusableCurrentGuidCount,
    required this.matchingRowIdBandCount,
  });

  static const String methodVersion = 'exact-rowid-guid-v1';

  final int donorRegisteredSourceCount;
  final int donorLiveSourceCount;
  final int donorMessageCount;
  final int usableDonorIdentityCount;
  final int blankDonorGuidCount;
  final int inconsistentScopedIdentityCount;
  final int duplicateDonorRowIdCount;
  final int currentRowsInDonorRangeCount;
  final int comparableCount;
  final int matchingCount;
  final int contradictionCount;
  final int missingCurrentRowCount;
  final int unusableCurrentGuidCount;
  final int matchingRowIdBandCount;
}

@immutable
final class MessageLensArchiveLineageAdmission {
  const MessageLensArchiveLineageAdmission({
    required this.status,
    required this.evidence,
  });

  final MessageLensArchiveLineageAdmissionStatus status;
  final MessageLensArchiveLineageEvidence evidence;
}
