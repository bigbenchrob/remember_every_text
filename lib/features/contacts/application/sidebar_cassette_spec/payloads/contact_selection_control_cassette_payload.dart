import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

/// Inert transport payload for the contact selection control cassette.
final class ContactSelectionControlCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const ContactSelectionControlCassettePayload({
    required this.contactId,
    required this.cassetteIndex,
    super.title = '',
    super.subtitle,
    super.sectionTitle,
    super.footerText,
    super.placementMode = SidebarBodyPlacementMode.fullWidth,
    super.contentAlignment = SidebarBodyContentAlignment.leftAnchored,
    super.layoutStyle = SidebarCardLayoutStyle.standard,
    super.isNaked = true,
    super.shouldExpand = false,
    super.role = SidebarCassetteRole.appControl,
    super.topSpacing = 0,
  });

  final int contactId;
  final int cassetteIndex;
}
