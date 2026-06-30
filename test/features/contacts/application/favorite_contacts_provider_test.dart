import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/contacts/application/contact_access/contact_access_provider.dart';
import 'package:remember_this_text/features/contacts/application/favorites/favorite_contacts_repository_provider.dart';
import 'package:remember_this_text/features/contacts/application/read_models/contacts_list_repository_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/contact_favorite_actions_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/contact_is_favorite_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/favorite_contacts_provider.dart';
import 'package:remember_this_text/features/contacts/infrastructure/repositories/favorite_contacts_repository.dart';
import 'package:remember_this_text/features/contacts/infrastructure/repositories/overlay_contact_access_store.dart';

import '../../../test_utils/contact_summary_fixture.dart';

void main() {
  group('favoriteContactsProvider', () {
    late OverlayDatabase overlayDb;
    ProviderContainer? container;

    setUp(() {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await overlayDb.close();
      container?.dispose();
    });

    test(
      'returns resolved favorites ordered by last interaction, newest first',
      () async {
        await overlayDb.addFavorite(1, DateTime.utc(2024, 12, 1));
        await overlayDb.addFavorite(2, DateTime.utc(2024, 12, 5));

        container = ProviderContainer(
          overrides: [
            favoriteContactsRepositoryProvider.overrideWith(
              (ref) async => FavoriteContactsRepository(overlayDb),
            ),
            contactsListRepositoryProvider.overrideWith(
              (ref) async => [
                buildContactSummary(participantId: 1, displayName: 'Alice'),
                buildContactSummary(participantId: 2, displayName: 'Bob'),
              ],
            ),
          ],
        );

        final results = await container!.read(favoriteContactsProvider.future);

        expect(results, hasLength(2));
        expect(
          results.map((entry) => entry.contact.participantId),
          equals([2, 1]), // lastInteractionUtc desc
        );
      },
    );

    test('excludes favorites without matching contact summaries', () async {
      await overlayDb.addFavorite(1, DateTime.utc(2024, 12, 1));

      container = ProviderContainer(
        overrides: [
          favoriteContactsRepositoryProvider.overrideWith(
            (ref) async => FavoriteContactsRepository(overlayDb),
          ),
          contactsListRepositoryProvider.overrideWith(
            (ref) async => [
              buildContactSummary(participantId: 2, displayName: 'Bob'),
            ],
          ),
        ],
      );

      final results = await container!.read(favoriteContactsProvider.future);

      expect(results, isEmpty);
    });

    test('resolves rowid-keyed favorite to graph contact summary', () async {
      const rowidKeyedContactId = 24;
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: rowidKeyedContactId,
      );
      await overlayDb.addFavorite(
        rowidKeyedContactId,
        DateTime.utc(2024, 12, 1),
      );

      container = ProviderContainer(
        overrides: [
          favoriteContactsRepositoryProvider.overrideWith(
            (ref) async => FavoriteContactsRepository(overlayDb),
          ),
          contactsListRepositoryProvider.overrideWith(
            (ref) async => [
              buildContactSummary(
                participantId: graphContactId,
                displayName: 'Claire',
              ),
            ],
          ),
        ],
      );

      final favorites = await container!.read(favoriteContactsProvider.future);
      final isFavorite = await container!.read(
        contactIsFavoriteProvider(participantId: graphContactId).future,
      );

      expect(favorites, hasLength(1));
      expect(favorites.single.contact.participantId, graphContactId);
      expect(isFavorite, isTrue);
    });

    test(
      'deduplicates rowid-keyed and graph favorites for same contact',
      () async {
        const rowidKeyedContactId = 24;
        final graphContactId = SourceScopedRowKey.pack(
          sourceId: liveAddressBookSourceId,
          sourceRowId: rowidKeyedContactId,
        );
        await overlayDb.addFavorite(
          rowidKeyedContactId,
          DateTime.utc(2024, 12, 1),
        );
        await overlayDb.addFavorite(graphContactId, DateTime.utc(2024, 12, 5));

        container = ProviderContainer(
          overrides: [
            favoriteContactsRepositoryProvider.overrideWith(
              (ref) async => FavoriteContactsRepository(overlayDb),
            ),
            contactsListRepositoryProvider.overrideWith(
              (ref) async => [
                buildContactSummary(
                  participantId: graphContactId,
                  displayName: 'Claire',
                ),
              ],
            ),
          ],
        );

        final favorites = await container!.read(
          favoriteContactsProvider.future,
        );

        expect(favorites, hasLength(1));
        expect(favorites.single.contact.participantId, graphContactId);
        expect(favorites.single.lastInteractionAt, DateTime.utc(2024, 12, 5));
      },
    );

    test('unfavorite clears rowid-keyed and graph key variants', () async {
      const rowidKeyedContactId = 24;
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: rowidKeyedContactId,
      );
      await overlayDb.addFavorite(
        rowidKeyedContactId,
        DateTime.utc(2024, 12, 1),
      );
      await overlayDb.addFavorite(graphContactId, DateTime.utc(2024, 12, 5));

      container = ProviderContainer(
        overrides: [
          favoriteContactsRepositoryProvider.overrideWith(
            (ref) async => FavoriteContactsRepository(overlayDb),
          ),
          contactsListRepositoryProvider.overrideWith(
            (ref) async => [
              buildContactSummary(
                participantId: graphContactId,
                displayName: 'Claire',
              ),
            ],
          ),
        ],
      );

      await container!
          .read(contactFavoriteActionsProvider.notifier)
          .setFavorite(contactId: graphContactId, isFavorite: false);

      final favorites = await container!.read(favoriteContactsProvider.future);
      final isFavorite = await container!.read(
        contactIsFavoriteProvider(participantId: graphContactId).future,
      );

      expect(favorites, isEmpty);
      expect(isFavorite, isFalse);
    });

    test('favorite rewrites rowid-keyed variant to graph key', () async {
      const rowidKeyedContactId = 24;
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: rowidKeyedContactId,
      );
      await overlayDb.addFavorite(
        rowidKeyedContactId,
        DateTime.utc(2024, 12, 1),
      );

      container = ProviderContainer(
        overrides: [
          favoriteContactsRepositoryProvider.overrideWith(
            (ref) async => FavoriteContactsRepository(overlayDb),
          ),
          contactsListRepositoryProvider.overrideWith(
            (ref) async => [
              buildContactSummary(
                participantId: graphContactId,
                displayName: 'Claire',
              ),
            ],
          ),
        ],
      );

      await container!
          .read(contactFavoriteActionsProvider.notifier)
          .setFavorite(contactId: graphContactId, isFavorite: true);

      final repository = await container!.read(
        favoriteContactsRepositoryProvider.future,
      );
      final rawFavorites = await repository.getAllFavorites();
      final favorites = await container!.read(favoriteContactsProvider.future);

      expect(rawFavorites.map((entry) => entry.participantId), [
        graphContactId,
      ]);
      expect(favorites.single.contact.participantId, graphContactId);
    });

    test(
      'recent contact selection rewrites access marker to graph key',
      () async {
        const rowidKeyedContactId = 24;
        final graphContactId = SourceScopedRowKey.pack(
          sourceId: liveAddressBookSourceId,
          sourceRowId: rowidKeyedContactId,
        );
        await overlayDb.addFavorite(
          rowidKeyedContactId,
          DateTime.utc(2024, 12, 1),
        );

        container = ProviderContainer(
          overrides: [
            contactAccessStoreProvider.overrideWith(
              (ref) async =>
                  OverlayContactAccessStore(overlayDatabase: overlayDb),
            ),
          ],
        );

        await container!
            .read(contactAccessActionsProvider.notifier)
            .recordContactSelection(graphContactId);

        final recentRows = await overlayDb.getRecentContacts(limit: 10);
        final favoriteRows = await overlayDb.getAllFavorites();

        expect(recentRows.map((row) => row.participantId), [graphContactId]);
        expect(favoriteRows.map((row) => row.participantId), [
          rowidKeyedContactId,
        ]);
      },
    );
  });
}
