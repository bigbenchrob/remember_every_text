import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'message_data_reset_service.dart';
import 'onboarding_environment_report_provider.dart';
import 'onboarding_gate_provider.dart';
import 'onboarding_readiness_actions_provider.dart';

part 'onboarding_dev_panel_actions_provider.g.dart';

@riverpod
class OnboardingDevPanelActions extends _$OnboardingDevPanelActions {
  @override
  FutureOr<void> build() {}

  void refreshDiagnostics() {
    ref
        .read(onboardingReadinessActionsProvider.notifier)
        .recheckReadiness(clearSimulationOverride: false);
  }

  Future<void> resetDerivedDataAndRefreshEnvironment() async {
    await ref.read(messageDataResetServiceProvider).resetDerivedData();
    ref.read(onboardingGateProvider.notifier).refreshEnvironment();
  }

  void clearSimulations() {
    ref.read(onboardingDevOverridesProvider.notifier).clearAll();
  }

  void setFullDiskAccessBlocked({required bool enabled}) {
    ref
        .read(onboardingDevOverridesProvider.notifier)
        .setFullDiskAccessBlocked(enabled: enabled);
  }

  void setMessagesDatabaseMissing({required bool enabled}) {
    ref
        .read(onboardingDevOverridesProvider.notifier)
        .setMessagesDatabaseMissing(enabled: enabled);
  }

  void setAddressBookUnavailable({required bool enabled}) {
    ref
        .read(onboardingDevOverridesProvider.notifier)
        .setAddressBookUnavailable(enabled: enabled);
  }

  void setSparseSourceHistory({required bool enabled}) {
    ref
        .read(onboardingDevOverridesProvider.notifier)
        .setSparseSourceHistory(enabled: enabled);
  }

  void setImportFailure({required bool enabled}) {
    ref
        .read(onboardingDevOverridesProvider.notifier)
        .setImportFailure(enabled: enabled);
  }

  void setGraphProjectionFailure({required bool enabled}) {
    ref
        .read(onboardingDevOverridesProvider.notifier)
        .setGraphProjectionFailure(enabled: enabled);
  }
}
