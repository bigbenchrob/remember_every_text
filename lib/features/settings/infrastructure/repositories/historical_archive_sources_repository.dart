import '../../../../essentials/db/application/retained_archive_metadata_store.dart';
import '../../application/historical_archive_sources.dart';

class HistoricalArchiveSourcesRepository implements HistoricalArchiveSources {
  const HistoricalArchiveSourcesRepository({
    required RetainedArchiveMetadataStore metadataStore,
  }) : _metadataStore = metadataStore;

  final RetainedArchiveMetadataStore _metadataStore;

  @override
  Future<List<HistoricalArchiveSourceMetadata>> readKnownSources() async {
    final records = await _metadataStore.listHistoricalArchiveSources();
    return [
      for (final record in records)
        HistoricalArchiveSourceMetadata(
          sourceLabel: record.sourceLabel,
          totalMessages: record.totalMessages,
          earliestMessageUtc: record.earliestMessageUtc,
          latestMessageUtc: record.latestMessageUtc,
          preflightStatusLabel: record.preflightStatusLabel,
          dryRunNewMessages: record.dryRunNewMessages,
          dryRunDuplicateMessages: record.dryRunDuplicateMessages,
          lastImportFinishedAtUtc: record.lastImportFinishedAtUtc,
          lastImportSuccess: record.lastImportSuccess,
          lastImportError: record.lastImportError,
          lastImportedMessageCount: record.lastImportedMessageCount,
        ),
    ];
  }

  @override
  Future<void> upsertSourceMetadata(
    HistoricalArchiveSourceMetadataUpdate update,
  ) {
    return _metadataStore.upsertHistoricalArchiveSource(
      sourceChatDb: update.sourceChatDb,
      folderPath: update.folderPath,
      sourceLabel: update.sourceLabel,
      chatDbStatusLabel: update.chatDbStatusLabel,
      attachmentsStatusLabel: update.attachmentsStatusLabel,
      preflightStatusLabel: update.preflightStatusLabel,
      preflightDetail: update.preflightDetail,
      totalMessages: update.totalMessages,
      totalChats: update.totalChats,
      totalHandles: update.totalHandles,
      missingGuids: update.missingGuids,
      earliestMessageUtc: update.earliestMessageUtc,
      latestMessageUtc: update.latestMessageUtc,
      dryRunNewMessages: update.dryRunNewMessages,
      dryRunDuplicateMessages: update.dryRunDuplicateMessages,
      lastImportFinishedAtUtc: update.lastImportFinishedAtUtc,
      lastImportSuccess: update.lastImportSuccess,
      lastImportError: update.lastImportError,
      lastImportedMessageCount: update.lastImportedMessageCount,
      updatedAtUtc: update.updatedAtUtc,
    );
  }
}
