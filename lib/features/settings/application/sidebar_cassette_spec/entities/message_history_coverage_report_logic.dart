import 'package:intl/intl.dart';

import '../../../../../essentials/conversation_graph/feature_level_providers.dart'
    show CurrentSourceMessageGraphPlacement;
import '../../message_history_coverage_repository.dart';
import 'message_history_coverage_report.dart';

const _suspiciouslyRecentWindowDays = 365 * 5;

MessageHistoryCoverageReport reconcileMessageHistoryCoverage({
  required MessageHistoryCoverageEvidence evidence,
  required DateTime generatedAt,
}) {
  final source = evidence.currentSource;
  final graphPlacements = evidence.currentSourceGraph.placementBySourceRowId;

  var accountedInConversations = 0;
  var recoveredUnlinked = 0;
  var unaccounted = 0;
  for (final sourceRowId in source.sourceRowIds) {
    switch (graphPlacements[sourceRowId]) {
      case CurrentSourceMessageGraphPlacement.conversationLinked:
        accountedInConversations++;
      case CurrentSourceMessageGraphPlacement.recoveredUnlinked:
        recoveredUnlinked++;
      case null:
        unaccounted++;
    }
  }

  return MessageHistoryCoverageReport.reconciled(
    totalCurrentMessages: source.totalRowCount,
    accountedInConversations: accountedInConversations,
    recoveredUnlinked: recoveredUnlinked,
    unaccounted: unaccounted,
    earliestMessageDate: source.earliestMessageDate,
    latestMessageDate: source.latestMessageDate,
    generatedAt: generatedAt,
  );
}

bool isSuspiciouslyRecentMessageHistoryStart(
  DateTime earliestMessageDate, {
  DateTime? nowUtc,
}) {
  final effectiveNow = nowUtc ?? DateTime.now().toUtc();
  final threshold = effectiveNow.subtract(
    const Duration(days: _suspiciouslyRecentWindowDays),
  );
  return earliestMessageDate.isAfter(threshold);
}

String buildMessageHistoryCoverageBodyText(
  MessageHistoryCoverageReport report,
) {
  final summaryLines = [
    'Total messages on this Mac: ${_formatCount(report.totalCurrentMessages)}',
    'Visible in MessageLens: ${_formatCount(report.accountedInConversations)}',
    'Recovered (unlinked): ${_formatCount(report.recoveredUnlinked)}',
    'Total accounted for: ${_formatCount(report.totalAccounted)}',
    'Missing: ${_formatCount(report.unaccounted)}',
    'Date range: ${_formatDateRange(report)}',
  ].join('\n');

  final interpretation = switch (report.status) {
    MessageHistoryCoverageStatus.complete =>
      'MessageLens has accounted for all messages currently available on this Mac. No missing messages were detected.',
    MessageHistoryCoverageStatus.incomplete =>
      "Some messages in your Mac's Messages database could not be reconciled to MessageLens.",
    MessageHistoryCoverageStatus.temporarilyUnavailable =>
      report.detail ??
          'Message History Coverage is temporarily unavailable while MessageLens updates its data.',
    MessageHistoryCoverageStatus.failed =>
      report.detail ??
          'MessageLens could not complete the coverage check safely.',
  };

  return '$interpretation\n\n$summaryLines';
}

String _formatCount(int? value) {
  if (value == null) {
    return 'Unavailable';
  }
  return NumberFormat.decimalPattern().format(value);
}

String _formatDate(DateTime? value) {
  if (value == null) {
    return 'Unavailable';
  }
  return DateFormat('MMM d, y').format(value.toLocal());
}

String _formatDateRange(MessageHistoryCoverageReport report) {
  return '${_formatDate(report.earliestMessageDate)} -> ${_formatDate(report.latestMessageDate)}';
}
