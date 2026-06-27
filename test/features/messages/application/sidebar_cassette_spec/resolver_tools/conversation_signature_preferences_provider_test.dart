import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers/persistent_database_providers.dart';
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

    test('defaults to recent filter and recent sort', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final preferences = container.read(
        conversationSignaturePreferencesControllerProvider,
      );

      expect(preferences.filter, ConversationSignatureFilter.recent);
      expect(preferences.sort, ConversationSignatureSort.recent);
    });

    test('persists filter and sort choices in the overlay database', () async {
      final firstContainer = buildContainer();
      addTearDown(firstContainer.dispose);

      await firstContainer
          .read(conversationSignaturePreferencesControllerProvider.notifier)
          .setFilter(ConversationSignatureFilter.highActivity);
      await firstContainer
          .read(conversationSignaturePreferencesControllerProvider.notifier)
          .setSort(ConversationSignatureSort.largest);

      final restoredContainer = buildContainer();
      addTearDown(restoredContainer.dispose);

      final initialRestored = restoredContainer.read(
        conversationSignaturePreferencesControllerProvider,
      );
      expect(initialRestored.filter, ConversationSignatureFilter.recent);
      expect(initialRestored.sort, ConversationSignatureSort.recent);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      final restored = restoredContainer.read(
        conversationSignaturePreferencesControllerProvider,
      );

      expect(restored.filter, ConversationSignatureFilter.highActivity);
      expect(restored.sort, ConversationSignatureSort.largest);
    });

    test('falls back to safe defaults for unknown stored values', () {
      final restored = ConversationSignaturePreferences.fromStorage(
        'unknown|also_unknown',
      );

      expect(restored.filter, ConversationSignatureFilter.recent);
      expect(restored.sort, ConversationSignatureSort.recent);
    });

    test('does not let delayed restore overwrite local choices', () async {
      final firstContainer = buildContainer();
      addTearDown(firstContainer.dispose);

      await firstContainer
          .read(conversationSignaturePreferencesControllerProvider.notifier)
          .setFilter(ConversationSignatureFilter.groups);
      await firstContainer
          .read(conversationSignaturePreferencesControllerProvider.notifier)
          .setSort(ConversationSignatureSort.largest);

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
          .setSort(ConversationSignatureSort.mostActiveRecently);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      final preferences = restoredContainer.read(
        conversationSignaturePreferencesControllerProvider,
      );
      expect(preferences.filter, ConversationSignatureFilter.oneToOne);
      expect(preferences.sort, ConversationSignatureSort.mostActiveRecently);
    });
  });
}
