import 'dart:io';

import 'package:path/path.dart' as path;

import '../../db/feature_level_providers/conversation_graph_readiness_provider.dart';
import '../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../source_scoped_import/feature_level_providers.dart';

/// Pure check: do `macos_import_ss.db` and the conversation graph exist?
///
/// Returns `true` when the graph import ledger exists and the graph is ready.
/// This is a cheap filesystem check that avoids opening SQLite connections.
///
/// A zero-byte file is treated the same as absent — SQLite creates the file
/// on first connection but it contains no tables until schema runs.
class DatabaseExistenceChecker {
  const DatabaseExistenceChecker();

  /// Returns `true` if both import and graph databases exist and are populated.
  bool hasPopulatedDatabases(String databaseDirectory) {
    final importFile = File(
      path.join(databaseDirectory, sourceScopedImportDatabaseFileName),
    );
    final graphPath = path.join(
      databaseDirectory,
      conversationGraphDatabaseFileName,
    );

    if (!importFile.existsSync()) {
      return false;
    }

    // A freshly-created SQLite DB may have schema but zero user data.
    // For a robust check we'd query row counts, but file size > 4096
    // (one page) is a reasonable heuristic for "has tables with data".
    // The gate provider does the definitive row-count check if the files exist.
    final graphReady = const ConversationGraphReadinessChecker()
        .checkPath(graphPath)
        .isReady;
    return importFile.lengthSync() > 0 && graphReady;
  }
}
