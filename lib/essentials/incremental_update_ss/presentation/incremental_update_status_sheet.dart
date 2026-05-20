import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../application/chat_handle_joins/chat_handle_join_importer_provider.dart';
import '../application/chat_handle_joins/chat_to_handle_projector_provider.dart';
import '../application/chat_message_joins/chat_message_join_importer_provider.dart';
import '../application/chat_message_joins/chat_to_message_projector_provider.dart';
import '../application/chat_summaries/chat_summary.dart';
import '../application/chat_summaries/chat_summary_provider.dart';
import '../application/chats/chat_importer_provider.dart';
import '../application/chats/chat_projector_provider.dart';
import '../application/handles/handle_importer_provider.dart';
import '../application/handles/handle_projector_provider.dart';
import '../application/messages/message_importer_provider.dart';
import '../application/messages/message_projector_provider.dart';
import '../application/messages/status/incremental_update_status_provider.dart';
import '../application/messages/status/source_scoped_proof_log_writer.dart';

enum _StatusSheetTab { status, groupProfiles }

class IncrementalUpdateStatusSheet extends ConsumerStatefulWidget {
  const IncrementalUpdateStatusSheet({super.key});

  @override
  ConsumerState<IncrementalUpdateStatusSheet> createState() =>
      _IncrementalUpdateStatusSheetState();
}

class _IncrementalUpdateStatusSheetState
    extends ConsumerState<IncrementalUpdateStatusSheet> {
  _StatusSheetTab _selectedTab = _StatusSheetTab.status;

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(incrementalUpdateStatusProvider);
    final summariesAsync = ref.watch(chatSummariesProvider);
    final summaryCountsAsync = ref.watch(chatSummarySanityCountsProvider);

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
                  _StatusSheetTab.groupProfiles: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Group profiles'),
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
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _StatusControls(ref: ref),
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
  });

  final _StatusSheetTab selectedTab;
  final IncrementalUpdateStatus status;
  final AsyncValue<List<ChatSummary>> summariesAsync;
  final AsyncValue<ChatSummarySanityCounts> summaryCountsAsync;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: switch (selectedTab) {
        _StatusSheetTab.status => _StatusContent(status: status),
        _StatusSheetTab.groupProfiles => _ChatSummarySection(
          summariesAsync: summariesAsync,
          summaryCountsAsync: summaryCountsAsync,
        ),
      },
    );
  }
}

class _StatusContent extends StatelessWidget {
  const _StatusContent({required this.status});

  final IncrementalUpdateStatus status;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusSection(
          title: 'Proof scope',
          rows: [
            const _StatusRow('Mode', 'manual one-shot import'),
            _StatusRow('Source', 'live-chat-db (${status.sourceId})'),
            _StatusRow('Import DB', status.importDatabaseName),
            _StatusRow('Working DB', status.workingDatabaseName),
            _StatusRow('chat.db path', status.chatDbPath),
          ],
        ),
        _StatusSection(
          title: 'Messages',
          rows: [
            _StatusRow('Cursor state', status.cursorState),
            _StatusRow('Source max ROWID', '${status.sourceMaxRowId}'),
            _StatusRow(
              'Last imported source_rowid',
              '${status.ledgerMaxSourceRowId}',
            ),
            _StatusRow('rowIdDelta', '${status.rowIdDelta}'),
            _StatusRow('source messages', '${status.sourceMessageCount}'),
            _StatusRow('import_ss messages', '${status.ledgerMessageCount}'),
            _StatusRow('working_ss messages', '${status.workingMessageCount}'),
            _StatusRow(
              'associated-message edges',
              '${status.associatedMessageEdgeCount}',
            ),
            _StatusRow('messageCountDelta', '${status.messageCountDelta}'),
          ],
        ),
        _StatusSection(
          title: 'Chats + topology',
          rows: [
            _StatusRow('source chats', '${status.sourceChatCount}'),
            _StatusRow('import_ss chats', '${status.importChatCount}'),
            _StatusRow('working_ss chats', '${status.workingChatCount}'),
            _StatusRow('source handles', '${status.sourceHandleCount}'),
            _StatusRow('import_ss handles', '${status.importHandleCount}'),
            _StatusRow('working_ss handles', '${status.workingHandleCount}'),
            _StatusRow(
              'import_ss chat_to_message',
              '${status.importTopologyEdgeCount}',
            ),
            _StatusRow(
              'working_ss chat_to_message',
              '${status.workingTopologyEdgeCount}',
            ),
            _StatusRow(
              'duplicate working edges',
              '${status.duplicateWorkingTopologyEdgeCount}',
            ),
            _StatusRow(
              'import_ss chat_to_handle',
              '${status.importChatToHandleEdgeCount}',
            ),
            _StatusRow(
              'working_ss chat_to_handle',
              '${status.workingChatToHandleEdgeCount}',
            ),
            _StatusRow(
              'duplicate working chat_to_handle',
              '${status.duplicateWorkingChatToHandleEdgeCount}',
            ),
          ],
        ),
      ],
    );
  }
}

