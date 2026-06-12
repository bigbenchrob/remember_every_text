import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../application/monitor/import_ledger_probe_reader.dart';

final class SourceScopedImportLedgerProbeReader
    implements ImportLedgerProbeReader {
  const SourceScopedImportLedgerProbeReader({required ImportDatabase importDb})
    : _importDb = importDb;

  final ImportDatabase _importDb;

  @override
  Future<ImportLedgerProbeSnapshot> readForSource(int sourceId) async {
    final maxSourceRowId = await _importDb.maxMessageSourceRowIdForSource(
      sourceId,
    );
    final messageCount = await _importDb.messageCountForSource(sourceId);

    return ImportLedgerProbeSnapshot(
      maxSourceRowId: maxSourceRowId,
      messageCount: messageCount,
    );
  }
}
