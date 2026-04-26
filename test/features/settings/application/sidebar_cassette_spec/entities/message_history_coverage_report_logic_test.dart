import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/entities/message_history_coverage_report.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/entities/message_history_coverage_report_logic.dart';

void main() {
  group('classifyMessageHistoryCoverageReport', () {
    test('returns complete when totals match and history is not recent', () {
      final status = classifyMessageHistoryCoverageReport(
        sourceCount: 100,
        accountedCount: 100,
        earliestMessageDate: DateTime.utc(2010, 01, 01),
        nowUtc: DateTime.utc(2026, 04, 26),
      );

      expect(status, MessageHistoryCoverageStatus.complete);
    });

    test('returns incomplete import when source total is higher', () {
      final status = classifyMessageHistoryCoverageReport(
        sourceCount: 100,
        accountedCount: 96,
        earliestMessageDate: DateTime.utc(2010, 01, 01),
        nowUtc: DateTime.utc(2026, 04, 26),
      );

      expect(status, MessageHistoryCoverageStatus.incompleteImport);
    });

    test('returns incomplete source history when earliest date is recent', () {
      final status = classifyMessageHistoryCoverageReport(
        sourceCount: 100,
        accountedCount: 100,
        earliestMessageDate: DateTime.utc(2024, 01, 01),
        nowUtc: DateTime.utc(2026, 04, 26),
      );

      expect(status, MessageHistoryCoverageStatus.incompleteSourceHistory);
    });

    test('returns unknown when totals are unavailable', () {
      final status = classifyMessageHistoryCoverageReport(
        sourceCount: null,
        accountedCount: 100,
        earliestMessageDate: null,
        nowUtc: DateTime.utc(2026, 04, 26),
      );

      expect(status, MessageHistoryCoverageStatus.unknown);
    });
  });

  group('buildMessageHistoryCoverageBodyText', () {
    test('includes summary lines and complete interpretation', () {
      final bodyText = buildMessageHistoryCoverageBodyText(
        MessageHistoryCoverageReport(
          status: MessageHistoryCoverageStatus.complete,
          chatDbTotalCount: 1200,
          workingDbVisibleCount: 1190,
          workingDbRecoveredCount: 10,
          earliestMessageDate: DateTime.utc(2014, 05, 01),
          latestMessageDate: DateTime.utc(2026, 04, 26),
        ),
      );

      expect(bodyText, contains('MessageLens has accounted for all messages'));
      expect(bodyText, contains('Total messages on this Mac: 1,200'));
      expect(bodyText, contains('Visible in MessageLens: 1,190'));
      expect(bodyText, contains('Recovered (unlinked): 10'));
      expect(bodyText, contains('Total accounted for: 1,200'));
      expect(bodyText, contains('Missing: 0'));
      expect(bodyText, contains('Date range:'));
      expect(bodyText, isNot(contains('Troubleshooting steps:')));
    });

    test(
      'adds inline troubleshooting guidance for incomplete source history',
      () {
        final bodyText = buildMessageHistoryCoverageBodyText(
          MessageHistoryCoverageReport(
            status: MessageHistoryCoverageStatus.incompleteSourceHistory,
            chatDbTotalCount: 120,
            workingDbVisibleCount: 115,
            workingDbRecoveredCount: 5,
            earliestMessageDate: DateTime.utc(2024, 01, 01),
            latestMessageDate: DateTime.utc(2026, 04, 26),
          ),
        );

        expect(bodyText, contains('Troubleshooting steps:'));
        expect(
          bodyText,
          contains('Open Messages on this Mac and scroll farther back'),
        );
        expect(
          bodyText,
          contains('Check another device signed into the same Apple Account'),
        );
        expect(bodyText, contains('run Message History Coverage again'));
      },
    );

    test('uses detail text for unknown reports', () {
      final bodyText = buildMessageHistoryCoverageBodyText(
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

      expect(bodyText, contains('Full Disk Access is not currently granted.'));
      expect(bodyText, contains('Unavailable'));
    });
  });

  group('MessageHistoryCoverageReport', () {
    test('serializes the expected JSON fields', () {
      final report = MessageHistoryCoverageReport(
        status: MessageHistoryCoverageStatus.complete,
        chatDbTotalCount: 120,
        workingDbVisibleCount: 115,
        workingDbRecoveredCount: 5,
        earliestMessageDate: DateTime.utc(2020, 01, 01),
        latestMessageDate: DateTime.utc(2026, 04, 26),
      );

      expect(report.toJson(), {
        'chatDbTotal': 120,
        'visible': 115,
        'recovered': 5,
        'accounted': 120,
        'missing': 0,
        'earliest': '2020-01-01T00:00:00.000Z',
        'latest': '2026-04-26T00:00:00.000Z',
        'status': 'complete',
        'detail': null,
      });
    });
  });
}
