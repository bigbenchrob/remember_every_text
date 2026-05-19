import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../application/messages/message_importer_provider.dart';
import '../application/messages/message_projector_provider.dart';
import '../application/messages/status/incremental_update_status_provider.dart';

class IncrementalUpdateStatusSheet extends ConsumerWidget {
  const IncrementalUpdateStatusSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(incrementalUpdateStatusProvider);

    return MacosSheet(
      child: SizedBox(
        width: 680,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              statusAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CupertinoActivityIndicator()),
                ),
                error: (error, stackTrace) => _StatusError(error: error),
                data: (status) => _StatusContent(status: status),
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
          child: const Text('Import + Project Messages'),
        ),
      ],
    );
  }

  Future<void> _importAndProjectOnce(WidgetRef ref) async {
    final importer = await ref.read(messageImporterProvider.future);
    await importer.importNewMessages();
    final projector = await ref.read(messageProjectorProvider.future);
    await projector.projectMessages();
    ref.invalidate(incrementalUpdateStatusProvider);
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
  const _StatusRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
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
