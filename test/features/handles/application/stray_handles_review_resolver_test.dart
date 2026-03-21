import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/resolvers/stray_handles_review_resolver.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';

void main() {
  group('StrayHandlesReviewResolver', () {
    test('declares gutter-aware placement for review list content', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final viewModel = await container
          .read(strayHandlesReviewResolverProvider.notifier)
          .resolve(
            filter: StrayHandleFilter.phones,
            mode: StrayHandleMode.allStrays,
          );

      expect(
        viewModel.placementMode,
        SidebarBodyPlacementMode.insetWithTrailingGutter,
      );
      expect(viewModel.shouldExpand, isTrue);
    });
  });
}
