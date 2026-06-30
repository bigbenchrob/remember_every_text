import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers/conversation_graph_readiness_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/panel_widget_providers.dart';
import 'package:remember_this_text/essentials/navigation/application/sidebar_mode_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_rack_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/ephemeral_cassette_projection_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_action_dispatcher.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_cassette_spec.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_view_spec.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

void main() {
  group('activeSidebarModeProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          conversationGraphPopulatedProvider.overrideWith(
            _AlwaysPopulatedGraph.new,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'leaving settings after transient action clears ephemeral projection and leaves settings at the root menu',
      () async {
        final modeNotifier = container.read(activeSidebarModeProvider.notifier);
        final dispatcher = container.read(
          sidebarActionDispatcherProvider.notifier,
        );

        modeNotifier.setMode(SidebarMode.settings);

        await dispatcher.dispatch(
          intent: const SettingsPersistentContextChosen(
            actionId: SettingsMenuActionId.textSize,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        await dispatcher.dispatch(
          intent: const ShowResetMessageDataFlow(),
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
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
          ]),
        );
        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          equals([
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
          ]),
        );
        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          isEmpty,
        );
        expect(
          container.read(sidebarFlowProvider).persistentSettingsContext,
          isNull,
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
          ]),
        );
      },
    );

    test(
      'transient send logs after message history coverage does not restore the prior durable settings child on mode switch',
      () async {
        final modeNotifier = container.read(activeSidebarModeProvider.notifier);
        final dispatcher = container.read(
          sidebarActionDispatcherProvider.notifier,
        );

        modeNotifier.setMode(SidebarMode.settings);

        await dispatcher.dispatch(
          intent: const SettingsPersistentContextChosen(
            actionId: SettingsMenuActionId.messageHistoryCoverage,
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
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
            const CassetteSpec.settings(
              SettingsCassetteSpec.messageHistoryCoverageOverview(),
            ),
            const CassetteSpec.settings(
              SettingsCassetteSpec.messageHistoryCoverageHowToRead(),
            ),
            const CassetteSpec.settings(
              SettingsCassetteSpec.messageHistoryCoverageOlderMessagesNote(),
            ),
          ]),
        );
        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          isEmpty,
        );
        expect(
          container.read(
            effectiveCenterPanelSpecProvider(SidebarMode.settings),
          ),
          equals(
            const ViewSpec.settings(
              SettingsViewSpec.messageHistoryCoverageReport(),
            ),
          ),
        );

        await dispatcher.dispatch(
          intent: const ShowSendLogsFlow(),
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
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
          ]),
        );
        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.settings(SettingsCassetteSpec.sendLogsPanel()),
          ]),
        );
        expect(
          container.read(sidebarFlowProvider).persistentSettingsContext,
          isNull,
        );
        expect(
          container.read(
            effectiveCenterPanelSpecProvider(SidebarMode.settings),
          ),
          isNull,
        );

        modeNotifier.setMode(SidebarMode.messages);

        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          isEmpty,
        );

        modeNotifier.setMode(SidebarMode.settings);

        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
          ]),
        );
        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          isEmpty,
        );
        expect(
          container.read(
            effectiveCenterPanelSpecProvider(SidebarMode.settings),
          ),
          isNull,
        );
      },
    );
  });
}

class _AlwaysPopulatedGraph extends ConversationGraphPopulated {
  @override
  bool build() {
    return true;
  }
}
