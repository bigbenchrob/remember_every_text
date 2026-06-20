import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/features/chats/application/actions/chat_selection_actions_provider.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';

void main() {
  group('ChatSelectionActions', () {
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

    test('selectChat dispatches conversation sidebar flow intent', () async {
      await container
          .read(chatSelectionActionsProvider.notifier)
          .selectChat(
            8796093022216,
            anchorMessageId: 8796093170832,
            searchQuery: 'flower',
          );

      final flowState = container.read(sidebarFlowProvider);
      expect(flowState.topMenuChoice, TopChatMenuChoice.conversations);
      expect(flowState.selectedConversationId, 8796093022216);
      expect(flowState.selectedConversationAnchorMessageId, 8796093170832);
      expect(flowState.selectedConversationSearchQuery, 'flower');
    });
  });
}
