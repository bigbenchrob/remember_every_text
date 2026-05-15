import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../application/messages/orchestrators/sync_state_polling_orchestrator_provider.dart';
import '../application/messages/status/shadow_incremental_update_status_provider.dart';
import '../domain/sealed_unions/comparison_outcome.dart';
import '../domain/sealed_unions/import_decision.dart';
import '../domain/sealed_unions/message_migration_state.dart';
import '../domain/sealed_unions/migration_decision.dart';
import '../domain/sealed_unions/sync_state.dart';

class ShadowIncrementalUpdateStatusSheet extends ConsumerWidget {
  const ShadowIncrementalUpdateStatusSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(shadowIncrementalUpdateStatusProvider);

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
                      'Shadow incremental update',
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

  final ShadowIncrementalUpdateStatus status;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusSection(
          title: 'Polling',
          rows: [
            _StatusRow('Status', status.pollingActive ? 'active' : 'inactive'),
            _StatusRow('Last refresh', _formatDateTime(status.lastRefreshTime)),
            _StatusRow(
              'Last transition',
              _formatDateTime(status.lastTransitionTime),
            ),
          ],
        ),
        _StatusSection(
          title: 'Shadow import',
          rows: [
            _StatusRow(
              'ImportDecision',
              _formatImportDecision(status.importDecision),
            ),
            _StatusRow(
              'MessageSyncState',
              _formatMessageSyncState(status.messageSyncState),
            ),
            _StatusRow('rowIdDelta', '${status.snapshotDelta.rowIdDelta}'),
            _StatusRow(
              'messageCountDelta',
              '${status.snapshotDelta.messageCountDelta}',
            ),
          ],
        ),
        _StatusSection(
          title: 'Shadow migration',
          rows: [
            _StatusRow(
              'MigrationDecision',
              _formatMigrationDecision(status.migrationDecision),
            ),
            _StatusRow(
              'MessageMigrationState',
              _formatMigrationState(status.messageMigrationState),
            ),
            _StatusRow(
              'messageIdDelta',
              '${status.migrationDelta.messageIdDelta}',
            ),
            _StatusRow(
              'messageCountDelta',
              '${status.migrationDelta.messageCountDelta}',
            ),
          ],
        ),
        _StatusSection(
          title: 'Comparative validation',
          rows: [
            _StatusRow(
              'Import comparison',
              _formatComparison(status.importComparisonOutcome),
            ),
            _StatusRow(
              'Migration comparison',
              _formatComparison(status.migrationComparisonOutcome),
            ),
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
            ref.read(deltaRefreshOrchestratorProvider).startPolling();
            ref.invalidate(shadowIncrementalUpdateStatusProvider);
          },
          child: const Text('Start polling'),
        ),
        const SizedBox(width: 8),
        PushButton(
          controlSize: ControlSize.regular,
          secondary: true,
          onPressed: () {
            ref.read(deltaRefreshOrchestratorProvider).stopPolling();
            ref.invalidate(shadowIncrementalUpdateStatusProvider);
          },
          child: const Text('Stop polling'),
        ),
        const SizedBox(width: 8),
        PushButton(
          controlSize: ControlSize.regular,
          onPressed: () {
            unawaited(ref.read(deltaRefreshOrchestratorProvider).refreshOnce());
            ref.invalidate(shadowIncrementalUpdateStatusProvider);
          },
          child: const Text('Refresh once'),
        ),
      ],
    );
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
            width: 170,
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
      child: Text('Unable to load shadow status: $error'),
    );
  }
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return 'not observed';
  }

  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  final second = local.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second';
}

String _formatImportDecision(ImportDecision decision) {
  return switch (decision) {
    ImportDecisionDoNothing() => 'ImportDecision.doNothing',
    ImportDecisionConsiderIncrementalImport() =>
      'ImportDecision.considerIncrementalImport',
    ImportDecisionBlockAndReportLedgerAhead() =>
      'ImportDecision.blockAndReportLedgerAhead',
  };
}

String _formatMessageSyncState(MessageSyncState state) {
  return switch (state) {
    MessageSyncCursorsMatch() => 'MessageSyncState.sourceAndLedgerCursorsMatch',
    MessageSyncSourceAheadOfLedger() => 'MessageSyncState.sourceAheadOfLedger',
    MessageSyncLedgerAheadOfSource() => 'MessageSyncState.ledgerAheadOfSource',
  };
}

String _formatMigrationDecision(MigrationDecision decision) {
  return switch (decision) {
    MigrationDecisionDoNothing() => 'MigrationDecision.doNothing',
    MigrationDecisionConsiderShadowMigration() =>
      'MigrationDecision.considerShadowMigration',
    MigrationDecisionBlockAndReportProjectionAhead() =>
      'MigrationDecision.blockAndReportProjectionAhead',
  };
}

String _formatMigrationState(MessageMigrationState state) {
  return switch (state) {
    MessageMigrationProjectionCaughtUp() =>
      'MessageMigrationState.projectionCaughtUp',
    MessageMigrationLedgerAheadOfProjection() =>
      'MessageMigrationState.ledgerAheadOfProjection',
    MessageMigrationProjectionAheadOfLedger() =>
      'MessageMigrationState.projectionAheadOfLedger',
  };
}

String _formatComparison(ComparisonOutcome outcome) {
  return switch (outcome) {
    ComparisonOutcomeMatch(:final legacy, :final shadow) =>
      'MATCH: legacy=$legacy; shadow=$shadow',
    ComparisonOutcomePhaseSkew(:final legacy, :final shadow, :final reason) =>
      'PHASE SKEW: legacy=$legacy; shadow=$shadow; reason=$reason',
    ComparisonOutcomeMismatch(:final legacy, :final shadow, :final reason) =>
      'MISMATCH: legacy=$legacy; shadow=$shadow; reason=$reason',
    ComparisonOutcomeNotComparable(
      :final legacy,
      :final shadow,
      :final reason,
    ) =>
      'NOT COMPARABLE: legacy=$legacy; shadow=$shadow; reason=$reason',
  };
}
