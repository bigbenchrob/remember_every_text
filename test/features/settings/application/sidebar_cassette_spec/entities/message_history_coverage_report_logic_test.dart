import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/feature_level_providers.dart';
import 'package:remember_this_text/essentials/source_scoped_import/feature_level_providers.dart';
import 'package:remember_this_text/features/settings/application/message_history_coverage_repository.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/entities/message_history_coverage_report.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/entities/message_history_coverage_report_logic.dart';

void main() {
  group('reconcileMessageHistoryCoverage', () {
    test('partitions every current source row exactly once', () {
      final report = reconcileMessageHistoryCoverage(
        evidence: _evidence(
          sourceRows: const <int>{1, 2, 3},
          graphRows: const <int, CurrentSourceMessageGraphPlacement>{
            1: CurrentSourceMessageGraphPlacement.conversationLinked,
            2: CurrentSourceMessageGraphPlacement.recoveredUnlinked,
          },
        ),
        generatedAt: _generatedAt,
      );

      expect(report.status, MessageHistoryCoverageStatus.incomplete);
      expect(report.totalCurrentMessages, 3);
      expect(report.accountedInConversations, 1);
      expect(report.recoveredUnlinked, 1);
      expect(report.unaccounted, 1);
      expect(
        report.accountedInConversations! +
            report.recoveredUnlinked! +
            report.unaccounted!,
        report.totalCurrentMessages,
      );
    });

    test('complete derives only from an empty unaccounted set', () {
      final report = reconcileMessageHistoryCoverage(
        evidence: _evidence(
          sourceRows: const <int>{1, 2},
          graphRows: const <int, CurrentSourceMessageGraphPlacement>{
            1: CurrentSourceMessageGraphPlacement.conversationLinked,
            2: CurrentSourceMessageGraphPlacement.recoveredUnlinked,
          },
        ),
        generatedAt: _generatedAt,
      );

      expect(report.status, MessageHistoryCoverageStatus.complete);
      expect(report.unaccounted, 0);
    });

    test('equal gross totals do not conceal different row identities', () {
      final report = reconcileMessageHistoryCoverage(
        evidence: _evidence(
          sourceRows: const <int>{1, 2},
          graphRows: const <int, CurrentSourceMessageGraphPlacement>{
            1: CurrentSourceMessageGraphPlacement.conversationLinked,
            3: CurrentSourceMessageGraphPlacement.recoveredUnlinked,
          },
        ),
        generatedAt: _generatedAt,
      );

      expect(report.status, MessageHistoryCoverageStatus.incomplete);
      expect(report.accountedInConversations, 1);
      expect(report.recoveredUnlinked, 0);
      expect(report.unaccounted, 1);
    });

    test('impossible arithmetic is rejected instead of clamped', () {
      expect(
        () => MessageHistoryCoverageReport.reconciled(
          totalCurrentMessages: 2,
          accountedInConversations: 2,
          recoveredUnlinked: 1,
          unaccounted: 0,
          earliestMessageDate: null,
          latestMessageDate: null,
          generatedAt: _generatedAt,
        ),
        throwsStateError,
      );
      expect(
        () => MessageHistoryCoverageReport.reconciled(
          totalCurrentMessages: 2,
          accountedInConversations: 1,
          recoveredUnlinked: 0,
          unaccounted: -1,
          earliestMessageDate: null,
          latestMessageDate: null,
          generatedAt: _generatedAt,
        ),
        throwsStateError,
      );
    });
  });

  group('MessageHistoryCoverageReport', () {
    test('serializes the exact current-source partition', () {
      final report = MessageHistoryCoverageReport.reconciled(
        totalCurrentMessages: 120,
        accountedInConversations: 115,
        recoveredUnlinked: 5,
        unaccounted: 0,
        earliestMessageDate: DateTime.utc(2020),
        latestMessageDate: DateTime.utc(2026, 4, 26),
        generatedAt: _generatedAt,
      );

      expect(report.toJson(), {
        'totalCurrentMessages': 120,
        'accountedInConversations': 115,
        'recoveredUnlinked': 5,
        'unaccounted': 0,
        'accounted': 120,
        'earliest': '2020-01-01T00:00:00.000Z',
        'latest': '2026-04-26T00:00:00.000Z',
        'generatedAt': '2026-08-22T12:00:00.000Z',
        'status': 'complete',
        'detail': null,
      });
    });

    test('body text uses unavailable rather than stale success counts', () {
      final body = buildMessageHistoryCoverageBodyText(
        MessageHistoryCoverageReport.temporarilyUnavailable(
          generatedAt: _generatedAt,
          detail: 'Database maintenance is active.',
        ),
      );

      expect(body, contains('Database maintenance is active.'));
      expect(body, contains('Unavailable'));
      expect(body, isNot(contains('No missing messages were detected')));
    });
  });
}

final _generatedAt = DateTime.utc(2026, 8, 22, 12);

MessageHistoryCoverageEvidence _evidence({
  required Set<int> sourceRows,
  required Map<int, CurrentSourceMessageGraphPlacement> graphRows,
}) {
  return MessageHistoryCoverageEvidence(
    currentSource: CurrentMessagesSourceCoverageEvidence(
      sourceRowIds: sourceRows,
      earliestMessageDate: DateTime.utc(2012, 7, 25),
      latestMessageDate: DateTime.utc(2026, 8, 22),
    ),
    currentSourceGraph: CurrentSourceMessageGraphCoverageEvidence(
      placementBySourceRowId: graphRows,
    ),
  );
}
