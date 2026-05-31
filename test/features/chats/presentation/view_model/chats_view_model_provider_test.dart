import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/navigation/application/panel_widget_providers.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
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
}

ViewSpec? _effectiveCenterSpec(ProviderContainer container) {
  return container.read(effectiveCenterPanelSpecProvider(SidebarMode.messages));
}
