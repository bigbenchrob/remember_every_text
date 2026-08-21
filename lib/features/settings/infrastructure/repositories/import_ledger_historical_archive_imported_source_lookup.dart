import '../../../../essentials/source_scoped_import/domain/historical_archive_source_identity.dart';
import '../../../../essentials/source_scoped_import/domain/ports/import_ledger_port.dart';
import '../../application/historical_archive_sources.dart';

final class ImportLedgerHistoricalArchiveImportedSourceLookup
    implements HistoricalArchiveImportedSourceLookup {
  const ImportLedgerHistoricalArchiveImportedSourceLookup({
    required ImportLedger importLedger,
  }) : _importLedger = importLedger;

  final ImportLedger _importLedger;

  @override
  Future<HistoricalArchiveImportedSourceMatch?> findImportedSource({
    required HistoricalArchiveSourceIdentity identity,
  }) async {
    final sourceId = await _importLedger.sourceIdForKey(identity.value);
    if (sourceId == null) {
      return null;
    }

    final importedMessageCount = await _importLedger.messageCountForSource(
      sourceId,
    );
    if (importedMessageCount <= 0) {
      return null;
    }

    return HistoricalArchiveImportedSourceMatch(
      identity: identity,
      sourceId: sourceId,
      importedMessageCount: importedMessageCount,
    );
  }
}
