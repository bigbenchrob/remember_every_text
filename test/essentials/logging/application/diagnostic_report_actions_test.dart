import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/logging/application/diagnostic_report_actions.dart';
import 'package:remember_this_text/essentials/logging/application/diagnostic_report_exporter.dart';
import 'package:remember_this_text/essentials/logging/domain/diagnostic_report_presentation_result.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/source_scoped_import/feature_level_providers.dart';

void main() {
  test('exportDiagnosticReport delegates through exporter boundary', () async {
    final exporter = _FakeDiagnosticReportExporter();

    final result = await exportDiagnosticReport(exporter);

    expect(result.exportPath, '/tmp/report');
    expect(exporter.requests, hasLength(1));
    expect(
      exporter.requests.single.subjectPrefix,
      'MessageLens Diagnostic Report',
    );
    expect(
      exporter.requests.single.recipientEmail,
      developerDiagnosticRecipientEmail,
    );
  });

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
      sourceScopedImportDatabase: const OnboardingDatabaseProbe(
        path: sourceScopedImportDatabaseFileName,
        exists: true,
        readable: true,
        rowCount: 123,
      ),
      conversationGraph: const OnboardingDatabaseProbe(
        path: conversationGraphDatabaseFileName,
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
        'Source-scoped import ledger: path=$sourceScopedImportDatabaseFileName; exists=true; readable=true; rows=123',
      ),
    );
    expect(
      headerLines,
      contains(
        'Conversation graph: path=$conversationGraphDatabaseFileName; exists=true; readable=true; rows=0',
      ),
    );
  });
}

class _FakeDiagnosticReportExporter implements DiagnosticReportExporter {
  final requests = <DiagnosticReportExportRequest>[];

  @override
  Future<DiagnosticReportPresentationResult> exportAndPresent(
    DiagnosticReportExportRequest request,
  ) async {
    requests.add(request);
    return const DiagnosticReportPresentationResult(
      exportPath: '/tmp/report',
      attachedToMailDraft: false,
    );
  }
}
