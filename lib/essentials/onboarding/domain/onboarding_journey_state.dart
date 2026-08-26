import 'onboarding_environment_report.dart';
import 'onboarding_status.dart';

enum OnboardingJourneyEpisode {
  checkingPrerequisites,
  establishingMessagesAccess,
  confirmingLocalMessageHistory,
  establishingContactsAccess,
  readyToImport,
  recoveringDerivedData,
  preparingImport,
  buildingLocalData,
  verifyingDurableReadiness,
  operationFailed,
  readyToStart,
  normalApplication,
  reimporting,
  reimportReady,
}

final class OnboardingPrerequisiteEvidence {
  const OnboardingPrerequisiteEvidence({
    required this.revision,
    required this.observedAtUtc,
    required this.report,
  });

  final int revision;
  final DateTime observedAtUtc;
  final OnboardingEnvironmentReport report;
}

sealed class OnboardingJourneyState {
  const OnboardingJourneyState({
    required this.occurrence,
    required this.episode,
    required this.compatibilityStatus,
    this.evidence,
    this.transitionReason,
  });

  final int occurrence;
  final OnboardingJourneyEpisode episode;
  final OnboardingStatus compatibilityStatus;
  final OnboardingPrerequisiteEvidence? evidence;
  final String? transitionReason;

  bool get ownsFirstRunPresentation {
    return switch (this) {
      OnboardingNormalApplication() ||
      OnboardingReimporting() ||
      OnboardingReimportReady() => false,
      _ => true,
    };
  }
}

final class OnboardingCheckingPrerequisites extends OnboardingJourneyState {
  const OnboardingCheckingPrerequisites({
    required super.occurrence,
    super.transitionReason,
  }) : super(
         episode: OnboardingJourneyEpisode.checkingPrerequisites,
         compatibilityStatus: OnboardingStatus.awaitingUserAction,
       );
}

final class OnboardingNeedsMessagesAccess extends OnboardingJourneyState {
  const OnboardingNeedsMessagesAccess({
    required super.occurrence,
    required OnboardingPrerequisiteEvidence super.evidence,
    super.transitionReason,
  }) : super(
         episode: OnboardingJourneyEpisode.establishingMessagesAccess,
         compatibilityStatus: OnboardingStatus.awaitingFda,
       );
}

final class OnboardingNeedsLocalHistoryConfirmation
    extends OnboardingJourneyState {
  const OnboardingNeedsLocalHistoryConfirmation({
    required super.occurrence,
    required OnboardingPrerequisiteEvidence super.evidence,
    super.transitionReason,
  }) : super(
         episode: OnboardingJourneyEpisode.confirmingLocalMessageHistory,
         compatibilityStatus: OnboardingStatus.awaitingUserAction,
       );
}

final class OnboardingNeedsContactsAccess extends OnboardingJourneyState {
  const OnboardingNeedsContactsAccess({
    required super.occurrence,
    required OnboardingPrerequisiteEvidence super.evidence,
    super.transitionReason,
  }) : super(
         episode: OnboardingJourneyEpisode.establishingContactsAccess,
         compatibilityStatus: OnboardingStatus.awaitingUserAction,
       );
}

final class OnboardingReadyToImport extends OnboardingJourneyState {
  const OnboardingReadyToImport({
    required super.occurrence,
    required OnboardingPrerequisiteEvidence super.evidence,
    required this.localHistoryAccepted,
    super.transitionReason,
  }) : super(
         episode: OnboardingJourneyEpisode.readyToImport,
         compatibilityStatus: OnboardingStatus.awaitingUserAction,
       );

  final bool localHistoryAccepted;
}

final class OnboardingRecoveringDerivedData extends OnboardingJourneyState {
  const OnboardingRecoveringDerivedData({
    required super.occurrence,
    super.transitionReason,
  }) : super(
         episode: OnboardingJourneyEpisode.recoveringDerivedData,
         compatibilityStatus: OnboardingStatus.recoveringFailedAttempt,
       );
}

final class OnboardingPreparingImport extends OnboardingJourneyState {
  const OnboardingPreparingImport({
    required super.occurrence,
    super.transitionReason,
  }) : super(
         episode: OnboardingJourneyEpisode.preparingImport,
         compatibilityStatus: OnboardingStatus.importing,
       );
}

final class OnboardingBuildingLocalData extends OnboardingJourneyState {
  const OnboardingBuildingLocalData({
    required super.occurrence,
    super.transitionReason,
  }) : super(
         episode: OnboardingJourneyEpisode.buildingLocalData,
         compatibilityStatus: OnboardingStatus.buildingGraph,
       );
}

