class DiagnosticReportPresentationResult {
  const DiagnosticReportPresentationResult({
    required this.exportPath,
    required this.attachedToMailDraft,
  });

  final String? exportPath;
  final bool attachedToMailDraft;
}
