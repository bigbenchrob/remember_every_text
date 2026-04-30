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
        'Older Messages folders may contain message records that are not present on this Mac today. MessageLens imports those records into its canonical message ledger, then migrates them into the normal timeline, search, and heatmap surfaces. Historical archive import is additive and does not replace current message data.',
    super.role = SidebarCassetteRole.contextSecondary,
    super.topSpacing = 0,
    super.footnote =
        'This shell is the first step: it makes the archive workflow visible before real import wiring is enabled.',
    this.knownSources = const [],
  });

  final List<HistoricalArchiveSidebarSourceSummary> knownSources;
}
