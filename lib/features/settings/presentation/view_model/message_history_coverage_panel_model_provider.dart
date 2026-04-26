import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/navigation/presentation/view/center_panel_report_layout.dart';
import '../../application/sidebar_cassette_spec/entities/message_history_coverage_report.dart';
import '../../application/sidebar_cassette_spec/resolvers/message_history_coverage_settings_resolver.dart';

part 'message_history_coverage_panel_model_provider.g.dart';

enum CoverageSegmentId { visible, recovered, missing }

enum CoverageSegmentSemanticKind { visible, recovered, missing }

enum MessageCoveragePanelSectionChild {
  hero,
  accounting,
  reconciliation,
  timelineCoverage,
  recoveredMessages,
  notes,
}

final class CoverageSegmentViewModel {
  const CoverageSegmentViewModel({
    required this.id,
    required this.label,
    required this.count,
    required this.fraction,
    required this.semanticKind,
  });

  final CoverageSegmentId id;
  final String label;
  final int count;
  final double fraction;
  final CoverageSegmentSemanticKind semanticKind;
}

final class MessageCoveragePanelViewModel {
  const MessageCoveragePanelViewModel({
    required this.title,
    required this.status,
    required this.statusLabel,
    required this.headline,
    required this.summaryText,
    required this.chatDbTotal,
    required this.chatDbTotalLabel,
    required this.visibleCount,
    required this.visibleCountLabel,
    required this.recoveredCount,
    required this.recoveredCountLabel,
    required this.accountedCount,
    required this.accountedCountLabel,
    required this.missingCount,
    required this.missingCountLabel,
    required this.earliestLabel,
    required this.latestLabel,
    required this.generatedAtLabel,
    required this.reconciliationResultLabel,
    required this.timelineCoverageLabel,
    required this.timelineCoverageDetail,
    required this.recoveredExplanation,
    required this.segments,
    required this.notes,
    required this.sections,
  });

  final String title;
  final MessageHistoryCoverageStatus status;
  final String statusLabel;
  final String headline;
  final String summaryText;
  final int? chatDbTotal;
  final String chatDbTotalLabel;
  final int? visibleCount;
  final String visibleCountLabel;
  final int? recoveredCount;
  final String recoveredCountLabel;
  final int? accountedCount;
  final String accountedCountLabel;
  final int? missingCount;
  final String missingCountLabel;
  final String earliestLabel;
  final String latestLabel;
  final String? generatedAtLabel;
  final String reconciliationResultLabel;
  final String timelineCoverageLabel;
  final String? timelineCoverageDetail;
  final String recoveredExplanation;
  final List<CoverageSegmentViewModel> segments;
  final List<String> notes;
  final List<PanelSection<MessageCoveragePanelSectionChild>> sections;
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
  final chatDbTotal = report.chatDbTotalCount;
  final visibleCount = report.workingDbVisibleCount;
  final recoveredCount = report.workingDbRecoveredCount;
  final accountedCount = report.workingDbTotalAccountedCount;
  final missingCount = report.missingCount;
  final notes = _notesFor(report);

  return MessageCoveragePanelViewModel(
    title: 'Message History Coverage',
    status: report.status,
    statusLabel: _statusLabel(report.status),
    headline: _headline(report),
    summaryText: _summaryText(report),
    chatDbTotal: chatDbTotal,
    chatDbTotalLabel: _formatCount(chatDbTotal),
    visibleCount: visibleCount,
    visibleCountLabel: _formatCount(visibleCount),
    recoveredCount: recoveredCount,
    recoveredCountLabel: _formatCount(recoveredCount),
    accountedCount: accountedCount,
    accountedCountLabel: _formatCount(accountedCount),
    missingCount: missingCount,
    missingCountLabel: _formatCount(missingCount),
    earliestLabel: _formatDate(report.earliestMessageDate),
    latestLabel: _formatDate(report.latestMessageDate),
    generatedAtLabel: _formatDateTime(report.generatedAt),
    reconciliationResultLabel: _reconciliationResultLabel(report),
    timelineCoverageLabel: _timelineCoverageLabel(report),
    timelineCoverageDetail: _timelineCoverageDetail(report),
    recoveredExplanation: _recoveredExplanation(report),
    segments: _segmentsFor(report),
    notes: notes,
    sections: _sectionsFor(includeNotes: notes.isNotEmpty),
  );
}

