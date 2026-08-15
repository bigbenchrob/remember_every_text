import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'onboarding_gate_provider.dart';
import 'onboarding_readiness_actions_provider.dart';

part 'onboarding_overlay_actions_provider.g.dart';

@riverpod
class OnboardingOverlayActions extends _$OnboardingOverlayActions {
  @override
  FutureOr<void> build() {}

  Future<void> openFullDiskAccessSettings() async {
    await ref.read(onboardingGateProvider.notifier).openFdaSettings();
  }

  void recheckEnvironment() {
    ref
        .read(onboardingReadinessActionsProvider.notifier)
        .recheckReadiness(clearSimulationOverride: false);
  }

  Future<void> startImportAndGraphBuild() async {
    await ref.read(onboardingGateProvider.notifier).startImportAndGraphBuild();
  }

  void dismiss() {
    ref.read(onboardingGateProvider.notifier).dismiss();
  }
}
