import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/sqlite_onboarding_database_probe_reader.dart';

void main() {
  group('SqliteOnboardingDatabaseProbeReader', () {
    test('reports why an existing path cannot be read as a database file', () {
      final tempDirectory = Directory.systemTemp.createTempSync(
        'onboarding-probe-unreadable-',
      );
      final unreadableFile = File('${tempDirectory.path}/unreadable.db')
        ..writeAsStringSync('not readable');
      Process.runSync('chmod', ['000', unreadableFile.path]);
      addTearDown(() {
        Process.runSync('chmod', ['600', unreadableFile.path]);
        if (tempDirectory.existsSync()) {
          tempDirectory.deleteSync(recursive: true);
        }
      });

      final probe = const SqliteOnboardingDatabaseProbeReader().probeFile(
        unreadableFile.path,
      );

      expect(probe.exists, isTrue);
      expect(probe.readable, isFalse);
      expect(
        probe.failureMessage,
        startsWith('Database file exists but could not be opened:'),
      );
    });

    test('reports table count read failures through diagnostic callback', () {
      final tempDirectory = Directory.systemTemp.createTempSync(
        'onboarding-probe-invalid-table-count-',
      );
      addTearDown(() {
        if (tempDirectory.existsSync()) {
          tempDirectory.deleteSync(recursive: true);
        }
      });

      final invalidDb = File('${tempDirectory.path}/invalid.db')
        ..writeAsStringSync('not sqlite');
      String? reportedPath;
      String? reportedTableName;
      Object? reportedError;
      StackTrace? reportedStackTrace;
      final reader = SqliteOnboardingDatabaseProbeReader(
        onTableCountFailure: (dbPath, tableName, error, stackTrace) {
          reportedPath = dbPath;
          reportedTableName = tableName;
          reportedError = error;
          reportedStackTrace = stackTrace;
        },
      );

      final count = reader.readTableCount(
        dbPath: invalidDb.path,
        tableName: 'message',
      );

      expect(count, isNull);
      expect(reportedPath, invalidDb.path);
      expect(reportedTableName, 'message');
      expect(reportedError, isNotNull);
      expect(reportedStackTrace, isNotNull);
    });
  });
}
