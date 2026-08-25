import '../domain/message_lens_installation_state.dart';
import '../domain/onboarding_operation_snapshot.dart';

final class MessageLensInstallationStateClassifier {
  const MessageLensInstallationStateClassifier();

  MessageLensInstallationState classify(
    MessageLensInstallationEvidence evidence,
  ) {
    final import = evidence.sourceScopedImport;
    final graph = evidence.conversationGraph;

    final preservationStoreProblem = <InstallationDatabaseEvidence>[
      evidence.overlay,
      evidence.presence,
    ].any((database) => database.exists && !database.isUsable);
    if (preservationStoreProblem) {
      return const MessageLensInstallationState(
        kind: MessageLensInstallationStateKind.remediationRequired,
        reason:
            'A preserved MessageLens store is unreadable or has an unsupported schema.',
      );
    }

    final derivedStoreProblem = <InstallationDatabaseEvidence>[
      import,
      graph,
    ].any((database) => database.exists && !database.isUsable);
    if (derivedStoreProblem) {
      return const MessageLensInstallationState(
        kind: MessageLensInstallationStateKind.remediationRequired,
        reason:
            'A derived MessageLens store is unreadable or has an unsupported schema.',
      );
    }

    final hasHistoricalSources = (import.nonLiveSourceCount ?? 0) > 0;
    final importRows = import.messageCount ?? 0;
    final graphRows = graph.messageCount ?? 0;
    final graphHasTopology =
        (graph.chatCount ?? 0) > 0 && (graph.chatMessageEdgeCount ?? 0) > 0;
    final durableCompletion =
        import.isUsable &&
        graph.isUsable &&
        importRows > 0 &&
        importRows == graphRows &&
        graphHasTopology;
    if (durableCompletion) {
      return const MessageLensInstallationState(
        kind: MessageLensInstallationStateKind.completed,
        reason:
            'The source-scoped import and Conversation Graph stores reconcile.',
      );
    }

    final snapshot = evidence.operationSnapshot;
    if (snapshot.status == OnboardingOperationStatus.completed) {
      return const MessageLensInstallationState(
        kind: MessageLensInstallationStateKind.remediationRequired,
        reason:
            'Onboarding is recorded as complete but durable installation facts do not agree.',
      );
    }
    if (hasHistoricalSources) {
      return const MessageLensInstallationState(
        kind: MessageLensInstallationStateKind.remediationRequired,
        reason:
            'An incomplete installation contains historical archive sources that must be preserved for review.',
      );
    }

    final hasDerivedArtifacts =
        import.exists || graph.exists || evidence.hasRetiredDerivedArtifacts;
    if (!hasDerivedArtifacts &&
        snapshot.status == OnboardingOperationStatus.idle) {
      return const MessageLensInstallationState(
        kind: MessageLensInstallationStateKind.virgin,
        reason: 'No consequential MessageLens import has begun.',
      );
    }

    if (_isSafelyResumable(snapshot)) {
      return const MessageLensInstallationState(
        kind: MessageLensInstallationStateKind.resumable,
        reason:
            'Current Onboarding operation evidence permits retry from a safe boundary.',
      );
    }

    return const MessageLensInstallationState(
      kind: MessageLensInstallationStateKind.abandoned,
      reason:
          'MessageLens-owned installation artifacts exist without a current resumable operation.',
    );
  }

  bool _isSafelyResumable(OnboardingOperationSnapshot snapshot) {
    return switch (snapshot.status) {
      OnboardingOperationStatus.running ||
      OnboardingOperationStatus.interrupted => true,
      OnboardingOperationStatus.failed =>
        snapshot.failure?.recoveryDisposition ==
            OnboardingOperationRecoveryDisposition.retryFromSafeBoundary,
      OnboardingOperationStatus.idle ||
      OnboardingOperationStatus.completed => false,
    };
  }
}
