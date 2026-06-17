import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'message_data_reset_service.dart';
import 'onboarding_gate_provider.dart';

part 'onboarding_dev_panel_actions_provider.g.dart';

@riverpod
class OnboardingDevPanelActions extends _$OnboardingDevPanelActions {
  @override
  FutureOr<void> build() {}

  Future<void> resetDerivedDataAndRefreshEnvironment() async {
    await ref.read(messageDataResetServiceProvider).resetDerivedData();
    ref.read(onboardingGateProvider.notifier).refreshEnvironment();
  }
}
