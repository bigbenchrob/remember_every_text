import '../../db/application/database_health_audit/database_health_audit_service.dart';
import '../../onboarding/domain/onboarding_environment_report.dart';
import '../domain/pipeline_incident_report.dart';
import '../infrastructure/log_export_service.dart';
import '../infrastructure/log_file_writer.dart';
import '../infrastructure/support_bundle_export_service.dart';

const developerDiagnosticRecipientEmail = 'messagelens@gmail.com';

Future<DiagnosticReportPresentationResult> exportDiagnosticReport(
  LogFileWriter writer, {
  required DatabaseHealthAuditService databaseHealthAuditService,
}) {
  return LogExportService(
    SupportBundleExportService(writer, databaseHealthAuditService),
  ).exportAndPresent(recipientEmail: developerDiagnosticRecipientEmail);
}

Future<DiagnosticReportPresentationResult>
exportOnboardingFailureDiagnosticReport(
  LogFileWriter writer, {
  required OnboardingEnvironmentReport report,
  required DatabaseHealthAuditService databaseHealthAuditService,
}) {
  return LogExportService(
    SupportBundleExportService(writer, databaseHealthAuditService),
  ).exportAndPresent(
    recipientEmail: developerDiagnosticRecipientEmail,
    subjectPrefix: 'MessageLens Onboarding Failure Report',
    attachedEmailBodyLines: [
      'MessageLens attached the support bundle to this draft.',
      '',
      'This report was prepared from the onboarding failure screen.',
      'Observed state: ${report.state.name}',
      'Blocker kind: ${report.blockerKind.name}',
      '',
      'Describe what happened just before setup failed:',
    ],
    manualAttachmentEmailBodyLines: [
      'MessageLens prepared a support bundle but could not attach it automatically.',
      'It has been revealed in Finder so it can be attached manually.',
      '',
      'This report was prepared from the onboarding failure screen.',
      'Observed state: ${report.state.name}',
      'Blocker kind: ${report.blockerKind.name}',
      '',
      'Describe what happened just before setup failed:',
    ],
    headerLines: buildOnboardingFailureReportHeaderLines(report),
  );
}

Future<DiagnosticReportPresentationResult>
exportPipelineIncidentDiagnosticReport(
  LogFileWriter writer, {
  required PipelineIncidentReport report,
  required DatabaseHealthAuditService databaseHealthAuditService,
}) {
  return LogExportService(
    SupportBundleExportService(writer, databaseHealthAuditService),
  ).exportAndPresent(
    recipientEmail: developerDiagnosticRecipientEmail,
    subjectPrefix: 'MessageLens Pipeline Incident Report',
    attachedEmailBodyLines: [
      'MessageLens attached the support bundle to this draft.',
      '',
      'This report was prepared from the pipeline incident screen.',
      'Observed stage: ${report.stage.displayLabel}',
      'Headline: ${report.headline}',
      '',
      'Describe what happened just before the failure appeared:',
    ],
    manualAttachmentEmailBodyLines: [
      'MessageLens prepared a support bundle but could not attach it automatically.',
      'It has been revealed in Finder so it can be attached manually.',
      '',
      'This report was prepared from the pipeline incident screen.',
      'Observed stage: ${report.stage.displayLabel}',
      'Headline: ${report.headline}',
      '',
      'Describe what happened just before the failure appeared:',
    ],
    headerLines: buildPipelineIncidentReportHeaderLines(report),
  );
}

List<String> buildOnboardingFailureReportHeaderLines(
  OnboardingEnvironmentReport report,
) {
  final lines = <String>[
    'Context: onboarding_failure',
    'State: ${report.state.name}',
    'Blocker: ${report.blockerKind.name}',
    'Full Disk Access: ${report.hasFullDiskAccess ? 'available' : 'missing'}',
    _describeProbe(label: 'Messages database', probe: report.messagesDatabase),
    _describeProbe(
      label: 'Contacts database',
      probe: report.addressBookDatabase,
      unavailableMessage: report.addressBookFailureMessage ?? 'unavailable',
    ),
    _describeProbe(
      label: 'Source-scoped import ledger',
      probe: report.importDatabase,
    ),
    _describeProbe(
      label: 'Conversation graph',
      probe: report.conversationGraph,
    ),
  ];

  final importMessage = report.importFailureMessage;
  if (importMessage != null && importMessage.isNotEmpty) {
    lines.add('Import failure: $importMessage');
  }

  final graphProjectionMessage = report.graphProjectionFailureMessage;
  if (graphProjectionMessage != null && graphProjectionMessage.isNotEmpty) {
    lines.add('Graph projection failure: $graphProjectionMessage');
  }

  final recordedAt = report.latestFailureRecordedAt;
  if (recordedAt != null) {
    lines.add('Failure recorded at: ${recordedAt.toUtc().toIso8601String()}');
  }

  lines.add('');
  return lines;
}

List<String> buildPipelineIncidentReportHeaderLines(
  PipelineIncidentReport report,
) {
  final lines = <String>[
    'Context: pipeline_incident',
    'Stage: ${report.stage.displayLabel}',
    'Headline: ${report.headline}',
    'Summary: ${report.summary}',
    'Blocking incident: ${report.hasBlockingIncident}',
    'Batch id: ${report.batchId}',
    'Recorded at: ${report.recordedAtUtc.toUtc().toIso8601String()}',
  ];

  for (final entry in report.entries) {
    lines.add(
      'Entry [${entry.severity.name}/${entry.stage.displayLabel}]: ${entry.summary}',
    );
    if (entry.code != null && entry.code!.isNotEmpty) {
      lines.add('Entry code: ${entry.code}');
    }
    if (entry.detail != null && entry.detail!.isNotEmpty) {
      lines.add('Entry detail: ${entry.detail}');
    }
  }

  lines.add('');
  return lines;
}

String _describeProbe({
  required String label,
  required OnboardingDatabaseProbe? probe,
  String unavailableMessage = 'not available',
}) {
  if (probe == null) {
    return '$label: $unavailableMessage';
  }

  return '$label: '
      'path=${probe.path}; '
      'exists=${probe.exists}; '
      'readable=${probe.readable}; '
      'rows=${probe.rowCount ?? 'unknown'}';
}
