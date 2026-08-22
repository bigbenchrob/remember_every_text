import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/navigation/presentation/view/center_panel_report_layout.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/entities/message_history_coverage_report.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/resolvers/message_history_coverage_settings_resolver.dart';
import 'package:remember_this_text/features/settings/presentation/view_model/message_history_coverage_panel_model_provider.dart';

void main() {
  group('buildMessageCoveragePanelViewModel', () {
    test('presents the exact complete partition', () {
      final model = buildMessageCoveragePanelViewModel(
        _report(conversation: 115, recovered: 5, unaccounted: 0),
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
      expect(model.missingCount, 0);
      expect(model.segments, hasLength(2));
      expect(
        model.segments.fold<double>(
          0,
          (sum, segment) => sum + segment.fraction,
        ),
        1,
      );
      expect(model.notes, isEmpty);
    });

    test('makes unaccounted rows visible without normalization', () {
      final model = buildMessageCoveragePanelViewModel(
        _report(conversation: 100, recovered: 10, unaccounted: 10),
      );

      expect(model.status, MessageHistoryCoverageStatus.incomplete);
      expect(model.statusLabel, 'Needs Attention');
      expect(model.missingCount, 10);
      expect(
        model.segments.map((segment) => segment.id),
        contains(CoverageSegmentId.missing),
      );
      expect(
        model.segments.fold<double>(
          0,
          (sum, segment) => sum + segment.fraction,
        ),
        1,
      );
    });

    test('keeps recent source-history guidance orthogonal to coverage', () {
      final model = buildMessageCoveragePanelViewModel(
        MessageHistoryCoverageReport.reconciled(
          totalCurrentMessages: 120,
          accountedInConversations: 115,
          recoveredUnlinked: 5,
          unaccounted: 0,
          earliestMessageDate: DateTime.utc(2024),
          latestMessageDate: DateTime.utc(2026, 4, 26),
          generatedAt: _generatedAt,
        ),
      );

      expect(model.status, MessageHistoryCoverageStatus.complete);
      expect(
        model.notes,
        contains(
          'Older messages may exist on another Apple device or in iCloud.',
        ),
      );
    });

    test('presents maintenance without stale counts or success', () {
      final model = buildMessageCoveragePanelViewModel(
        MessageHistoryCoverageReport.temporarilyUnavailable(
          generatedAt: _generatedAt,
          detail: 'Maintenance is active.',
        ),
      );

      expect(model.statusLabel, 'Temporarily Unavailable');
      expect(model.chatDbTotal, isNull);
      expect(model.segments, isEmpty);
      expect(model.notes, contains('Maintenance is active.'));
    });

    test('declares row-owned report sections', () {
      final model = buildMessageCoveragePanelViewModel(
        _report(conversation: 100, recovered: 10, unaccounted: 10),
      );

      expect(model.sections, hasLength(5));
      expect(model.sections[0].layoutStyle, PanelSectionLayoutStyle.fullWidth);
      expect(model.sections[0].children, [
        MessageCoveragePanelSectionChild.hero,
      ]);
      expect(
        model.sections[2].layoutStyle,
        PanelSectionLayoutStyle.twoColumnEqualHeight,
      );
      expect(model.sections[2].children, [
        MessageCoveragePanelSectionChild.reconciliation,
        MessageCoveragePanelSectionChild.timelineCoverage,
      ]);
    });
  });

  test('panel provider maps one report request', () async {
    final container = ProviderContainer(
      overrides: [
        messageHistoryCoverageReportProvider.overrideWith(
          (ref) async =>
              _report(conversation: 115, recovered: 5, unaccounted: 0),
        ),
      ],
    );
    addTearDown(container.dispose);

    final model = await container.read(
      messageHistoryCoveragePanelModelProvider.future,
    );

    expect(model.status, MessageHistoryCoverageStatus.complete);
    expect(model.chatDbTotalLabel, '120');
  });
}

final _generatedAt = DateTime.utc(2026, 4, 26, 18);

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
    earliestMessageDate: DateTime.utc(2020),
    latestMessageDate: DateTime.utc(2026, 4, 26),
    generatedAt: _generatedAt,
  );
}
