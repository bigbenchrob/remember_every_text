import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/onboarding/domain/onboarding_environment_report.dart';
import '../../../../../essentials/onboarding/domain/onboarding_status.dart';
import '../../../../../essentials/onboarding/feature_level_providers.dart'
    show onboardingEnvironmentReportProvider, onboardingGateProvider;
import '../../../domain/entities/environment_readiness_surface_view_model.dart';

part 'environment_readiness_surface_provider.g.dart';

@riverpod
EnvironmentReadinessSurfaceViewModel environmentReadinessSurface(Ref ref) {
  final status = ref.watch(onboardingGateProvider);
  final report = ref.watch(onboardingEnvironmentReportProvider).valueOrNull;
  final activeStep = _activeStepFor(status: status, report: report);
  final isReady = report?.state == OnboardingEnvironmentState.ready;
  final detailsByStep = {
    for (final step in EnvironmentReadinessStepKey.values)
      step: _detailFor(activeStep: step, report: report),
  };

  return EnvironmentReadinessSurfaceViewModel(
    activeStepKey: activeStep,
    steps: _buildSteps(activeStep, allSucceeded: isReady),
    detailsByStep: detailsByStep,
    detail: detailsByStep[activeStep]!,
  );
}

EnvironmentReadinessStepKey _activeStepFor({
  required OnboardingStatus status,
  required OnboardingEnvironmentReport? report,
}) {
  if (status == OnboardingStatus.awaitingFda) {
    return EnvironmentReadinessStepKey.fullDiskAccess;
  }

  if (report == null) {
    return EnvironmentReadinessStepKey.importReadiness;
  }

  return switch (report.blockerKind) {
    OnboardingBlockerKind.fullDiskAccessMissing =>
      EnvironmentReadinessStepKey.fullDiskAccess,
    OnboardingBlockerKind.messagesDatabaseMissing ||
    OnboardingBlockerKind.sourceDataSparseOrUnsynced =>
      EnvironmentReadinessStepKey.messagesDatabase,
    OnboardingBlockerKind.addressBookUnavailable =>
      EnvironmentReadinessStepKey.contactsDatabase,
    _ => EnvironmentReadinessStepKey.importReadiness,
  };
}

List<EnvironmentReadinessStepViewModel> _buildSteps(
  EnvironmentReadinessStepKey activeStep, {
  required bool allSucceeded,
}) {
  const orderedKeys = EnvironmentReadinessStepKey.values;
  final activeIndex = orderedKeys.indexOf(activeStep);

  return orderedKeys.indexed.map((entry) {
    final index = entry.$1;
    final key = entry.$2;
    final status = allSucceeded
        ? EnvironmentReadinessStepStatus.success
        : index < activeIndex
        ? EnvironmentReadinessStepStatus.success
        : index == activeIndex
        ? EnvironmentReadinessStepStatus.active
        : EnvironmentReadinessStepStatus.pending;

    return switch (key) {
      EnvironmentReadinessStepKey.fullDiskAccess =>
        EnvironmentReadinessStepViewModel(
          key: key,
          title: 'Full Disk Access',
          subtitle: 'Permission to read protected macOS databases',
          status: status,
        ),
      EnvironmentReadinessStepKey.messagesDatabase =>
        EnvironmentReadinessStepViewModel(
          key: key,
          title: 'Messages Database',
          subtitle: 'Local Messages history must be present on this Mac',
          status: status,
        ),
      EnvironmentReadinessStepKey.contactsDatabase =>
        EnvironmentReadinessStepViewModel(
          key: key,
          title: 'Contacts Database',
          subtitle: 'Names and contact details improve message context',
          status: status,
        ),
      EnvironmentReadinessStepKey.importReadiness =>
        EnvironmentReadinessStepViewModel(
          key: key,
          title: 'Import Readiness',
          subtitle: 'App storage and pipeline setup are ready for import',
          status: status,
        ),
    };
  }).toList();
}