final class OnboardingVerifyingDurableReadiness extends OnboardingJourneyState {
  const OnboardingVerifyingDurableReadiness({
    required super.occurrence,
    super.transitionReason,
  }) : super(
         episode: OnboardingJourneyEpisode.verifyingDurableReadiness,
         compatibilityStatus: OnboardingStatus.buildingGraph,
       );
}

final class OnboardingOperationFailed extends OnboardingJourneyState {
  const OnboardingOperationFailed({
    required super.occurrence,
    required this.summary,
    required OnboardingStatus compatibilityStatus,
    super.evidence,
    super.transitionReason,
  }) : super(
         episode: OnboardingJourneyEpisode.operationFailed,
         compatibilityStatus: compatibilityStatus,
       );

  final String summary;
}

final class OnboardingReadyToStart extends OnboardingJourneyState {
  const OnboardingReadyToStart({
    required super.occurrence,
    super.transitionReason,
  }) : super(
         episode: OnboardingJourneyEpisode.readyToStart,
         compatibilityStatus: OnboardingStatus.complete,
       );
}

final class OnboardingNormalApplication extends OnboardingJourneyState {
  const OnboardingNormalApplication({
    required super.occurrence,
    super.evidence,
    super.transitionReason,
  }) : super(
         episode: OnboardingJourneyEpisode.normalApplication,
         compatibilityStatus: OnboardingStatus.notNeeded,
       );
}

final class OnboardingReimporting extends OnboardingJourneyState {
  const OnboardingReimporting({
    required super.occurrence,
    required OnboardingStatus status,
    super.transitionReason,
  }) : assert(
         status == OnboardingStatus.reimporting ||
             status == OnboardingStatus.reimportBuildingGraph,
       ),
       super(
         episode: OnboardingJourneyEpisode.reimporting,
         compatibilityStatus: status,
       );
}

final class OnboardingReimportReady extends OnboardingJourneyState {
  const OnboardingReimportReady({
    required super.occurrence,
    super.transitionReason,
  }) : super(
         episode: OnboardingJourneyEpisode.reimportReady,
         compatibilityStatus: OnboardingStatus.reimportComplete,
       );
}

final class OnboardingJourneyDiagnosticSnapshot {
  const OnboardingJourneyDiagnosticSnapshot({
    required this.episode,
    required this.occurrence,
    required this.evidenceRevision,
    required this.environmentState,
    required this.blockerKind,
    required this.operationStatus,
    required this.installationClassification,
    required this.lastTransitionReason,
  });

  final OnboardingJourneyEpisode episode;
  final int occurrence;
  final int? evidenceRevision;
  final OnboardingEnvironmentState? environmentState;
  final OnboardingBlockerKind? blockerKind;
  final String operationStatus;
  final String installationClassification;
  final String? lastTransitionReason;
}

bool onboardingJourneyAllowsCommandedTransition(
  OnboardingStatus from,
  OnboardingStatus to,
) {
  if (from == to) {
    return true;
  }
  return switch (from) {
    OnboardingStatus.awaitingFda =>
      to == OnboardingStatus.awaitingUserAction ||
          to == OnboardingStatus.recoveringFailedAttempt ||
          to == OnboardingStatus.preparationFailed,
    OnboardingStatus.awaitingUserAction || OnboardingStatus.preparationFailed =>
      to == OnboardingStatus.awaitingFda ||
          to == OnboardingStatus.importing ||
          to == OnboardingStatus.recoveringFailedAttempt ||
          to == OnboardingStatus.awaitingUserAction ||
          to == OnboardingStatus.preparationFailed,
    OnboardingStatus.recoveringFailedAttempt =>
      to == OnboardingStatus.awaitingUserAction ||
          to == OnboardingStatus.preparationFailed,
    OnboardingStatus.importing =>
      to == OnboardingStatus.awaitingFda ||
          to == OnboardingStatus.buildingGraph ||
          to == OnboardingStatus.preparationFailed,
    OnboardingStatus.buildingGraph =>
      to == OnboardingStatus.complete ||
          to == OnboardingStatus.awaitingUserAction ||
          to == OnboardingStatus.preparationFailed,
    OnboardingStatus.complete => to == OnboardingStatus.notNeeded,
    OnboardingStatus.notNeeded =>
      to == OnboardingStatus.reimporting ||
          to == OnboardingStatus.awaitingFda ||
          to == OnboardingStatus.awaitingUserAction,
    OnboardingStatus.reimporting =>
      to == OnboardingStatus.reimportBuildingGraph ||
          to == OnboardingStatus.preparationFailed,
    OnboardingStatus.reimportBuildingGraph =>
      to == OnboardingStatus.reimportComplete ||
          to == OnboardingStatus.awaitingUserAction ||
          to == OnboardingStatus.preparationFailed,
    OnboardingStatus.reimportComplete => to == OnboardingStatus.notNeeded,
  };
}
