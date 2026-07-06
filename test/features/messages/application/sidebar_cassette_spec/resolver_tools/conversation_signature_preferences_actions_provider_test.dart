import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/conversation_signature_display_provider.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/conversation_signature_preferences_actions_provider.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/conversation_signature_preferences_provider.dart';

void main() {
  test(
    'actions delegate filter, sort, and mode mutation to controller',
    () async {
      final overlayDb = OverlayDatabase(NativeDatabase.memory());
      addTearDown(overlayDb.close);
      final container = ProviderContainer(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
        ],
      );
      addTearDown(container.dispose);

      final initial = container.read(
        conversationSignaturePreferencesControllerProvider,
      );
      expect(initial.filter, ConversationSignatureFilter.all);
      expect(initial.sort, ConversationSignatureSort.mostRecentlyUpdated);
      expect(initial.mode, ConversationSignatureMode.browse);

      await container
          .read(conversationSignaturePreferencesActionsProvider.notifier)
          .setFilter(ConversationSignatureFilter.highActivity);
      await container
          .read(conversationSignaturePreferencesActionsProvider.notifier)
          .setSort(ConversationSignatureSort.mostTotalMessages);
      await container
          .read(conversationSignaturePreferencesActionsProvider.notifier)
          .setMode(ConversationSignatureMode.favourites);

      final updated = container.read(
        conversationSignaturePreferencesControllerProvider,
      );
      expect(updated.filter, ConversationSignatureFilter.highActivity);
      expect(updated.sort, ConversationSignatureSort.mostTotalMessages);
      expect(updated.mode, ConversationSignatureMode.favourites);
    },
  );
}
