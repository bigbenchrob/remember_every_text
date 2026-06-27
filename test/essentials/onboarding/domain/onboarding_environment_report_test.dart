import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/app_database_files.dart';
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

    test('import failure helpers expose persisted failure state', () {
      final report = _report(
        lastImportFailure: const OnboardingPipelineFailure(
          phase: OnboardingPipelinePhase.import,
          batchId: 1,
          message: 'Import exploded',
        ),
      );

      expect(report.hasImportFailure, isTrue);
      expect(report.importFailureMessage, 'Import exploded');
      expect(report.hasGraphProjectionFailure, isFalse);
    });

    test('graph projection failure helpers expose persisted failure state', () {
      final report = _report(
        lastGraphProjectionFailure: const OnboardingPipelineFailure(
          phase: OnboardingPipelinePhase.graphProjection,
          batchId: 2,
          message: 'Graph projection exploded',
        ),
      );

      expect(report.hasGraphProjectionFailure, isTrue);
      expect(report.graphProjectionFailureMessage, 'Graph projection exploded');
      expect(report.hasImportFailure, isFalse);
    });

    test('absent failure summaries do not report failures', () {
      final report = _report();

      expect(report.hasImportFailure, isFalse);
      expect(report.importFailureMessage, isNull);
      expect(report.hasGraphProjectionFailure, isFalse);
      expect(report.graphProjectionFailureMessage, isNull);
    });

    test(
      'latestFailureRecordedAt prefers graph projection timestamp when present',
      () {
        final importAt = DateTime.utc(2026, 03, 24, 10, 00);
        final graphProjectionAt = DateTime.utc(2026, 03, 24, 11, 00);

        final report = _report(
          lastImportFailure: const OnboardingPipelineFailure(
            phase: OnboardingPipelinePhase.import,
            batchId: 1,
          ),
          lastGraphProjectionFailure: const OnboardingPipelineFailure(
            phase: OnboardingPipelinePhase.graphProjection,
            batchId: 2,
          ),
          lastImportFailureRecordedAt: importAt,
          lastGraphProjectionFailureRecordedAt: graphProjectionAt,
        );

        expect(report.latestFailureRecordedAt, graphProjectionAt);
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

    test(
      'graphProjectionFailureFreshness is older for previous-day failures',
      () {
        final report = _report(
          lastGraphProjectionFailureRecordedAt: DateTime(2026, 03, 23, 23, 50),
        );

        expect(
          report.graphProjectionFailureFreshness(
            now: DateTime(2026, 03, 24, 0, 10),
          ),
          OnboardingFailureFreshness.older,
        );
      },
    );
  });
}

OnboardingEnvironmentReport _report({
  OnboardingPipelineFailure? lastImportFailure,
  OnboardingPipelineFailure? lastGraphProjectionFailure,
  DateTime? lastImportFailureRecordedAt,
  DateTime? lastGraphProjectionFailureRecordedAt,
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
    sourceScopedImportDatabase: OnboardingDatabaseProbe(
      path: appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
      exists: true,
      readable: true,
      rowCount: 100,
    ),
    conversationGraph: OnboardingDatabaseProbe(
      path: appDatabaseFileName(AppDatabaseFile.conversationGraph),
      exists: true,
      readable: true,
      rowCount: 100,
    ),
    hasFullDiskAccess: true,
    lastImportFailure: lastImportFailure,
    lastGraphProjectionFailure: lastGraphProjectionFailure,
    lastImportFailureRecordedAt: lastImportFailureRecordedAt,
    lastGraphProjectionFailureRecordedAt: lastGraphProjectionFailureRecordedAt,
  );
}
