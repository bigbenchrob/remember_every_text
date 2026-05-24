import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/theme/colors/theme_colors_annotated.dart';
import '../../../config/theme/theme_typography.dart';
import '../../../features/chats/application/chat_read_model_source_provider.dart';
import '../../../features/chats/presentation/view_model/chats_view_model_provider.dart';
import '../../../features/chats/presentation/view_model/recent_chats_provider.dart';
import '../../conversation_graph/application/chat_summaries/chat_summary.dart';
import '../../conversation_graph/application/chat_summaries/chat_summary_provider.dart';
import '../../conversation_graph/application/conversation_graph_build_service_provider.dart';
import '../../conversation_graph/application/health/graph_health_provider.dart';
import '../../conversation_graph/application/health/graph_health_report.dart';
import '../application/messages/status/incremental_update_status_provider.dart';
import '../application/messages/status/recent_chats_comparison_provider.dart';
import '../application/messages/status/source_scoped_proof_log_writer.dart';

enum _StatusSheetTab { status, graphHealth, groupProfiles, messages }

class IncrementalUpdateStatusSheet extends ConsumerStatefulWidget {
  const IncrementalUpdateStatusSheet({super.key});

  @override
  ConsumerState<IncrementalUpdateStatusSheet> createState() =>
      _IncrementalUpdateStatusSheetState();
}

class _IncrementalUpdateStatusSheetState
    extends ConsumerState<IncrementalUpdateStatusSheet> {
  _StatusSheetTab _selectedTab = _StatusSheetTab.status;
  ChatSummaryFilter _summaryFilter = ChatSummaryFilter.all;
  ChatSummarySort _summarySort = ChatSummarySort.mostRecentMessage;
  int? _selectedChatSsId;
  int? _selectedMessageSsId;

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(incrementalUpdateStatusProvider);
    final recentChatsComparisonAsync = ref.watch(
      recentChatsComparisonProvider(),
    );
    final graphHealthAsync = ref.watch(graphHealthReportProvider);
    final summariesAsync = ref.watch(chatSummariesProvider);
    final summaryCountsAsync = ref.watch(chatSummarySanityCountsProvider);
    final selectedMessagesAsync = _selectedChatSsId == null
        ? const AsyncValue<List<RecentChatMessage>>.data([])
        : ref.watch(recentChatMessagesProvider(_selectedChatSsId!));
    final selectedTextMessagesAsync = _selectedChatSsId == null
        ? const AsyncValue<List<RecentChatMessage>>.data([])
        : ref.watch(recentTextChatMessagesProvider(_selectedChatSsId!));
    final selectedTextStatsAsync = _selectedChatSsId == null
        ? const AsyncValue<ChatMessageTextStats>.data(
            ChatMessageTextStats(
              totalMessageCount: 0,
              textMessageCount: 0,
              noTextMessageCount: 0,
            ),
          )
        : ref.watch(chatMessageTextStatsProvider(_selectedChatSsId!));
    final selectedAttachmentStatsAsync = _selectedChatSsId == null
        ? const AsyncValue<ChatAttachmentStats>.data(
            ChatAttachmentStats(
              messageWithAttachmentCount: 0,
              attachmentCount: 0,
              imageAttachmentCount: 0,
              videoAttachmentCount: 0,
              documentAttachmentCount: 0,
              sourcePathHintCount: 0,
              localFileAvailableCount: 0,
              localFileMissingCount: 0,
              archiveRecordCount: 0,
              archiveFileAvailableCount: 0,
              archiveFileMissingCount: 0,
            ),
          )
        : ref.watch(chatAttachmentStatsProvider(_selectedChatSsId!));
    final selectedMessageAttachmentsAsync = _selectedMessageSsId == null
        ? const AsyncValue<List<MessageAttachment>>.data([])
        : ref.watch(messageAttachmentsProvider(_selectedMessageSsId!));
    final chatReadModelSource = ref.watch(chatReadModelSourceProvider);

    return MacosSheet(
      child: SizedBox(
        width: 760,
        height: 720,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Source-scoped incremental update',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PushButton(
                    controlSize: ControlSize.regular,
                    secondary: true,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CupertinoSlidingSegmentedControl<_StatusSheetTab>(
                groupValue: _selectedTab,
                children: const {
                  _StatusSheetTab.status: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Status'),
                  ),
                  _StatusSheetTab.graphHealth: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Graph health'),
                  ),
                  _StatusSheetTab.groupProfiles: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Group profiles'),
                  ),
                  _StatusSheetTab.messages: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Messages'),
                  ),
                },
                onValueChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTab = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              statusAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CupertinoActivityIndicator()),
                ),
                error: (error, stackTrace) => _StatusError(error: error),
                data: (status) => Expanded(
                  child: _StatusTabView(
                    selectedTab: _selectedTab,
                    status: status,
                    summariesAsync: summariesAsync,
                    summaryCountsAsync: summaryCountsAsync,
                    selectedMessagesAsync: selectedMessagesAsync,
                    selectedTextMessagesAsync: selectedTextMessagesAsync,
                    selectedTextStatsAsync: selectedTextStatsAsync,
                    selectedAttachmentStatsAsync: selectedAttachmentStatsAsync,
                    selectedMessageAttachmentsAsync:
                        selectedMessageAttachmentsAsync,
                    graphHealthAsync: graphHealthAsync,
                    recentChatsComparisonAsync: recentChatsComparisonAsync,
                    summaryFilter: _summaryFilter,
                    summarySort: _summarySort,
                    selectedChatSsId: _selectedChatSsId,
                    selectedMessageSsId: _selectedMessageSsId,
                    onSummaryFilterChanged: (value) {
                      setState(() {
                        _summaryFilter = value;
                        _selectedChatSsId = null;
                        _selectedMessageSsId = null;
                      });
                    },
                    onSummarySortChanged: (value) {
                      setState(() {
                        _summarySort = value;
                      });
                    },
                    onChatSelected: (chatSsId) {
                      setState(() {
                        _selectedChatSsId = chatSsId;
                        _selectedMessageSsId = null;
                        _selectedTab = _StatusSheetTab.messages;
                      });
                    },
                    onMessageSelected: (messageSsId) {
                      setState(() {
                        _selectedMessageSsId = messageSsId;
                      });
                    },
                    onChatOpened: (chatSsId) {
                      unawaited(
                        ref
                            .read(chatsViewModelProvider.notifier)
                            .selectChat(chatSsId),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _StatusControls(
                ref: ref,
                chatReadModelSource: chatReadModelSource,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusTabView extends StatelessWidget {
  const _StatusTabView({
    required this.selectedTab,
    required this.status,
    required this.summariesAsync,
    required this.summaryCountsAsync,
    required this.selectedMessagesAsync,
    required this.selectedTextMessagesAsync,
    required this.selectedTextStatsAsync,
    required this.selectedAttachmentStatsAsync,
    required this.selectedMessageAttachmentsAsync,
    required this.graphHealthAsync,
    required this.recentChatsComparisonAsync,
    required this.summaryFilter,
    required this.summarySort,
    required this.selectedChatSsId,
    required this.selectedMessageSsId,
    required this.onSummaryFilterChanged,
    required this.onSummarySortChanged,
    required this.onChatSelected,
    required this.onMessageSelected,
    required this.onChatOpened,
  });

  final _StatusSheetTab selectedTab;
  final IncrementalUpdateStatus status;
  final AsyncValue<List<ChatSummary>> summariesAsync;
  final AsyncValue<ChatSummarySanityCounts> summaryCountsAsync;
  final AsyncValue<List<RecentChatMessage>> selectedMessagesAsync;
  final AsyncValue<List<RecentChatMessage>> selectedTextMessagesAsync;
  final AsyncValue<ChatMessageTextStats> selectedTextStatsAsync;
  final AsyncValue<ChatAttachmentStats> selectedAttachmentStatsAsync;
  final AsyncValue<List<MessageAttachment>> selectedMessageAttachmentsAsync;
  final AsyncValue<GraphHealthReport> graphHealthAsync;
  final AsyncValue<RecentChatsComparison> recentChatsComparisonAsync;
  final ChatSummaryFilter summaryFilter;
  final ChatSummarySort summarySort;
  final int? selectedChatSsId;
  final int? selectedMessageSsId;
  final ValueChanged<ChatSummaryFilter> onSummaryFilterChanged;
  final ValueChanged<ChatSummarySort> onSummarySortChanged;
  final ValueChanged<int> onChatSelected;
  final ValueChanged<int> onMessageSelected;
  final ValueChanged<int> onChatOpened;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: switch (selectedTab) {
        _StatusSheetTab.status => _StatusContent(
          status: status,
          recentChatsComparisonAsync: recentChatsComparisonAsync,
        ),
        _StatusSheetTab.graphHealth => _GraphHealthSection(
          graphHealthAsync: graphHealthAsync,
        ),
        _StatusSheetTab.groupProfiles => _ChatSummarySection(
          summariesAsync: summariesAsync,
          summaryCountsAsync: summaryCountsAsync,
          summaryFilter: summaryFilter,
          summarySort: summarySort,
          selectedChatSsId: selectedChatSsId,
          onSummaryFilterChanged: onSummaryFilterChanged,
          onSummarySortChanged: onSummarySortChanged,
          onChatSelected: onChatSelected,
          onChatOpened: onChatOpened,
        ),
        _StatusSheetTab.messages => _MessagesSection(
          summariesAsync: summariesAsync,
          selectedChatSsId: selectedChatSsId,
          selectedMessagesAsync: selectedMessagesAsync,
          selectedTextMessagesAsync: selectedTextMessagesAsync,
          selectedTextStatsAsync: selectedTextStatsAsync,
          selectedAttachmentStatsAsync: selectedAttachmentStatsAsync,
          selectedMessageAttachmentsAsync: selectedMessageAttachmentsAsync,
          selectedMessageSsId: selectedMessageSsId,
          onMessageSelected: onMessageSelected,
        ),
      },
    );
  }
}

class _StatusContent extends ConsumerWidget {
  const _StatusContent({
    required this.status,
    required this.recentChatsComparisonAsync,
  });

  final IncrementalUpdateStatus status;
  final AsyncValue<RecentChatsComparison> recentChatsComparisonAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ProofScopeCard(status: status, colors: colors),
        const SizedBox(height: 12),
        _PipelineDashboard(status: status, colors: colors),
        const SizedBox(height: 12),
        _StatusSection(
          title: 'Diagnostics',
          rows: [
            _StatusRow('Message cursor', status.cursorState),
            _StatusRow('rowIdDelta', '${status.rowIdDelta}'),
            _StatusRow('messageCountDelta', '${status.messageCountDelta}'),
            _StatusRow(
              'duplicate chat/message edges',
              '${status.duplicateWorkingTopologyEdgeCount}',
            ),
            _StatusRow(
              'duplicate chat/handle edges',
              '${status.duplicateWorkingChatToHandleEdgeCount}',
            ),
            _StatusRow(
              'duplicate message/attachment edges',
              '${status.duplicateWorkingMessageToAttachmentEdgeCount}',
            ),
          ],
        ),
        const SizedBox(height: 12),
        _RecentChatsComparisonSection(
          comparisonAsync: recentChatsComparisonAsync,
        ),
      ],
    );
  }
}

