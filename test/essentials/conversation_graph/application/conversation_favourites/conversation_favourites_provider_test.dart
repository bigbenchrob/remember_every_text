import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/conversation_graph/application/conversation_favourites/conversation_favourites_provider.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';

void main() {
  group('ConversationFavouritesController', () {
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

    test('defaults to no Core favourites', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final favourites = container.read(
        conversationFavouritesControllerProvider,
      );

      expect(favourites.coreConversationIds, isEmpty);
    });

    test('persists Core favourites in the overlay database', () async {
      final firstContainer = buildContainer();
      addTearDown(firstContainer.dispose);

      await firstContainer
          .read(conversationFavouritesControllerProvider.notifier)
          .toggleCoreFavourite(42);
      await firstContainer
          .read(conversationFavouritesControllerProvider.notifier)
          .toggleCoreFavourite(7);

      expect(
        firstContainer
            .read(conversationFavouritesControllerProvider)
            .coreConversationIds,
        [7, 42],
      );
      expect(
        await overlayDb.readOverlaySetting('conversation_favourites/core'),
        '{"coreConversationIds":[7,42]}',
      );

      final restoredContainer = buildContainer();
      addTearDown(restoredContainer.dispose);

      expect(
        restoredContainer
            .read(conversationFavouritesControllerProvider)
            .coreConversationIds,
        isEmpty,
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(
        restoredContainer
            .read(conversationFavouritesControllerProvider)
            .coreConversationIds,
        [7, 42],
      );
    });

    test('removes an existing Core favourite', () async {
      final container = buildContainer();
      addTearDown(container.dispose);

      await container
          .read(conversationFavouritesControllerProvider.notifier)
          .toggleCoreFavourite(42);
      await container
          .read(conversationFavouritesControllerProvider.notifier)
          .toggleCoreFavourite(42);

      expect(
        container
            .read(conversationFavouritesControllerProvider)
            .coreConversationIds,
        isEmpty,
      );
    });

    test('restores Core favourites from structured JSON storage', () {
      final favourites = ConversationFavourites.fromCoreStorage(
        '{"coreConversationIds":[42,"nope",42,7]}',
      );

      expect(favourites.coreConversationIds, [42, 7]);
    });

    test('restores legacy comma-delimited Core favourites', () {
      final favourites = ConversationFavourites.fromCoreStorage('42,nope,42,7');

      expect(favourites.coreConversationIds, [42, 7]);
    });
  });
}
