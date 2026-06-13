import '../application/diagnostic_report_exporter.dart';
import '../domain/diagnostic_report_presentation_result.dart';
import 'log_export_service.dart';

class SupportBundleDiagnosticReportExporter
    implements DiagnosticReportExporter {
  const SupportBundleDiagnosticReportExporter(this._logExportService);

  final LogExportService _logExportService;

  @override
  Future<DiagnosticReportPresentationResult> exportAndPresent(
    DiagnosticReportExportRequest request,
  ) {
    return _logExportService.exportAndPresent(
      recipientEmail: request.recipientEmail,
      subjectPrefix: request.subjectPrefix,
      attachedEmailBodyLines: request.attachedEmailBodyLines,
      manualAttachmentEmailBodyLines: request.manualAttachmentEmailBodyLines,
      headerLines: request.headerLines,
    );
  }
}
