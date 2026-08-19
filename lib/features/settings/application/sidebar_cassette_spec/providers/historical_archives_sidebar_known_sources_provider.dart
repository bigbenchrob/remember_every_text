import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../core/util/count_label_formatter.dart';
import '../../../../../core/util/date_label_formatter.dart';
import '../../../../../essentials/db/feature_level_providers/message_data_version_provider.dart';
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
  ref.watch(messageDataVersionProvider);
  final sources = await ref.watch(
    historicalArchiveSourceMetadataProvider.future,
  );
  final importedSourceLookup = await ref.watch(
    historicalArchiveImportedSourceLookupProvider.future,
  );
  final importedSourcesByKey = <String, HistoricalArchiveImportedSourceMatch>{};
  for (final source in sources) {
    final match = await importedSourceLookup.findImportedSourceByKey(
      sourceKey: source.sourceKey,
    );
    if (match != null) {
      importedSourcesByKey[source.sourceKey] = match;
    }
  }
  final presentation = ref.watch(
    historicalArchivesWorkflowProvider.select(
      (state) => (
        context: state.presentationContext,
        selectedSourceKey: state.selectedKnownSourceKey,
        removingImportedMessageCount: state.inspectionEvidence?.totalMessages,
        reference: state.knownSourceReference,
      ),
    ),
  );
  return buildHistoricalArchiveSidebarKnownSources(
    sources: sources,
    importedSourcesByKey: importedSourcesByKey,
    presentationContext: presentation.context,
    selectedSourceKey: presentation.selectedSourceKey,
    removingImportedMessageCount: presentation.removingImportedMessageCount,
    reference: presentation.reference,
  );
}

List<HistoricalArchiveSidebarSourceSummary>
buildHistoricalArchiveSidebarKnownSources({
  required List<HistoricalArchiveSourceMetadata> sources,
  required Map<String, HistoricalArchiveImportedSourceMatch>
  importedSourcesByKey,
  HistoricalArchivesPresentationContext presentationContext =
      HistoricalArchivesPresentationContext.hub,
  String? selectedSourceKey,
  int? removingImportedMessageCount,
  HistoricalArchivesKnownSourceReference? reference,
}) {
  return <HistoricalArchiveSidebarSourceSummary>[
    for (final source in sources)
      if (importedSourcesByKey[source.sourceKey] != null ||
          presentationContext ==
                  HistoricalArchivesPresentationContext.removingSource &&
              source.sourceKey == selectedSourceKey)
        HistoricalArchiveSidebarSourceSummary(
          sourceKey: source.sourceKey,
          label: source.sourceLabel,
          dateRangeLabel: _buildDateRangeLabel(source),
          messageCountLabel: _buildMessageCountLabel(
            source,
            importedSource: importedSourcesByKey[source.sourceKey],
            removingImportedMessageCount:
                presentationContext ==
                        HistoricalArchivesPresentationContext.removingSource &&
                    source.sourceKey == selectedSourceKey
                ? removingImportedMessageCount
                : null,
          ),
          importedOnLabel: _buildImportedOnLabel(source),
          isSelected:
              presentationContext ==
                  HistoricalArchivesPresentationContext.existingSource &&
              source.sourceKey == selectedSourceKey,
          isReferenced: source.sourceKey == reference?.sourceKey,
          isBusy:
              presentationContext ==
                  HistoricalArchivesPresentationContext.removingSource &&
              source.sourceKey == selectedSourceKey,
          referenceOccurrence: source.sourceKey == reference?.sourceKey
              ? reference?.referenceOccurrence ?? 0
              : 0,
        ),
  ];
}

String _buildMessageCountLabel(
  HistoricalArchiveSourceMetadata source, {
  required HistoricalArchiveImportedSourceMatch? importedSource,
  required int? removingImportedMessageCount,
}) {
  final messageCount =
      importedSource?.importedMessageCount ??
      removingImportedMessageCount ??
      source.lastImportedMessageCount ??
      source.totalMessages;
  if (messageCount == null) {
    return 'Messages: unavailable';
  }
  return 'Messages: ${CountLabelFormatter.formatCount(messageCount)}';
}

String? _buildDateRangeLabel(HistoricalArchiveSourceMetadata source) {
  final earliest = _formatDate(source.earliestMessageUtc);
  final latest = _formatDate(source.latestMessageUtc);
  if (earliest == null || latest == null) {
    return null;
  }

  if (earliest == latest) {
    return 'Date range: $earliest';
  }

  return 'Date range: $earliest – $latest';
}

String? _buildImportedOnLabel(HistoricalArchiveSourceMetadata source) {
  if (source.lastImportSuccess != true) {
    return null;
  }

  final finishedAtUtc = source.lastImportFinishedAtUtc;
  final parsed = finishedAtUtc == null
      ? null
      : DateTime.tryParse(finishedAtUtc);
  if (parsed == null) {
    return null;
  }

  return 'Imported on: ${DateLabelFormatter.fullDate(parsed)}';
}

String? _formatDate(String? utcIsoString) {
  final parsed = utcIsoString == null ? null : DateTime.tryParse(utcIsoString);
  if (parsed == null) {
    return null;
  }

  return DateLabelFormatter.compactMonthYear(parsed);
}
