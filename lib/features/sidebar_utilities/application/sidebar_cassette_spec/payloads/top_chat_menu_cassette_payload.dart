import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/sidebar_utilities_constants.dart';

/// Inert transport payload for the top chat menu cassette.
final class TopChatMenuCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const TopChatMenuCassettePayload({
    required this.currentChoice,
    required this.cassetteIndex,
    required this.sidebarMode,
    super.title = '',
    super.subtitle,
    super.sectionTitle,
    super.footerText,
    super.placementMode = SidebarBodyPlacementMode.fullWidth,
    super.contentAlignment = SidebarBodyContentAlignment.insetControl,
    super.layoutStyle = SidebarCardLayoutStyle.standard,
    super.isNaked = true,
    super.shouldExpand = false,
    super.role = SidebarCassetteRole.appControl,
    super.topSpacing = 0,
  });

  final TopChatMenuChoice currentChoice;
  final int cassetteIndex;
  final SidebarMode sidebarMode;
}
