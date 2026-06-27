import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../infrastructure/persistence/sqlite_onboarding_database_probe_reader.dart';
import 'onboarding_database_probe_reader.dart';

part 'onboarding_database_probe_reader_provider.g.dart';

@riverpod
OnboardingDatabaseProbeReader onboardingDatabaseProbeReader(Ref ref) {
  return SqliteOnboardingDatabaseProbeReader(
    onTableCountFailure: (dbPath, tableName, error, stackTrace) {
      scheduleMicrotask(
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
