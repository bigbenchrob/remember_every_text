import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/conversation_signature_display_provider.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/conversation_signature_preferences_provider.dart';

void main() {
  group('ConversationSignaturePreferencesController', () {
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

    test(
      'defaults to all filter, most recently updated sort, and browse mode',
      () {
        final container = buildContainer();
        addTearDown(container.dispose);

        final preferences = container.read(
          conversationSignaturePreferencesControllerProvider,
        );

        expect(preferences.filter, ConversationSignatureFilter.all);
        expect(preferences.sort, ConversationSignatureSort.mostRecentlyUpdated);
        expect(preferences.mode, ConversationSignatureMode.browse);
      },
    );

    test('persists filter, sort, and mode choices in overlay', () async {
      final firstContainer = buildContainer();
      addTearDown(firstContainer.dispose);

      await firstContainer
          .read(conversationSignaturePreferencesControllerProvider.notifier)
          .setFilter(ConversationSignatureFilter.highActivity);
      await firstContainer
          .read(conversationSignaturePreferencesControllerProvider.notifier)
          .setSort(ConversationSignatureSort.mostTotalMessages);
      await firstContainer
          .read(conversationSignaturePreferencesControllerProvider.notifier)
          .setMode(ConversationSignatureMode.favourites);

      final restoredContainer = buildContainer();
      addTearDown(restoredContainer.dispose);

      final initialRestored = restoredContainer.read(
        conversationSignaturePreferencesControllerProvider,
      );
      expect(initialRestored.filter, ConversationSignatureFilter.all);
      expect(
        initialRestored.sort,
        ConversationSignatureSort.mostRecentlyUpdated,
      );
      expect(initialRestored.mode, ConversationSignatureMode.browse);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      final restored = restoredContainer.read(
        conversationSignaturePreferencesControllerProvider,
      );

      expect(restored.filter, ConversationSignatureFilter.highActivity);
      expect(restored.sort, ConversationSignatureSort.mostTotalMessages);
      expect(restored.mode, ConversationSignatureMode.favourites);
    });

    test('falls back to safe defaults for unknown stored values', () {
      final restored = ConversationSignaturePreferences.fromStorage(
        'unknown|also_unknown|still_unknown',
      );

      expect(restored.filter, ConversationSignatureFilter.all);
      expect(restored.sort, ConversationSignatureSort.mostRecentlyUpdated);
      expect(restored.mode, ConversationSignatureMode.browse);
    });

    test('restores old two-part storage as browse mode with renamed sort', () {
      final restored = ConversationSignaturePreferences.fromStorage(
        'groups|largest',
      );

      expect(restored.filter, ConversationSignatureFilter.groups);
      expect(restored.sort, ConversationSignatureSort.mostTotalMessages);
      expect(restored.mode, ConversationSignatureMode.browse);
    });

    test('maps retired recent and dormant filters to current defaults', () {
      final recent = ConversationSignaturePreferences.fromStorage(
        'recent|most_active_recently',
      );
      final dormantRevived = ConversationSignaturePreferences.fromStorage(
        'dormant_revived|recent',
      );

      expect(recent.filter, ConversationSignatureFilter.all);
      expect(recent.sort, ConversationSignatureSort.mostRecentlyUpdated);
      expect(dormantRevived.filter, ConversationSignatureFilter.all);
      expect(
        dormantRevived.sort,
        ConversationSignatureSort.mostRecentlyUpdated,
      );
    });

    test('does not let delayed restore overwrite local choices', () async {
      final firstContainer = buildContainer();
      addTearDown(firstContainer.dispose);

      await firstContainer
          .read(conversationSignaturePreferencesControllerProvider.notifier)
          .setFilter(ConversationSignatureFilter.groups);
      await firstContainer
          .read(conversationSignaturePreferencesControllerProvider.notifier)
          .setSort(ConversationSignatureSort.mostTotalMessages);

      final restoredContainer = buildContainer();
      addTearDown(restoredContainer.dispose);

      restoredContainer.read(
        conversationSignaturePreferencesControllerProvider,
      );
      await restoredContainer
          .read(conversationSignaturePreferencesControllerProvider.notifier)
          .setFilter(ConversationSignatureFilter.oneToOne);
      await restoredContainer
          .read(conversationSignaturePreferencesControllerProvider.notifier)
          .setSort(ConversationSignatureSort.dormant);
      await restoredContainer
          .read(conversationSignaturePreferencesControllerProvider.notifier)
          .setMode(ConversationSignatureMode.favourites);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      final preferences = restoredContainer.read(
        conversationSignaturePreferencesControllerProvider,
      );
      expect(preferences.filter, ConversationSignatureFilter.oneToOne);
      expect(preferences.sort, ConversationSignatureSort.dormant);
      expect(preferences.mode, ConversationSignatureMode.favourites);
    });
  });
}
