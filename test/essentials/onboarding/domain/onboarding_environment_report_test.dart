import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db_importers/domain/entities/db_import_result.dart';
import 'package:remember_this_text/essentials/db_migrate/domain/entities/db_migration_result.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';

void main() {
  group('OnboardingEnvironmentReport', () {
    test(
      'hasPopulatedAppDatabases is true only when both app databases have data',
      () {
        final report = _report();

        expect(report.hasPopulatedAppDatabases, isTrue);
      },
    );

    test(
      'hasPopulatedAppDatabases is false when working projection is incomplete',
      () {
        final report = _report(
          workingDatabase: const OnboardingDatabaseProbe(
            path: 'working.db',
            exists: true,
            readable: true,
            rowCount: 100,
            projectionStatus: 'incomplete',
            lastCompletedBatchId: 8,
          ),
        );

        expect(report.hasPopulatedAppDatabases, isFalse);
      },
    );

    test(
      'hasIncompleteWorkingProjectionWithMissingImportDatabase requires an existing incomplete working db',
      () {
        final report = _report(
          importDatabase: const OnboardingDatabaseProbe(
            path: 'macos_import.db',
            exists: false,
            readable: false,
            rowCount: 0,
          ),
          workingDatabase: const OnboardingDatabaseProbe(
            path: 'working.db',
            exists: true,
            readable: true,
            rowCount: 10,
            projectionStatus: 'incomplete',
          ),
        );

        expect(report.hasExistingWorkingDatabase, isTrue);
        expect(report.hasExistingIncompleteWorkingDatabase, isTrue);
        expect(
          report.hasIncompleteWorkingProjectionWithMissingImportDatabase,
          isTrue,
        );
      },
    );

    test(
      'hasIncompleteWorkingProjectionWithMissingImportDatabase stays false for fresh onboarding with no working db',
      () {
        final report = _report(
          importDatabase: const OnboardingDatabaseProbe(
            path: 'macos_import.db',
            exists: false,
            readable: false,
            rowCount: 0,
          ),
          workingDatabase: const OnboardingDatabaseProbe(
            path: 'working.db',
            exists: false,
            readable: false,
            rowCount: 0,
            projectionStatus: 'incomplete',
          ),
        );

        expect(report.hasExistingWorkingDatabase, isFalse);
        expect(report.hasExistingIncompleteWorkingDatabase, isFalse);
        expect(
          report.hasIncompleteWorkingProjectionWithMissingImportDatabase,
          isFalse,
        );
      },
    );

    test('import failure helpers expose persisted failure state', () {
      final report = _report(
        lastImportResult: const DbImportResult(
          batchId: 1,
          success: false,
          error: 'Import exploded',
        ),
      );

      expect(report.hasImportFailure, isTrue);
      expect(report.importFailureMessage, 'Import exploded');
      expect(report.hasMigrationFailure, isFalse);
    });

    test('migration failure helpers expose persisted failure state', () {
      final report = _report(
        lastMigrationResult: const DbMigrationResult(
          batchId: 2,
          success: false,
          error: 'Migration exploded',
        ),
      );

      expect(report.hasMigrationFailure, isTrue);
      expect(report.migrationFailureMessage, 'Migration exploded');
      expect(report.hasImportFailure, isFalse);
    });

    test('successful results do not report failures', () {
      final report = _report(
        lastImportResult: const DbImportResult(batchId: 3, success: true),
        lastMigrationResult: const DbMigrationResult(batchId: 4, success: true),
      );

      expect(report.hasImportFailure, isFalse);
      expect(report.importFailureMessage, isNull);
      expect(report.hasMigrationFailure, isFalse);
      expect(report.migrationFailureMessage, isNull);
    });

    test(
      'latestFailureRecordedAt prefers migration timestamp when present',
      () {
        final importAt = DateTime.utc(2026, 03, 24, 10, 00);
        final migrationAt = DateTime.utc(2026, 03, 24, 11, 00);

        final report = _report(
          lastImportResult: const DbImportResult(batchId: 1, success: false),
          lastMigrationResult: const DbMigrationResult(
            batchId: 2,
            success: false,
          ),
          lastImportFailureRecordedAt: importAt,
          lastMigrationFailureRecordedAt: migrationAt,
        );

        expect(report.latestFailureRecordedAt, migrationAt);
      },
    );

    test('importFailureFreshness is today for same-day failures', () {
      final report = _report(
        lastImportFailureRecordedAt: DateTime(2026, 03, 24, 8, 00),
      );

      expect(
        report.importFailureFreshness(now: DateTime(2026, 03, 24, 20, 00)),
        OnboardingFailureFreshness.today,
      );
    });

    test('migrationFailureFreshness is older for previous-day failures', () {
      final report = _report(
        lastMigrationFailureRecordedAt: DateTime(2026, 03, 23, 23, 50),
      );

      expect(
        report.migrationFailureFreshness(now: DateTime(2026, 03, 24, 0, 10)),
        OnboardingFailureFreshness.older,
      );
    });
  });
}

OnboardingEnvironmentReport _report({
  DbImportResult? lastImportResult,
  DbMigrationResult? lastMigrationResult,
  DateTime? lastImportFailureRecordedAt,
  DateTime? lastMigrationFailureRecordedAt,
  OnboardingDatabaseProbe? importDatabase,
  OnboardingDatabaseProbe? workingDatabase,
}) {
  return OnboardingEnvironmentReport(
    state: OnboardingEnvironmentState.ready,
    blockerKind: OnboardingBlockerKind.none,
    syncPlausibility: OnboardingSyncPlausibility.likelySyncedOrLocallyAvailable,
    messagesDatabase: const OnboardingDatabaseProbe(
      path: 'messages.db',
      exists: true,
      readable: true,
      rowCount: 100,
    ),
    addressBookDatabase: const OnboardingDatabaseProbe(
      path: 'addressbook.db',
      exists: true,
      readable: true,
      rowCount: 50,
    ),
    importDatabase:
        importDatabase ??
        const OnboardingDatabaseProbe(
          path: 'macos_import.db',
          exists: true,
          readable: true,
          rowCount: 100,
        ),
    workingDatabase:
        workingDatabase ??
        const OnboardingDatabaseProbe(
          path: 'working.db',
          exists: true,
          readable: true,
          rowCount: 100,
        ),
    hasFullDiskAccess: true,
    lastImportResult: lastImportResult,
    lastMigrationResult: lastMigrationResult,
    lastImportFailureRecordedAt: lastImportFailureRecordedAt,
    lastMigrationFailureRecordedAt: lastMigrationFailureRecordedAt,
  );
}
