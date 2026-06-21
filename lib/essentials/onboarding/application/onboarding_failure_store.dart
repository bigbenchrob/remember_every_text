import '../domain/onboarding_environment_report.dart';

class PersistedOnboardingSourceImportFailure {
  const PersistedOnboardingSourceImportFailure({
    required this.failure,
    this.recordedAt,
  });

  final OnboardingPipelineFailure failure;
  final DateTime? recordedAt;
}

class PersistedOnboardingGraphProjectionResult {
  const PersistedOnboardingGraphProjectionResult({
    required this.failure,
    this.recordedAt,
  });

  final OnboardingPipelineFailure failure;
  final DateTime? recordedAt;
}

abstract interface class OnboardingFailureStore {
  Future<OnboardingPipelineFailure?> loadSourceImportFailure();

  Future<PersistedOnboardingSourceImportFailure?>
  loadSourceImportFailureEntry();

  Future<void> saveImportFailure({
    required String message,
    int batchId,
    DateTime? recordedAt,
    List<String> warnings,
  });

  Future<void> clearSourceImportFailure();

  Future<OnboardingPipelineFailure?> loadGraphProjectionResult();

  Future<PersistedOnboardingGraphProjectionResult?>
  loadGraphProjectionResultEntry();

  Future<void> saveGraphProjectionFailure({
    required String message,
    int batchId,
    DateTime? recordedAt,
  });

  Future<void> clearGraphProjectionResult();
}
