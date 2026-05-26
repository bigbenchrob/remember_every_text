import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/navigation/application/panel_widget_providers.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/navigation/feature_level_providers.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/features/chats/application/chat_read_model_source_provider.dart';
import 'package:remember_this_text/features/chats/presentation/view_model/chats_view_model_provider.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';

void main() {
  test('selectChat routes graph-backed chats to conversation spec', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(chatsViewModelProvider.notifier).selectChat(42);

    final activeSpec = _effectiveCenterSpec(container);
    expect(container.read(sidebarFlowProvider).selectedConversationId, 42);
    expect(
      activeSpec,
      const ViewSpec.messages(MessagesSpec.forConversation(conversationId: 42)),
    );
  });

  test('selectChat can carry graph search anchor context', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(chatsViewModelProvider.notifier)
        .selectChat(42, anchorMessageId: 99, searchQuery: 'settlement');

    final activeSpec = _effectiveCenterSpec(container);
    final flowState = container.read(sidebarFlowProvider);
    expect(flowState.selectedConversationId, 42);
    expect(flowState.selectedConversationAnchorMessageId, 99);
    expect(flowState.selectedConversationSearchQuery, 'settlement');
    expect(
      activeSpec,
      const ViewSpec.messages(
        MessagesSpec.forConversation(
          conversationId: 42,
          anchorMessageId: 99,
          searchQuery: 'settlement',
        ),
      ),
    );
  });

  test('selectChat preserves legacy chat routing when switched', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(chatReadModelSourceProvider.notifier)
        .setMode(ChatReadModelSourceMode.legacy);

    await container.read(chatsViewModelProvider.notifier).selectChat(42);

    final activeSpec = _activeCenterSpec(container);
    expect(
      activeSpec,
      const ViewSpec.messages(MessagesSpec.forChat(chatId: 42)),
    );
  });
}

ViewSpec? _effectiveCenterSpec(ProviderContainer container) {
  return container.read(effectiveCenterPanelSpecProvider(SidebarMode.messages));
}

ViewSpec? _activeCenterSpec(ProviderContainer container) {
  return container
      .read(panelsViewStateProvider(SidebarMode.messages))[WindowPanel.center]
      ?.activePage
      ?.spec;
}
