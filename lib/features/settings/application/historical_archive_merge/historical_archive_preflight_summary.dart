final class HistoricalArchivePreflightSummary {
  const HistoricalArchivePreflightSummary({
    required this.archiveLabel,
    required this.archivePath,
    required this.totalMessages,
    required this.duplicateMessages,
    required this.newMessages,
    required this.earliestDate,
    required this.latestDate,
    required this.canImport,
    required this.rowsWithoutGuidCount,
    required this.warnings,
  });

  final String archiveLabel;
  final String archivePath;
  final int totalMessages;
  final int duplicateMessages;
  final int newMessages;
  final DateTime? earliestDate;
  final DateTime? latestDate;
  final bool canImport;
  final int rowsWithoutGuidCount;
  final List<String> warnings;
}
