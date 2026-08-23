import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../../db/app_database_files.dart';
import 'onboarding_database_probe_reader.dart';
import 'onboarding_database_probe_reader_provider.dart';
import 'onboarding_operation_snapshot_controller.dart';

part 'onboarding_durable_completion_verifier_provider.g.dart';

abstract interface class OnboardingDurableCompletionVerifier {
  Future<OnboardingInstallationReadyProof> verifyInstallationReady();
}

final class ProbeOnboardingDurableCompletionVerifier
    implements OnboardingDurableCompletionVerifier {
  const ProbeOnboardingDurableCompletionVerifier({
    required OnboardingDatabaseProbeReader databaseProbeReader,
    required String archiveRootPath,
  }) : _databaseProbeReader = databaseProbeReader,
       _archiveRootPath = archiveRootPath;

  final OnboardingDatabaseProbeReader _databaseProbeReader;
  final String _archiveRootPath;

  @override
  Future<OnboardingInstallationReadyProof> verifyInstallationReady() async {
    final importPath = appDatabasePath(
      AppDatabaseFile.sourceScopedImport,
      databaseDirectory: _archiveRootPath,
    );
    final graphPath = appDatabasePath(
      AppDatabaseFile.conversationGraph,
      databaseDirectory: _archiveRootPath,
    );
    final importRows = _databaseProbeReader.readTableCount(
      dbPath: importPath,
      tableName: 'messages',
    );
    final graphRows = _databaseProbeReader.readTableCount(
      dbPath: graphPath,
      tableName: 'messages',
    );
    final importProbe = _databaseProbeReader.probeFile(
      importPath,
      rowCount: importRows,
    );
    final graphProbe = _databaseProbeReader.probeFile(
      graphPath,
      rowCount: graphRows,
    );
    if (!importProbe.hasData || !graphProbe.hasData) {
      throw StateError(
        'Durable onboarding readiness was not established after the build.',
      );
    }
    return OnboardingInstallationReadyProof(
      verifiedAtUtc: DateTime.now().toUtc(),
      sourceScopedImportRows: importProbe.rowCount!,
      conversationGraphRows: graphProbe.rowCount!,
    );
  }
}

@riverpod
OnboardingDurableCompletionVerifier onboardingDurableCompletionVerifier(
  Ref ref,
) {
  return ProbeOnboardingDurableCompletionVerifier(
    databaseProbeReader: ref.watch(onboardingDatabaseProbeReaderProvider),
    archiveRootPath: ref.watch(archiveAccessAuthorityProvider).rootPath,
  );
}
