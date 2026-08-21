import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../../../essentials/source_scoped_import/domain/historical_archive_source_identity.dart';

const historicalArchivesSidebarDescription =
    'Add older message history to MessageLens without replacing your current data.';

final class HistoricalArchiveSidebarSourceSummary {
  const HistoricalArchiveSidebarSourceSummary({
    required this.identity,
    required this.label,
    required this.dateRangeLabel,
    required this.messageCountLabel,
    this.importedOnLabel,
    this.isReferenced = false,
    this.isSelected = false,
    this.isBusy = false,
    this.referenceOccurrence = 0,
  });

  final HistoricalArchiveSourceIdentity identity;
  final String label;
  final String? dateRangeLabel;
  final String messageCountLabel;
  final String? importedOnLabel;
  final bool isReferenced;
  final bool isSelected;
  final bool isBusy;
  final int referenceOccurrence;

  String get sourceKey => identity.value;
}

final class HistoricalArchivesSettingsCassettePayload
    extends FeatureInfoSidebarCassettePayload {
  const HistoricalArchivesSettingsCassettePayload({
    super.bodyText = historicalArchivesSidebarDescription,
    super.role = SidebarCassetteRole.contextSecondary,
    super.topSpacing = 0,
    this.knownSources = const [],
  });

  final List<HistoricalArchiveSidebarSourceSummary> knownSources;
}
