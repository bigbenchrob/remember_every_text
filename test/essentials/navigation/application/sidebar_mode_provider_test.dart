import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers/working_db_populated_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/sidebar_mode_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_rack_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_action_dispatcher.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_cassette_spec.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/settings_top_menu_row.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

void main() {
  group('activeSidebarModeProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          workingDbPopulatedProvider.overrideWith(
            _AlwaysPopulatedWorkingDb.new,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'leaving settings clears transient rack state and preserves only durable settings context',
      () async {
        final modeNotifier = container.read(activeSidebarModeProvider.notifier);
        final dispatcher = container.read(
          sidebarActionDispatcherProvider.notifier,
        );

        modeNotifier.setMode(SidebarMode.settings);

        await dispatcher.dispatch(
          intent: const SettingsTopMenuActionChosen(
            actionId: SettingsMenuActionId.textSize,
            semantic: SettingsTopMenuActionSemantic.persistentContext,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        await dispatcher.dispatch(
          intent: const SettingsTopMenuActionChosen(
            actionId: SettingsMenuActionId.resetMessageData,
            semantic: SettingsTopMenuActionSemantic.transientAction,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(
                expandedActionId: SettingsMenuActionId.resetMessageData,
              ),
            ),
            const CassetteSpec.settings(
              SettingsCassetteSpec.resetMessageDataPanel(),
            ),
          ]),
        );

        modeNotifier.setMode(SidebarMode.messages);

        expect(container.read(activeSidebarModeProvider), SidebarMode.messages);
        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
            const CassetteSpec.settings(
              SettingsCassetteSpec.textSizePlaceholder(),
            ),
          ]),
        );
        expect(
          container.read(sidebarFlowProvider).persistentSettingsContext,
          SettingsMenuActionId.textSize,
        );

        modeNotifier.setMode(SidebarMode.settings);

        expect(container.read(activeSidebarModeProvider), SidebarMode.settings);
        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
            const CassetteSpec.settings(
              SettingsCassetteSpec.textSizePlaceholder(),
            ),
          ]),
        );
      },
    );
  });
}

class _AlwaysPopulatedWorkingDb extends WorkingDbPopulated {
  @override
  bool build() {
    return true;
  }
}
