import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/conversation_graph/application/conversation_favourites/conversation_favourite_actions_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_favourites/conversation_favourites_provider.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';

void main() {
  group('ConversationFavouriteActions', () {
    late OverlayDatabase overlayDb;

    ProviderContainer buildContainer() {
      return ProviderContainer(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
        ],
      );
    }

    setUp(() {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await overlayDb.close();
    });

    test('toggles Core favourites through the action boundary', () async {
      final container = buildContainer();
      addTearDown(container.dispose);

      await container
          .read(conversationFavouriteActionsProvider.notifier)
          .toggleCoreFavourite(8796093022216);

      expect(
        container
            .read(conversationFavouritesControllerProvider)
            .coreConversationIds,
        [8796093022216],
      );

      await container
          .read(conversationFavouriteActionsProvider.notifier)
          .toggleCoreFavourite(8796093022216);

      expect(
        container
            .read(conversationFavouritesControllerProvider)
            .coreConversationIds,
        isEmpty,
      );
    });
  });
}
