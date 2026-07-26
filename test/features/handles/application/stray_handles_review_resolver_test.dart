import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/payloads/stray_handles_review_cassette_payload.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/resolvers/stray_handles_review_resolver.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';

void main() {
  group('StrayHandlesReviewResolver', () {
    test('leaves the trailing action rail to the review rows', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final payload = await container
          .read(strayHandlesReviewResolverProvider.notifier)
          .resolve(
            investigation: StrayHandleInvestigation.identifySources,
            filter: StrayHandleFilter.phones,
            mode: StrayHandleReviewMode.active,
          );

      expect(payload, isA<StrayHandlesReviewCassettePayload>());
      final viewModel = payload as StrayHandlesReviewCassettePayload;

      expect(viewModel.placementMode, SidebarBodyPlacementMode.inset);
      expect(viewModel.shouldExpand, isTrue);
    });
  });
}
