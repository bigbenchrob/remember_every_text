import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../../../essentials/sidebar/domain/sidebar_body_model.dart';
import '../../../../../essentials/sidebar/domain/sidebar_body_option.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/sidebar_utilities_constants.dart';

part 'settings_top_menu_resolver.g.dart';

/// Settings Top Menu Resolver
///
/// This resolver implements the cross-surface spec system contract:
///
/// - Receives explicit parameters (NOT a spec)
/// - Returns Future<SidebarCassetteCardViewModel>
/// - Determines which widget builder is used
/// - Owns all decision-making for this cassette
///
/// The resolver MUST NOT:
/// - Accept a spec object
/// - Read a spec from shared state
/// - Return widgets, builders, or partial results
///
/// See: _AGENT_INSTRUCTIONS/agent-per-project/90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md
@riverpod
class SettingsTopMenuResolver extends _$SettingsTopMenuResolver {
  @override
  void build() {
    // Stateless resolver; invoked imperatively.
  }

  /// Resolve the settings top menu cassette.
  ///
  /// Parameters are explicit and fully-decided - no spec interpretation here.
  Future<SidebarCassetteCardViewModel> resolve({
    required SettingsMenuChoice currentChoice,
  }) async {
    return SidebarCassetteCardViewModel(
      role: SidebarCassetteRole.appControl,
      placementMode: SidebarBodyPlacementMode.fullWidth,
      contentAlignment: SidebarBodyContentAlignment.insetControl,
      title: '',
      isNaked: true,
      bodyModel: SidebarDropdownBodyModel(
        promptLabel: '',
        selectedOptionId: currentChoice.id,
        options: SettingsMenuChoice.values
            .map(
              (choice) => SidebarDropdownOption(
                id: choice.id,
                label: choice.label,
                selectionIntent: SettingsMenuChanged(
                  choice: _mapSettingsMenuChoice(choice),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

SidebarSettingsMenuChoice _mapSettingsMenuChoice(SettingsMenuChoice choice) {
  return switch (choice) {
    SettingsMenuChoice.actions => SidebarSettingsMenuChoice.actions,
  };
}
