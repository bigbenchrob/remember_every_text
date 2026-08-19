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
    this.referenceOccurrence = 0,
  });

  final String sourceKey;
  final String label;
  final String? dateRangeLabel;
  final String messageCountLabel;
  final String? importedOnLabel;
  final bool isReferenced;
  final bool isSelected;
  final int referenceOccurrence;
}

final class HistoricalArchivesSettingsCassettePayload
    extends FeatureInfoSidebarCassettePayload {
  const HistoricalArchivesSettingsCassettePayload({
    super.bodyText =
        'Add older message history to MessageLens without replacing your current data. Choose where that history comes from below.',
    super.role = SidebarCassetteRole.contextSecondary,
    super.topSpacing = 0,
    this.knownSources = const [],
  });

  final List<HistoricalArchiveSidebarSourceSummary> knownSources;
}
