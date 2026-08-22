import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/entities/message_history_coverage_report.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/resolvers/message_history_coverage_settings_resolver.dart';
import 'package:remember_this_text/features/settings/presentation/view_model/message_history_coverage_panel_model_provider.dart';

void main() {
  group('buildMessageCoveragePanelViewModel', () {
    test('presents a concise complete result with recovered messages', () {
      final model = buildMessageCoveragePanelViewModel(
        _report(conversation: 115, recovered: 5, unaccounted: 0),
      );

      expect(model.headline, 'All messages on this Mac are accounted for');
      expect(
        model.summaryText,
        'MessageLens has accounted for all 120 messages. '
        '115 appear in conversations and 5 are available in Recovered Messages.',
      );
      expect(model.totalCount, 120);
      expect(model.accountedCount, 120);
      expect(model.unaccountedCount, 0);
      expect(model.detailLines, contains('Total accounted for: 120'));
      expect(model.detailLines, isNot(contains('Recovered Messages: 5')));
      expect(model.detailLines, isNot(contains('Unaccounted: 0')));
    });

    test('names the exact incomplete exception and full denominator', () {
      final model = buildMessageCoveragePanelViewModel(
        _report(conversation: 100, recovered: 10, unaccounted: 10),
      );

      expect(model.status, MessageHistoryCoverageStatus.incomplete);
      expect(model.headline, '10 messages could not be accounted for');
      expect(
        model.summaryText,
        '110 of 120 messages on this Mac are accounted for.',
      );
      expect(model.unaccountedCount, 10);
    });

    test('distinguishes maintenance from failure without stale counts', () {
      final unavailable = buildMessageCoveragePanelViewModel(
        MessageHistoryCoverageReport.temporarilyUnavailable(
          generatedAt: _generatedAt,
          detail: 'Maintenance is active.',
        ),
      );
      final failed = buildMessageCoveragePanelViewModel(
        MessageHistoryCoverageReport.failed(
          generatedAt: _generatedAt,
          detail: 'Evidence read failed.',
        ),
      );

      expect(unavailable.totalCount, isNull);
      expect(unavailable.detailLines, contains('Maintenance is active.'));
      expect(failed.headline, 'Message history coverage could not be checked');
      expect(failed.detailLines, contains('Evidence read failed.'));
    });

    test('keeps Historical Archives outside the displayed scope', () {
      final model = buildMessageCoveragePanelViewModel(
        _report(conversation: 115, recovered: 5, unaccounted: 0),
      );

      expect(
        model.detailLines,
        contains(
          'Imported Historical Archives are outside this report unless those messages are also currently stored on this Mac.',
        ),
      );
    });
  });

  test('panel provider maps one typed report request', () async {
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
    expect(model.totalCountLabel, '120');
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
