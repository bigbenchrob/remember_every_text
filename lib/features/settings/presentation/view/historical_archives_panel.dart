import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../view_model/historical_archives_workflow_panel_model_provider.dart';

class HistoricalArchivesPanel extends ConsumerWidget {
  const HistoricalArchivesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final panelModel = ref.watch(historicalArchivesWorkflowPanelModelProvider);

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ShellHeroCard(
                  statusLabel: panelModel.statusLabel,
                  summaryText: panelModel.summaryText,
                  executionGate: panelModel.executionGate,
                  preflight: panelModel.preflight,
                ),
                const SizedBox(height: 20),
                _ShellSectionCard(
                  title: 'Choose Messages Folder',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _PlaceholderButton(
                            label: 'Choose Messages Folder...',
                            enabled: true,
                            onPressed: () {
                              ref
                                  .read(
                                    historicalArchivesWorkflowProvider.notifier,
                                  )
                                  .chooseMessagesFolder();
                            },
                          ),
                          _PlaceholderButton(
                            label: 'Clear Selected Folder',
                            enabled: panelModel.selectedFolderPath != null,
                            onPressed: panelModel.selectedFolderPath == null
                                ? null
                                : () {
                                    ref
                                        .read(
                                          historicalArchivesWorkflowProvider
                                              .notifier,
                                        )
                                        .clearSelection();
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'This only clears the currently selected folder from the workflow UI. It does not delete imported archive records or reset MessageLens data.',
                        style: typography.body.copyWith(
                          color: colors.content.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _MetadataLine(
                        label: 'Folder path',
                        value:
                            panelModel.selectedFolderPath ??
                            'No folder selected yet',
                      ),
                      _MetadataLine(
                        label: 'chat.db',
                        value: panelModel.chatDbStatusLabel,
                      ),
                      _MetadataLine(
                        label: 'Attachments/',
                        value: panelModel.attachmentsStatusLabel,
                      ),
                      _MetadataLine(
                        label: 'Source label',
                        value: panelModel.sourceLabel,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _ShellSectionCard(
                  title: 'Preflight Summary',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusCallout(
                        title: 'Preflight State',
                        statusLabel: panelModel.preflight.statusLabel,
                        detail: panelModel.preflight.detail,
                        tone: _preflightTone(panelModel.preflight.status),
                      ),
                      const SizedBox(height: 14),
                      for (final line in panelModel.preflightSummaryLines) ...[
                        Text(
                          line,
                          style: typography.body.copyWith(
                            color: colors.content.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Dry Run Summary',
                        style: typography.controlValue.copyWith(
                          color: colors.content.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final line in panelModel.dryRunSummaryLines) ...[
                        Text(
                          line,
                          style: typography.body.copyWith(
                            color: colors.content.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _ShellSectionCard(
                  title: 'Begin Import',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PlaceholderButton(
                        label: 'Begin Import',
                        enabled: panelModel.importButtonEnabled,
                        onPressed: panelModel.importButtonEnabled
                            ? () {
                                ref
                                    .read(
                                      historicalArchivesWorkflowProvider
                                          .notifier,
                                    )
                                    .beginImportForSelectedSource();
                              }
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        panelModel.importButtonDetail,
                        style: typography.body.copyWith(
                          color: colors.content.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _ShellSectionCard(
                  title: 'Developer Testing Controls',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PlaceholderButton(
                        label: 'Clear Imported Archive Data for This Source',
                        enabled: panelModel.removeImportedArchiveDataEnabled,
                        onPressed: panelModel.removeImportedArchiveDataEnabled
                            ? () {
                                _showRemoveImportedArchiveDataConfirmationDialog(
                                  context: context,
                                  ref: ref,
                                  panelModel: panelModel,
                                );
                              }
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Developer/testing only. This deletes previously imported archive records from MessageLens for the selected archive source, then rebuilds the app timeline.',
                        style: typography.body.copyWith(
                          color: colors.content.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'It does not delete or modify the source archive folder. It does not reset overlay or user-intent data. Live current_mac data must remain untouched.',
                        style: typography.body.copyWith(
                          color: colors.content.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final line
                          in panelModel.archiveManagementSummaryLines) ...[
                        Text(
                          line,
                          style: typography.body.copyWith(
                            color: colors.content.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        panelModel.removeImportedArchiveDataDetail,
                        style: typography.body.copyWith(
                          color: colors.content.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _ShellSectionCard(
                  title: 'Activity Log',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (
                        var index = 0;
                        index < panelModel.activityLog.length;
                        index++
                      ) ...[
                        _LogRow(entry: panelModel.activityLog[index]),
                        if (index < panelModel.activityLog.length - 1)
                          const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _ShellSectionCard(
                  title: 'Progress',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (
                        var index = 0;
                        index < panelModel.phases.length;
                        index++
                      ) ...[
                        _PhaseRow(phase: panelModel.phases[index]),
                        if (index < panelModel.phases.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _ShellSectionCard(
                  title: 'Result Summary',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final line in panelModel.resultSummaryLines) ...[
                        Text(
                          line,
                          style: typography.body.copyWith(
                            color: colors.content.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showRemoveImportedArchiveDataConfirmationDialog({
  required BuildContext context,
  required WidgetRef ref,
  required HistoricalArchivesWorkflowPanelViewModel panelModel,
}) async {
  final targetPath = panelModel.archiveRemovalTargetChatDbPath;
  final batchCount = panelModel.matchedImportedArchiveBatchCount;
  if (targetPath == null || batchCount == null || batchCount <= 0) {
    return;
  }

  final confirmed = await showCupertinoDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return CupertinoAlertDialog(
        title: const Text('Remove Imported Archive Data?'),
        content: Text(
          'Removal target chat.db: $targetPath\n\n'
          'Matched imported archive batches in db-import: $batchCount\n\n'
          'This deletes previously imported archive records from MessageLens for this selected source, then rebuilds the app timeline. It does not delete or modify the source archive folder, and it does not reset overlay or user-intent data.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Remove Imported Archive Data'),
          ),
        ],
      );
    },
  );

  if (confirmed == true) {
    await ref
        .read(historicalArchivesWorkflowProvider.notifier)
        .removeImportedArchiveDataForSelectedSource();
  }
}

class _ShellHeroCard extends ConsumerWidget {
  const _ShellHeroCard({
    required this.statusLabel,
    required this.summaryText,
    required this.executionGate,
    required this.preflight,
  });

  final String statusLabel;
  final String summaryText;
  final HistoricalArchivesExecutionGateViewModel executionGate;
  final HistoricalArchivesPreflightViewModel preflight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.surfaceRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historical Archives',
              style: typography.caption.copyWith(
                color: colors.content.textTertiary,
              ),
            ),
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.accents.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: colors.accents.primary.withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  statusLabel,
                  style: typography.caption.copyWith(
                    color: colors.accents.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This shell makes the historical archive workflow visible before real import wiring is enabled.',
              style: typography.title1.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              summaryText,
              style: typography.body.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StatusSummaryTile(
                    title: 'Execution Gate',
                    statusLabel: executionGate.statusLabel,
                    detail: executionGate.detail,
                    tone: _executionGateTone(executionGate.status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusSummaryTile(
                    title: 'Preflight',
                    statusLabel: preflight.statusLabel,
                    detail: preflight.detail,
                    tone: _preflightTone(preflight.status),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellSectionCard extends ConsumerWidget {
  const _ShellSectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: typography.title3.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _PlaceholderButton extends ConsumerWidget {
  const _PlaceholderButton({
    required this.label,
    this.enabled = false,
    this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final isInteractive = enabled && onPressed != null;

    return MouseRegion(
      cursor: isInteractive
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isInteractive ? onPressed : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: enabled
                ? colors.accents.primary.withValues(alpha: 0.10)
                : colors.surfaces.control,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled
                  ? colors.accents.primary.withValues(alpha: 0.25)
                  : colors.lines.borderSubtle,
              width: 0.8,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              label,
              style: typography.controlValue.copyWith(
                color: enabled
                    ? colors.accents.primary
                    : colors.content.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetadataLine extends ConsumerWidget {
  const _MetadataLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label: $value',
        style: typography.body.copyWith(color: colors.content.textSecondary),
      ),
    );
  }
}

class _StatusSummaryTile extends ConsumerWidget {
  const _StatusSummaryTile({
    required this.title,
    required this.statusLabel,
    required this.detail,
    required this.tone,
  });

  final String title;
  final String statusLabel;
  final String detail;
  final Color tone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: typography.caption.copyWith(
                color: colors.content.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusLabel,
              style: typography.controlValue.copyWith(color: tone),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCallout extends ConsumerWidget {
  const _StatusCallout({
    required this.title,
    required this.statusLabel,
    required this.detail,
    required this.tone,
  });

  final String title;
  final String statusLabel;
  final String detail;
  final Color tone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: 0.22), width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: typography.caption.copyWith(
                color: colors.content.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusLabel,
              style: typography.controlValue.copyWith(color: tone),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogRow extends ConsumerWidget {
  const _LogRow({required this.entry});

  final HistoricalArchivesLogEntryViewModel entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.label,
              style: typography.controlValue.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              entry.message,
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseRow extends ConsumerWidget {
  const _PhaseRow({required this.phase});

  final HistoricalArchivesWorkflowPhaseViewModel phase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaces.control,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(
              _statusLabel(phase.status),
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                phase.label,
                style: typography.controlValue.copyWith(
                  color: colors.content.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                phase.detail,
                style: typography.caption1.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _statusLabel(HistoricalArchivesWorkflowPhaseStatus status) {
    return switch (status) {
      HistoricalArchivesWorkflowPhaseStatus.waiting => 'Waiting',
      HistoricalArchivesWorkflowPhaseStatus.running => 'Running',
      HistoricalArchivesWorkflowPhaseStatus.succeeded => 'Succeeded',
      HistoricalArchivesWorkflowPhaseStatus.failed => 'Failed',
      HistoricalArchivesWorkflowPhaseStatus.skipped => 'Skipped',
    };
  }
}

Color _executionGateTone(HistoricalArchivesExecutionGateStatus status) {
  return switch (status) {
    HistoricalArchivesExecutionGateStatus.available => const Color(0xFF1F8A52),
    HistoricalArchivesExecutionGateStatus.busy => const Color(0xFFB36A00),
    HistoricalArchivesExecutionGateStatus.blocked => const Color(0xFFC03A2B),
  };
}

Color _preflightTone(HistoricalArchivesPreflightStatus status) {
  return switch (status) {
    HistoricalArchivesPreflightStatus.waitingForFolder => const Color(
      0xFF7A7D84,
    ),
    HistoricalArchivesPreflightStatus.running => const Color(0xFFB36A00),
    HistoricalArchivesPreflightStatus.completeReadyToImport => const Color(
      0xFF1F8A52,
    ),
    HistoricalArchivesPreflightStatus.failed => const Color(0xFFC03A2B),
  };
}
