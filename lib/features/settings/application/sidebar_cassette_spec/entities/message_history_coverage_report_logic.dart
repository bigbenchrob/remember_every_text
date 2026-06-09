import 'package:intl/intl.dart';

import 'message_history_coverage_report.dart';

const _suspiciouslyRecentWindowDays = 365 * 5;

MessageHistoryCoverageStatus classifyMessageHistoryCoverageReport({
  required int? sourceCount,
  required int? accountedCount,
  required DateTime? earliestMessageDate,
  DateTime? nowUtc,
}) {
  if (sourceCount == null || accountedCount == null) {
    return MessageHistoryCoverageStatus.unknown;
  }

  if (sourceCount > accountedCount) {
    return MessageHistoryCoverageStatus.incompleteImport;
  }

  if (sourceCount == accountedCount &&
      earliestMessageDate != null &&
      isSuspiciouslyRecentMessageHistoryStart(
        earliestMessageDate,
        nowUtc: nowUtc,
      )) {
    return MessageHistoryCoverageStatus.incompleteSourceHistory;
  }

  return MessageHistoryCoverageStatus.complete;
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
    'Total messages on this Mac: ${_formatCount(report.chatDbTotalCount)}',
    'Visible in MessageLens: ${_formatCount(report.graphConversationLinkedCount)}',
    'Recovered (unlinked): ${_formatCount(report.graphRecoveredOrphanCount)}',
    'Total accounted for: ${_formatCount(report.graphTotalAccountedCount)}',
    'Missing: ${_formatCount(report.missingCount)}',
    'Date range: ${_formatDateRange(report)}',
  ].join('\n');

  final interpretation = switch (report.status) {
    MessageHistoryCoverageStatus.complete =>
      'MessageLens has accounted for all messages currently available on this Mac. No missing messages were detected.',
    MessageHistoryCoverageStatus.incompleteImport =>
      "Some messages in your Mac's Messages database were not imported into MessageLens. This may indicate an interrupted or incomplete import.",
    MessageHistoryCoverageStatus.incompleteSourceHistory =>
      "MessageLens has imported all messages available on this Mac. However, this Mac's Messages database only appears to contain messages starting from ${_formatDate(report.earliestMessageDate)}. Older messages may exist on another device or in iCloud.",
    MessageHistoryCoverageStatus.unknown =>
      report.detail ??
          'MessageLens could not complete the coverage check safely.',
  };

  final detail = report.detail;
  final troubleshootingGuidance = _buildTroubleshootingGuidance(report);

  if (report.status == MessageHistoryCoverageStatus.unknown ||
      detail == null ||
      detail.isEmpty) {
    if (troubleshootingGuidance == null) {
      return '$interpretation\n\n$summaryLines';
    }

    return '$interpretation\n\n$summaryLines\n\n$troubleshootingGuidance';
  }

  if (troubleshootingGuidance == null) {
    return '$interpretation\n\n$summaryLines\n\n$detail';
  }

  return '$interpretation\n\n$summaryLines\n\n$troubleshootingGuidance\n\n$detail';
}

String? _buildTroubleshootingGuidance(MessageHistoryCoverageReport report) {
  if (report.status != MessageHistoryCoverageStatus.incompleteSourceHistory) {
    return null;
  }

  return [
    'Troubleshooting steps:',
    '1. Open Messages on this Mac and scroll farther back to confirm whether older conversations are available locally.',
    '2. Check another device signed into the same Apple Account. Older history may still exist there even if this Mac only has recent messages downloaded.',
    '3. If older messages appear on another device, allow Messages to finish syncing on this Mac and then run Message History Coverage again.',
  ].join('\n');
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
