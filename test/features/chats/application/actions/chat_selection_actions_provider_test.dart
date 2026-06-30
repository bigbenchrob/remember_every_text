import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_preference_store.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_preference_store_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/features/chats/application/actions/chat_selection_actions_provider.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';

void main() {
  group('ChatSelectionActions', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          sidebarFlowPreferenceStoreProvider.overrideWith((ref) async {
            return _InMemorySidebarFlowPreferenceStore();
          }),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
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

class _InMemorySidebarFlowPreferenceStore
    implements SidebarFlowPreferenceStore {
  String? _contactContextPreference;
  String? _navigationPreference;

  @override
  Future<String?> readContactContextPreference() async {
    return _contactContextPreference;
  }

  @override
  Future<String?> readNavigationPreference() async {
    return _navigationPreference;
  }

  @override
  Future<void> writeContactContextPreference(String value) async {
    _contactContextPreference = value;
  }

  @override
  Future<void> writeNavigationPreference(String value) async {
    _navigationPreference = value;
  }
}
