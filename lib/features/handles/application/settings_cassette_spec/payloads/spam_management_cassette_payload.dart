import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

/// Inert transport payload for the spam-management settings cassette.
final class SpamManagementCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const SpamManagementCassettePayload({
    super.title = 'Spam Management',
    super.subtitle = 'Block unwanted handles and manage your blacklist.',
    super.sectionTitle,
    super.footerText,
    super.placementMode = SidebarBodyPlacementMode.inset,
    super.contentAlignment = SidebarBodyContentAlignment.fill,
    super.layoutStyle = SidebarCardLayoutStyle.standard,
    super.isNaked = false,
    super.shouldExpand = true,
    super.role = SidebarCassetteRole.action,
    super.topSpacing = 0,
  });
}
