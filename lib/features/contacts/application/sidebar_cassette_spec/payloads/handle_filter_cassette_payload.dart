import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

/// Inert transport payload for the contact handle-filter cassette.
final class HandleFilterCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const HandleFilterCassettePayload({
    required this.contactId,
    required this.selectedHandleId,
    required this.cassetteIndex,
    super.title = '',
    super.subtitle,
    super.sectionTitle,
    super.footerText,
    super.placementMode = SidebarBodyPlacementMode.fullWidth,
    super.contentAlignment = SidebarBodyContentAlignment.insetControl,
    super.layoutStyle = SidebarCardLayoutStyle.standard,
    super.isNaked = true,
    super.shouldExpand = false,
    super.role = SidebarCassetteRole.filter,
    super.topSpacing = 0,
  });

  final int contactId;
  final int? selectedHandleId;
  final int cassetteIndex;
}
