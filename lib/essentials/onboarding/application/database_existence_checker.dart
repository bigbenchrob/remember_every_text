import 'package:path/path.dart' as path;

import '../../db/feature_level_providers/conversation_graph_readiness_provider.dart';
import '../../source_scoped_import/feature_level_providers.dart';
import 'onboarding_database_probe_reader.dart';

/// Pure check: do `macos_import_ss.db` and the conversation graph exist?
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
      path.join(databaseDirectory, sourceScopedImportDatabaseFileName),
    );
    final graphPath = path.join(
      databaseDirectory,
      conversationGraphDatabaseFileName,
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
