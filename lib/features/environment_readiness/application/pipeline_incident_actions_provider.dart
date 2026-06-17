import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/logging/application/pipeline_incident_tracker_provider.dart';
import '../../../essentials/onboarding/application/onboarding_gate_provider.dart';

part 'pipeline_incident_actions_provider.g.dart';

@riverpod
class PipelineIncidentActions extends _$PipelineIncidentActions {
  @override
  FutureOr<void> build() {}

  Future<void> retryImportAndGraphBuild() async {
    await ref.read(onboardingGateProvider.notifier).startImportAndGraphBuild();
  }

  void dismissActiveReport() {
    ref.read(pipelineIncidentTrackerProvider.notifier).dismissActiveReport();
  }
}