List<PanelSection<MessageCoveragePanelSectionChild>> _sectionsFor({
  required bool includeNotes,
}) {
  final sections = <PanelSection<MessageCoveragePanelSectionChild>>[
    PanelSection<MessageCoveragePanelSectionChild>(
      layoutStyle: PanelSectionLayoutStyle.fullWidth,
      children: const [MessageCoveragePanelSectionChild.hero],
    ),
    PanelSection<MessageCoveragePanelSectionChild>(
      layoutStyle: PanelSectionLayoutStyle.fullWidth,
      children: const [MessageCoveragePanelSectionChild.accounting],
    ),
    PanelSection<MessageCoveragePanelSectionChild>(
      layoutStyle: PanelSectionLayoutStyle.twoColumnEqualHeight,
      children: const [
        MessageCoveragePanelSectionChild.reconciliation,
        MessageCoveragePanelSectionChild.timelineCoverage,
      ],
    ),
    PanelSection<MessageCoveragePanelSectionChild>(
      layoutStyle: PanelSectionLayoutStyle.fullWidth,
      children: const [MessageCoveragePanelSectionChild.recoveredMessages],
    ),
  ];

  if (includeNotes) {
    sections.add(
      PanelSection<MessageCoveragePanelSectionChild>(
        layoutStyle: PanelSectionLayoutStyle.compactFullWidth,
        children: const [MessageCoveragePanelSectionChild.notes],
      ),
    );
  }

  return List<PanelSection<MessageCoveragePanelSectionChild>>.unmodifiable(
    sections,
  );
}

String _statusLabel(MessageHistoryCoverageStatus status) {
  return switch (status) {
    MessageHistoryCoverageStatus.complete => 'Fully Accounted For',
    MessageHistoryCoverageStatus.incompleteImport => 'Needs Attention',
    MessageHistoryCoverageStatus.incompleteSourceHistory => 'Limited History',
    MessageHistoryCoverageStatus.unknown => 'Unknown',
  };
}

String _headline(MessageHistoryCoverageReport report) {
  if (report.chatDbTotalCount == 0) {
    return "No messages were found in this Mac's Messages database.";
  }

  return switch (report.status) {
    MessageHistoryCoverageStatus.complete =>
      'Every message on this Mac has been accounted for.',
    MessageHistoryCoverageStatus.incompleteImport =>
      'Some messages could not be accounted for.',
    MessageHistoryCoverageStatus.incompleteSourceHistory =>
      "This Mac's Messages history begins on ${_formatDate(report.earliestMessageDate)}.",
    MessageHistoryCoverageStatus.unknown =>
      'MessageLens could not complete the coverage check.',
  };
}

String _summaryText(MessageHistoryCoverageReport report) {
  if (report.chatDbTotalCount == 0) {
    return 'MessageLens did not find any source messages to reconcile on this Mac.';
  }

  final chatDbTotal = report.chatDbTotalCount;

  return switch (report.status) {
    MessageHistoryCoverageStatus.complete
        when chatDbTotal != null && chatDbTotal > 0 =>
      'All ${_formatCount(chatDbTotal)} messages on this Mac are accounted for.',
    MessageHistoryCoverageStatus.complete =>
      "Nothing in this Mac's Messages database is missing from MessageLens.",
    MessageHistoryCoverageStatus.incompleteImport =>
      'Some source messages are missing from the MessageLens import and need follow-up.',
    MessageHistoryCoverageStatus.incompleteSourceHistory =>
      'MessageLens accounted for the messages available locally, but older messages may exist on another device or in iCloud.',
    MessageHistoryCoverageStatus.unknown =>
      "MessageLens could not safely compare this Mac's Messages database with the imported data.",
  };
}

String _reconciliationResultLabel(MessageHistoryCoverageReport report) {
  if (report.chatDbTotalCount == 0) {
    return 'Result: no source messages found';
  }

  final overlapNote = _hasAccountingOverlap(report)
      ? '\n\nA small overlap was detected while reconciling visible and recovered messages. This does not indicate missing data.'
      : '';

  return switch (report.status) {
    MessageHistoryCoverageStatus.complete =>
      'Result: fully reconciled$overlapNote',
    MessageHistoryCoverageStatus.incompleteImport =>
      'Result: some source messages are still missing',
    MessageHistoryCoverageStatus.incompleteSourceHistory =>
      'Result: locally complete, but this Mac\'s source history is limited',
    MessageHistoryCoverageStatus.unknown =>
      'Result: could not complete the check',
  };
}

String _timelineCoverageLabel(MessageHistoryCoverageReport report) {
  if (report.chatDbTotalCount == 0) {
    return 'This Mac currently has no local Messages history to display.';
  }

  return "This Mac's Messages history spans:";
}

String? _timelineCoverageDetail(MessageHistoryCoverageReport report) {
  if (report.chatDbTotalCount == null || report.chatDbTotalCount == 0) {
    return null;
  }

  return 'If you expected to see older messages, they may exist on another device or in iCloud, but are not present on this Mac.';
}

