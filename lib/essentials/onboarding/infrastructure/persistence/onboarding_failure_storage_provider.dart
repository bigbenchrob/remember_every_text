import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import 'overlay_onboarding_failure_storage.dart';

part 'onboarding_failure_storage_provider.g.dart';

@riverpod
OverlayOnboardingFailureStorage onboardingFailureStorage(
  OnboardingFailureStorageRef ref,
) {
  return OverlayOnboardingFailureStorage(
    overlayDb: ref.watch(overlayDatabaseProvider.future),
  );
}
