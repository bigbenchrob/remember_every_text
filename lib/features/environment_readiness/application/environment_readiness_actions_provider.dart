import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/onboarding/application/onboarding_gate_provider.dart';
import '../../../essentials/onboarding/application/onboarding_readiness_actions_provider.dart';

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

  void clearSimulationsAndRefresh() {
    ref
        .read(onboardingReadinessActionsProvider.notifier)
        .recheckReadiness(clearSimulationOverride: true);
  }
}
