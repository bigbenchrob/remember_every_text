import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

/// Inert transport payload for the no-handle/from-me recovered navigator.
final class RecoveredNoHandleFromMeNavigatorCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const RecoveredNoHandleFromMeNavigatorCassettePayload({
    required this.cassetteIndex,
    super.title = '',
    super.subtitle,
    super.sectionTitle,
    super.footerText,
    super.placementMode = SidebarBodyPlacementMode.fullWidth,
    super.contentAlignment = SidebarBodyContentAlignment.fill,
    super.layoutStyle = SidebarCardLayoutStyle.standard,
    super.isNaked = false,
    super.shouldExpand = false,
    super.role = SidebarCassetteRole.action,
    super.topSpacing = 0,
  });

  final int cassetteIndex;
}
