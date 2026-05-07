import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';

import '../feature_level_providers.dart' show databaseDirectoryPath;
import 'message_data_version_provider.dart';

part 'working_projection_readiness_provider.g.dart';

class WorkingProjectionReadiness {
  const WorkingProjectionReadiness({
    required this.isReady,
    required this.reason,
  });

  final bool isReady;
  final String reason;
}

class WorkingProjectionReadinessChecker {
  const WorkingProjectionReadinessChecker();

  WorkingProjectionReadiness checkPath(String dbPath) {
    final file = File(dbPath);
    if (!file.existsSync()) {
      return const WorkingProjectionReadiness(
        isReady: false,
        reason: 'working.db is missing',
      );
    }

    if (file.lengthSync() == 0) {
      return const WorkingProjectionReadiness(
        isReady: false,
        reason: 'working.db is empty',
      );
    }

    try {
      final db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
      try {
        db.execute('PRAGMA query_only = ON;');
        db.execute('PRAGMA busy_timeout = 3000;');
        final rows = db.select('''
          SELECT
            last_import_batch_id,
            last_projected_at_utc,
            last_projected_message_id,
            last_projected_attachment_id
          FROM projection_state
          WHERE id = 1
        ''');

        if (rows.length != 1) {
          return const WorkingProjectionReadiness(
            isReady: false,
            reason: 'projection_state singleton row is missing',
          );
        }

        final row = rows.first;
        if (row['last_import_batch_id'] == null) {
          return const WorkingProjectionReadiness(
            isReady: false,
            reason: 'projection_state.last_import_batch_id is null',
          );
        }
        if (row['last_projected_at_utc'] == null) {
          return const WorkingProjectionReadiness(
            isReady: false,
            reason: 'projection_state.last_projected_at_utc is null',
          );
        }
        if (row['last_projected_message_id'] == null) {
          return const WorkingProjectionReadiness(
            isReady: false,
            reason: 'projection_state.last_projected_message_id is null',
          );
        }

        return const WorkingProjectionReadiness(
          isReady: true,
          reason: 'projection_state is complete',
        );
      } finally {
        db.dispose();
      }
    } catch (error) {
      return WorkingProjectionReadiness(
        isReady: false,
        reason: 'projection_state readiness check failed: $error',
      );
    }
  }
}

@Riverpod(keepAlive: true)
Future<WorkingProjectionReadiness> workingProjectionReadiness(
  WorkingProjectionReadinessRef ref,
) async {
  ref.watch(messageDataVersionProvider);
  final dbPath = path.join(databaseDirectoryPath, 'working.db');
  return const WorkingProjectionReadinessChecker().checkPath(dbPath);
}
