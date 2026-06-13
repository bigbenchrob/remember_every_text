import '../domain/onboarding_environment_report.dart';

class PersistedOnboardingImportResult {
  const PersistedOnboardingImportResult({
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
  Future<OnboardingPipelineFailure?> loadImportResult();

  Future<PersistedOnboardingImportResult?> loadImportResultEntry();

  Future<void> saveImportFailure({
    required String message,
    int batchId,
    DateTime? recordedAt,
    List<String> warnings,
  });

  Future<void> clearImportResult();

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
