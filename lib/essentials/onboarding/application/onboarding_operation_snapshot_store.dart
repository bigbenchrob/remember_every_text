import '../domain/onboarding_operation_snapshot.dart';

abstract interface class OnboardingOperationSnapshotStore {
  Future<OnboardingOperationSnapshot?> load();

  Future<void> save(OnboardingOperationSnapshot snapshot);
}
