import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

final class HistoricalArchiveSidebarSourceSummary {
  const HistoricalArchiveSidebarSourceSummary({
    required this.label,
    required this.dateRangeLabel,
    required this.messageCountLabel,
    required this.statusLabel,
    required this.lastRunSummaryLabel,
    required this.lastImportedLabel,
  });

  final String label;
  final String dateRangeLabel;
  final String messageCountLabel;
  final String statusLabel;
  final String lastRunSummaryLabel;
  final String lastImportedLabel;
}

final class HistoricalArchivesSettingsCassettePayload
    extends FeatureInfoSidebarCassettePayload {
  const HistoricalArchivesSettingsCassettePayload({
    super.title = 'Historical Archives',
    super.bodyText =
        'Older Messages folders may contain message records that are not present on this Mac today. MessageLens imports those records into source-scoped provenance, then projects them into the conversation graph and shared message evidence surfaces. Historical archive import is additive and does not replace current message data.',
    super.role = SidebarCassetteRole.contextSecondary,
    super.topSpacing = 0,
    super.footnote =
        'Archive import adds historical Messages folders to the source-scoped graph without replacing current message data.',
    this.knownSources = const [],
  });

  final List<HistoricalArchiveSidebarSourceSummary> knownSources;
}
