import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/sidebar_cassette_spec/entities/message_history_coverage_report.dart';
import '../../application/sidebar_cassette_spec/resolvers/message_history_coverage_settings_resolver.dart';

part 'message_history_coverage_panel_model_provider.g.dart';

final class MessageCoveragePanelViewModel {
  const MessageCoveragePanelViewModel({
    required this.title,
    required this.status,
    required this.headline,
    required this.summaryText,
    required this.totalCount,
    required this.totalCountLabel,
    required this.conversationCount,
    required this.conversationCountLabel,
    required this.recoveredCount,
    required this.recoveredCountLabel,
    required this.accountedCount,
    required this.accountedCountLabel,
    required this.unaccountedCount,
    required this.unaccountedCountLabel,
    required this.dateRangeLabel,
    required this.generatedAtLabel,
    required this.detailLines,
  });

  final String title;
  final MessageHistoryCoverageStatus status;
  final String headline;
  final String summaryText;
  final int? totalCount;
  final String totalCountLabel;
  final int? conversationCount;
  final String conversationCountLabel;
  final int? recoveredCount;
  final String recoveredCountLabel;
  final int? accountedCount;
  final String accountedCountLabel;
  final int? unaccountedCount;
  final String unaccountedCountLabel;
  final String dateRangeLabel;
  final String? generatedAtLabel;
  final List<String> detailLines;

  bool get hasCoverageCounts =>
      totalCount != null &&
      conversationCount != null &&
      recoveredCount != null &&
      accountedCount != null &&
      unaccountedCount != null;
}

@riverpod
Future<MessageCoveragePanelViewModel> messageHistoryCoveragePanelModel(
  Ref ref,
) async {
  final report = await ref.watch(messageHistoryCoverageReportProvider.future);
  return buildMessageCoveragePanelViewModel(report);
}

MessageCoveragePanelViewModel buildMessageCoveragePanelViewModel(
  MessageHistoryCoverageReport report,
) {
  return MessageCoveragePanelViewModel(
    title: 'Message History Coverage',
    status: report.status,
    headline: _headline(report),
    summaryText: _summaryText(report),
    totalCount: report.totalCurrentMessages,
    totalCountLabel: _formatCount(report.totalCurrentMessages),
    conversationCount: report.accountedInConversations,
    conversationCountLabel: _formatCount(report.accountedInConversations),
    recoveredCount: report.recoveredUnlinked,
    recoveredCountLabel: _formatCount(report.recoveredUnlinked),
    accountedCount: report.totalAccounted,
    accountedCountLabel: _formatCount(report.totalAccounted),
    unaccountedCount: report.unaccounted,
    unaccountedCountLabel: _formatCount(report.unaccounted),
    dateRangeLabel: _formatDateRange(
      report.earliestMessageDate,
      report.latestMessageDate,
    ),
    generatedAtLabel: _formatDateTime(report.generatedAt),
    detailLines: List<String>.unmodifiable(_detailLines(report)),
  );
}

String _headline(MessageHistoryCoverageReport report) {
  if (report.totalCurrentMessages == 0) {
    return 'No messages are currently stored on this Mac.';
  }

  return switch (report.status) {
    MessageHistoryCoverageStatus.complete =>
      'All messages on this Mac are accounted for',
    MessageHistoryCoverageStatus.incomplete =>
      '${_formatCount(report.unaccounted)} ${_messageWord(report.unaccounted)} could not be accounted for',
    MessageHistoryCoverageStatus.temporarilyUnavailable =>
      'Message history coverage is temporarily unavailable',
    MessageHistoryCoverageStatus.failed =>
      'Message history coverage could not be checked',
  };
}

String _summaryText(MessageHistoryCoverageReport report) {
  if (report.totalCurrentMessages == 0) {
    return 'There is no current Messages history to check.';
  }

  final total = report.totalCurrentMessages;
  final accounted = report.totalAccounted;
  return switch (report.status) {
    MessageHistoryCoverageStatus.complete =>
      total == null
          ? 'Every message currently stored on this Mac has a known place in MessageLens.'
          : _completeSummary(
              total: total,
              inConversations: report.accountedInConversations ?? 0,
              recovered: report.recoveredUnlinked ?? 0,
            ),
    MessageHistoryCoverageStatus.incomplete =>
      accounted == null || total == null
          ? 'Some messages currently stored on this Mac do not yet have a known place in MessageLens.'
          : '${_formatCount(accounted)} of ${_formatCount(total)} messages on this Mac are accounted for.',
    MessageHistoryCoverageStatus.temporarilyUnavailable =>
      'MessageLens is updating its message data. This report will refresh when that work finishes.',
    MessageHistoryCoverageStatus.failed =>
      'MessageLens could not safely compare the messages on this Mac with its current message accounting.',
  };
}

String _completeSummary({
  required int total,
  required int inConversations,
  required int recovered,
}) {
  if (recovered == 0) {
    return 'All ${_formatCount(total)} messages are available in conversations.';
  }

  return 'MessageLens has accounted for all ${_formatCount(total)} messages. '
      '${_formatCount(inConversations)} appear in conversations and '
      '${_formatCount(recovered)} are available in Recovered Messages.';
}

List<String> _detailLines(MessageHistoryCoverageReport report) {
  final lines = <String>[];
  if (report.totalAccounted case final count?) {
    lines.add('Total accounted for: ${_formatCount(count)}');
  }
  if (report.earliestMessageDate != null || report.latestMessageDate != null) {
    lines.add(
      'Date range on this Mac: ${_formatDateRange(report.earliestMessageDate, report.latestMessageDate)}',
    );
  }
  if (_formatDateTime(report.generatedAt) case final generatedAt?) {
    lines.add('Checked: $generatedAt');
  }
  if (report.detail case final detail? when detail.isNotEmpty) {
    lines.add(detail);
  }
  lines.add(
    'Imported Historical Archives are outside this report unless those messages are also currently stored on this Mac.',
  );
  return lines;
}

String _messageWord(int? count) => count == 1 ? 'message' : 'messages';

String _formatCount(int? value) {
  if (value == null) {
    return 'Unknown';
  }
  return NumberFormat.decimalPattern().format(value);
}

String _formatDateRange(DateTime? earliest, DateTime? latest) {
  if (earliest == null && latest == null) {
    return 'Unavailable';
  }
  if (earliest == null) {
    return 'Through ${_formatDate(latest!)}';
  }
  if (latest == null) {
    return 'From ${_formatDate(earliest)}';
  }
  return '${_formatDate(earliest)} – ${_formatDate(latest)}';
}

String _formatDate(DateTime value) {
  return DateFormat('MMM d, y').format(value.toLocal());
}

String? _formatDateTime(DateTime? value) {
  if (value == null) {
    return null;
  }
  return DateFormat('MMM d, y h:mm a').format(value.toLocal());
}
