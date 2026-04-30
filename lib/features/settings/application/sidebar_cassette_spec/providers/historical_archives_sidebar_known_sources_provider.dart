import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../payloads/historical_archives_settings_cassette_payload.dart';

part 'historical_archives_sidebar_known_sources_provider.g.dart';

@riverpod
Future<List<HistoricalArchiveSidebarSourceSummary>>
historicalArchivesSidebarKnownSources(
  HistoricalArchivesSidebarKnownSourcesRef ref,
) async {
  final importDb = await ref.watch(sqfliteImportDatabaseProvider.future);
  final records = await importDb.listHistoricalArchiveSources();
  return buildHistoricalArchiveSidebarKnownSources(records: records);
}

List<HistoricalArchiveSidebarSourceSummary>
buildHistoricalArchiveSidebarKnownSources({
  required List<HistoricalArchiveSourceRecord> records,
}) {
  return <HistoricalArchiveSidebarSourceSummary>[
    for (final record in records)
      HistoricalArchiveSidebarSourceSummary(
        label: record.sourceLabel,
        dateRangeLabel: _buildDateRangeLabel(record),
        messageCountLabel: record.totalMessages == null
            ? 'Total messages: unavailable'
            : 'Total messages: ${record.totalMessages}',
        statusLabel: _buildStatusLabel(record),
        lastRunSummaryLabel: _buildLastRunSummaryLabel(record),
        lastImportedLabel: _buildLastImportedLabel(record),
      ),
  ];
}

String _buildDateRangeLabel(HistoricalArchiveSourceRecord record) {
  final earliest = _formatDate(record.earliestMessageUtc);
  final latest = _formatDate(record.latestMessageUtc);
  if (earliest == null || latest == null) {
    return 'Date range: unavailable';
  }

  if (earliest == latest) {
    return 'Date range: $earliest';
  }

  return 'Date range: $earliest to $latest';
}

String _buildStatusLabel(HistoricalArchiveSourceRecord record) {
  if (record.lastImportSuccess == true) {
    return 'Current status: Imported successfully';
  }
  if (record.lastImportSuccess == false) {
    return 'Current status: ${record.lastImportError ?? 'Import failed'}';
  }
  return 'Current status: ${record.preflightStatusLabel}';
}

String _buildLastRunSummaryLabel(HistoricalArchiveSourceRecord record) {
  if (record.lastImportSuccess == true &&
      record.lastImportedMessageCount != null) {
    return 'Last run: imported ${record.lastImportedMessageCount} messages';
  }

  if (record.dryRunNewMessages != null &&
      record.dryRunDuplicateMessages != null) {
    return 'Last dry run: new ${record.dryRunNewMessages} | duplicates ${record.dryRunDuplicateMessages}';
  }

  return 'Last dry run: unavailable';
}

String _buildLastImportedLabel(HistoricalArchiveSourceRecord record) {
  final formatted = _formatTimestamp(record.lastImportFinishedAtUtc);
  if (formatted == null) {
    return 'Last imported: not yet imported';
  }

  return 'Last imported: $formatted';
}

String? _formatDate(String? utcIsoString) {
  final parsed = utcIsoString == null ? null : DateTime.tryParse(utcIsoString);
  if (parsed == null) {
    return null;
  }

  final utc = parsed.toUtc();
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  return '${utc.year}-$month-$day';
}

String? _formatTimestamp(String? utcIsoString) {
  final parsed = utcIsoString == null ? null : DateTime.tryParse(utcIsoString);
  if (parsed == null) {
    return null;
  }

  final utc = parsed.toUtc();
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  final hour = utc.hour.toString().padLeft(2, '0');
  final minute = utc.minute.toString().padLeft(2, '0');
  return '${utc.year}-$month-$day $hour:$minute UTC';
}
