import '../../../../essentials/source_scoped_import/application/archives/historical_messages_archive_source_folder_resolver.dart';
import '../../../../essentials/source_scoped_import/domain/ports/import_ledger_port.dart';
import '../../application/historical_archive_sources.dart';

final class ImportLedgerHistoricalArchiveImportedSourceLookup
    implements HistoricalArchiveImportedSourceLookup {
  const ImportLedgerHistoricalArchiveImportedSourceLookup({
    required ImportLedger importLedger,
    required HistoricalMessagesArchiveSourceFolderResolver folderResolver,
  }) : _importLedger = importLedger,
       _folderResolver = folderResolver;

  final ImportLedger _importLedger;
  final HistoricalMessagesArchiveSourceFolderResolver _folderResolver;

  @override
  Future<HistoricalArchiveImportedSourceMatch?> findImportedSource({
    required String folderPath,
  }) async {
    final sourceKey = _folderResolver.resolveFolder(folderPath).sourceKey;
    return findImportedSourceByKey(sourceKey: sourceKey);
  }

  @override
  Future<HistoricalArchiveImportedSourceMatch?> findImportedSourceByKey({
    required String sourceKey,
  }) async {
    final sourceId = await _importLedger.sourceIdForKey(sourceKey);
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
      sourceKey: sourceKey,
      sourceId: sourceId,
      importedMessageCount: importedMessageCount,
    );
  }
}
