import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/entities/message_history_coverage_report.dart';
import 'package:remember_this_text/features/settings/presentation/view/message_history_coverage_report_panel.dart';
import 'package:remember_this_text/features/settings/presentation/view_model/message_history_coverage_panel_model_provider.dart';

void main() {
  group('MessageHistoryCoverageReportPanel', () {
    testWidgets(
      'renders the rich complete-state report with a zero-missing badge',
      (tester) async {
        final model = buildMessageCoveragePanelViewModel(
          MessageHistoryCoverageReport(
            status: MessageHistoryCoverageStatus.complete,
            chatDbTotalCount: 120,
            graphConversationLinkedCount: 115,
            graphRecoveredOrphanCount: 5,
            earliestMessageDate: DateTime.utc(2020, 01, 01),
            latestMessageDate: DateTime.utc(2026, 04, 26),
            generatedAt: DateTime.utc(2026, 04, 26, 18),
          ),
        );

        final container = ProviderContainer(
          overrides: [
            messageHistoryCoveragePanelModelProvider.overrideWith(
              (ref) async => model,
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const CupertinoApp(
              home: MessageHistoryCoverageReportPanel(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Fully Accounted For'), findsOneWidget);
        expect(
          find.text('All 120 messages on this Mac are accounted for.'),
          findsOneWidget,
        );
        expect(find.text('Message Accounting'), findsOneWidget);
        expect(
          find.text('All messages on this Mac are accounted for as:'),
          findsOneWidget,
        );
        expect(find.text('Reconciliation'), findsOneWidget);
        expect(find.text('Timeline Coverage'), findsOneWidget);
        expect(find.text("This Mac's Messages history spans:"), findsOneWidget);
        expect(
          find.text(
            'If you expected to see older messages, they may exist on another device or in iCloud, but are not present on this Mac.',
          ),
          findsOneWidget,
        );
        expect(find.text('Recovered Messages'), findsOneWidget);
        expect(find.text('Notes & Next Steps'), findsNothing);
        expect(find.text('Export Coverage Report'), findsNothing);
        expect(
          find.byKey(MessageHistoryCoverageReportPanel.accountingBarKey),
          findsOneWidget,
        );
        expect(
          find.byKey(
            MessageHistoryCoverageReportPanel.segmentKey(
              CoverageSegmentId.visible,
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(
            MessageHistoryCoverageReportPanel.segmentKey(
              CoverageSegmentId.recovered,
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(
            MessageHistoryCoverageReportPanel.segmentKey(
              CoverageSegmentId.missing,
            ),
          ),
          findsNothing,
        );
        expect(
          find.byKey(MessageHistoryCoverageReportPanel.zeroMissingBadgeKey),
          findsOneWidget,
        );
      },
    );

    testWidgets('renders a missing segment for incomplete import', (
      tester,
    ) async {
      final model = buildMessageCoveragePanelViewModel(
        MessageHistoryCoverageReport(
          status: MessageHistoryCoverageStatus.incompleteImport,
          chatDbTotalCount: 100,
          graphConversationLinkedCount: 80,
          graphRecoveredOrphanCount: 10,
          earliestMessageDate: DateTime.utc(2020, 01, 01),
          latestMessageDate: DateTime.utc(2026, 04, 26),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          messageHistoryCoveragePanelModelProvider.overrideWith(
            (ref) async => model,
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const CupertinoApp(home: MessageHistoryCoverageReportPanel()),
        ),
      );
      await tester.pump();

      expect(
        find.text('Some messages could not be accounted for.'),
        findsOneWidget,
      );
      expect(find.text('Notes'), findsOneWidget);
      expect(
        find.byKey(
          MessageHistoryCoverageReportPanel.segmentKey(
            CoverageSegmentId.missing,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(MessageHistoryCoverageReportPanel.zeroMissingBadgeKey),
        findsNothing,
      );
    });
  });
}
