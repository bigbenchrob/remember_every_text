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

class HistoricalArchiveSourcesRepository {
  const HistoricalArchiveSourcesRepository();

  Future<List<HistoricalArchiveSourceMetadata>> readKnownSources(
    SqfliteImportDatabase importDb,
  ) async {
    final records = await importDb.listHistoricalArchiveSources();
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
}

@riverpod
Future<List<HistoricalArchiveSourceMetadata>> historicalArchiveSourceMetadata(
  HistoricalArchiveSourceMetadataRef ref,
) async {
  final importDb = await ref.watch(sqfliteImportDatabaseProvider.future);
  return const HistoricalArchiveSourcesRepository().readKnownSources(importDb);
}
