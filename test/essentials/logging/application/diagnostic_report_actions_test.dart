import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/logging/application/diagnostic_report_actions.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';

void main() {
  test('buildOnboardingFailureReportHeaderLines includes failure context', () {
    final report = OnboardingEnvironmentReport(
      state: OnboardingEnvironmentState.graphProjectionFailed,
      blockerKind: OnboardingBlockerKind.graphProjectionFailed,
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
        path: 'macos_import_ss.db',
        exists: true,
        readable: true,
        rowCount: 123,
      ),
      conversationGraph: const OnboardingDatabaseProbe(
        path: 'working_ss.db',
        exists: true,
        readable: true,
        rowCount: 0,
      ),
      hasFullDiskAccess: true,
      lastImportFailure: const OnboardingPipelineFailure(
        phase: OnboardingPipelinePhase.import,
        batchId: 1,
        message: 'import failed',
      ),
      lastGraphProjectionFailure: const OnboardingPipelineFailure(
        phase: OnboardingPipelinePhase.graphProjection,
        batchId: 1,
        message: 'foreign key failed',
      ),
      lastGraphProjectionFailureRecordedAt: DateTime.utc(2026, 4, 14, 12, 0, 0),
    );

    final headerLines = buildOnboardingFailureReportHeaderLines(report);

    expect(headerLines, contains('Context: onboarding_failure'));
    expect(headerLines, contains('State: graphProjectionFailed'));
    expect(headerLines, contains('Blocker: graphProjectionFailed'));
    expect(
      headerLines,
      contains('Graph projection failure: foreign key failed'),
    );
    expect(
      headerLines,
      contains(
        'Source-scoped import ledger: path=macos_import_ss.db; exists=true; readable=true; rows=123',
      ),
    );
    expect(
      headerLines,
      contains(
        'Conversation graph: path=working_ss.db; exists=true; readable=true; rows=0',
      ),
    );
  });
}
