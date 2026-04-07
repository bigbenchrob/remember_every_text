import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/payloads/stray_handles_mode_switcher_cassette_payload.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/payloads/stray_handles_type_switcher_cassette_payload.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/resolvers/stray_handles_mode_switcher_resolver.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/resolvers/stray_handles_type_switcher_resolver.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';

void main() {
  group('Stray handle switcher resolvers', () {
    test(
      'mode switcher resolver returns inert payload with current mode',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final payload = await container
            .read(strayHandlesModeSwitcherResolverProvider.notifier)
            .resolve(
              filter: StrayHandleFilter.phones,
              mode: StrayHandleMode.spamCandidates,
            );

        expect(payload, isA<StrayHandlesModeSwitcherCassettePayload>());
        final viewModel = payload as StrayHandlesModeSwitcherCassettePayload;

        expect(viewModel.filter, StrayHandleFilter.phones);
        expect(viewModel.mode, StrayHandleMode.spamCandidates);
        expect(viewModel.placementMode, SidebarBodyPlacementMode.fullWidth);
        expect(viewModel.isNaked, isTrue);
      },
    );

    test(
      'type switcher resolver returns inert payload with cassette context',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final payload = await container
            .read(strayHandlesTypeSwitcherResolverProvider.notifier)
            .resolve(
              selectedFilter: StrayHandleFilter.businessUrns,
              cassetteIndex: 4,
            );

        expect(payload, isA<StrayHandlesTypeSwitcherCassettePayload>());
        final viewModel = payload as StrayHandlesTypeSwitcherCassettePayload;

        expect(viewModel.selectedFilter, StrayHandleFilter.businessUrns);
        expect(viewModel.cassetteIndex, 4);
        expect(viewModel.placementMode, SidebarBodyPlacementMode.fullWidth);
        expect(viewModel.isNaked, isTrue);
      },
    );
  });
}
