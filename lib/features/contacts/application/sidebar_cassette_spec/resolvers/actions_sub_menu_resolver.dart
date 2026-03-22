import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../../../essentials/sidebar/domain/sidebar_body_model.dart';
import '../../../../../essentials/sidebar/domain/sidebar_body_option.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../../sidebar_utilities/domain/sidebar_utilities_constants.dart';

part 'actions_sub_menu_resolver.g.dart';

/// Resolver for ContactsSettingsSpec.actionsMenu().
///
/// Returns a naked cassette with the actions submenu dropdown.
@riverpod
class ActionsSubMenuResolver extends _$ActionsSubMenuResolver {
  @override
  void build() {}

  SidebarCassetteCardViewModel resolve({
    required ActionsMenuChoice? currentChoice,
  }) {
    return SidebarCassetteCardViewModel(
      role: SidebarCassetteRole.action,
      placementMode: SidebarBodyPlacementMode.fullWidth,
      title: '',
      isNaked: true,
      bodyModel: SidebarDropdownBodyModel(
        promptLabel: 'Choose an action:',
        selectedOptionId: currentChoice?.id,
        options: ActionsMenuChoice.values
            .map(
              (choice) => SidebarDropdownOption(
                id: choice.id,
                label: choice.label,
                selectionIntent: SettingsActionChosen(
                  choice: _mapSettingsActionChoice(choice),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

SidebarSettingsActionChoice _mapSettingsActionChoice(ActionsMenuChoice choice) {
  return switch (choice) {
    ActionsMenuChoice.sendLogs => SidebarSettingsActionChoice.sendLogs,
    ActionsMenuChoice.reimportData => SidebarSettingsActionChoice.reimportData,
  };
}
