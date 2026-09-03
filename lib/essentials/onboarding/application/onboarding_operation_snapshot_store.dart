import '../domain/onboarding_operation_snapshot.dart';

const onboardingOperationSnapshotSettingKey =
    'onboarding_operation_snapshot_v1';

abstract interface class OnboardingOperationSnapshotStore {
  Future<OnboardingOperationSnapshot?> load();

  Future<void> save(OnboardingOperationSnapshot snapshot);
}
