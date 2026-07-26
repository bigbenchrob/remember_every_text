import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/handles_cassette_spec.dart';

/// Inert transport payload for the stray-handles review cassette.
final class StrayHandlesReviewCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const StrayHandlesReviewCassettePayload({
    required this.investigation,
    required this.filter,
    required this.mode,
    super.title = '',
    super.subtitle,
    super.sectionTitle,
    super.footerText,
    super.placementMode = SidebarBodyPlacementMode.inset,
    super.contentAlignment = SidebarBodyContentAlignment.fill,
    super.layoutStyle = SidebarCardLayoutStyle.controlAligned,
    super.isNaked = false,
    super.shouldExpand = true,
    super.role = SidebarCassetteRole.contextPrimary,
    super.topSpacing = 0,
  });

  final StrayHandleInvestigation investigation;
  final StrayHandleFilter? filter;
  final StrayHandleReviewMode mode;
}
