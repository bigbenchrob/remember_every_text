import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

final class ConversationSignaturesCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const ConversationSignaturesCassettePayload({
    required this.cassetteIndex,
    super.title = '',
    super.subtitle,
    super.sectionTitle,
    super.footerText,
    super.placementMode = SidebarBodyPlacementMode.fullWidth,
    super.contentAlignment = SidebarBodyContentAlignment.fill,
    super.layoutStyle = SidebarCardLayoutStyle.listDense,
    super.isNaked = false,
    super.shouldExpand = true,
    super.role = SidebarCassetteRole.contextPrimary,
    super.semanticStyle = SidebarCassetteSemanticStyle.visualization,
    super.topSpacing = 0,
  });

  final int cassetteIndex;
}
