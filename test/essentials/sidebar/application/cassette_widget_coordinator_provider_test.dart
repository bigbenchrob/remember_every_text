import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers/working_db_populated_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_rack_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_widget_coordinator_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view/sidebar_cassette_card.dart';
import 'package:remember_this_text/features/handles/application/state/stray_handle_mode_provider.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';

void main() {
  group('cassetteWidgetCoordinatorProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          workingDbPopulatedProvider.overrideWith(
            _AlwaysPopulatedWorkingDb.new,
          ),
        ],
      );

      container.read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        ..setRack([
          const CassetteSpec.handles(
            HandlesCassetteSpec.strayHandlesReview(
              filter: StrayHandleFilter.phones,
            ),
          ),
        ]);
    });

    tearDown(() {
      container.dispose();
    });

    test('rebuilds stray handle review cassette when mode changes', () async {
      final provider = cassetteWidgetCoordinatorProvider(SidebarMode.messages);

      final initialWidgets = await container.read(provider.future);
      expect(
        _reviewCard(initialWidgets).sectionTitle,
        'Unfamiliar phone numbers',
      );

      container
          .read(strayHandleModeSettingProvider.notifier)
          .setMode(StrayHandleMode.spamCandidates);

      final updatedWidgets = await container.read(provider.future);
      expect(_reviewCard(updatedWidgets).sectionTitle, 'Spam phone numbers');
    });
  });
}

SidebarCassetteCard _reviewCard(List<Widget> widgets) {
  expect(widgets, hasLength(1));

  Widget current = widgets.single;
  while (current is Padding) {
    final child = current.child;
    expect(child, isNotNull);
    current = child!;
  }

  expect(current, isA<SidebarCassetteCard>());
  return current as SidebarCassetteCard;
}

class _AlwaysPopulatedWorkingDb extends WorkingDbPopulated {
  @override
  bool build() {
    return true;
  }
}
