import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/handles_cassette_spec.dart';

/// Inert transport payload for the stray-handles mode switcher cassette.
final class StrayHandlesModeSwitcherCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const StrayHandlesModeSwitcherCassettePayload({
    required this.investigation,
    required this.filter,
    required this.mode,
    super.title = '',
    super.subtitle,
    super.sectionTitle,
    super.footerText,
    super.placementMode = SidebarBodyPlacementMode.fullWidth,
    super.contentAlignment = SidebarBodyContentAlignment.fill,
    super.layoutStyle = SidebarCardLayoutStyle.standard,
    super.isNaked = true,
    super.shouldExpand = false,
    super.role = SidebarCassetteRole.filter,
    super.topSpacing = 0,
  });

  final StrayHandleInvestigation investigation;
  final StrayHandleFilter? filter;
  final StrayHandleReviewMode mode;
}
