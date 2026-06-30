import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/logging/feature_level_providers.dart'
    show pipelineIncidentTrackerProvider;
import '../../../essentials/onboarding/feature_level_providers.dart'
    show onboardingGateProvider;

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
