import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/navigation/application/panel_actions_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/features/conversations/domain/spec_classes/conversations_view_spec.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';

void main() {
  test('showRightPanel opens right panel stack', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const spec = ViewSpec.conversations(
      ConversationsSpec.conversationExcerpt(
        conversationId: 200,
        anchorMessageId: 100,
      ),
    );

    container
        .read(panelActionsProvider.notifier)
        .showRightPanel(mode: SidebarMode.messages, spec: spec);

    expect(
      container
          .read(
            panelsViewStateProvider(SidebarMode.messages),
          )[WindowPanel.right]
          ?.activePage
          ?.spec,
      spec,
    );
  });

  test('activateTab and closeTab delegate to panel stack state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final panels = container.read(
      panelsViewStateProvider(SidebarMode.messages).notifier,
    );

    panels.show(
      panel: WindowPanel.right,
      spec: const ViewSpec.messages(MessagesSpec.globalTimeline()),
    );
    panels.push(
      panel: WindowPanel.right,
      spec: const ViewSpec.messages(MessagesSpec.forContact(contactId: 42)),
    );

    expect(
      container
          .read(
            panelsViewStateProvider(SidebarMode.messages),
          )[WindowPanel.right]
          ?.activeIndex,
      1,
    );

    container
        .read(panelActionsProvider.notifier)
        .activateTab(
          mode: SidebarMode.messages,
          panel: WindowPanel.right,
          index: 0,
        );

    expect(
      container
          .read(
            panelsViewStateProvider(SidebarMode.messages),
          )[WindowPanel.right]
          ?.activeIndex,
      0,
    );

    container
        .read(panelActionsProvider.notifier)
        .closeTab(
          mode: SidebarMode.messages,
          panel: WindowPanel.right,
          index: 1,
        );

    final rightStack = container.read(
      panelsViewStateProvider(SidebarMode.messages),
    )[WindowPanel.right];
    expect(rightStack?.pages, hasLength(1));
    expect(
      rightStack?.activePage?.spec,
      const ViewSpec.messages(MessagesSpec.globalTimeline()),
    );
  });

  test('cancelParkedCenterOperation clears center stack', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(panelsViewStateProvider(SidebarMode.messages).notifier)
        .show(
          panel: WindowPanel.center,
          spec: const ViewSpec.messages(MessagesSpec.globalTimeline()),
        );

    expect(
      container
          .read(
            panelsViewStateProvider(SidebarMode.messages),
          )[WindowPanel.center]
          ?.isEmpty,
      isFalse,
    );

    container
        .read(panelActionsProvider.notifier)
        .cancelParkedCenterOperation(mode: SidebarMode.messages);

    expect(
      container
          .read(
            panelsViewStateProvider(SidebarMode.messages),
          )[WindowPanel.center]
          ?.isEmpty,
      isTrue,
    );
  });
}
