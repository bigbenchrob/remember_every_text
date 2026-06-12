import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../../../db/feature_level_providers/conversation_graph_readiness_provider.dart';
import '../../application/onboarding_database_probe_reader.dart';
import '../../domain/onboarding_environment_report.dart';

final class SqliteOnboardingDatabaseProbeReader
    implements OnboardingDatabaseProbeReader {
  const SqliteOnboardingDatabaseProbeReader();

  @override
  OnboardingDatabaseProbe probeFile(String filePath, {int? rowCount}) {
    final file = File(filePath);
    if (!file.existsSync()) {
      return OnboardingDatabaseProbe(
        path: filePath,
        exists: false,
        readable: false,
      );
    }

    try {
      final stat = file.statSync();
      final raf = file.openSync(mode: FileMode.read);
      raf.closeSync();

      return OnboardingDatabaseProbe(
        path: filePath,
        exists: true,
        readable: true,
        sizeBytes: stat.size,
        lastModified: stat.modified,
        rowCount: rowCount,
      );
    } catch (_) {
      return OnboardingDatabaseProbe(
        path: filePath,
        exists: true,
        readable: false,
        rowCount: rowCount,
      );
    }
  }

  @override
  int? readTableCount({
    required String dbPath,
    required String tableName,
    bool queryOnly = false,
  }) {
    final file = File(dbPath);
    if (!file.existsSync()) {
      return null;
    }

    try {
      final db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
      try {
        if (queryOnly) {
          db.execute('PRAGMA query_only = ON;');
          db.execute('PRAGMA busy_timeout = 3000;');
        }
        final result = db.select('SELECT COUNT(*) as count FROM $tableName');
        if (result.isEmpty || result.first.values.isEmpty) {
          return null;
        }
        return _asInt(result.first.values.first);
      } finally {
        db.dispose();
      }
    } catch (_) {
      return null;
    }
  }

  @override
  ConversationGraphReadiness readConversationGraphReadiness(String dbPath) {
    return const ConversationGraphReadinessChecker().checkPath(dbPath);
  }

  static int? _asInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value');
  }
}
