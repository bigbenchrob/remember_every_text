import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db_importers/domain/entities/db_import_result.dart';
import 'package:remember_this_text/essentials/db_migrate/domain/entities/db_migration_result.dart';
import 'package:remember_this_text/essentials/logging/application/diagnostic_report_actions.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';

void main() {
  test('buildOnboardingFailureReportHeaderLines includes failure context', () {
    final report = OnboardingEnvironmentReport(
      state: OnboardingEnvironmentState.migrationFailed,
      blockerKind: OnboardingBlockerKind.migrationFailed,
      syncPlausibility: OnboardingSyncPlausibility.unknown,
      messagesDatabase: const OnboardingDatabaseProbe(
        path: 'messages.db',
        exists: true,
        readable: true,
        rowCount: 123,
      ),
      addressBookDatabase: const OnboardingDatabaseProbe(
        path: 'addressbook.db',
        exists: true,
        readable: true,
        rowCount: 10,
      ),
      importDatabase: const OnboardingDatabaseProbe(
        path: 'macos_import.db',
        exists: true,
        readable: true,
        rowCount: 123,
      ),
      workingDatabase: const OnboardingDatabaseProbe(
        path: 'working.db',
        exists: true,
        readable: true,
        rowCount: 0,
        projectionStatus: 'incomplete',
        lastCompletedBatchId: 8,
        completedAtUtc: '2026-05-02T14:57:54.395398Z',
      ),
      hasFullDiskAccess: true,
      lastImportResult: const DbImportResult(
        batchId: 1,
        success: false,
        error: 'import failed',
      ),
      lastMigrationResult: const DbMigrationResult(
        batchId: 1,
        success: false,
        error: 'foreign key failed',
      ),
      lastMigrationFailureRecordedAt: DateTime.utc(2026, 4, 14, 12, 0, 0),
    );

    final headerLines = buildOnboardingFailureReportHeaderLines(report);

    expect(headerLines, contains('Context: onboarding_failure'));
    expect(headerLines, contains('State: migrationFailed'));
    expect(headerLines, contains('Blocker: migrationFailed'));
    expect(headerLines, contains('Migration failure: foreign key failed'));
    expect(
      headerLines,
      contains(
        'Working database: path=working.db; exists=true; readable=true; rows=0; projectionStatus=incomplete; lastCompletedBatchId=8; completedAtUtc=2026-05-02T14:57:54.395398Z',
      ),
    );
  });
}
