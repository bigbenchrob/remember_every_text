import '../../onboarding/domain/onboarding_environment_report.dart';
import '../infrastructure/log_file_writer.dart';
import '../infrastructure/log_export_service.dart';

const developerDiagnosticRecipientEmail = 'bigbenchrob@gmail.com';

Future<DiagnosticReportPresentationResult> exportDiagnosticReport(
  LogFileWriter writer,
) {
  return LogExportService(
    writer,
  ).exportAndPresent(recipientEmail: developerDiagnosticRecipientEmail);
}

Future<DiagnosticReportPresentationResult>
exportOnboardingFailureDiagnosticReport(
  LogFileWriter writer, {
  required OnboardingEnvironmentReport report,
}) {
  return LogExportService(writer).exportAndPresent(
    recipientEmail: developerDiagnosticRecipientEmail,
    subjectPrefix: 'MessageLens Onboarding Failure Report',
    emailBodyLines: [
      'Please attach the diagnostic report that was just revealed in Finder.',
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
    _describeProbe(label: 'Import database', probe: report.importDatabase),
    _describeProbe(label: 'Working database', probe: report.workingDatabase),
  ];

  final importMessage = report.importFailureMessage;
  if (importMessage != null && importMessage.isNotEmpty) {
    lines.add('Import failure: $importMessage');
  }

  final migrationMessage = report.migrationFailureMessage;
  if (migrationMessage != null && migrationMessage.isNotEmpty) {
    lines.add('Migration failure: $migrationMessage');
  }

  final recordedAt = report.latestFailureRecordedAt;
  if (recordedAt != null) {
    lines.add('Failure recorded at: ${recordedAt.toUtc().toIso8601String()}');
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
