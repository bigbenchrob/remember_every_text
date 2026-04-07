import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

/// Inert transport payload for the stray-phone-numbers cassette.
final class StrayPhoneNumbersCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const StrayPhoneNumbersCassettePayload({
    super.title = 'Stray phone numbers',
    super.subtitle =
        'Phone numbers not linked to any contact in your address book.',
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
