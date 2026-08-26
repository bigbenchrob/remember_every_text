import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/onboarding/feature_level_providers.dart'
    show
        onboardingGateProvider,
        onboardingJourneyCoordinatorProvider,
        onboardingReadinessActionsProvider;

part 'environment_readiness_actions_provider.g.dart';

@riverpod
class EnvironmentReadinessActions extends _$EnvironmentReadinessActions {
  @override
  FutureOr<void> build() {}

  Future<void> openFdaSettings() async {
    await ref.read(onboardingGateProvider.notifier).openFdaSettings();
  }

  void refreshEnvironment() {
    ref.read(onboardingGateProvider.notifier).refreshEnvironment();
  }

  Future<void> startImportAndGraphBuild() async {
    await ref.read(onboardingGateProvider.notifier).startImportAndGraphBuild();
  }

  void acceptLocalMessageHistory() {
    ref
        .read(onboardingJourneyCoordinatorProvider.notifier)
        .acceptLocalMessageHistory();
  }

  void clearSimulationsAndRefresh() {
    ref
        .read(onboardingReadinessActionsProvider.notifier)
        .recheckReadiness(clearSimulationOverride: true);
  }
}
