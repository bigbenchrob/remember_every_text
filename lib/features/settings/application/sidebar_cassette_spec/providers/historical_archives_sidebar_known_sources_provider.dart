import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../core/util/count_label_formatter.dart';
import '../../../../../core/util/date_label_formatter.dart';
import '../../../../../essentials/db/feature_level_providers/message_data_version_provider.dart';
import '../../../../../essentials/source_scoped_import/domain/historical_archive_source_identity.dart';
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
  final importedSourcesByIdentity =
      <HistoricalArchiveSourceIdentity, HistoricalArchiveImportedSourceMatch>{};
  for (final source in sources) {
    final match = await importedSourceLookup.findImportedSource(
      identity: source.identity,
    );
    if (match != null) {
      importedSourcesByIdentity[source.identity] = match;
    }
  }
  final presentation = ref.watch(
    historicalArchivesWorkflowProvider.select((state) {
      final active = state.presentation;
      return (
        selectedSourceIdentity: active is HistoricalArchivesExistingSourceState
            ? active.facts.identity
            : null,
        removingSourceIdentity: active is HistoricalArchivesRemovingState
            ? active.facts.identity
            : active is HistoricalArchivesRemovalFailedState
            ? active.facts.identity
            : null,
        removingImportedMessageCount: active is HistoricalArchivesRemovingState
            ? active.facts.importedMessageCount
            : active is HistoricalArchivesRemovalFailedState
            ? active.facts.importedMessageCount
            : null,
        reference: state.knownSourceReference,
      );
    }),
  );
  return buildHistoricalArchiveSidebarKnownSources(
    sources: sources,
    importedSourcesByIdentity: importedSourcesByIdentity,
    selectedSourceIdentity: presentation.selectedSourceIdentity,
    removingSourceIdentity: presentation.removingSourceIdentity,
    removingImportedMessageCount: presentation.removingImportedMessageCount,
    reference: presentation.reference,
  );
}

List<HistoricalArchiveSidebarSourceSummary>
buildHistoricalArchiveSidebarKnownSources({
  required List<HistoricalArchiveSourceMetadata> sources,
  required Map<
    HistoricalArchiveSourceIdentity,
    HistoricalArchiveImportedSourceMatch
  >
  importedSourcesByIdentity,
  HistoricalArchiveSourceIdentity? selectedSourceIdentity,
  HistoricalArchiveSourceIdentity? removingSourceIdentity,
  int? removingImportedMessageCount,
  HistoricalArchivesKnownSourceReference? reference,
}) {
  return <HistoricalArchiveSidebarSourceSummary>[
    for (final source in sources)
      if ((source.lastImportSuccess == true &&
              importedSourcesByIdentity[source.identity] != null) ||
          source.identity == removingSourceIdentity)
        HistoricalArchiveSidebarSourceSummary(
          identity: source.identity,
          label: source.sourceLabel,
          dateRangeLabel: _buildDateRangeLabel(source),
          messageCountLabel: _buildMessageCountLabel(
            source,
            importedSource: importedSourcesByIdentity[source.identity],
            removingImportedMessageCount:
                source.identity == removingSourceIdentity
                ? removingImportedMessageCount
                : null,
          ),
          importedOnLabel: _buildImportedOnLabel(source),
          isSelected: source.identity == selectedSourceIdentity,
          isReferenced: source.identity == reference?.identity,
          isBusy: source.identity == removingSourceIdentity,
          referenceOccurrence: source.identity == reference?.identity
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
