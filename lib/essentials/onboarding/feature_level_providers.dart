import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/feature_level_providers.dart';
import '../logging/feature_level_providers.dart';
import 'application/derived_message_data_file_store.dart';
import 'application/full_disk_access.dart';
import 'application/onboarding_database_probe_reader.dart';
import 'application/onboarding_failure_store.dart';
import 'infrastructure/persistence/filesystem_derived_message_data_file_store.dart';
import 'infrastructure/persistence/overlay_onboarding_failure_storage.dart';
import 'infrastructure/persistence/sqlite_onboarding_database_probe_reader.dart';
import 'infrastructure/system/macos_full_disk_access.dart';

part 'feature_level_providers.g.dart';

@riverpod
OnboardingDatabaseProbeReader onboardingDatabaseProbeReader(Ref ref) {
  return SqliteOnboardingDatabaseProbeReader(
    onTableCountFailure: (dbPath, tableName, error, stackTrace) {
      _logWarningAfterProviderBuild(
        () => ref
            .read(appLoggerProvider.notifier)
            .warn(
              'OnboardingDatabaseProbeReader: failed to read table count',
              source: 'SqliteOnboardingDatabaseProbeReader',
              context: <String, Object?>{
                'dbPath': dbPath,
                'tableName': tableName,
                'error': error.toString(),
                'stackTrace': stackTrace.toString(),
              },
            ),
      );
    },
  );
}

@riverpod
OnboardingFailureStore onboardingFailureStorage(Ref ref) {
  return OverlayOnboardingFailureStorage(
    overlayDb: ref.watch(overlayDatabaseProvider.future),
    onReadFailure: (settingKey, error, stackTrace) {
      _logWarningAfterProviderBuild(
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

@riverpod
FullDiskAccess fullDiskAccess(Ref ref) {
  return MacosFullDiskAccess(
    onReadFailure: (error, stackTrace) {
      _logWarningAfterProviderBuild(
        () => ref
            .read(appLoggerProvider.notifier)
            .warn(
              'FullDiskAccess: Messages database exists but could not be read',
              source: 'MacosFullDiskAccess',
              context: <String, Object?>{
                'error': error.toString(),
                'stackTrace': stackTrace.toString(),
              },
            ),
      );
    },
  );
}

@riverpod
DerivedMessageDataFileStore derivedMessageDataFileStore(Ref ref) {
  return const FilesystemDerivedMessageDataFileStore();
}

void _logWarningAfterProviderBuild(void Function() logWarning) {
  scheduleMicrotask(logWarning);
}
