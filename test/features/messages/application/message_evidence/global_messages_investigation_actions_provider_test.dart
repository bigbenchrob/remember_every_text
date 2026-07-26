import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/conversation_graph_readiness_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/panel_widget_providers.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/features/conversations/application/actions/conversation_excerpt_navigation_actions_provider.dart';
import 'package:remember_this_text/features/conversations/domain/spec_classes/conversations_view_spec.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/current_search_investigation_provider.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/global_messages_investigation_actions_provider.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/global_messages_search_session_provider.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_search_mode.dart';
import 'package:remember_this_text/features/messages/domain/search_investigation_id.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        conversationGraphPopulatedProvider.overrideWith(
          _AlwaysPopulatedGraph.new,
        ),
      ],
    );
    container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
  });

  tearDown(() {
    container.dispose();
  });

  test(
    'browseMonth makes the stored excerpt ineffective without deleting it',
    () {
      final session = container.read(
        globalMessagesSearchSessionProvider(monthAnchor: null).notifier,
      );
      session.setQuery('kelowna');
      final originatingId = container.read(currentSearchInvestigationProvider);
      _openExcerpt(container, anchorMessageId: 9001);

      expect(_effectiveRightSpec(container), _excerptSpec(originatingId, 9001));

      final monthAnchor = DateTime(2024, 4, 1);
      container
          .read(globalMessagesInvestigationActionsProvider.notifier)
          .browseMonth(monthAnchor);

      expect(container.read(sidebarFlowProvider).scrollToDate, monthAnchor);
      expect(
        container.read(effectiveCenterPanelSpecProvider(SidebarMode.messages)),
        ViewSpec.messages(
          MessagesSpec.globalTimeline(scrollToDate: monthAnchor),
        ),
      );
      expect(
        container.read(currentSearchInvestigationProvider),
        isNot(originatingId),
      );
      expect(_storedRightSpec(container), _excerptSpec(originatingId, 9001));
      expect(_effectiveRightSpec(container), isNull);
      expect(
        container.read(shouldShowEndSidebarProvider(SidebarMode.messages)),
        isFalse,
      );
      expect(
        container
            .read(globalMessagesSearchSessionProvider(monthAnchor: monthAnchor))
            .query,
        isEmpty,
      );
    },
  );

  test(
    'query mutations advance opaque identity and equal text does not revive',
    () {
      final session = container.read(
        globalMessagesSearchSessionProvider(monthAnchor: null).notifier,
      );

      session.setQuery('family');
      final investigationOne = container.read(
        currentSearchInvestigationProvider,
      );
      _openExcerpt(container, anchorMessageId: 9001);

      session.setQuery('estate');
      final investigationTwo = container.read(
        currentSearchInvestigationProvider,
      );
      session.setQuery('family');
      final investigationThree = container.read(
        currentSearchInvestigationProvider,
      );

      expect(investigationTwo, isNot(investigationOne));
      expect(investigationThree, isNot(investigationOne));
      expect(investigationThree, isNot(investigationTwo));
      expect(_storedRightSpec(container), _excerptSpec(investigationOne, 9001));
      expect(_effectiveRightSpec(container), isNull);
    },
  );

  test('changing AND OR mode replaces the primary investigation', () {
    final session = container.read(
      globalMessagesSearchSessionProvider(monthAnchor: null).notifier,
    );
    session.setQuery('family estate');
    final originatingId = container.read(currentSearchInvestigationProvider);
    _openExcerpt(container, anchorMessageId: 9001);

    session.setMode(MessageEvidenceSearchMode.anyTerm);

    expect(
      container.read(currentSearchInvestigationProvider),
      isNot(originatingId),
    );
    expect(_storedRightSpec(container), _excerptSpec(originatingId, 9001));
    expect(_effectiveRightSpec(container), isNull);
  });

  test('navigation away and back restores an unchanged investigation', () {
    final session = container.read(
      globalMessagesSearchSessionProvider(monthAnchor: null).notifier,
    );
    session.setQuery('kelowna');
    final originatingId = container.read(currentSearchInvestigationProvider);
    _openExcerpt(container, anchorMessageId: 9001);

    container
        .read(sidebarFlowProvider.notifier)
        .showContactTimelineAt(contactId: 42);

    expect(_storedRightSpec(container), _excerptSpec(originatingId, 9001));
    expect(_effectiveRightSpec(container), isNull);

    container.read(sidebarFlowProvider.notifier).showGlobalTimeline();

    expect(container.read(currentSearchInvestigationProvider), originatingId);
    expect(_effectiveRightSpec(container), _excerptSpec(originatingId, 9001));
    expect(
      container
          .read(globalMessagesSearchSessionProvider(monthAnchor: null))
          .query,
      'kelowna',
    );
  });

  test(
    'opening another result replaces the excerpt without advancing identity',
    () {
      final session = container.read(
        globalMessagesSearchSessionProvider(monthAnchor: null).notifier,
      );
      session.setQuery('kelowna');
      final originatingId = container.read(currentSearchInvestigationProvider);

      _openExcerpt(container, anchorMessageId: 9001);
      _openExcerpt(container, anchorMessageId: 9002);

      expect(container.read(currentSearchInvestigationProvider), originatingId);
      expect(_storedRightSpec(container), _excerptSpec(originatingId, 9002));
      expect(_effectiveRightSpec(container), _excerptSpec(originatingId, 9002));
    },
  );
}

void _openExcerpt(ProviderContainer container, {required int anchorMessageId}) {
  container
      .read(conversationExcerptNavigationActionsProvider.notifier)
      .open(
        conversationId: 42,
        anchorMessageId: anchorMessageId,
        originatingInvestigationId: container.read(
          currentSearchInvestigationProvider,
        ),
      );
}

ViewSpec _excerptSpec(
  SearchInvestigationId investigationId,
  int anchorMessageId,
) {
  return ViewSpec.conversations(
    ConversationsSpec.conversationExcerpt(
      conversationId: 42,
      anchorMessageId: anchorMessageId,
      originatingInvestigationId: investigationId,
    ),
  );
}

ViewSpec? _storedRightSpec(ProviderContainer container) {
  return container
      .read(panelsViewStateProvider(SidebarMode.messages))[WindowPanel.right]
      ?.activePage
      ?.spec;
}

ViewSpec? _effectiveRightSpec(ProviderContainer container) {
  return container.read(effectiveRightPanelSpecProvider(SidebarMode.messages));
}

class _AlwaysPopulatedGraph extends ConversationGraphPopulated {
  @override
  bool build() => true;
}
