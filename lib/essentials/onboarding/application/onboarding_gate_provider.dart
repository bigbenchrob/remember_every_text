import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/onboarding_environment_report.dart';
import '../domain/onboarding_status.dart';
import 'onboarding_journey_coordinator_provider.dart';

part 'onboarding_gate_provider.g.dart';

/// Read-only compatibility projection for established presentation consumers.
///
/// Journey transitions belong exclusively to [OnboardingJourneyCoordinator].
/// The forwarding methods preserve existing caller and test seams while every
/// intent is decided by that coordinator.
@Riverpod(keepAlive: true)
class OnboardingGate extends _$OnboardingGate {
  @override
  OnboardingStatus build() {
    return ref.watch(onboardingJourneyCoordinatorProvider).compatibilityStatus;
  }

  static OnboardingStatus resolveBuildStatus({
    required AsyncValue<OnboardingEnvironmentReport> reportAsync,
    required OnboardingStatus? workflowOverrideStatus,
    required OnboardingStatus Function() fallbackBuildStatus,
  }) {
    return OnboardingJourneyCoordinator.resolveBuildStatus(
      reportAsync: reportAsync,
      workflowOverrideStatus: workflowOverrideStatus,
      fallbackBuildStatus: fallbackBuildStatus,
    );
  }

  Future<void> openFdaSettings() async {
    await ref
        .read(onboardingJourneyCoordinatorProvider.notifier)
        .openFdaSettings();
  }

  void refreshEnvironment() {
    ref
        .read(onboardingJourneyCoordinatorProvider.notifier)
        .refreshEnvironment();
  }

  Future<void> startImportAndGraphBuild() async {
    await ref
        .read(onboardingJourneyCoordinatorProvider.notifier)
        .startImportAndGraphBuild();
  }

  Future<void> startReimport() async {
    await ref
        .read(onboardingJourneyCoordinatorProvider.notifier)
        .startReimport();
  }

  void dismiss() {
    ref.read(onboardingJourneyCoordinatorProvider.notifier).dismiss();
  }
}
