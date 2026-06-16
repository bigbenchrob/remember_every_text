import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../application/monitor/import_ledger_probe_reader.dart';

final class SourceScopedImportLedgerProbeReader
    implements ImportLedgerProbeReader {
  const SourceScopedImportLedgerProbeReader({
    required ImportDatabase importLedgerDb,
  }) : _importLedgerDb = importLedgerDb;

  final ImportDatabase _importLedgerDb;

  @override
  Future<ImportLedgerProbeSnapshot> readForSource(int sourceId) async {
    final maxSourceRowId = await _importLedgerDb.maxMessageSourceRowIdForSource(
      sourceId,
    );
    final messageCount = await _importLedgerDb.messageCountForSource(sourceId);

    return ImportLedgerProbeSnapshot(
      maxSourceRowId: maxSourceRowId,
      messageCount: messageCount,
    );
  }
}
