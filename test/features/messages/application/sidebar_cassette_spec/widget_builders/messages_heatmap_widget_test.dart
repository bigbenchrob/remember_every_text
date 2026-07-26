import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/config/theme/spacing/app_spacing.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/feature_level_providers/conversation_graph_readiness_provider.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/navigation/application/panel_widget_providers.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_cassette_sectioning.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/features/conversations/domain/spec_classes/conversations_view_spec.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/current_search_investigation_provider.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/global_messages_heatmap_provider.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/widget_builders/messages_heatmap_widget.dart';
import 'package:remember_this_text/features/messages/domain/calendar_heatmap_timeline_data.dart';
import 'package:remember_this_text/features/messages/domain/search_investigation_id.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/calendar_heatmap_timeline_widget.dart';

void main() {
  group('MessageHeatmapContent', () {
    testWidgets(
      'uses the shared visualization rhythm for summary and legend spacing',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: MessageHeatmapContent(
                data: _sampleTimelineData(),
                selectedMonthKey: null,
                onMonthTap: (_, __, ___) {},
              ),
            ),
          ),
        );

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is SizedBox &&
                widget.width == null &&
                widget.height == sidebarCassetteVisualizationContentSpacing,
          ),
          findsNWidgets(2),
        );
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is SizedBox &&
                widget.width == null &&
                widget.height == AppSpacing.cassetteContentGap,
          ),
          findsNothing,
        );
      },
    );
  });

  testWidgets('global month tap replaces active Conversation context', (
    tester,
  ) async {
    final overlayDb = OverlayDatabase(NativeDatabase.memory());
    addTearDown(overlayDb.close);
    final container = ProviderContainer(
      overrides: [
        overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
        conversationGraphPopulatedProvider.overrideWith(
          _AlwaysPopulatedGraph.new,
        ),
        globalMessagesHeatmapProvider.overrideWith(
          (ref) async => _sampleTimelineData(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final flowSubscription = container.listen(sidebarFlowProvider, (_, __) {});
    final panelSubscription = container.listen(
      panelsViewStateProvider(SidebarMode.messages),
      (_, __) {},
    );
    addTearDown(flowSubscription.close);
    addTearDown(panelSubscription.close);

    container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
    final originatingInvestigationId = container.read(
      currentSearchInvestigationProvider,
    );
    container
        .read(panelsViewStateProvider(SidebarMode.messages).notifier)
        .show(
          panel: WindowPanel.right,
          spec: const ViewSpec.conversations(
            ConversationsSpec.conversationExcerpt(
              conversationId: 42,
              anchorMessageId: 9001,
              originatingInvestigationId: SearchInvestigationId(0),
            ),
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: MessagesHeatmapWidget(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(shouldShowEndSidebarProvider(SidebarMode.messages)),
      isTrue,
    );

    final januaryCell = find
        .descendant(
          of: find.byType(CalendarHeatmapTimelineWidget),
          matching: find.byType(GestureDetector),
        )
        .first;
    await tester.tap(januaryCell);
    await tester.pump();

    final monthAnchor = DateTime(2024, 1, 1);
    expect(
      container.read(effectiveCenterPanelSpecProvider(SidebarMode.messages)),
      ViewSpec.messages(MessagesSpec.globalTimeline(scrollToDate: monthAnchor)),
    );
    expect(
      container.read(effectiveRightPanelSpecProvider(SidebarMode.messages)),
      isNull,
    );
    expect(
      container
          .read(
            panelsViewStateProvider(SidebarMode.messages),
          )[WindowPanel.right]
          ?.activePage
          ?.spec,
      ViewSpec.conversations(
        ConversationsSpec.conversationExcerpt(
          conversationId: 42,
          anchorMessageId: 9001,
          originatingInvestigationId: originatingInvestigationId,
        ),
      ),
    );
    expect(
      container.read(currentSearchInvestigationProvider),
      isNot(originatingInvestigationId),
    );
    expect(
      container.read(shouldShowEndSidebarProvider(SidebarMode.messages)),
      isFalse,
    );
  });
}

class _AlwaysPopulatedGraph extends ConversationGraphPopulated {
  @override
  bool build() => true;
}

CalendarHeatmapTimelineData _sampleTimelineData() {
  return CalendarHeatmapTimelineData(
    yearRows: [
      YearRow(
        year: 2024,
        months: List<MonthData>.generate(12, (index) {
          final month = index + 1;
          if (month == 1) {
            return MonthData(
              year: 2024,
              month: month,
              messageCount: 15,
              intensity: MonthIntensity.mediumGray,
              chatId: 7,
            );
          }

          return MonthData(
            year: 2024,
            month: month,
            messageCount: 0,
            intensity: MonthIntensity.empty,
            chatId: 7,
          );
        }),
        hasMessages: true,
      ),
    ],
    firstMessageDate: DateTime(2024, 1, 1),
    lastMessageDate: DateTime(2024, 12, 1),
    totalMessages: 15,
    maxMonthCount: 15,
  );
}
