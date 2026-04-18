import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

final class SettingsActionCardCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const SettingsActionCardCassettePayload({
    required this.actions,
    required this.cassetteIndex,
    super.title = '',
    super.role = SidebarCassetteRole.action,
    super.topSpacing = 0,
    super.placementMode = SidebarBodyPlacementMode.fullWidth,
    super.contentAlignment = SidebarBodyContentAlignment.fill,
    super.layoutStyle = SidebarCardLayoutStyle.listDense,
    super.isNaked = false,
    super.shouldExpand = false,
  });

  final List<SidebarActionDescriptor> actions;
  final int cassetteIndex;
}