class _ChatSummarySection extends StatelessWidget {
  const _ChatSummarySection({
    required this.summariesAsync,
    required this.summaryCountsAsync,
  });

  final AsyncValue<List<ChatSummary>> summariesAsync;
  final AsyncValue<ChatSummarySanityCounts> summaryCountsAsync;

  @override
  Widget build(BuildContext context) {
    return _StatusSection(
      title: 'Chat summaries',
      rows: [
        ...summaryCountsAsync.maybeWhen(
          data: (counts) => [
            _StatusRow('group chats', '${counts.groupChatCount}'),
            _StatusRow(
              'single-participant chats',
              '${counts.singleParticipantChatCount}',
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
        ...summariesAsync.maybeWhen(
          data: (summaries) => [
            for (final summary in summaries)
              _StatusRow(
                summary.participantHandles.isEmpty
                    ? 'chat ${summary.chatSsId}'
                    : summary.participantHandles.join(', '),
                '${summary.messageCount} messages | '
                '${summary.participantCount} participants | '
                '${summary.isGroup ? 'group' : 'single'} | '
                '${summary.lastMessageAtUtc ?? 'no date'} | '
                '${summary.lastMessageText ?? 'no text'}',
                labelWidth: 260,
                verticalPadding: 8,
              ),
          ],
          orElse: () => [const _StatusRow('summaries', 'loading')],
        ),
      ],
    );
  }
}

class _StatusControls extends StatelessWidget {
  const _StatusControls({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PushButton(
          controlSize: ControlSize.regular,
          secondary: true,
          onPressed: () {
            ref.invalidate(incrementalUpdateStatusProvider);
          },
          child: const Text('Refresh'),
        ),
        const SizedBox(width: 8),
        PushButton(
          controlSize: ControlSize.regular,
          onPressed: () {
            unawaited(_importAndProjectOnce(ref));
          },
          child: const Text('Import + Project SS Graph'),
        ),
      ],
    );
  }

  Future<void> _importAndProjectOnce(WidgetRef ref) async {
    final before = await ref.read(incrementalUpdateStatusProvider.future);
    try {
      final chatImporter = await ref.read(chatImporterProvider.future);
      await chatImporter.importChats();
      final handleImporter = await ref.read(handleImporterProvider.future);
      await handleImporter.importNewHandles();
      final importer = await ref.read(messageImporterProvider.future);
      final importResult = await importer.importNewMessages();
      final joinImporter = await ref.read(
        chatMessageJoinImporterProvider.future,
      );
      await joinImporter.importJoins();
      final chatHandleJoinImporter = await ref.read(
        chatHandleJoinImporterProvider.future,
      );
      await chatHandleJoinImporter.importJoins();
      final handleProjector = await ref.read(handleProjectorProvider.future);
      await handleProjector.projectHandles();
      final chatToHandleProjector = await ref.read(
        chatToHandleProjectorProvider.future,
      );
      await chatToHandleProjector.projectEdges();
      final chatProjector = await ref.read(chatProjectorProvider.future);
      await chatProjector.projectChats();
      final projector = await ref.read(messageProjectorProvider.future);
      final projectionResult = await projector.projectMessages();
      final edgeProjector = await ref.read(
        chatToMessageProjectorProvider.future,
      );
      await edgeProjector.projectEdges();
      ref.invalidate(incrementalUpdateStatusProvider);
      ref.invalidate(chatSummariesProvider);
      ref.invalidate(chatSummarySanityCountsProvider);
      final after = await ref.read(incrementalUpdateStatusProvider.future);
      await const SourceScopedProofLogWriter().writeRun(
        before: before,
        after: after,
        importResult: importResult,
        projectionResult: projectionResult,
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
  final List<_StatusRow> rows;

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