String _recoveredExplanation(MessageHistoryCoverageReport report) {
  final recoveredCount = report.workingDbRecoveredCount;
  if (recoveredCount == null) {
    return 'Recovered-message details are unavailable until the coverage check can complete.';
  }

  if (recoveredCount == 0) {
    return 'No recovered or unlinked messages were needed for this reconciliation.';
  }

  return 'Recovered messages are present in the Messages database but are not linked to a normal conversation thread.\n\nThey are included in MessageLens and fully accounted for.';
}

List<CoverageSegmentViewModel> _segmentsFor(
  MessageHistoryCoverageReport report,
) {
  final chatDbTotal = report.chatDbTotalCount;
  final visibleCount = report.workingDbVisibleCount;
  final recoveredCount = report.workingDbRecoveredCount;
  final missingCount = report.missingCount;

  if (chatDbTotal == null || chatDbTotal <= 0) {
    return const <CoverageSegmentViewModel>[];
  }

  final visible = visibleCount ?? 0;
  final recovered = recoveredCount ?? 0;
  final missing = missingCount ?? 0;
  final visibleFraction = (visible / chatDbTotal).clamp(0.0, 1.0);

  final recoveredFraction = visible + recovered <= chatDbTotal
      ? (recovered / chatDbTotal).clamp(0.0, 1.0)
      : ((chatDbTotal - visible).clamp(0, chatDbTotal) / chatDbTotal).clamp(
          0.0,
          1.0,
        );

  final missingFraction = (missing / chatDbTotal).clamp(0.0, 1.0);

  final segments = <CoverageSegmentViewModel>[];
  if (visible > 0) {
    segments.add(
      CoverageSegmentViewModel(
        id: CoverageSegmentId.visible,
        label: 'Visible in timelines',
        count: visible,
        fraction: visibleFraction,
        semanticKind: CoverageSegmentSemanticKind.visible,
      ),
    );
  }
  if (recovered > 0) {
    segments.add(
      CoverageSegmentViewModel(
        id: CoverageSegmentId.recovered,
        label: 'Recovered / unlinked',
        count: recovered,
        fraction: recoveredFraction,
        semanticKind: CoverageSegmentSemanticKind.recovered,
      ),
    );
  }
  if (missing > 0) {
    segments.add(
      CoverageSegmentViewModel(
        id: CoverageSegmentId.missing,
        label: 'Missing',
        count: missing,
        fraction: missingFraction,
        semanticKind: CoverageSegmentSemanticKind.missing,
      ),
    );
  }

  return segments;
}

List<String> _notesFor(MessageHistoryCoverageReport report) {
  final notes = <String>[];

  if (report.chatDbTotalCount == 0) {
    notes.add("This Mac's Messages database appears to be empty.");
  }

  switch (report.status) {
    case MessageHistoryCoverageStatus.complete:
      break;
    case MessageHistoryCoverageStatus.incompleteImport:
      notes.add('Some messages in chat.db were not imported into MessageLens.');
    case MessageHistoryCoverageStatus.incompleteSourceHistory:
      notes.add(
        'Older messages may exist on another Apple device or in iCloud.',
      );
    case MessageHistoryCoverageStatus.unknown:
      if (report.detail != null && report.detail!.isNotEmpty) {
        notes.add(report.detail!);
      } else {
        notes.add('MessageLens could not complete the coverage check safely.');
      }
  }

  if (_hasAccountingOverlap(report)) {
    notes.add(
      'MessageLens detected a small overlap while reconciling visible and recovered messages.',
    );
  }

  if (report.chatDbTotalCount != null &&
      report.chatDbTotalCount! > 0 &&
      (report.earliestMessageDate == null ||
          report.latestMessageDate == null)) {
    notes.add('Some date coverage details are unavailable.');
  }

  return notes;
}

bool _hasAccountingOverlap(MessageHistoryCoverageReport report) {
  final chatDbTotal = report.chatDbTotalCount;
  final visibleCount = report.workingDbVisibleCount;
  final recoveredCount = report.workingDbRecoveredCount;
  final missingCount = report.missingCount;

  if (chatDbTotal == null || visibleCount == null || recoveredCount == null) {
    return false;
  }

  return visibleCount + recoveredCount > chatDbTotal && missingCount == 0;
}

String _formatCount(int? value) {
  if (value == null) {
    return 'Unknown';
  }

  return NumberFormat.decimalPattern().format(value);
}

String _formatDate(DateTime? value) {
  if (value == null) {
    return 'Unknown';
  }

  return DateFormat('MMM d, y').format(value.toLocal());
}

String? _formatDateTime(DateTime? value) {
  if (value == null) {
    return null;
  }

  return DateFormat('MMM d, y h:mm a').format(value.toLocal());
}
