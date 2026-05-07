import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers/working_db_populated_provider.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/working_projection_readiness_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_rack_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_action_dispatcher.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_cassette_spec.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

void main() {
  group('cassetteRackStateProvider', () {
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
      'select persistent context then rebuild settings rack retains durable child',
      () async {
        final dispatcher = container.read(
          sidebarActionDispatcherProvider.notifier,
        );

        await dispatcher.dispatch(
          intent: const SettingsPersistentContextChosen(
            actionId: SettingsMenuActionId.textSize,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        container
            .read(cassetteRackStateProvider(SidebarMode.settings).notifier)
            .resetToInitial();

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
      },
    );

    test(
      'does not activate contacts cascade when projection is incomplete',
      () {
        final guardedContainer = ProviderContainer(
          overrides: [
            workingProjectionReadinessProvider.overrideWith(
              (ref) async => const WorkingProjectionReadiness(
                isReady: false,
                reason: 'test incomplete projection',
              ),
            ),
          ],
        );
        addTearDown(guardedContainer.dispose);

        expect(
          guardedContainer
              .read(cassetteRackStateProvider(SidebarMode.messages))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.topChatMenu(),
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
