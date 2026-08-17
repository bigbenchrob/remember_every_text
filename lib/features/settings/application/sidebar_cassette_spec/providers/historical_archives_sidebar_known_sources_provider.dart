import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../historical_archive_sources.dart';
import '../../historical_archive_sources_provider.dart';
import '../../historical_archives_workflow_panel_model_provider.dart';
import '../payloads/historical_archives_settings_cassette_payload.dart';

part 'historical_archives_sidebar_known_sources_provider.g.dart';

@riverpod
Future<List<HistoricalArchiveSidebarSourceSummary>>
historicalArchivesSidebarKnownSources(
  HistoricalArchivesSidebarKnownSourcesRef ref,
) async {
  final sources = await ref.watch(
    historicalArchiveSourceMetadataProvider.future,
  );
  final presentation = ref.watch(
    historicalArchivesWorkflowProvider.select(
      (state) => (
        context: state.presentationContext,
        selectedSourceKey: state.selectedKnownSourceKey,
        reference: state.knownSourceReference,
      ),
    ),
  );
  return buildHistoricalArchiveSidebarKnownSources(
    sources: sources,
    presentationContext: presentation.context,
    selectedSourceKey: presentation.selectedSourceKey,
    reference: presentation.reference,
  );
}

List<HistoricalArchiveSidebarSourceSummary>
buildHistoricalArchiveSidebarKnownSources({
  required List<HistoricalArchiveSourceMetadata> sources,
  HistoricalArchivesPresentationContext presentationContext =
      HistoricalArchivesPresentationContext.hub,
  String? selectedSourceKey,
  HistoricalArchivesKnownSourceReference? reference,
}) {
  return <HistoricalArchiveSidebarSourceSummary>[
    for (final source in sources)
      HistoricalArchiveSidebarSourceSummary(
        sourceKey: source.sourceKey,
        label: source.sourceLabel,
        dateRangeLabel: _buildDateRangeLabel(source),
        messageCountLabel: source.totalMessages == null
            ? 'Total messages: unavailable'
            : 'Total messages: ${source.totalMessages}',
        statusLabel: _buildStatusLabel(source),
        lastRunSummaryLabel: _buildLastRunSummaryLabel(source),
        lastImportedLabel: _buildLastImportedLabel(source),
        isSelected:
            presentationContext ==
                HistoricalArchivesPresentationContext.existingSource &&
            source.sourceKey == selectedSourceKey,
        isReferenced: source.sourceKey == reference?.sourceKey,
        referencePulseOccurrence: source.sourceKey == reference?.sourceKey
            ? reference?.pulseOccurrence ?? 0
            : 0,
      ),
  ];
}

String _buildDateRangeLabel(HistoricalArchiveSourceMetadata source) {
  final earliest = _formatDate(source.earliestMessageUtc);
  final latest = _formatDate(source.latestMessageUtc);
  if (earliest == null || latest == null) {
    return 'Date range: unavailable';
  }

  if (earliest == latest) {
    return 'Date range: $earliest';
  }

  return 'Date range: $earliest to $latest';
}

String _buildStatusLabel(HistoricalArchiveSourceMetadata source) {
  if (source.lastImportSuccess == true) {
    return 'Current status: Imported successfully';
  }
  if (source.lastImportSuccess == false) {
    return 'Current status: ${source.lastImportError ?? 'Import failed'}';
  }
  return 'Current status: ${source.preflightStatusLabel}';
}

String _buildLastRunSummaryLabel(HistoricalArchiveSourceMetadata source) {
  if (source.lastImportSuccess == true &&
      source.lastImportedMessageCount != null) {
    return 'Last run: imported ${source.lastImportedMessageCount} messages';
  }

  if (source.dryRunNewMessages != null &&
      source.dryRunDuplicateMessages != null) {
    return 'Last dry run: new ${source.dryRunNewMessages} | duplicates ${source.dryRunDuplicateMessages}';
  }

  return 'Last dry run: unavailable';
}

String _buildLastImportedLabel(HistoricalArchiveSourceMetadata source) {
  final formatted = _formatTimestamp(source.lastImportFinishedAtUtc);
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
