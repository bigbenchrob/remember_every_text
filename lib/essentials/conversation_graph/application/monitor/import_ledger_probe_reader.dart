abstract interface class ImportLedgerProbeReader {
  Future<ImportLedgerProbeSnapshot> readForSource(int sourceId);
}

final class ImportLedgerProbeSnapshot {
  const ImportLedgerProbeSnapshot({
    required this.maxSourceRowId,
    required this.messageCount,
  });

  final int? maxSourceRowId;
  final int messageCount;
}
