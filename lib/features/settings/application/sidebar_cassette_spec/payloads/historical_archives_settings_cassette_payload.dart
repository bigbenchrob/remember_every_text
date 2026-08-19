import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

final class HistoricalArchiveSidebarSourceSummary {
  const HistoricalArchiveSidebarSourceSummary({
    required this.sourceKey,
    required this.label,
    required this.dateRangeLabel,
    required this.messageCountLabel,
    this.importedOnLabel,
    this.isReferenced = false,
    this.isSelected = false,
    this.referencePulseOccurrence = 0,
  });

  final String sourceKey;
  final String label;
  final String? dateRangeLabel;
  final String messageCountLabel;
  final String? importedOnLabel;
  final bool isReferenced;
  final bool isSelected;
  final int referencePulseOccurrence;
}

final class HistoricalArchivesSettingsCassettePayload
    extends FeatureInfoSidebarCassettePayload {
  const HistoricalArchivesSettingsCassettePayload({
    super.title = 'Historical Archives',
    super.bodyText =
        'Older Messages folders may contain message records that are not present on this Mac today. MessageLens can add those messages to its browsing data without replacing current message data.',
    super.role = SidebarCassetteRole.contextSecondary,
    super.topSpacing = 0,
    super.footnote =
        'Archive import is additive and keeps current message data intact.',
    this.knownSources = const [],
  });

  final List<HistoricalArchiveSidebarSourceSummary> knownSources;
}
