enum ArchiveAdmissionFailure {
  buildEnvironmentMismatch,
  bundleIdentifierMismatch,
  productNameMismatch,
  invalidProductionSignature,
  developmentRootOverrideNotPermitted,
  invalidDevelopmentRootOverride,
  unavailableDevelopmentRootOverride,
  nonCanonicalRoot,
  testApplicationSupportRoot,
  missingMarker,
  nonEmptyUnmarkedArchive,
  legacyTesterInspectionFailed,
  malformedMarker,
  markerCreationFailed,
  markerFormatMismatch,
  markerEnvironmentMismatch,
}

final class ArchiveAdmissionException implements Exception {
  const ArchiveAdmissionException(this.failure, this.message);

  final ArchiveAdmissionFailure failure;
  final String message;

  @override
  String toString() => 'ArchiveAdmissionException($failure): $message';
}
