import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/handles_cassette_spec.dart';

final class StrayHandlesInvestigationSwitcherCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const StrayHandlesInvestigationSwitcherCassettePayload({
    required this.selectedInvestigation,
    required this.cassetteIndex,
    super.title = '',
    super.placementMode = SidebarBodyPlacementMode.fullWidth,
    super.contentAlignment = SidebarBodyContentAlignment.fill,
    super.layoutStyle = SidebarCardLayoutStyle.standard,
    super.isNaked = true,
    super.shouldExpand = false,
    super.role = SidebarCassetteRole.filter,
    super.topSpacing = 0,
  });

  final StrayHandleInvestigation selectedInvestigation;
  final int cassetteIndex;
}
