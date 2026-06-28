import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/contact_conversation_navigation_actions_provider.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/conversation_navigation_actions_provider.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';

void main() {
  late OverlayDatabase overlayDb;
  late ProviderContainer container;

  setUp(() {
    overlayDb = OverlayDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await overlayDb.close();
  });

  test(
    'selectConversation dispatches conversation sidebar flow intent',
    () async {
      await container
          .read(conversationNavigationActionsProvider.notifier)
          .selectConversation(conversationId: 8796093022216);

      final flowState = container.read(sidebarFlowProvider);
      expect(flowState.topMenuChoice, TopChatMenuChoice.conversations);
      expect(flowState.selectedConversationId, 8796093022216);
      expect(flowState.chosenContactId, isNull);
    },
  );

  test(
    'selectContactConversation dispatches contact conversation flow intent',
    () async {
      await container
          .read(contactConversationNavigationActionsProvider.notifier)
          .selectContactConversation(
            contactId: 24,
            conversationId: 8796093022216,
          );

      final flowState = container.read(sidebarFlowProvider);
      expect(flowState.topMenuChoice, TopChatMenuChoice.contacts);
      expect(flowState.chosenContactId, 24);
      expect(flowState.selectedConversationId, 8796093022216);
      expect(
        flowState.contactProjection,
        SidebarFlowContactProjection.conversations,
      );
    },
  );
}
