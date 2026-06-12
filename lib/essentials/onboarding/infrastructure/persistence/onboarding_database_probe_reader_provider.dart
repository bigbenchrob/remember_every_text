import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/onboarding_database_probe_reader.dart';
import 'sqlite_onboarding_database_probe_reader.dart';

part 'onboarding_database_probe_reader_provider.g.dart';

@riverpod
OnboardingDatabaseProbeReader onboardingDatabaseProbeReader(
  OnboardingDatabaseProbeReaderRef ref,
) {
  return const SqliteOnboardingDatabaseProbeReader();
}
