enum CompleteInstallationErasePhase { idle, preparing, erasing, failed }

final class CompleteInstallationErasePresentation {
  const CompleteInstallationErasePresentation({
    required this.occurrence,
    required this.phase,
    this.failureSummary,
  });

  const CompleteInstallationErasePresentation.idle()
    : this(occurrence: 0, phase: CompleteInstallationErasePhase.idle);

  final int occurrence;
  final CompleteInstallationErasePhase phase;
  final String? failureSummary;

  bool get isVisible => phase != CompleteInstallationErasePhase.idle;
}
