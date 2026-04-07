import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/contact_hero_summary_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolvers/contact_hero_summary_resolver.dart';

void main() {
  group('ContactHeroSummaryResolver', () {
    test('returns an inert placement-governed hero payload', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final payload = await container
          .read(contactHeroSummaryResolverProvider.notifier)
          .resolve(contactId: 42, cassetteIndex: 1);

      expect(payload, isA<ContactHeroSummaryCassettePayload>());
      final heroPayload = payload as ContactHeroSummaryCassettePayload;

      expect(heroPayload.contactId, 42);
      expect(heroPayload.cassetteIndex, 1);
      expect(heroPayload.role, SidebarCassetteRole.contextPrimary);
      expect(heroPayload.placementMode, SidebarBodyPlacementMode.fullWidth);
      expect(heroPayload.isNaked, isTrue);
      expect(heroPayload.shouldExpand, isFalse);
    });
  });
}
