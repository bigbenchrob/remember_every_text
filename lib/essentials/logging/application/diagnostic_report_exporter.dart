import '../domain/diagnostic_report_presentation_result.dart';

class DiagnosticReportExportRequest {
  const DiagnosticReportExportRequest({
    required this.recipientEmail,
    required this.subjectPrefix,
    required this.attachedEmailBodyLines,
    required this.manualAttachmentEmailBodyLines,
    this.headerLines = const <String>[],
  });

  final String recipientEmail;
  final String subjectPrefix;
  final List<String> attachedEmailBodyLines;
  final List<String> manualAttachmentEmailBodyLines;
  final List<String> headerLines;
}

abstract interface class DiagnosticReportExporter {
  Future<DiagnosticReportPresentationResult> exportAndPresent(
    DiagnosticReportExportRequest request,
  );
}
