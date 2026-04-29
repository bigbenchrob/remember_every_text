final class HistoricalArchiveImportResult {
  const HistoricalArchiveImportResult({
    required this.archiveLabel,
    required this.archivePath,
    required this.stagedMessages,
    required this.importedMessages,
    required this.skippedDuplicates,
    required this.failedRows,
    required this.rowsWithoutGuidCount,
    required this.batchId,
    required this.warnings,
  });

  final String archiveLabel;
  final String archivePath;
  final int stagedMessages;
  final int importedMessages;
  final int skippedDuplicates;
  final int failedRows;
  final int rowsWithoutGuidCount;
  final int? batchId;
  final List<String> warnings;
}
