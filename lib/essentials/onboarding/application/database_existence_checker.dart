import '../../db/app_database_files.dart';
import 'onboarding_database_probe_reader.dart';

/// Pure check: do the source-scoped import ledger and conversation graph exist?
///
/// Returns `true` when the graph import ledger exists and the graph is ready.
/// This is a cheap filesystem check that avoids opening SQLite connections.
///
/// A zero-byte file is treated the same as absent — SQLite creates the file
/// on first connection but it contains no tables until schema runs.
class DatabaseExistenceChecker {
  const DatabaseExistenceChecker(this.databaseProbeReader);

  final OnboardingDatabaseProbeReader databaseProbeReader;

  /// Returns `true` if both import and graph databases exist and are populated.
  bool hasPopulatedDatabases(String databaseDirectory) {
    final importProbe = databaseProbeReader.probeFile(
      appDatabasePath(
        AppDatabaseFile.sourceScopedImport,
        databaseDirectory: databaseDirectory,
      ),
    );
    final graphPath = appDatabasePath(
      AppDatabaseFile.conversationGraph,
      databaseDirectory: databaseDirectory,
    );

    if (!importProbe.exists || !importProbe.readable) {
      return false;
    }

    final graphReady = databaseProbeReader
        .readConversationGraphReadiness(graphPath)
        .isReady;
    return (importProbe.sizeBytes ?? 0) > 0 && graphReady;
  }
}
