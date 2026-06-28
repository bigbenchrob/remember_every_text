import '../../../source_scoped_import/domain/ports/import_ledger_port.dart';
import '../../application/monitor/import_ledger_probe_reader.dart';

final class SourceScopedImportLedgerProbeReader
    implements ImportLedgerProbeReader {
  const SourceScopedImportLedgerProbeReader({
    required ImportLedger importLedger,
  }) : _importLedger = importLedger;

  final ImportLedger _importLedger;

  @override
  Future<ImportLedgerProbeSnapshot> readForSource(int sourceId) async {
    final maxSourceRowId = await _importLedger.maxMessageSourceRowIdForSource(
      sourceId,
    );
    final messageCount = await _importLedger.messageCountForSource(sourceId);

    return ImportLedgerProbeSnapshot(
      maxSourceRowId: maxSourceRowId,
      messageCount: messageCount,
    );
  }
}
