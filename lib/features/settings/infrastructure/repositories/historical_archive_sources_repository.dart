import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';

part 'historical_archive_sources_repository.g.dart';

final class HistoricalArchiveSourceMetadata {
  const HistoricalArchiveSourceMetadata({
    required this.sourceLabel,
    required this.totalMessages,
    required this.earliestMessageUtc,
    required this.latestMessageUtc,
    required this.preflightStatusLabel,
    required this.dryRunNewMessages,
    required this.dryRunDuplicateMessages,
    required this.lastImportFinishedAtUtc,
    required this.lastImportSuccess,
    required this.lastImportError,
    required this.lastImportedMessageCount,
  });

  final String sourceLabel;
  final int? totalMessages;
  final String? earliestMessageUtc;
  final String? latestMessageUtc;
  final String preflightStatusLabel;
  final int? dryRunNewMessages;
  final int? dryRunDuplicateMessages;
  final String? lastImportFinishedAtUtc;
  final bool? lastImportSuccess;
  final String? lastImportError;
  final int? lastImportedMessageCount;
}

final class HistoricalArchiveSourceMetadataUpdate {
  const HistoricalArchiveSourceMetadataUpdate({
    required this.sourceChatDb,
    required this.folderPath,
    required this.sourceLabel,
    required this.chatDbStatusLabel,
    required this.attachmentsStatusLabel,
    required this.preflightStatusLabel,
    required this.preflightDetail,
    required this.updatedAtUtc,
    this.totalMessages,
    this.totalChats,
    this.totalHandles,
    this.missingGuids,
    this.earliestMessageUtc,
    this.latestMessageUtc,
    this.dryRunNewMessages,
    this.dryRunDuplicateMessages,
    this.lastImportFinishedAtUtc,
    this.lastImportSuccess,
    this.lastImportError,
    this.lastImportedMessageCount,
  });

  final String sourceChatDb;
  final String folderPath;
  final String sourceLabel;
  final String chatDbStatusLabel;
  final String attachmentsStatusLabel;
  final String preflightStatusLabel;
  final String preflightDetail;
  final String updatedAtUtc;
  final int? totalMessages;
  final int? totalChats;
  final int? totalHandles;
  final int? missingGuids;
  final String? earliestMessageUtc;
  final String? latestMessageUtc;
  final int? dryRunNewMessages;
  final int? dryRunDuplicateMessages;
  final String? lastImportFinishedAtUtc;
  final bool? lastImportSuccess;
  final String? lastImportError;
  final int? lastImportedMessageCount;
}

class HistoricalArchiveSourcesRepository {
  const HistoricalArchiveSourcesRepository({
    required SqfliteImportDatabase importDb,
  }) : _importDb = importDb;

  final SqfliteImportDatabase _importDb;

  Future<List<HistoricalArchiveSourceMetadata>> readKnownSources() async {
    final records = await _importDb.listHistoricalArchiveSources();
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

  Future<void> upsertSourceMetadata(
    HistoricalArchiveSourceMetadataUpdate update,
  ) {
    return _importDb.upsertHistoricalArchiveSource(
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
  final importDb = await ref.watch(
    retainedArchiveMetadataDatabaseProvider.future,
  );
  return HistoricalArchiveSourcesRepository(importDb: importDb);
}

@riverpod
Future<List<HistoricalArchiveSourceMetadata>> historicalArchiveSourceMetadata(
  HistoricalArchiveSourceMetadataRef ref,
) async {
  final repository = await ref.watch(
    historicalArchiveSourcesRepositoryProvider.future,
  );
  return repository.readKnownSources();
}
