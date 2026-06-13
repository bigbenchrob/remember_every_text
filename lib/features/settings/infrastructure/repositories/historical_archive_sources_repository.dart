import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/application/retained_archive_metadata_store.dart';
import '../../../../essentials/db/feature_level_providers.dart';
import '../../application/historical_archive_sources.dart';

part 'historical_archive_sources_repository.g.dart';

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

@riverpod
Future<HistoricalArchiveSourcesRepository> historicalArchiveSourcesRepository(
  HistoricalArchiveSourcesRepositoryRef ref,
) async {
  final metadataStore = await ref.watch(
    retainedArchiveMetadataStoreProvider.future,
  );
  return HistoricalArchiveSourcesRepository(metadataStore: metadataStore);
}
