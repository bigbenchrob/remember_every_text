import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/settings_top_menu_row.dart';
import '../../../domain/sidebar_utilities_constants.dart';

final class SettingsTopMenuCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const SettingsTopMenuCassettePayload({
    required this.rows,
    required this.cassetteIndex,
    required this.promptLabel,
    this.persistentContextActionId,
    super.title = '',
    super.role = SidebarCassetteRole.appControl,
    super.topSpacing = 0,
    super.placementMode = SidebarBodyPlacementMode.fullWidth,
    super.contentAlignment = SidebarBodyContentAlignment.insetControl,
    super.layoutStyle = SidebarCardLayoutStyle.standard,
    super.isNaked = true,
    super.shouldExpand = false,
  });

  final List<SettingsTopMenuRow> rows;
  final int cassetteIndex;
  final String promptLabel;
  final SettingsMenuActionId? persistentContextActionId;
}
