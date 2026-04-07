import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

/// Inert transport payload for the manual-linking settings cassette.
final class ManualLinkingCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const ManualLinkingCassettePayload({
    super.title = 'Manual Linking',
    super.subtitle =
        'Link unknown handles to contacts when automatic matching fails.',
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
