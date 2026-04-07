import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

/// Inert transport payload for the contact hero summary cassette.
final class ContactHeroSummaryCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const ContactHeroSummaryCassettePayload({
    required this.contactId,
    required this.cassetteIndex,
    super.title = '',
    super.subtitle,
    super.sectionTitle,
    super.footerText,
    super.placementMode = SidebarBodyPlacementMode.fullWidth,
    super.contentAlignment = SidebarBodyContentAlignment.fill,
    super.layoutStyle = SidebarCardLayoutStyle.standard,
    super.isNaked = true,
    super.shouldExpand = false,
    super.role = SidebarCassetteRole.contextPrimary,
    super.topSpacing = 0,
  });

  final int contactId;
  final int cassetteIndex;
}
