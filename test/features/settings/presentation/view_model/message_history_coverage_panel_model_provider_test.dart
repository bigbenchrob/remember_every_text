import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/navigation/presentation/view/center_panel_report_layout.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/entities/message_history_coverage_report.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/resolvers/message_history_coverage_settings_resolver.dart';
import 'package:remember_this_text/features/settings/presentation/view_model/message_history_coverage_panel_model_provider.dart';

void main() {
  group('buildMessageCoveragePanelViewModel', () {
    test('produces a reassuring complete-state headline', () {
      final model = buildMessageCoveragePanelViewModel(
        MessageHistoryCoverageReport(
          status: MessageHistoryCoverageStatus.complete,
          chatDbTotalCount: 120,
          workingDbVisibleCount: 115,
          workingDbRecoveredCount: 5,
          earliestMessageDate: DateTime.utc(2020, 01, 01),
          latestMessageDate: DateTime.utc(2026, 04, 26),
          generatedAt: DateTime.utc(2026, 04, 26, 18),
        ),
      );

      expect(model.statusLabel, 'Fully Accounted For');
      expect(
        model.headline,
        'Every message on this Mac has been accounted for.',
      );
      expect(
        model.summaryText,
        'All 120 messages on this Mac are accounted for.',
      );
      expect(model.reconciliationResultLabel, 'Result: fully reconciled');
      expect(model.timelineCoverageLabel, "This Mac's Messages history spans:");
      expect(
        model.timelineCoverageDetail,
        'If you expected to see older messages, they may exist on another device or in iCloud, but are not present on this Mac.',
      );
      expect(model.notes, isEmpty);
      expect(model.segments, hasLength(2));
    });

    test('normalizes overlap and adds an overlap note', () {
      final model = buildMessageCoveragePanelViewModel(
        MessageHistoryCoverageReport(
          status: MessageHistoryCoverageStatus.complete,
          chatDbTotalCount: 100,
          workingDbVisibleCount: 90,
          workingDbRecoveredCount: 12,
          earliestMessageDate: DateTime.utc(2014, 01, 01),
          latestMessageDate: DateTime.utc(2026, 04, 26),
        ),
      );

      expect(
        model.headline,
        'Every message on this Mac has been accounted for.',
      );
      expect(
        model.notes,
        contains(
          'MessageLens detected a small overlap while reconciling visible and recovered messages.',
        ),
      );
      expect(
        model.reconciliationResultLabel,
        contains('Result: fully reconciled\n\n'),
      );
      expect(
        model.reconciliationResultLabel,
        contains(
          'A small overlap was detected while reconciling visible and recovered messages. This does not indicate missing data.',
        ),
      );
      expect(model.segments, hasLength(2));
      expect(model.segments[0].fraction, closeTo(0.9, 0.0001));
      expect(model.segments[1].fraction, closeTo(0.1, 0.0001));
      expect(
        model.segments.fold<double>(
          0,
          (sum, segment) => sum + segment.fraction,
        ),
        lessThanOrEqualTo(1.0),
      );
    });

    test('makes missing messages visible for incomplete import', () {
      final model = buildMessageCoveragePanelViewModel(
        MessageHistoryCoverageReport(
          status: MessageHistoryCoverageStatus.incompleteImport,
          chatDbTotalCount: 100,
          workingDbVisibleCount: 80,
          workingDbRecoveredCount: 10,
          earliestMessageDate: DateTime.utc(2014, 01, 01),
          latestMessageDate: DateTime.utc(2026, 04, 26),
        ),
      );

      expect(model.statusLabel, 'Needs Attention');
      expect(model.headline, 'Some messages could not be accounted for.');
      expect(model.missingCount, 10);
      expect(model.missingCountLabel, '10');
      expect(
        model.segments.map((segment) => segment.id),
        contains(CoverageSegmentId.missing),
      );
      expect(
        model.notes,
        contains(
          'Some messages in chat.db were not imported into MessageLens.',
        ),
      );
    });

    test('emphasizes local source history limits', () {
      final model = buildMessageCoveragePanelViewModel(
        MessageHistoryCoverageReport(
          status: MessageHistoryCoverageStatus.incompleteSourceHistory,
          chatDbTotalCount: 100,
          workingDbVisibleCount: 95,
          workingDbRecoveredCount: 5,
          earliestMessageDate: DateTime.utc(2024, 01, 01),
          latestMessageDate: DateTime.utc(2026, 04, 26),
        ),
      );

      expect(model.statusLabel, 'Limited History');
      expect(model.headline, contains("This Mac's Messages history begins on"));
      expect(
        model.summaryText,
        contains('older messages may exist on another device or in iCloud'),
      );
      expect(
        model.notes,
        contains(
          'Older messages may exist on another Apple device or in iCloud.',
        ),
      );
      expect(
        model.reconciliationResultLabel,
        'Result: locally complete, but this Mac\'s source history is limited',
      );
    });

    test('tightens recovered-message explanation for recovered rows', () {
      final model = buildMessageCoveragePanelViewModel(
        MessageHistoryCoverageReport(
          status: MessageHistoryCoverageStatus.complete,
          chatDbTotalCount: 100,
          workingDbVisibleCount: 95,
          workingDbRecoveredCount: 5,
          earliestMessageDate: DateTime.utc(2014, 01, 01),
          latestMessageDate: DateTime.utc(2026, 04, 26),
        ),
      );

      expect(
        model.recoveredExplanation,
        'Recovered messages are present in the Messages database but are not linked to a normal conversation thread.\n\nThey are included in MessageLens and fully accounted for.',
      );
    });

    test('preserves explanatory copy for unknown state', () {
      final model = buildMessageCoveragePanelViewModel(
        const MessageHistoryCoverageReport(
          status: MessageHistoryCoverageStatus.unknown,
          chatDbTotalCount: null,
          workingDbVisibleCount: null,
          workingDbRecoveredCount: null,
          earliestMessageDate: null,
          latestMessageDate: null,
          detail: 'Full Disk Access is not currently granted.',
        ),
      );

      expect(model.statusLabel, 'Unknown');
      expect(
        model.headline,
        'MessageLens could not complete the coverage check.',
      );
      expect(
        model.notes,
        contains('Full Disk Access is not currently granted.'),
      );
    });

    test('handles zero-message state with an empty segment list', () {
      final model = buildMessageCoveragePanelViewModel(
        const MessageHistoryCoverageReport(
          status: MessageHistoryCoverageStatus.complete,
          chatDbTotalCount: 0,
          workingDbVisibleCount: 0,
          workingDbRecoveredCount: 0,
          earliestMessageDate: null,
          latestMessageDate: null,
        ),
      );

      expect(
        model.headline,
        "No messages were found in this Mac's Messages database.",
      );
      expect(model.summaryText, contains('did not find any source messages'));
      expect(model.segments, isEmpty);
      expect(
        model.notes,
        contains("This Mac's Messages database appears to be empty."),
      );
    });

    test('handles null dates without failing', () {
      final model = buildMessageCoveragePanelViewModel(
        const MessageHistoryCoverageReport(
          status: MessageHistoryCoverageStatus.complete,
          chatDbTotalCount: 100,
          workingDbVisibleCount: 90,
          workingDbRecoveredCount: 10,
          earliestMessageDate: null,
          latestMessageDate: null,
        ),
      );

      expect(model.earliestLabel, 'Unknown');
      expect(model.latestLabel, 'Unknown');
      expect(
        model.notes,
        contains('Some date coverage details are unavailable.'),
      );
    });

    test('declares row-owned report sections for the center panel', () {
      final model = buildMessageCoveragePanelViewModel(
        MessageHistoryCoverageReport(
          status: MessageHistoryCoverageStatus.incompleteImport,
          chatDbTotalCount: 100,
          workingDbVisibleCount: 80,
          workingDbRecoveredCount: 10,
          earliestMessageDate: DateTime.utc(2020, 01, 01),
          latestMessageDate: DateTime.utc(2026, 04, 26),
        ),
      );

      expect(model.sections, hasLength(5));
      expect(model.sections[0].layoutStyle, PanelSectionLayoutStyle.fullWidth);
      expect(model.sections[0].children, [
        MessageCoveragePanelSectionChild.hero,
      ]);
      expect(model.sections[1].layoutStyle, PanelSectionLayoutStyle.fullWidth);
      expect(model.sections[1].children, [
        MessageCoveragePanelSectionChild.accounting,
      ]);
      expect(
        model.sections[2].layoutStyle,
        PanelSectionLayoutStyle.twoColumnEqualHeight,
      );
      expect(model.sections[2].children, [
        MessageCoveragePanelSectionChild.reconciliation,
        MessageCoveragePanelSectionChild.timelineCoverage,
      ]);
      expect(model.sections[3].layoutStyle, PanelSectionLayoutStyle.fullWidth);
      expect(model.sections[3].children, [
        MessageCoveragePanelSectionChild.recoveredMessages,
      ]);
      expect(
        model.sections[4].layoutStyle,
        PanelSectionLayoutStyle.compactFullWidth,
      );
      expect(model.sections[4].children, [
        MessageCoveragePanelSectionChild.notes,
      ]);
    });
  });

  group('messageHistoryCoveragePanelModelProvider', () {
    test('maps the report provider into the panel view model', () async {
      final container = ProviderContainer(
        overrides: [
          messageHistoryCoverageReportProvider.overrideWith(
            (ref) async => MessageHistoryCoverageReport(
              status: MessageHistoryCoverageStatus.complete,
              chatDbTotalCount: 120,
              workingDbVisibleCount: 115,
              workingDbRecoveredCount: 5,
              earliestMessageDate: DateTime.utc(2020, 01, 01),
              latestMessageDate: DateTime.utc(2026, 04, 26),
              generatedAt: DateTime.utc(2026, 04, 26, 18),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final model = await container.read(
        messageHistoryCoveragePanelModelProvider.future,
      );

      expect(model.status, MessageHistoryCoverageStatus.complete);
      expect(model.chatDbTotalLabel, '120');
      expect(model.generatedAtLabel, isNotNull);
      expect(model.statusLabel, 'Fully Accounted For');
    });
  });
}
