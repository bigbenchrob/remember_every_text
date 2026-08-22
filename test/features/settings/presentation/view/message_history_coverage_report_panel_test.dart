import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/config/theme/widgets/layout/page_track_layout_matrix.dart';
import 'package:remember_this_text/config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import 'package:remember_this_text/essentials/navigation/presentation/layout/message_history_coverage_page_track_plan.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/entities/message_history_coverage_report.dart';
import 'package:remember_this_text/features/settings/presentation/layout/message_history_coverage_track_occupants.dart';
import 'package:remember_this_text/features/settings/presentation/view/message_history_coverage_report_panel.dart';
import 'package:remember_this_text/features/settings/presentation/view_model/message_history_coverage_panel_model_provider.dart';

void main() {
  group('MessageHistoryCoverageReportPanel', () {
    testWidgets('keeps recovered messages inside a calm complete presentation', (
      tester,
    ) async {
      await _pumpModel(
        tester,
        buildMessageCoveragePanelViewModel(
          _report(conversation: 115, recovered: 5, unaccounted: 0),
        ),
      );

      expect(
        find.text('All messages on this Mac are accounted for'),
        findsOneWidget,
      );
      expect(
        find.text(
          'MessageLens has accounted for all 120 messages. '
          '115 appear in conversations and 5 are available in Recovered Messages.',
        ),
        findsOneWidget,
      );
      expect(find.text('Messages on this Mac'), findsOneWidget);
      expect(find.text('In conversations'), findsOneWidget);
      expect(find.text('Recovered Messages'), findsOneWidget);
      expect(find.text('Unaccounted'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('View Recovered Messages'), findsNothing);
      expect(find.text('Review unaccounted messages'), findsNothing);
      expect(find.text('Complete'), findsNothing);
      expect(
        find.bySemanticsLabel('All messages on this Mac are accounted for'),
        findsOneWidget,
      );
    });

    testWidgets('makes the exact incomplete exception primary', (tester) async {
      await _pumpModel(
        tester,
        buildMessageCoveragePanelViewModel(
          _report(conversation: 100, recovered: 10, unaccounted: 10),
        ),
      );

      expect(
        find.text('10 messages could not be accounted for'),
        findsOneWidget,
      );
      expect(
        find.text('110 of 120 messages on this Mac are accounted for.'),
        findsOneWidget,
      );
      expect(
        find.text('All messages on this Mac are accounted for'),
        findsNothing,
      );
      expect(
        find.bySemanticsLabel('10 messages could not be accounted for'),
        findsOneWidget,
      );
      expect(find.text('Review needed'), findsNothing);
    });

    testWidgets('presents maintenance as temporarily unavailable', (
      tester,
    ) async {
      await _pumpModel(
        tester,
        buildMessageCoveragePanelViewModel(
          MessageHistoryCoverageReport.temporarilyUnavailable(
            generatedAt: DateTime.utc(2026, 8, 22),
            detail: 'Maintenance is active.',
          ),
        ),
      );

      expect(
        find.text('Message history coverage is temporarily unavailable'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          'Message history coverage is temporarily unavailable',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(MessageHistoryCoverageReportPanel.retryButtonKey),
        findsNothing,
      );
      expect(find.text('Messages on this Mac'), findsNothing);
    });

    testWidgets('presents failure with retry and diagnostic details', (
      tester,
    ) async {
      await _pumpModel(
        tester,
        buildMessageCoveragePanelViewModel(
          MessageHistoryCoverageReport.failed(
            generatedAt: DateTime.utc(2026, 8, 22),
            detail: 'Evidence read failed.',
          ),
        ),
      );

      expect(
        find.text('Message history coverage could not be checked'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Message history coverage could not be checked'),
        findsOneWidget,
      );
      expect(
        find.byKey(MessageHistoryCoverageReportPanel.retryButtonKey),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(MessageHistoryCoverageReportPanel.detailsToggleKey),
      );
      await tester.pump();
      expect(find.text('Evidence read failed.'), findsOneWidget);
    });

    testWidgets('Details adds evidence without repeating primary count rows', (
      tester,
    ) async {
      await _pumpModel(
        tester,
        buildMessageCoveragePanelViewModel(
          _report(conversation: 115, recovered: 5, unaccounted: 0),
        ),
      );

      await tester.tap(
        find.byKey(MessageHistoryCoverageReportPanel.detailsToggleKey),
      );
      await tester.pump();

      expect(find.text('Total accounted for: 120'), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey<String>(
            'message-history-coverage-detail-Recovered Messages: 5',
          ),
        ),
        findsNothing,
      );
      expect(
        find.textContaining('Imported Historical Archives are outside'),
        findsOneWidget,
      );
    });

    testWidgets(
      'Track title and report body share canonical inset at narrow and wide widths',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1200, 800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        for (final width in <double>[520, 1000]) {
          await _pumpTrackedAlignmentFixture(tester, width: width);

          final titleLeft = tester
              .getTopLeft(find.byKey(messageHistoryCoverageTitleKey))
              .dx;
          final bodyLeft = tester
              .getTopLeft(
                find.byKey(MessageHistoryCoverageReportPanel.reportBodyKey),
              )
              .dx;
          expect(titleLeft, bodyLeft);
          expect(
            titleLeft,
            MessageHistoryCoverageCenterColumnGeometry.horizontalInset,
          );
          expect(
            find.bySemanticsLabel('Message History Coverage'),
            findsOneWidget,
          );
        }
      },
    );

    testWidgets('loading and result share one stable report skeleton', (
      tester,
    ) async {
      final completer = Completer<MessageCoveragePanelViewModel>();
      final container = ProviderContainer(
        overrides: [
          messageHistoryCoveragePanelModelProvider.overrideWith(
            (ref) => completer.future,
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
        find.byKey(MessageHistoryCoverageReportPanel.loadingBodyKey),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('message-history-coverage-track-skeleton')),
        findsOneWidget,
      );
      expect(find.text('Message History Coverage'), findsOneWidget);

      completer.complete(
        buildMessageCoveragePanelViewModel(
          _report(conversation: 120, recovered: 0, unaccounted: 0),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(MessageHistoryCoverageReportPanel.loadingBodyKey),
        findsNothing,
      );
      expect(
        find.text('All messages on this Mac are accounted for'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('message-history-coverage-track-skeleton')),
        findsOneWidget,
      );
    });
  });
}

Future<void> _pumpTrackedAlignmentFixture(
  WidgetTester tester, {
  required double width,
}) async {
  await tester.pumpWidget(
    CupertinoApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          height: 700,
          child: Builder(
            builder: (context) {
              final matrix = buildMessageHistoryCoveragePageTrackLayoutMatrix(
                sidebarSettingsMenu: const FixedHeightTrackOccupant(height: 40),
                centerTitle: messageHistoryCoverageTitleTrackOccupant(
                  style: const TextStyle(fontSize: 20),
                ),
              );
              final resolvedMatrix = ResolvedTrackLayoutMatrix.resolve(
                matrix: matrix,
                constraints: PresentationConstraints.fromBuildContext(
                  context,
                  availableWidth: width,
                ),
              );
              return ResolvedTrackLayoutMatrixScope(
                matrix: resolvedMatrix,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TrackCellView(
                      cellId: CellId(
                        trackId: TrackId.trackA,
                        columnId: TrackColumnId.column2,
                      ),
                    ),
                    MessageHistoryCoverageCenterColumn(
                      child: SizedBox(
                        key: MessageHistoryCoverageReportPanel.reportBodyKey,
                        height: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _pumpModel(
  WidgetTester tester,
  MessageCoveragePanelViewModel model,
) async {
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
}

MessageHistoryCoverageReport _report({
  required int conversation,
  required int recovered,
  required int unaccounted,
}) {
  return MessageHistoryCoverageReport.reconciled(
    totalCurrentMessages: conversation + recovered + unaccounted,
    accountedInConversations: conversation,
    recoveredUnlinked: recovered,
    unaccounted: unaccounted,
    earliestMessageDate: DateTime.utc(2020, 1, 1),
    latestMessageDate: DateTime.utc(2026, 4, 26),
    generatedAt: DateTime.utc(2026, 4, 26, 18),
  );
}