EnvironmentReadinessDetailViewModel _detailFor({
  required EnvironmentReadinessStepKey activeStep,
  required OnboardingEnvironmentReport? report,
}) {
  switch (activeStep) {
    case EnvironmentReadinessStepKey.fullDiskAccess:
      return const EnvironmentReadinessDetailViewModel(
        stepKey: EnvironmentReadinessStepKey.fullDiskAccess,
        title: 'Grant Full Disk Access',
        body:
            "MessageLens needs permission to read your Messages and Contacts databases so it can import your history into the app. It cannot modify Apple's databases, and your data stays on this Mac.",
        instructions: [
          'Click Open System Settings below.',
          'Add MessageLens to Full Disk Access, or turn it on if it is already listed.',
          'When macOS asks, quit and reopen the app.',
          'Come back here and re-check the environment.',
        ],
        actions: [
          EnvironmentReadinessAction(
            kind: EnvironmentReadinessActionKind.openSettings,
            label: 'Open System Settings',
          ),
          EnvironmentReadinessAction(
            kind: EnvironmentReadinessActionKind.recheck,
            label: 'Re-check',
          ),
        ],
        tone: EnvironmentReadinessTone.warning,
      );
    case EnvironmentReadinessStepKey.messagesDatabase:
      return EnvironmentReadinessDetailViewModel(
        stepKey: EnvironmentReadinessStepKey.messagesDatabase,
        title: 'Confirm Local Messages History',
        body:
            'MessageLens can only import what is stored locally on this Mac. If Messages history has not been downloaded here yet, setup cannot continue even though the app itself is working normally.',
        instructions: [
          'Open Apple Messages on this Mac and leave it running for a moment.',
          'Confirm you are signed into the expected Apple Account and that your history is appearing locally.',
          'If this Mac has little or no history, wait for Messages to sync, then re-check here.',
        ],
        actions: const [
          EnvironmentReadinessAction(
            kind: EnvironmentReadinessActionKind.recheck,
            label: 'Re-check',
          ),
        ],
        tone:
            report?.blockerKind == OnboardingBlockerKind.messagesDatabaseMissing
            ? EnvironmentReadinessTone.warning
            : EnvironmentReadinessTone.primary,
      );
    case EnvironmentReadinessStepKey.contactsDatabase:
      return const EnvironmentReadinessDetailViewModel(
        stepKey: EnvironmentReadinessStepKey.contactsDatabase,
        title: 'Confirm Contacts Data',
        body:
            'MessageLens reads local Contacts data to show names and relationship context more clearly. This improves navigation and understanding, but the data remains on this Mac.',
        instructions: [
          'Make sure Contacts data is present on this Mac.',
          'If you recently changed privacy or sync settings, wait a moment for local data to settle.',
          'Use Re-check once Contacts appears available again.',
        ],
        actions: [
          EnvironmentReadinessAction(
            kind: EnvironmentReadinessActionKind.recheck,
            label: 'Re-check',
          ),
        ],
        tone: EnvironmentReadinessTone.warning,
      );
    case EnvironmentReadinessStepKey.importReadiness:
      final isReady = report?.state == OnboardingEnvironmentState.ready;
      final isGraphProjectionRetry =
          report?.state == OnboardingEnvironmentState.graphProjectionFailed ||
          report?.blockerKind == OnboardingBlockerKind.graphProjectionFailed;
      final isImportRetry =
          report?.state == OnboardingEnvironmentState.importFailed ||
          report?.blockerKind == OnboardingBlockerKind.importFailed;
      final isRetry = isImportRetry || isGraphProjectionRetry;
      final label = isGraphProjectionRetry
          ? 'Retry Import and Graph Build'
          : isImportRetry
          ? 'Try Import Again'
          : 'Import My Messages';

      return EnvironmentReadinessDetailViewModel(
        stepKey: EnvironmentReadinessStepKey.importReadiness,
        title: isReady
            ? 'Ready To Use'
            : isRetry
            ? 'Retry Setup'
            : 'Ready To Import',
        body: isReady
            ? 'MessageLens can read the required local sources and the conversation graph is available for normal browsing.'
            : isRetry
            ? 'MessageLens reached the import pipeline, but the last setup attempt did not finish cleanly. You can retry from here or send a report to the developer with diagnostic logs.'
            : 'The required local permissions and sources appear ready. The next step is importing your Messages and Contacts data into the app.',
        instructions: isReady
            ? [
                'Continue using MessageLens normally.',
                'If new messages do not appear, re-check this panel and then use the graph status panel for live-update details.',
              ]
            : isRetry
            ? [
                'Review the machine view below to confirm the local sources still look healthy.',
                'Start setup again to retry import and graph build.',
                'If the problem repeats, use Send Report To Developer to have MessageLens prepare an email with the diagnostic report attached when possible.',
              ]
            : [
                'Start the import when you are ready.',
                'MessageLens will copy local Messages and Contacts data into its own app databases.',
                'When setup finishes, the app will move into the normal browsing experience.',
              ],
        actions: [
          if (!isReady)
            EnvironmentReadinessAction(
              kind: EnvironmentReadinessActionKind.startImport,
              label: label,
            ),
          if (isRetry)
            const EnvironmentReadinessAction(
              kind: EnvironmentReadinessActionKind.sendReport,
              label: 'Send Report To Developer',
            ),
          const EnvironmentReadinessAction(
            kind: EnvironmentReadinessActionKind.recheck,
            label: 'Re-check',
          ),
        ],
        tone: isRetry
            ? EnvironmentReadinessTone.warning
            : EnvironmentReadinessTone.success,
      );
  }
}