class _GraphHealthSection extends StatelessWidget {
  const _GraphHealthSection({required this.graphHealthAsync});

  final AsyncValue<GraphHealthReport> graphHealthAsync;

  @override
  Widget build(BuildContext context) {
    return graphHealthAsync.when(
      loading: () => const _StatusSection(
        title: 'Graph health',
        rows: [_StatusRow('report', 'loading')],
      ),
      error: (error, stackTrace) => _StatusSection(
        title: 'Graph health',
        rows: [_StatusRow('report error', error.toString())],
      ),
      data: (report) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusSection(
            title: 'Graph health summary',
            rows: [
              _StatusRow(
                'source rows without topology',
                '${report.sourceRowsWithoutTopologyCount}',
                labelWidth: 230,
              ),
              _StatusRow(
                'semantic coverage gaps',
                '${report.semanticCoverageIssueCount}',
                labelWidth: 230,
              ),
              _StatusRow(
                'missing endpoint issues',
                '${report.missingEndpointIssueCount}',
                labelWidth: 230,
              ),
              const _StatusRow(
                'interpretation',
                'endpoint issues indicate graph corruption; source rows '
                    'without topology usually reflect deleted/stale source rows',
                labelWidth: 230,
              ),
            ],
          ),
          _StatusSection(
            title: 'Working graph rows',
            rows: [
              _StatusRow('messages', '${report.messageCount}'),
              _StatusRow('chats', '${report.chatCount}'),
              _StatusRow('handles', '${report.handleCount}'),
              _StatusRow('canonical handles', '${report.canonicalHandleCount}'),
              _StatusRow('handle aliases', '${report.handleAliasCount}'),
              _StatusRow('contacts', '${report.contactCount}'),
              _StatusRow('attachments', '${report.attachmentCount}'),
            ],
          ),
          _StatusSection(
            title: 'Attachment archive readiness',
            rows: [
              _StatusRow('archive records', '${report.archiveRecordCount}'),
              _StatusRow(
                'attachments with archive record',
                '${report.attachmentsWithArchiveRecordCount}',
                labelWidth: 250,
              ),
              _StatusRow(
                'attachments missing archive record',
                '${report.attachmentsMissingArchiveRecordCount}',
                labelWidth: 250,
              ),
              _StatusRow(
                'archive files available',
                '${report.archiveFilesAvailableCount}',
                labelWidth: 250,
              ),
              _StatusRow(
                'archive files missing',
                '${report.archiveFilesMissingCount}',
                labelWidth: 250,
              ),
              _StatusRow(
                'archive records without working attachment',
                '${report.archiveRecordsWithoutWorkingAttachmentCount}',
                labelWidth: 250,
              ),
            ],
          ),
          _StatusSection(
            title: 'Attachment recovery source audit',
            rows: [
              _StatusRow(
                'historical MessageLens archive',
                report.historicalArchiveAvailable ? 'available' : 'not found',
                labelWidth: 260,
              ),
              _StatusRow(
                'historical archive records',
                '${report.historicalArchiveRecordCount}',
                labelWidth: 260,
              ),
              _StatusRow(
                'historical archive files available',
                '${report.historicalArchiveFilesAvailableCount}',
                labelWidth: 260,
              ),
              _StatusRow(
                'historical archive files missing',
                '${report.historicalArchiveFilesMissingCount}',
                labelWidth: 260,
              ),
              _StatusRow(
                'recoverable from historical archive',
                '${report.attachmentsRecoverableFromHistoricalArchiveCount}',
                labelWidth: 260,
              ),
              _StatusRow(
                'recovered Messages source',
                report.recoveredMessagesSourceAvailable
                    ? 'available'
                    : 'not found',
                labelWidth: 260,
              ),
              _StatusRow(
                'recovered Messages attachment links',
                '${report.recoveredMessagesAttachmentKeyCount}',
                labelWidth: 260,
              ),
              _StatusRow(
                'recoverable from recovered Messages',
                '${report.attachmentsRecoverableFromRecoveredMessagesCount}',
                labelWidth: 260,
              ),
              _StatusRow(
                'recoverable from both sources',
                '${report.attachmentsRecoverableFromBothRecoverySourcesCount}',
                labelWidth: 260,
              ),
              _StatusRow(
                'not found in known recovery sources',
                '${report.attachmentsStillMissingFromKnownRecoverySourcesCount}',
                labelWidth: 260,
              ),
            ],
          ),
          _StatusSection(
            title: 'Archive rehydrate dry run',
            rows: [
              _StatusRow(
                'already available in current archive',
                '${report.dryRunAlreadyAvailableInCurrentArchiveCount}',
                labelWidth: 270,
              ),
              _StatusRow(
                'would copy from historical archive',
                '${report.dryRunWouldCopyFromHistoricalArchiveCount}',
                labelWidth: 270,
              ),
              _StatusRow(
                'would copy from recovered Messages',
                '${report.dryRunWouldCopyFromRecoveredMessagesCount}',
                labelWidth: 270,
              ),
              _StatusRow(
                'would archive from current source path',
                '${report.dryRunWouldArchiveFromCurrentSourcePathCount}',
                labelWidth: 270,
              ),
              _StatusRow(
                'still missing after all sources',
                '${report.dryRunStillMissingEverywhereCount}',
                labelWidth: 270,
              ),
              _StatusRow(
                'still-missing plugin payload candidates',
                '${report.dryRunStillMissingPluginPayloadCandidateCount}',
                labelWidth: 270,
              ),
            ],
          ),
          if (report.missingAttachmentSamples.isNotEmpty)
            _MissingAttachmentSampleSection(
              samples: report.missingAttachmentSamples,
            ),
          _StatusSection(
            title: 'Working graph edges',
            rows: [
              _StatusRow('chat -> message', '${report.chatToMessageEdgeCount}'),
              _StatusRow('chat -> handle', '${report.chatToHandleEdgeCount}'),
              _StatusRow(
                'message -> attachment',
                '${report.messageToAttachmentEdgeCount}',
              ),
              _StatusRow(
                'contact -> handle',
                '${report.contactToHandleEdgeCount}',
              ),
            ],
          ),
          _StatusSection(
            title: 'Source-retained rows without current topology',
            rows: [
              _StatusRow(
                'messages without conversation edge',
                '${report.orphanMessageCount}',
                labelWidth: 250,
              ),
              _StatusRow(
                'chats without message edge',
                '${report.chatsWithZeroMessagesCount}',
                labelWidth: 250,
              ),
              _StatusRow(
                'attachments without message edge',
                '${report.attachmentsWithoutMessageEdgeCount}',
                labelWidth: 250,
              ),
            ],
          ),
          _StatusSection(
            title: 'Semantic coverage',
            rows: [
              _StatusRow(
                'chats with zero handles',
                '${report.chatsWithZeroHandlesCount}',
              ),
              _StatusRow(
                'messages missing sender canonical handle',
                '${report.messagesMissingSenderCanonicalHandleCount}',
                labelWidth: 260,
              ),
              _StatusRow(
                'handles without canonical alias',
                '${report.handlesWithoutCanonicalAliasCount}',
                labelWidth: 260,
              ),
              _StatusRow(
                'contacts without handles',
                '${report.contactsWithoutHandlesCount}',
              ),
            ],
          ),
          _StatusSection(
            title: 'Endpoint integrity',
            rows: [
              _StatusRow(
                'chat/message edges missing chat',
                '${report.chatToMessageEdgesMissingChatCount}',
                labelWidth: 250,
              ),
              _StatusRow(
                'chat/message edges missing message',
                '${report.chatToMessageEdgesMissingMessageCount}',
                labelWidth: 250,
              ),
              _StatusRow(
                'chat/handle edges missing chat',
                '${report.chatToHandleEdgesMissingChatCount}',
                labelWidth: 250,
              ),
              _StatusRow(
                'chat/handle edges missing handle',
                '${report.chatToHandleEdgesMissingHandleCount}',
                labelWidth: 250,
              ),
              _StatusRow(
                'message/attachment edges missing message',
                '${report.messageToAttachmentEdgesMissingMessageCount}',
                labelWidth: 250,
              ),
              _StatusRow(
                'message/attachment edges missing attachment',
                '${report.messageToAttachmentEdgesMissingAttachmentCount}',
                labelWidth: 250,
              ),
              _StatusRow(
                'contact/handle edges missing contact',
                '${report.contactToHandleEdgesMissingContactCount}',
                labelWidth: 250,
              ),
              _StatusRow(
                'contact/handle edges missing handle',
                '${report.contactToHandleEdgesMissingHandleCount}',
                labelWidth: 250,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MissingAttachmentSampleSection extends StatelessWidget {
  const _MissingAttachmentSampleSection({required this.samples});

  final List<MissingAttachmentRecoverySample> samples;

  @override
  Widget build(BuildContext context) {
    return _StatusSection(
      title: 'Missing attachment sample',
      rows: [
        const _StatusRow(
          'sample meaning',
          'These are the first 20 attachments not found in the current archive, '
              'historical archive, or recovered Messages folder.',
          labelWidth: 150,
        ),
        for (final sample in samples)
          _MissingAttachmentSampleCard(sample: sample),
      ],
    );
  }
}

class _MissingAttachmentSampleCard extends ConsumerWidget {
  const _MissingAttachmentSampleCard({required this.sample});

  final MissingAttachmentRecoverySample sample;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.graySix.withValues(alpha: 0.30),
        border: Border.all(color: colors.grayFive.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'attachment ${sample.attachmentSsId}',
            style: typography.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _AuditBadge(
                label: sample.currentSourcePathExists
                    ? 'current file exists'
                    : 'current file missing',
                isPositive: sample.currentSourcePathExists,
              ),
              _AuditBadge(
                label: sample.historicalArchiveKeyExists
                    ? 'archive key found'
                    : 'archive key missing',
                isPositive: sample.historicalArchiveKeyExists,
              ),
              _AuditBadge(
                label: sample.recoveredMessagesKeyExists
                    ? 'recovered key found'
                    : 'recovered key missing',
                isPositive: sample.recoveredMessagesKeyExists,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _AttachmentSampleDetail(
            label: 'likely meaning',
            value: _missingAttachmentLikelyMeaning(sample),
          ),
          _AttachmentSampleDetail(
            label: 'source rowid',
            value: '${sample.importAttachmentId}',
          ),
          _AttachmentSampleDetail(
            label: 'type',
            value: sample.mimeType ?? sample.uti ?? 'unknown type',
          ),
          _AttachmentSampleDetail(
            label: 'message guid',
            value: sample.messageGuid,
            monospace: true,
          ),
          _AttachmentSampleDetail(
            label: 'source path',
            value: sample.filename ?? 'no filename',
            monospace: true,
          ),
          _AttachmentSampleDetail(
            label: 'recovered path tried',
            value: sample.attemptedRecoveredPath ?? 'no recovered path',
            monospace: true,
          ),
        ],
      ),
    );
  }

  String _missingAttachmentLikelyMeaning(
    MissingAttachmentRecoverySample sample,
  ) {
    if (sample.currentSourcePathExists) {
      return 'The source file exists now, so this may be recoverable from the '
          'live Messages attachment path even though it is not archived yet.';
    }
    if (sample.historicalArchiveKeyExists) {
      return 'An archive record exists but the archive file was not available; '
          'this points to an archive file integrity problem.';
    }
    if (sample.recoveredMessagesKeyExists) {
      return 'The recovered Messages database has the relationship, but the '
          'file path check failed; this suggests path normalization needs work.';
    }
    return 'No matching archive or recovered Messages key was found. This may '
        'be a true source gap, or the matching key differs across sources.';
  }
}

class _AuditBadge extends ConsumerWidget {
  const _AuditBadge({required this.label, required this.isPositive});

  final String label;
  final bool isPositive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final color = isPositive
        ? colors.brandHighlight(BrandHighlight.primary)
        : colors.grayFour;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: typography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AttachmentSampleDetail extends ConsumerWidget {
  const _AttachmentSampleDetail({
    required this.label,
    required this.value,
    this.monospace = false,
  });

  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final displayValue = monospace ? _middleTruncate(value, 110) : value;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: TextStyle(
                color: colors.grayThree,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Tooltip(
              message: value,
              waitDuration: const Duration(milliseconds: 450),
              child: SelectableText(
                displayValue,
                maxLines: monospace ? 2 : 4,
                style: TextStyle(
                  color: colors.grayTwo,
                  fontSize: 12,
                  fontFamily: monospace ? 'Menlo' : null,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _middleTruncate(String value, int maxLength) {
    if (value.length <= maxLength) {
      return value;
    }
    final keep = maxLength - 3;
    final head = (keep * 0.58).floor();
    final tail = keep - head;
    return '${value.substring(0, head)}...${value.substring(value.length - tail)}';
  }
}

class _ProofScopeCard extends StatelessWidget {
  const _ProofScopeCard({required this.status, required this.colors});

  final IncrementalUpdateStatus status;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.graySix.withValues(alpha: 0.38),
        border: Border.all(color: colors.grayFive.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: _ScopeValue(
                label: 'Mode',
                value: 'manual import + project',
                colors: colors,
              ),
            ),
            Expanded(
              child: _ScopeValue(
                label: 'Source',
                value: 'live-chat-db (${status.sourceId})',
                colors: colors,
              ),
            ),
            Expanded(
              child: _ScopeValue(
                label: 'Import DB',
                value: status.importDatabaseName,
                colors: colors,
              ),
            ),
            Expanded(
              child: _ScopeValue(
                label: 'Working DB',
                value: status.workingDatabaseName,
                colors: colors,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScopeValue extends StatelessWidget {
  const _ScopeValue({
    required this.label,
    required this.value,
    required this.colors,
  });

  final String label;
  final String value;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.grayFour,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.grayOne, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PipelineDashboard extends StatelessWidget {
  const _PipelineDashboard({required this.status, required this.colors});

  final IncrementalUpdateStatus status;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final sourceToImport = <_PipelineMetric>[
      _PipelineMetric(
        label: 'Messages',
        current: status.ledgerMessageCount,
        total: status.sourceMessageCount,
        detail: 'last row ${status.ledgerMaxSourceRowId}',
      ),
      _PipelineMetric(
        label: 'Chats',
        current: status.importChatCount,
        total: status.sourceChatCount,
      ),
      _PipelineMetric(
        label: 'Handles',
        current: status.importHandleCount,
        total: status.sourceHandleCount,
      ),
      _PipelineMetric(
        label: 'Attachments',
        current: status.importAttachmentCount,
        total: status.sourceAttachmentCount,
        detail: 'source paths are hints',
      ),
    ];
    final importToWorking = <_PipelineMetric>[
      _PipelineMetric(
        label: 'Messages',
        current: status.workingMessageCount,
        total: status.ledgerMessageCount,
      ),
      _PipelineMetric(
        label: 'Chats',
        current: status.workingChatCount,
        total: status.importChatCount,
      ),
      _PipelineMetric(
        label: 'Handles',
        current: status.workingHandleCount,
        total: status.importHandleCount,
      ),
      _PipelineMetric(
        label: 'Attachments',
        current: status.workingAttachmentCount,
        total: status.importAttachmentCount,
      ),
    ];
    final topology = <_PipelineMetric>[
      _PipelineMetric(
        label: 'Chat -> message',
        current: status.workingTopologyEdgeCount,
        total: status.importTopologyEdgeCount,
      ),
      _PipelineMetric(
        label: 'Chat -> handle',
        current: status.workingChatToHandleEdgeCount,
        total: status.importChatToHandleEdgeCount,
      ),
      _PipelineMetric(
        label: 'Message -> attachment',
        current: status.workingMessageToAttachmentEdgeCount,
        total: status.importMessageToAttachmentEdgeCount,
      ),
      _PipelineMetric(
        label: 'Text enrichment',
        current:
            status.ledgerMessageCount - status.ledgerMessagesNeedingEnrichment,
        total: status.ledgerMessageCount,
        detail: '${status.ledgerMessagesStillWithoutText} still no text',
      ),
    ];

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _PipelineStageCard(
                title: 'Source -> import_ss',
                subtitle: 'source facts + provenance',
                metrics: sourceToImport,
                colors: colors,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PipelineStageCard(
                title: 'import_ss -> working_ss',
                subtitle: 'canonical graph rows',
                metrics: importToWorking,
                colors: colors,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _PipelineStageCard(
          title: 'Graph topology + enrichment',
          subtitle: 'canonical ss_id edges and usable message text',
          metrics: topology,
          colors: colors,
        ),
      ],
    );
  }
}

class _PipelineMetric {
  const _PipelineMetric({
    required this.label,
    required this.current,
    required this.total,
    this.detail,
  });

  final String label;
  final int current;
  final int total;
  final String? detail;

  double get progress {
    if (total <= 0) {
      return current > 0 ? 1 : 0;
    }
    final value = current / total;
    if (value < 0) {
      return 0;
    }
    if (value > 1) {
      return 1;
    }
    return value;
  }

  String get countText => '$current / $total';
}

class _PipelineStageCard extends StatelessWidget {
  const _PipelineStageCard({
    required this.title,
    required this.subtitle,
    required this.metrics,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final List<_PipelineMetric> metrics;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.graySix.withValues(alpha: 0.24),
        border: Border.all(color: colors.grayFive.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: colors.grayOne,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(color: colors.grayFour, fontSize: 11),
            ),
            const SizedBox(height: 12),
            for (final metric in metrics) ...[
              _MetricProgressRow(metric: metric, colors: colors),
              if (metric != metrics.last) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricProgressRow extends StatelessWidget {
  const _MetricProgressRow({required this.metric, required this.colors});

  final _PipelineMetric metric;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final isComplete = metric.total > 0 && metric.current >= metric.total;
    final accent = isComplete
        ? colors.brandHighlight(BrandHighlight.primary)
        : colors.brandHighlight(BrandHighlight.secondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                metric.label,
                style: TextStyle(
                  color: colors.grayTwo,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              metric.countText,
              style: TextStyle(
                color: colors.grayThree,
                fontSize: 11,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: metric.progress,
            minHeight: 7,
            color: accent,
            backgroundColor: colors.grayFive.withValues(alpha: 0.28),
          ),
        ),
        if (metric.detail case final String detail) ...[
          const SizedBox(height: 4),
          Text(detail, style: TextStyle(color: colors.grayFour, fontSize: 10)),
        ],
      ],
    );
  }
}

class _RecentChatsComparisonSection extends StatelessWidget {
  const _RecentChatsComparisonSection({required this.comparisonAsync});

  final AsyncValue<RecentChatsComparison> comparisonAsync;

  @override
  Widget build(BuildContext context) {
    return comparisonAsync.when(
      data: (comparison) => _StatusSection(
        title: 'Recent chats comparison',
        rows: [
          _StatusRow('legacy count', '${comparison.legacyCount}'),
          _StatusRow('graph count', '${comparison.graphCount}'),
          const _StatusRow('legacy top rows', 'working.db recentChatsProvider'),
          for (final row in comparison.legacyRows)
            _StatusRow(_rowLabel(row), _rowValue(row), labelWidth: 210),
          const _StatusRow(
            'graph top rows',
            'working_ss.db conversation graph',
          ),
          for (final row in comparison.graphRows)
            _StatusRow(_rowLabel(row), _rowValue(row), labelWidth: 210),
        ],
      ),
      loading: () => const _StatusSection(
        title: 'Recent chats comparison',
        rows: [_StatusRow('comparison', 'loading')],
      ),
      error: (error, stackTrace) => _StatusSection(
        title: 'Recent chats comparison',
        rows: [_StatusRow('comparison error', error.toString())],
      ),
    );
  }

  String _rowLabel(RecentChatsComparisonRow row) {
    return '${row.chatId}';
  }

  String _rowValue(RecentChatsComparisonRow row) {
    final groupText = row.isGroup ? 'group' : 'single';
    final dateText = row.lastMessageDate?.toIso8601String() ?? 'no date';
    return '$groupText | participants=${row.participantCount} | '
        'messages=${row.messageCount} | $dateText | ${row.title}';
  }
}

class _ChatSummarySection extends StatelessWidget {
  const _ChatSummarySection({
    required this.summariesAsync,
    required this.summaryCountsAsync,
    required this.summaryFilter,
    required this.summarySort,
    required this.selectedChatSsId,
    required this.onSummaryFilterChanged,
    required this.onSummarySortChanged,
    required this.onChatSelected,
    required this.onChatOpened,
  });

  final AsyncValue<List<ChatSummary>> summariesAsync;
  final AsyncValue<ChatSummarySanityCounts> summaryCountsAsync;
  final ChatSummaryFilter summaryFilter;
  final ChatSummarySort summarySort;
  final int? selectedChatSsId;
  final ValueChanged<ChatSummaryFilter> onSummaryFilterChanged;
  final ValueChanged<ChatSummarySort> onSummarySortChanged;
  final ValueChanged<int> onChatSelected;
  final ValueChanged<int> onChatOpened;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryControls(
          filter: summaryFilter,
          sort: summarySort,
          onFilterChanged: onSummaryFilterChanged,
          onSortChanged: onSummarySortChanged,
        ),
        const SizedBox(height: 12),
        _StatusSection(
          title: 'Topology diagnostics',
          rows: [
            ...summaryCountsAsync.maybeWhen(
              data: (counts) => [
                _StatusRow('group chats', '${counts.groupChatCount}'),
                _StatusRow(
                  'single-participant chats',
                  '${counts.singleParticipantChatCount}',
                ),
                _StatusRow('orphan chats', '${counts.orphanChatCount}'),
                _StatusRow(
                  'chats with zero handles',
                  '${counts.zeroHandleChatCount}',
                ),
                _StatusRow(
                  'chats with zero messages',
                  '${counts.zeroMessageChatCount}',
                ),
                _StatusRow(
                  'largest participant count',
                  '${counts.largestParticipantCount}',
                ),
                _StatusRow(
                  'largest message count',
                  '${counts.largestMessageCount}',
                ),
              ],
              orElse: () => [const _StatusRow('summary counts', 'loading')],
            ),
          ],
        ),
        summariesAsync.maybeWhen(
          data: (summaries) {
            final visibleSummaries = _visibleSummaries(summaries);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusSection(
                  title: 'Chat summaries',
                  rows: [
                    const _StatusRow(
                      'visible chats',
                      'select a row to inspect recent messages',
                    ),
                    for (final summary in visibleSummaries)
                      _ChatSummaryRow(
                        summary: summary,
                        isSelected: summary.chatSsId == selectedChatSsId,
                        onSelected: () => onChatSelected(summary.chatSsId),
                        onOpened: () => onChatOpened(summary.chatSsId),
                      ),
                  ],
                ),
              ],
            );
          },
          orElse: () => const _StatusSection(
            title: 'Chat summaries',
            rows: [_StatusRow('summaries', 'loading')],
          ),
        ),
      ],
    );
  }

  List<ChatSummary> _visibleSummaries(List<ChatSummary> summaries) {
    final filtered = switch (summaryFilter) {
      ChatSummaryFilter.all => summaries.toList(),
      ChatSummaryFilter.groupOnly =>
        summaries.where((summary) => summary.isGroup).toList(),
      ChatSummaryFilter.singleParticipantOnly =>
        summaries.where((summary) => summary.participantCount == 1).toList(),
    };
    filtered.sort((left, right) {
      final comparison = switch (summarySort) {
        ChatSummarySort.mostRecentMessage =>
          (right.lastMessageAtUtc ?? '').compareTo(left.lastMessageAtUtc ?? ''),
        ChatSummarySort.largestMessageCount => right.messageCount.compareTo(
          left.messageCount,
        ),
        ChatSummarySort.largestParticipantCount =>
          right.participantCount.compareTo(left.participantCount),
      };
      if (comparison != 0) {
        return comparison;
      }
      return left.chatSsId.compareTo(right.chatSsId);
    });
    return filtered;
  }
}

class _MessagesSection extends StatelessWidget {
  const _MessagesSection({
    required this.summariesAsync,
    required this.selectedChatSsId,
    required this.selectedMessagesAsync,
    required this.selectedTextMessagesAsync,
    required this.selectedTextStatsAsync,
    required this.selectedAttachmentStatsAsync,
    required this.selectedMessageAttachmentsAsync,
    required this.selectedMessageSsId,
    required this.onMessageSelected,
  });

  final AsyncValue<List<ChatSummary>> summariesAsync;
  final int? selectedChatSsId;
  final AsyncValue<List<RecentChatMessage>> selectedMessagesAsync;
  final AsyncValue<List<RecentChatMessage>> selectedTextMessagesAsync;
  final AsyncValue<ChatMessageTextStats> selectedTextStatsAsync;
  final AsyncValue<ChatAttachmentStats> selectedAttachmentStatsAsync;
  final AsyncValue<List<MessageAttachment>> selectedMessageAttachmentsAsync;
  final int? selectedMessageSsId;
  final ValueChanged<int> onMessageSelected;

  @override
  Widget build(BuildContext context) {
    final chatSsId = selectedChatSsId;
    if (chatSsId == null) {
      return const _StatusSection(
        title: 'Selected chat messages',
        rows: [
          _StatusRow(
            'selection',
            'select a chat from Group profiles to inspect recent messages',
          ),
        ],
      );
    }

    return summariesAsync.maybeWhen(
      data: (summaries) {
        final summary = _summaryForChat(summaries, chatSsId);
        if (summary == null) {
          return _StatusSection(
            title: 'Selected chat messages',
            rows: [
              _StatusRow('chat_ss_id', '$chatSsId'),
              const _StatusRow('messages', 'selected chat not found'),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SelectedChatMetadataSection(
              summary: summary,
              textStatsAsync: selectedTextStatsAsync,
              attachmentStatsAsync: selectedAttachmentStatsAsync,
            ),
            _SelectedChatSection(
              title: 'Latest rows',
              messagesAsync: selectedMessagesAsync,
              selectedMessageSsId: selectedMessageSsId,
              onMessageSelected: onMessageSelected,
            ),
            _SelectedMessageAttachmentSection(
              selectedMessageSsId: selectedMessageSsId,
              attachmentsAsync: selectedMessageAttachmentsAsync,
            ),
            _SelectedChatSection(
              title: 'Latest text-bearing messages',
              messagesAsync: selectedTextMessagesAsync,
              selectedMessageSsId: selectedMessageSsId,
              onMessageSelected: onMessageSelected,
            ),
          ],
        );
      },
      orElse: () => const _StatusSection(
        title: 'Selected chat messages',
        rows: [_StatusRow('messages', 'loading')],
      ),
    );
  }

  ChatSummary? _summaryForChat(List<ChatSummary> summaries, int chatSsId) {
    for (final summary in summaries) {
      if (summary.chatSsId == chatSsId) {
        return summary;
      }
    }
    return null;
  }
}

class _SummaryControls extends StatelessWidget {
  const _SummaryControls({
    required this.filter,
    required this.sort,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  final ChatSummaryFilter filter;
  final ChatSummarySort sort;
  final ValueChanged<ChatSummaryFilter> onFilterChanged;
  final ValueChanged<ChatSummarySort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoSlidingSegmentedControl<ChatSummaryFilter>(
          groupValue: filter,
          children: const {
            ChatSummaryFilter.all: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('All chats'),
            ),
            ChatSummaryFilter.groupOnly: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Groups'),
            ),
            ChatSummaryFilter.singleParticipantOnly: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Single'),
            ),
          },
          onValueChanged: (value) {
            if (value != null) {
              onFilterChanged(value);
            }
          },
        ),
        const SizedBox(height: 8),
        CupertinoSlidingSegmentedControl<ChatSummarySort>(
          groupValue: sort,
          children: const {
            ChatSummarySort.mostRecentMessage: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Recent'),
            ),
            ChatSummarySort.largestMessageCount: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Messages'),
            ),
            ChatSummarySort.largestParticipantCount: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Participants'),
            ),
          },
          onValueChanged: (value) {
            if (value != null) {
              onSortChanged(value);
            }
          },
        ),
      ],
    );
  }
}

class _ChatSummaryRow extends StatelessWidget {
  const _ChatSummaryRow({
    required this.summary,
    required this.isSelected,
    required this.onSelected,
    required this.onOpened,
  });

  final ChatSummary summary;
  final bool isSelected;
  final VoidCallback onSelected;
  final VoidCallback onOpened;

  @override
  Widget build(BuildContext context) {
    final participantText = summary.participantHandles.isEmpty
        ? 'chat ${summary.chatSsId}'
        : summary.participantHandles.join('  |  ');
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected
            ? CupertinoColors.activeBlue.withValues(alpha: 0.12)
            : CupertinoColors.transparent,
        border: Border.all(
          color: isSelected
              ? CupertinoColors.activeBlue.withValues(alpha: 0.45)
              : CupertinoColors.separator.withValues(alpha: 0.35),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSelected,
              child: _StatusRow(
                participantText,
                '${summary.messageCount} messages | '
                '${summary.participantCount} participants | '
                '${summary.isGroup ? 'group' : 'single'} | '
                '${summary.lastMessageAtUtc ?? 'no date'} | '
                '${summary.lastMessageText ?? 'no text'}',
                labelWidth: 300,
                verticalPadding: 0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PushButton(
            controlSize: ControlSize.small,
            secondary: true,
            onPressed: onOpened,
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

class _SelectedChatMetadataSection extends StatelessWidget {
  const _SelectedChatMetadataSection({
    required this.summary,
    required this.textStatsAsync,
    required this.attachmentStatsAsync,
  });

  final ChatSummary summary;
  final AsyncValue<ChatMessageTextStats> textStatsAsync;
  final AsyncValue<ChatAttachmentStats> attachmentStatsAsync;

  @override
  Widget build(BuildContext context) {
    return _StatusSection(
      title: 'Selected chat',
      rows: [
        _StatusRow('chat_ss_id', '${summary.chatSsId}'),
        _StatusRow('participants', summary.participantHandles.join('  |  ')),
        _StatusRow('participant_count', '${summary.participantCount}'),
        _StatusRow('message_count', '${summary.messageCount}'),
        ...textStatsAsync.maybeWhen(
          data: (stats) => [
            _StatusRow('text-bearing messages', '${stats.textMessageCount}'),
            _StatusRow('no-text messages', '${stats.noTextMessageCount}'),
          ],
          orElse: () => [const _StatusRow('text profile', 'loading')],
        ),
        ...attachmentStatsAsync.maybeWhen(
          data: (stats) => [
            _StatusRow(
              'messages with attachments',
              '${stats.messageWithAttachmentCount}',
            ),
            _StatusRow('attachments', '${stats.attachmentCount}'),
            _StatusRow('source path hints', '${stats.sourcePathHintCount}'),
            _StatusRow(
              'local files available',
              '${stats.localFileAvailableCount}',
            ),
            _StatusRow('local files missing', '${stats.localFileMissingCount}'),
            _StatusRow('archive records', '${stats.archiveRecordCount}'),
            _StatusRow(
              'archive files available',
              '${stats.archiveFileAvailableCount}',
            ),
            _StatusRow(
              'archive files missing',
              '${stats.archiveFileMissingCount}',
            ),
            _StatusRow(
              'attachment mix',
              'images=${stats.imageAttachmentCount} | '
                  'videos=${stats.videoAttachmentCount} | '
                  'documents=${stats.documentAttachmentCount}',
            ),
          ],
          orElse: () => [const _StatusRow('attachment profile', 'loading')],
        ),
      ],
    );
  }
}

class _SelectedChatSection extends StatelessWidget {
  const _SelectedChatSection({
    required this.title,
    required this.messagesAsync,
    required this.selectedMessageSsId,
    required this.onMessageSelected,
  });

  final String title;
  final AsyncValue<List<RecentChatMessage>> messagesAsync;
  final int? selectedMessageSsId;
  final ValueChanged<int> onMessageSelected;

  @override
  Widget build(BuildContext context) {
    return _StatusSection(
      title: title,
      rows: [
        ...messagesAsync.maybeWhen(
          data: (messages) => [
            if (messages.isEmpty) const _StatusRow('messages', 'none'),
            for (final message in messages)
              _RecentMessageRow(
                message: message,
                isSelected: message.messageSsId == selectedMessageSsId,
                onSelected: () => onMessageSelected(message.messageSsId),
              ),
          ],
          orElse: () => [const _StatusRow('recent messages', 'loading')],
        ),
      ],
    );
  }
}

class _RecentMessageRow extends StatelessWidget {
  const _RecentMessageRow({
    required this.message,
    required this.isSelected,
    required this.onSelected,
  });

  final RecentChatMessage message;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final text = message.text;
    final attachmentText = message.attachmentCount == 0
        ? ''
        : ' | attachments=${message.attachmentCount}';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelected,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.activeBlue.withValues(alpha: 0.11)
              : CupertinoColors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: _StatusRow(
          '${message.messageSsId}',
          '${message.dateUtc ?? 'no date'} | '
              '${message.isFromMe ? 'from me' : 'received'} | '
              '${text == null || text.isEmpty ? 'no text' : text}'
              '$attachmentText',
          labelWidth: 150,
          verticalPadding: 6,
        ),
      ),
    );
  }
}

class _SelectedMessageAttachmentSection extends StatelessWidget {
  const _SelectedMessageAttachmentSection({
    required this.selectedMessageSsId,
    required this.attachmentsAsync,
  });

  final int? selectedMessageSsId;
  final AsyncValue<List<MessageAttachment>> attachmentsAsync;

  @override
  Widget build(BuildContext context) {
    final messageSsId = selectedMessageSsId;
    if (messageSsId == null) {
      return const _StatusSection(
        title: 'Selected message attachments',
        rows: [_StatusRow('selection', 'click a message row to inspect')],
      );
    }

    return _StatusSection(
      title: 'Selected message attachments',
      rows: [
        _StatusRow('message_ss_id', '$messageSsId'),
        ...attachmentsAsync.maybeWhen(
          data: (attachments) => [
            if (attachments.isEmpty)
              const _StatusRow('attachments', 'none linked'),
            for (final attachment in attachments)
              _AttachmentMetadataRow(attachment: attachment),
          ],
          orElse: () => [const _StatusRow('attachments', 'loading')],
        ),
      ],
    );
  }
}

class _AttachmentMetadataRow extends ConsumerWidget {
  const _AttachmentMetadataRow({required this.attachment});

  final MessageAttachment attachment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final name =
        attachment.transferName ??
        attachment.filename?.split('/').last ??
        attachment.guid ??
        'attachment ${attachment.attachmentSsId}';
    final type = attachment.mimeType ?? attachment.uti ?? 'unknown type';
    final size = attachment.totalBytes == null
        ? 'unknown size'
        : '${attachment.totalBytes} bytes';
    final pathHint = attachment.filename ?? 'no source path hint';
    final availability = attachment.hasSourcePathHint
        ? attachment.localFileExists
              ? 'file exists locally'
              : 'missing locally'
        : 'no source path hint';
    final archiveAvailability = attachment.hasArchiveRecord
        ? attachment.archiveFileExists
              ? 'file exists in archive'
              : 'archive record, file missing'
        : 'no archive record';
    final archivedFilePath = attachment.archiveAbsolutePath;
    final canOpenArchivedFile =
        attachment.archiveFileExists &&
        archivedFilePath != null &&
        archivedFilePath.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.graySix.withValues(alpha: 0.34),
        border: Border.all(color: colors.grayFive.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          SelectableText(
            'ss_id=${attachment.attachmentSsId} | $type | $size',
            style: TextStyle(color: colors.grayThree, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: PushButton(
              controlSize: ControlSize.small,
              secondary: true,
              onPressed: canOpenArchivedFile
                  ? () => _openArchivedFile(archivedFilePath)
                  : null,
              child: Text(
                canOpenArchivedFile
                    ? 'Open archived file'
                    : _disabledArchiveActionLabel(attachment),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _AttachmentDetailRow(
            label: 'source path',
            value: pathHint,
            monospace: attachment.hasSourcePathHint,
          ),
          _AttachmentDetailRow(label: 'source file', value: availability),
          _AttachmentDetailRow(
            label: 'archive file',
            value: archiveAvailability,
          ),
          if (attachment.archiveRelativePath case final archivePath?)
            _AttachmentDetailRow(
              label: 'archive path',
              value: archivePath,
              monospace: true,
            ),
        ],
      ),
    );
  }

  static Future<void> _openArchivedFile(String archivedFilePath) async {
    final uri = Uri.file(archivedFilePath);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static String _disabledArchiveActionLabel(MessageAttachment attachment) {
    if (!attachment.hasArchiveRecord) {
      return 'No archive record';
    }
    return 'Archive file missing';
  }
}

class _AttachmentDetailRow extends ConsumerWidget {
  const _AttachmentDetailRow({
    required this.label,
    required this.value,
    this.monospace = false,
  });

  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final displayValue = monospace ? _middleTruncate(value, 96) : value;
    final textStyle = TextStyle(
      color: colors.grayTwo,
      fontSize: 12,
      fontFamily: monospace ? 'Menlo' : null,
      height: 1.2,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: TextStyle(
                color: colors.grayThree,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Tooltip(
              message: value,
              waitDuration: const Duration(milliseconds: 450),
              child: SelectableText(
                displayValue,
                maxLines: 2,
                style: textStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _middleTruncate(String value, int maxLength) {
    if (value.length <= maxLength) {
      return value;
    }
    final keep = maxLength - 3;
    final head = (keep * 0.58).floor();
    final tail = keep - head;
    return '${value.substring(0, head)}...${value.substring(value.length - tail)}';
  }
}

class _StatusControls extends StatefulWidget {
  const _StatusControls({required this.ref, required this.chatReadModelSource});

  final WidgetRef ref;
  final ChatReadModelSourceMode chatReadModelSource;

  @override
  State<_StatusControls> createState() => _StatusControlsState();
}

class _StatusControlsState extends State<_StatusControls> {
  var _isHoveringImport = false;
  var _isImporting = false;
  Timer? _statusRefreshTimer;

  @override
  void dispose() {
    _statusRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Recent chats',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            CupertinoSlidingSegmentedControl<ChatReadModelSourceMode>(
              groupValue: widget.chatReadModelSource,
              children: const {
                ChatReadModelSourceMode.legacy: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Legacy'),
                ),
                ChatReadModelSourceMode.conversationGraph: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Graph'),
                ),
              },
              onValueChanged: (value) {
                if (value == null) {
                  return;
                }
                widget.ref
                    .read(chatReadModelSourceProvider.notifier)
                    .setMode(value);
                widget.ref.invalidate(recentChatsProvider);
              },
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PushButton(
              controlSize: ControlSize.regular,
              secondary: true,
              onPressed: () {
                widget.ref.invalidate(incrementalUpdateStatusProvider);
                widget.ref.invalidate(graphHealthReportProvider);
              },
              child: const Text('Refresh'),
            ),
            const SizedBox(width: 8),
            MouseRegion(
              onEnter: (_) {
                setState(() {
                  _isHoveringImport = true;
                });
              },
              onExit: (_) {
                setState(() {
                  _isHoveringImport = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: _isHoveringImport || _isImporting
                      ? CupertinoColors.activeBlue.withValues(alpha: 0.14)
                      : CupertinoColors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _isHoveringImport || _isImporting
                        ? CupertinoColors.activeBlue.withValues(alpha: 0.55)
                        : CupertinoColors.transparent,
                  ),
                ),
                child: PushButton(
                  controlSize: ControlSize.regular,
                  onPressed: () {
                    if (_isImporting) {
                      return;
                    }
                    unawaited(_runImport());
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isImporting) ...[
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CupertinoActivityIndicator(radius: 7),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _isImporting
                            ? 'Importing + Projecting...'
                            : 'Import + Project SS Graph',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _runImport() async {
    setState(() {
      _isImporting = true;
    });
    widget.ref.invalidate(incrementalUpdateStatusProvider);
    widget.ref.invalidate(graphHealthReportProvider);
    _statusRefreshTimer?.cancel();
    _statusRefreshTimer = Timer.periodic(const Duration(milliseconds: 750), (
      _,
    ) {
      widget.ref.invalidate(incrementalUpdateStatusProvider);
    });
    try {
      await _importAndProjectOnce(widget.ref);
    } finally {
      _statusRefreshTimer?.cancel();
      _statusRefreshTimer = null;
      widget.ref.invalidate(incrementalUpdateStatusProvider);
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  Future<void> _importAndProjectOnce(WidgetRef ref) async {
    final before = await ref.read(incrementalUpdateStatusProvider.future);
    try {
      final service = await ref.read(
        conversationGraphBuildServiceProvider.future,
      );
      final buildReport = await service.runOnce();
      ref.invalidate(incrementalUpdateStatusProvider);
      ref.invalidate(graphHealthReportProvider);
      ref.invalidate(chatSummariesProvider);
      ref.invalidate(chatSummarySanityCountsProvider);
      final after = await ref.read(incrementalUpdateStatusProvider.future);
      await const SourceScopedProofLogWriter().writeRun(
        before: before,
        after: after,
        buildReport: buildReport,
      );
    } catch (error, stackTrace) {
      await const SourceScopedProofLogWriter().writeRun(
        before: before,
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          for (final row in rows) row,
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow(
    this.label,
    this.value, {
    this.labelWidth = 180,
    this.verticalPadding = 2,
  });

  final String label;
  final String value;
  final double labelWidth;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

class _StatusError extends StatelessWidget {
  const _StatusError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text('Unable to load source-scoped status: $error'),
    );
  }
}
