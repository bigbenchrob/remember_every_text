import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/payloads/top_chat_menu_cassette_payload.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/resolvers/top_chat_menu_resolver.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

void main() {
  group('TopChatMenuChoice', () {
    test('uses the app-wide default for unknown serialized ids', () {
      expect(TopChatMenuChoice.fromId('unknown'), defaultTopChatMenuChoice);
    });

    test('top menu cassette default uses the app-wide default', () {
      const spec = SidebarUtilityCassetteSpec.topChatMenu();

      expect(
        spec.when(
          topChatMenu: (selectedChoice) => selectedChoice,
          settingsMenu: () => null,
        ),
        defaultTopChatMenuChoice,
      );
    });
  });

  group('TopChatMenuResolver', () {
    test('returns an inert placement-governed top menu payload', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final payload = await container
          .read(topChatMenuResolverProvider.notifier)
          .resolve(
            currentChoice: TopChatMenuChoice.contacts,
            cassetteIndex: 0,
            sidebarMode: SidebarMode.messages,
          );

      expect(payload, isA<TopChatMenuCassettePayload>());
      final topMenuPayload = payload as TopChatMenuCassettePayload;

      expect(topMenuPayload.currentChoice, TopChatMenuChoice.contacts);
      expect(topMenuPayload.cassetteIndex, 0);
      expect(topMenuPayload.sidebarMode, SidebarMode.messages);
      expect(topMenuPayload.role, SidebarCassetteRole.appControl);
      expect(topMenuPayload.placementMode, SidebarBodyPlacementMode.fullWidth);
      expect(topMenuPayload.isNaked, isTrue);
    });
  });
}
