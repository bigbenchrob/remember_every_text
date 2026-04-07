import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

/// Inert transport payload for the messages heatmap cassette.
final class MessagesHeatmapCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const MessagesHeatmapCassettePayload({
    required this.contactId,
    super.title = '',
    super.subtitle,
    super.sectionTitle,
    super.footerText,
    super.placementMode = SidebarBodyPlacementMode.inset,
    super.contentAlignment = SidebarBodyContentAlignment.loose,
    super.layoutStyle = SidebarCardLayoutStyle.standard,
    super.isNaked = false,
    super.shouldExpand = false,
    super.role = SidebarCassetteRole.contextPrimary,
    super.topSpacing = 0,
  });

  final int? contactId;
}
