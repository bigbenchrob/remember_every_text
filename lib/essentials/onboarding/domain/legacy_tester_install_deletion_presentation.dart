enum LegacyTesterInstallDeletionPhase {
  awaitingAuthorization,
  cancelled,
  preparing,
  deleting,
  handingOff,
  failed,
}

enum LegacyTesterInstallDeletionFailureKind {
  mutationUnavailable,
  virginVerificationFailed,
  executionFailed,
}

final class LegacyTesterInstallDeletionFailure {
  const LegacyTesterInstallDeletionFailure({
    required this.kind,
    required this.summary,
    required this.canRetry,
  });

  final LegacyTesterInstallDeletionFailureKind kind;
  final String summary;
  final bool canRetry;
}

final class LegacyTesterInstallDeletionPresentation {
  const LegacyTesterInstallDeletionPresentation({
    required this.occurrence,
    required this.phase,
    this.failure,
  });

  const LegacyTesterInstallDeletionPresentation.awaitingAuthorization()
    : this(
        occurrence: 0,
        phase: LegacyTesterInstallDeletionPhase.awaitingAuthorization,
      );

  final int occurrence;
  final LegacyTesterInstallDeletionPhase phase;
  final LegacyTesterInstallDeletionFailure? failure;
}
