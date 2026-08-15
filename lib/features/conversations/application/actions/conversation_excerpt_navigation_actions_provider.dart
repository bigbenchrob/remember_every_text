import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/navigation/application/panel_actions_provider.dart';
import '../../../../essentials/navigation/application/panels_view_state_provider.dart';
import '../../../../essentials/navigation/domain/entities/investigation_identity.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../domain/spec_classes/conversations_view_spec.dart';

part 'conversation_excerpt_navigation_actions_provider.g.dart';

@riverpod
class ConversationExcerptNavigationActions
    extends _$ConversationExcerptNavigationActions {
  @override
  void build() {
    // Stateless action boundary.
  }

  bool isActive({
    required int conversationId,
    required int anchorMessageId,
    required InvestigationIdentity originatingInvestigationId,
  }) {
    final targetSpec = _spec(
      conversationId: conversationId,
      anchorMessageId: anchorMessageId,
      originatingInvestigationId: originatingInvestigationId,
    );
    final rightPanelStack = ref.read(
      panelsViewStateProvider(SidebarMode.messages),
    )[WindowPanel.right];
    return rightPanelStack?.activePage?.spec == targetSpec;
  }

  void open({
    required int conversationId,
    required int anchorMessageId,
    required InvestigationIdentity originatingInvestigationId,
  }) {
    final targetSpec = _spec(
      conversationId: conversationId,
      anchorMessageId: anchorMessageId,
      originatingInvestigationId: originatingInvestigationId,
    );
    ref
        .read(panelActionsProvider.notifier)
        .showRightPanel(mode: SidebarMode.messages, spec: targetSpec);
  }

  ViewSpec _spec({
    required int conversationId,
    required int anchorMessageId,
    required InvestigationIdentity originatingInvestigationId,
  }) {
    return ViewSpec.conversations(
      ConversationsSpec.conversationExcerpt(
        conversationId: conversationId,
        anchorMessageId: anchorMessageId,
        originatingInvestigationId: originatingInvestigationId,
      ),
    );
  }
}
