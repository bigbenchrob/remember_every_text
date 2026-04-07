import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/payloads/messages_heatmap_cassette_payload.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolvers/heatmap_resolver.dart';

void main() {
  group('HeatmapResolver', () {
    test('returns an inert placement-governed heatmap payload', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final payload = await container
          .read(heatmapResolverProvider.notifier)
          .resolve(contactId: 42, cassetteIndex: 3);

      expect(payload, isA<MessagesHeatmapCassettePayload>());
      final heatmapPayload = payload as MessagesHeatmapCassettePayload;

      expect(heatmapPayload.contactId, 42);
      expect(heatmapPayload.placementMode, SidebarBodyPlacementMode.inset);
      expect(
        heatmapPayload.contentAlignment,
        SidebarBodyContentAlignment.loose,
      );
      expect(
        heatmapPayload.renderKind,
        SidebarCassetteRenderKind.placementGovernedFeature,
      );
    });
  });
}
