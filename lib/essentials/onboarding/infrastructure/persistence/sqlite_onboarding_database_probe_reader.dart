import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../../../db/application/conversation_graph_readiness.dart';
import '../../../db/application/read_only_sql_guard.dart';
import '../../../db/infrastructure/repositories/sqlite_conversation_graph_readiness_checker.dart';
import '../../application/onboarding_database_probe_reader.dart';
import '../../domain/onboarding_environment_report.dart';

final class SqliteOnboardingDatabaseProbeReader
    implements OnboardingDatabaseProbeReader {
  const SqliteOnboardingDatabaseProbeReader({
    void Function(
      String dbPath,
      String tableName,
      Object error,
      StackTrace stackTrace,
    )?
    onTableCountFailure,
  }) : _onTableCountFailure = onTableCountFailure;

  final void Function(
    String dbPath,
    String tableName,
    Object error,
    StackTrace stackTrace,
  )?
  _onTableCountFailure;

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
    } catch (error) {
      return OnboardingDatabaseProbe(
        path: filePath,
        exists: true,
        readable: false,
        rowCount: rowCount,
        failureMessage: 'Database file exists but could not be opened: $error',
      );
    }
  }

  @override
  OnboardingDatabaseProbe probeDirectory(String directoryPath) {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      return OnboardingDatabaseProbe(
        path: directoryPath,
        exists: false,
        readable: false,
      );
    }

    try {
      final stat = directory.statSync();
      directory.listSync(followLinks: false);
      return OnboardingDatabaseProbe(
        path: directoryPath,
        exists: true,
        readable: true,
        sizeBytes: stat.size,
        lastModified: stat.modified,
      );
    } catch (error) {
      return OnboardingDatabaseProbe(
        path: directoryPath,
        exists: true,
        readable: false,
        failureMessage: 'Directory exists but could not be read: $error',
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
        db.execute('PRAGMA query_only = ON;');
        db.execute('PRAGMA busy_timeout = 3000;');
        final sql = 'SELECT COUNT(*) as count FROM $tableName';
        assertReadOnlySql(
          sql,
          boundary: 'Onboarding database probe count query',
        );
        final result = db.select(sql);
        if (result.isEmpty || result.first.values.isEmpty) {
          return null;
        }
        return _asInt(result.first.values.first);
      } finally {
        db.dispose();
      }
    } catch (error, stackTrace) {
      _onTableCountFailure?.call(dbPath, tableName, error, stackTrace);
      return null;
    }
  }

  @override
  ConversationGraphReadiness readConversationGraphReadiness(String dbPath) {
    return const SqliteConversationGraphReadinessChecker().checkPath(dbPath);
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
