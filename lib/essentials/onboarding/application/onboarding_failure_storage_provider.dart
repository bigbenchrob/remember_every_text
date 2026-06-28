import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart' show overlayDatabaseProvider;
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../infrastructure/persistence/overlay_onboarding_failure_storage.dart';
import 'onboarding_failure_store.dart';

part 'onboarding_failure_storage_provider.g.dart';

@riverpod
OnboardingFailureStore onboardingFailureStorage(Ref ref) {
  return OverlayOnboardingFailureStorage(
    overlayDb: ref.watch(overlayDatabaseProvider.future),
    onReadFailure: (settingKey, error, stackTrace) {
      scheduleMicrotask(
        () => ref
            .read(appLoggerProvider.notifier)
            .warn(
              'OnboardingFailureStorage: ignored unreadable persisted failure state',
              source: 'OverlayOnboardingFailureStorage',
              context: <String, Object?>{
                'settingKey': settingKey,
                'error': error.toString(),
                'stackTrace': stackTrace.toString(),
              },
            ),
      );
    },
  );
}
