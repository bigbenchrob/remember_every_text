import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

/// Inert transport payload for the unmatched-handles cassette.
final class UnmatchedHandlesCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const UnmatchedHandlesCassettePayload({
    super.title = 'Unmatched phone numbers & emails',
    super.subtitle =
        'Link stray handles to contacts to keep conversations organized.',
    super.sectionTitle,
    super.footerText,
    super.placementMode = SidebarBodyPlacementMode.inset,
    super.contentAlignment = SidebarBodyContentAlignment.fill,
    super.layoutStyle = SidebarCardLayoutStyle.standard,
    super.isNaked = false,
    super.shouldExpand = true,
    super.role = SidebarCassetteRole.contextPrimary,
    super.topSpacing = 0,
  });
}
