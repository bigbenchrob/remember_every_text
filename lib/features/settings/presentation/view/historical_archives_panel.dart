import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../core/util/date_converter.dart';
import '../../../../essentials/db/application/database_health_audit/database_health_audit_service.dart';
import '../../../../essentials/logging/application/app_logger.dart';
import '../../../../essentials/logging/application/diagnostic_report_actions.dart';
import '../view_model/historical_archives_workflow_panel_model_provider.dart';

class HistoricalArchivesPanel extends ConsumerStatefulWidget {
  const HistoricalArchivesPanel({super.key});

  @override
  ConsumerState<HistoricalArchivesPanel> createState() =>
      _HistoricalArchivesPanelState();
}

class _HistoricalArchivesPanelState
    extends ConsumerState<HistoricalArchivesPanel> {
  bool _detailsExpanded = false;

  @override
  Widget build(BuildContext context) {
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
                _WorkflowHeroCard(
                  isBlocked:
                      panelModel.executionGate.status ==
                      HistoricalArchivesExecutionGateStatus.blocked,
                  blockedDetail: panelModel.executionGate.detail,
                ),
                const SizedBox(height: 20),
                _ShellSectionCard(
                  title: 'Step 1: Choose Messages Folder',
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
                      if (panelModel.selectedFolderPath == null) ...[
                        Text(
                          'Choose an older Messages folder. MessageLens will check what it contains before importing anything.',
                          style: typography.body.copyWith(
                            color: colors.content.textSecondary,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Clearing the selection only removes this folder from this page. It does not delete imported records or reset MessageLens data.',
                          style: typography.body.copyWith(
                            color: colors.content.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _MetadataLine(
                          label: 'Folder path',
                          value: panelModel.selectedFolderPath!,
                        ),
                        _MetadataLine(
                          label: 'chat.db',
                          value: panelModel.chatDbStatusLabel,
                        ),
                        _MetadataLine(
                          label: 'Attachments',
                          value: panelModel.attachmentsStatusLabel,
                        ),
                        _MetadataLine(
                          label: 'Source label',
                          value: panelModel.sourceLabel,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _ShellSectionCard(
                  title: 'Step 2: Review Archive Contents',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (panelModel.selectedFolderPath == null) ...[
                        Text(
                          'Choose a folder to see message counts and date range.',
                          style: typography.body.copyWith(
                            color: colors.content.textSecondary,
                          ),
                        ),
                      ] else ...[
                        _StatusCallout(
                          title: 'Archive Check',
                          statusLabel: _reviewStatusLabel(panelModel),
                          detail: panelModel.preflight.detail,
                          tone: _preflightTone(panelModel.preflight.status),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Import Preview',
                          style: typography.controlValue.copyWith(
                            color: colors.content.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _MetadataLine(
                          label: 'Already in current Mac data',
                          value: _summaryValueWithFallback(
                            primaryLines: panelModel.preflightSummaryLines,
                            primaryPrefix: 'Already in current Mac import:',
                            fallbackLines: panelModel.dryRunSummaryLines,
                            fallbackPrefix: 'Estimated duplicates:',
                          ),
                        ),
                        _MetadataLine(
                          label: 'Already imported from historical archives',
                          value: _summaryValue(
                            panelModel.preflightSummaryLines,
                            'Already in historical archive imports:',
                          ),
                        ),
                        _MetadataLine(
                          label: 'Will be added from this archive',
                          value: _summaryValue(
                            panelModel.dryRunSummaryLines,
                            'Estimated new messages:',
                          ),
                        ),
                        _MetadataLine(
                          label: 'Missing identifiers',
                          value: _summaryValue(
                            panelModel.preflightSummaryLines,
                            'Rows with missing GUIDs:',
                          ),
                        ),
                        const SizedBox(height: 8),
                        _DisclosureButton(
                          label: 'Details',
                          isExpanded: _detailsExpanded,
                          onPressed: () {
                            setState(() {
                              _detailsExpanded = !_detailsExpanded;
                            });
                          },
                        ),
                        if (_detailsExpanded) ...[
                          const SizedBox(height: 12),
                          _MetadataLine(
                            label: 'Total messages',
                            value: _summaryValue(
                              panelModel.preflightSummaryLines,
                              'Total messages:',
                            ),
                          ),
                          _MetadataLine(
                            label: 'Total chats',
                            value: _summaryValue(
                              panelModel.preflightSummaryLines,
                              'Total chats:',
                            ),
                          ),
                          _MetadataLine(
                            label: 'Total handles',
                            value: _summaryValue(
                              panelModel.preflightSummaryLines,
                              'Total handles:',
                            ),
                          ),
                          _MetadataLine(
                            label: 'Date range',
                            value: _dateRangeSummary(panelModel),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _ShellSectionCard(
                  title: 'Step 3: Begin Import',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PlaceholderButton(
                        label: 'Begin Import',
                        enabled: panelModel.importButtonEnabled,
                        onPressed: panelModel.importButtonEnabled
                            ? () {
                                _beginImportWithModal(
                                  context: context,
                                  ref: ref,
                                );
                              }
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _importStepDescription(panelModel),
                        style: typography.body.copyWith(
                          color: colors.content.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Import progress appears in a blocking dialog after you begin.',
                        style: typography.caption1.copyWith(
                          color: colors.content.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _ShellSectionCard(
                  title: 'Imported Archive Records',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PlaceholderButton(
                        label: 'Delete Imported Records for This Folder',
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
                        'This removes imported records for the selected archive source from MessageLens and then rebuilds the app timeline.',
                        style: typography.body.copyWith(
                          color: colors.content.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'It does not delete the original archive folder. It does not reset overlay or user data. Your current Mac Messages data stays untouched.',
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
        title: const Text('Delete Imported Records?'),
        content: Text(
          'Folder source: $targetPath\n\n'
          'Matched imported batches in MessageLens: $batchCount\n\n'
          'This removes imported records for the selected archive source from MessageLens and rebuilds the app timeline. It does not delete the original archive folder, and it does not reset overlay or user data.',
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
            child: const Text('Delete Imported Records'),
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

Future<void> _beginImportWithModal({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  unawaited(
    ref
        .read(historicalArchivesWorkflowProvider.notifier)
        .beginImportForSelectedSource(),
  );

  await Future<void>.delayed(Duration.zero);
  if (!context.mounted) {
    return;
  }

  final workflowState = ref.read(historicalArchivesWorkflowProvider);
  final shouldOpenDialog = switch (workflowState.preflight.status) {
    HistoricalArchivesPreflightStatus.running => true,
    HistoricalArchivesPreflightStatus.failed => true,
    HistoricalArchivesPreflightStatus.migrationCompleted => true,
    HistoricalArchivesPreflightStatus.waitingForFolder => false,
    HistoricalArchivesPreflightStatus.completeReadyToImport => false,
    HistoricalArchivesPreflightStatus.preparationRecorded => true,
  };

  if (!shouldOpenDialog) {
    return;
  }

  await showCupertinoDialog<void>(
    context: context,
    builder: (_) {
      return const _HistoricalArchivesImportDialog();
    },
  );
}

class _WorkflowHeroCard extends ConsumerWidget {
  const _WorkflowHeroCard({
    required this.isBlocked,
    required this.blockedDetail,
  });

  final bool isBlocked;
  final String blockedDetail;

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
              'Historical Messages',
              style: typography.caption.copyWith(
                color: colors.content.textTertiary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Import Historical Messages',
              style: typography.title1.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose an older Messages folder. MessageLens will check what it contains before importing anything.',
              style: typography.body.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
            if (isBlocked) ...[
              const SizedBox(height: 16),
              _StatusCallout(
                title: 'Temporarily unavailable',
                statusLabel: 'Maintenance in progress',
                detail: blockedDetail,
                tone: const Color(0xFFC03A2B),
              ),
            ],
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

class _DisclosureButton extends ConsumerWidget {
  const _DisclosureButton({
    required this.label,
    required this.isExpanded,
    required this.onPressed,
  });

  final String label;
  final bool isExpanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isExpanded
                  ? CupertinoIcons.chevron_down
                  : CupertinoIcons.chevron_right,
              size: 14,
              color: colors.content.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              '$label:',
              style: typography.controlValue.copyWith(
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

class _PhaseRow extends ConsumerWidget {
  const _PhaseRow({
    required this.phase,
    required this.animationTick,
    this.elapsed,
    this.stalledFor,
  });

  final HistoricalArchivesWorkflowPhaseViewModel phase;
  final int animationTick;
  final Duration? elapsed;
  final Duration? stalledFor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final tone = _statusTone(phase.status);
    final statusLabel = _statusLabel(phase.status);
    final longRunningNote =
        phase.status == HistoricalArchivesWorkflowPhaseStatus.running
        ? _longRunningNote(stalledFor)
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            Row(
              children: [
                Icon(_statusIcon(phase.status), size: 14, color: tone),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    elapsed == null
                        ? 'Status: $statusLabel'
                        : 'Status: $statusLabel · ${_formatElapsed(elapsed!)}',
                    style: typography.caption1.copyWith(color: tone),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _PhaseProgressBar(
              progress: phase.progress,
              status: phase.status,
              tone: tone,
              animationTick: animationTick,
            ),
            const SizedBox(height: 8),
            Text(
              phase.detail,
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
            if (longRunningNote != null) ...[
              const SizedBox(height: 6),
              Text(
                longRunningNote,
                style: typography.caption1.copyWith(
                  color: colors.content.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(HistoricalArchivesWorkflowPhaseStatus status) {
    return switch (status) {
      HistoricalArchivesWorkflowPhaseStatus.waiting => CupertinoIcons.circle,
      HistoricalArchivesWorkflowPhaseStatus.running =>
        CupertinoIcons.arrow_2_circlepath,
      HistoricalArchivesWorkflowPhaseStatus.succeeded =>
        CupertinoIcons.check_mark_circled_solid,
      HistoricalArchivesWorkflowPhaseStatus.failed =>
        CupertinoIcons.xmark_circle_fill,
      HistoricalArchivesWorkflowPhaseStatus.skipped =>
        CupertinoIcons.minus_circle,
    };
  }

  Color _statusTone(HistoricalArchivesWorkflowPhaseStatus status) {
    return switch (status) {
      HistoricalArchivesWorkflowPhaseStatus.waiting => const Color(0xFF7A7D84),
      HistoricalArchivesWorkflowPhaseStatus.running => const Color(0xFFB36A00),
      HistoricalArchivesWorkflowPhaseStatus.succeeded => const Color(
        0xFF1F8A52,
      ),
      HistoricalArchivesWorkflowPhaseStatus.failed => const Color(0xFFC03A2B),
      HistoricalArchivesWorkflowPhaseStatus.skipped => const Color(0xFF7A7D84),
    };
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

class _PhaseProgressBar extends StatelessWidget {
  const _PhaseProgressBar({
    required this.progress,
    required this.status,
    required this.tone,
    required this.animationTick,
  });

  final double? progress;
  final HistoricalArchivesWorkflowPhaseStatus status;
  final Color tone;
  final int animationTick;

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xFFD8DDE3);

    return SizedBox(
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(color: baseColor.withValues(alpha: 0.65)),
                ),
                ...switch (status) {
                  HistoricalArchivesWorkflowPhaseStatus.waiting ||
                  HistoricalArchivesWorkflowPhaseStatus.skipped =>
                    const <Widget>[],
                  HistoricalArchivesWorkflowPhaseStatus.succeeded => <Widget>[
                    Positioned.fill(
                      child: ColoredBox(color: tone.withValues(alpha: 0.95)),
                    ),
                  ],
                  HistoricalArchivesWorkflowPhaseStatus.failed => <Widget>[
                    Positioned.fill(
                      child: ColoredBox(color: tone.withValues(alpha: 0.95)),
                    ),
                  ],
                  HistoricalArchivesWorkflowPhaseStatus.running => <Widget>[
                    if (progress != null)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: SizedBox(
                          width:
                              constraints.maxWidth * progress!.clamp(0.0, 1.0),
                          child: ColoredBox(
                            color: tone.withValues(alpha: 0.95),
                          ),
                        ),
                      )
                    else
                      Positioned(
                        left: _runningBarLeft(
                          maxWidth: constraints.maxWidth,
                          animationTick: animationTick,
                        ),
                        top: 0,
                        bottom: 0,
                        child: SizedBox(
                          width: constraints.maxWidth * 0.34,
                          child: ColoredBox(
                            color: tone.withValues(alpha: 0.95),
                          ),
                        ),
                      ),
                  ],
                },
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HistoricalArchivesImportDialog extends ConsumerStatefulWidget {
  const _HistoricalArchivesImportDialog();

  @override
  ConsumerState<_HistoricalArchivesImportDialog> createState() =>
      _HistoricalArchivesImportDialogState();
}

class _HistoricalArchivesImportDialogState
    extends ConsumerState<_HistoricalArchivesImportDialog> {
  Timer? _animationTimer;
  int _animationTick = 0;
  String? _trackedPhaseLabel;
  HistoricalArchivesWorkflowPhaseStatus? _trackedPhaseStatus;
  int? _trackedPhaseStartedAtUnixSeconds;
  int? _trackedPhaseLastProgressAtUnixSeconds;
  Duration? _trackedPhaseFrozenElapsed;
  String? _trackedPhaseProgressFingerprint;
  String? _dismissedPotentiallyStuckPhaseFingerprint;

  @override
  void initState() {
    super.initState();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _animationTick += 1;
      });
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final panelModel = ref.watch(historicalArchivesWorkflowPanelModelProvider);
    final dialogModel = buildHistoricalArchivesImportDialogViewModel(
      panelModel: panelModel,
    );
    final dialogPhases = _normalizeSequentialPhases(dialogModel.phases);
    final currentPhase = _currentPhase(dialogPhases);
    _syncTrackedPhase(currentPhase);
    final currentPhaseElapsed = _elapsedForPhase(currentPhase);
    final currentPhaseStalledFor = _stalledForPhase(currentPhase);
    final currentStepNote =
        currentPhase?.status == HistoricalArchivesWorkflowPhaseStatus.running
        ? _longRunningNote(currentPhaseStalledFor)
        : null;
    final currentPhaseFingerprint = currentPhase == null
        ? null
        : _phaseProgressFingerprint(currentPhase);
    final watchdogState = _watchdogState(currentPhaseStalledFor);
    final showPotentiallyStuckActions =
        watchdogState == _PhaseWatchdogState.potentiallyStuck &&
        currentPhaseFingerprint != null &&
        currentPhaseFingerprint != _dismissedPotentiallyStuckPhaseFingerprint;

    return PopScope(
      canPop: dialogModel.isTerminal,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680, maxHeight: 620),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaces.surfaceRaised,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dialogModel.title,
                      style: typography.title2.copyWith(
                        color: colors.content.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (dialogModel.state ==
                        HistoricalArchivesImportDialogState.running) ...[
                      Text(
                        'Current step: ${currentPhase?.label ?? 'Preparing import'}',
                        style: typography.controlValue.copyWith(
                          color: colors.content.textPrimary,
                        ),
                      ),
                      if (currentPhaseElapsed != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Elapsed: ${_formatElapsed(currentPhaseElapsed)}',
                          style: typography.caption1.copyWith(
                            color: colors.content.textSecondary,
                          ),
                        ),
                      ],
                      if (currentStepNote != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          currentStepNote,
                          style: typography.caption1.copyWith(
                            color: colors.content.textTertiary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      for (
                        var index = 0;
                        index < dialogPhases.length;
                        index++
                      ) ...[
                        _PhaseRow(
                          phase: dialogPhases[index],
                          animationTick: _animationTick,
                          elapsed: _elapsedForPhase(dialogPhases[index]),
                          stalledFor: _stalledForPhase(dialogPhases[index]),
                        ),
                        if (index < dialogPhases.length - 1)
                          const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (showPotentiallyStuckActions) ...[
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              onPressed: () {
                                setState(() {
                                  _dismissedPotentiallyStuckPhaseFingerprint =
                                      currentPhaseFingerprint;
                                });
                              },
                              child: Text(
                                'Wait',
                                style: typography.caption1.copyWith(
                                  color: colors.content.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              onPressed: () async {
                                await _sendDiagnosticReport(context);
                              },
                              child: Text(
                                'Send Report',
                                style: typography.caption1.copyWith(
                                  color: colors.accents.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            color: const Color(0xFFC03A2B),
                            onPressed: () {
                              ref
                                  .read(
                                    historicalArchivesWorkflowProvider.notifier,
                                  )
                                  .requestCancelRunningImport();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Cancel Import',
                              style: typography.controlValue.copyWith(
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      if (dialogModel.state ==
                          HistoricalArchivesImportDialogState.success) ...[
                        for (final line in dialogModel.summaryLines) ...[
                          Text(
                            line,
                            style: typography.body.copyWith(
                              color: colors.content.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                      if (dialogModel.state ==
                          HistoricalArchivesImportDialogState.failure) ...[
                        if (dialogModel.failureStageLabel != null) ...[
                          Text(
                            'Failed step: ${dialogModel.failureStageLabel!}',
                            style: typography.controlValue.copyWith(
                              color: const Color(0xFFC03A2B),
                            ),
                          ),
                        ],
                        if (currentPhaseElapsed != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Elapsed: ${_formatElapsed(currentPhaseElapsed)}',
                            style: typography.caption1.copyWith(
                              color: colors.content.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${dialogModel.detail}',
                          style: typography.body.copyWith(
                            color: colors.content.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (
                          var index = 0;
                          index < dialogPhases.length;
                          index++
                        ) ...[
                          _PhaseRow(
                            phase: dialogPhases[index],
                            animationTick: _animationTick,
                            elapsed: _elapsedForPhase(dialogPhases[index]),
                            stalledFor: _stalledForPhase(dialogPhases[index]),
                          ),
                          if (index < dialogPhases.length - 1)
                            const SizedBox(height: 10),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          dialogModel.cleanupAvailable
                              ? dialogModel.cleanupDetail
                              : 'Cleanup availability: not available in this run state.',
                          style: typography.caption1.copyWith(
                            color: colors.content.textSecondary,
                          ),
                        ),
                      ],
                    ],
                    if (dialogModel.dismissActionLabel
                        case final String dismissActionLabel) ...[
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (dialogModel.state ==
                              HistoricalArchivesImportDialogState.failure)
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              onPressed: () async {
                                await _sendDiagnosticReport(context);
                              },
                              child: Text(
                                'Send Report To Developer',
                                style: typography.caption1.copyWith(
                                  color: colors.accents.primary,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            color: colors.accents.primary,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              dismissActionLabel,
                              style: typography.controlValue.copyWith(
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _syncTrackedPhase(HistoricalArchivesWorkflowPhaseViewModel? phase) {
    final nowUnixSeconds = DateConverter.nowUnixSeconds();
    if (phase == null) {
      _trackedPhaseLabel = null;
      _trackedPhaseStatus = null;
      _trackedPhaseStartedAtUnixSeconds = null;
      _trackedPhaseLastProgressAtUnixSeconds = null;
      _trackedPhaseFrozenElapsed = null;
      _trackedPhaseProgressFingerprint = null;
      return;
    }

    final fingerprint = _phaseProgressFingerprint(phase);

    if (_trackedPhaseLabel == phase.label &&
        _trackedPhaseStatus == phase.status) {
      if (phase.status == HistoricalArchivesWorkflowPhaseStatus.running &&
          _trackedPhaseProgressFingerprint != fingerprint) {
        _trackedPhaseProgressFingerprint = fingerprint;
        _trackedPhaseLastProgressAtUnixSeconds = nowUnixSeconds;
        if (_dismissedPotentiallyStuckPhaseFingerprint != null &&
            _dismissedPotentiallyStuckPhaseFingerprint != fingerprint) {
          _dismissedPotentiallyStuckPhaseFingerprint = null;
        }
      }
      return;
    }

    if (phase.status == HistoricalArchivesWorkflowPhaseStatus.running) {
      _trackedPhaseLabel = phase.label;
      _trackedPhaseStatus = phase.status;
      _trackedPhaseStartedAtUnixSeconds = nowUnixSeconds;
      _trackedPhaseLastProgressAtUnixSeconds = nowUnixSeconds;
      _trackedPhaseFrozenElapsed = null;
      _trackedPhaseProgressFingerprint = fingerprint;
      _dismissedPotentiallyStuckPhaseFingerprint = null;
      return;
    }

    if (phase.status == HistoricalArchivesWorkflowPhaseStatus.failed) {
      if (_trackedPhaseLabel == phase.label &&
          _trackedPhaseStartedAtUnixSeconds != null) {
        _trackedPhaseFrozenElapsed = DateConverter.durationBetweenUnixSeconds(
          _trackedPhaseStartedAtUnixSeconds!,
          nowUnixSeconds,
        );
      } else {
        _trackedPhaseStartedAtUnixSeconds = null;
        _trackedPhaseLastProgressAtUnixSeconds = null;
        _trackedPhaseFrozenElapsed = null;
      }
      _trackedPhaseLabel = phase.label;
      _trackedPhaseStatus = phase.status;
      _trackedPhaseProgressFingerprint = fingerprint;
      return;
    }

    _trackedPhaseLabel = phase.label;
    _trackedPhaseStatus = phase.status;
    _trackedPhaseProgressFingerprint = fingerprint;
  }

  Duration? _elapsedForPhase(HistoricalArchivesWorkflowPhaseViewModel? phase) {
    if (phase == null || _trackedPhaseLabel != phase.label) {
      return null;
    }

    if (phase.status == HistoricalArchivesWorkflowPhaseStatus.running &&
        _trackedPhaseStartedAtUnixSeconds != null) {
      return DateConverter.durationSinceUnixSeconds(
        _trackedPhaseStartedAtUnixSeconds!,
      );
    }

    if (phase.status == HistoricalArchivesWorkflowPhaseStatus.failed) {
      return _trackedPhaseFrozenElapsed;
    }

    return null;
  }

  Duration? _stalledForPhase(HistoricalArchivesWorkflowPhaseViewModel? phase) {
    if (phase == null ||
        phase.status != HistoricalArchivesWorkflowPhaseStatus.running ||
        _trackedPhaseLabel != phase.label ||
        _trackedPhaseLastProgressAtUnixSeconds == null) {
      return null;
    }

    return DateConverter.durationSinceUnixSeconds(
      _trackedPhaseLastProgressAtUnixSeconds!,
    );
  }

  String _phaseProgressFingerprint(
    HistoricalArchivesWorkflowPhaseViewModel phase,
  ) {
    return '${phase.label}|${phase.status.name}|${phase.progress?.toStringAsFixed(4) ?? 'indeterminate'}|${phase.detail}';
  }

  Future<void> _sendDiagnosticReport(BuildContext context) async {
    final writer = ref.read(appLoggerProvider.notifier).writer;
    final databaseHealthAuditService = await ref.read(
      databaseHealthAuditServiceProvider.future,
    );
    final result = await exportDiagnosticReport(
      writer,
      databaseHealthAuditService: databaseHealthAuditService,
    );
    if (!context.mounted) {
      return;
    }
    await _showDiagnosticReportResultDialog(
      context,
      attachedToMailDraft: result.attachedToMailDraft,
      exportPath: result.exportPath,
    );
  }
}

Future<void> _showDiagnosticReportResultDialog(
  BuildContext context, {
  required bool attachedToMailDraft,
  required String? exportPath,
}) {
  final message = exportPath == null
      ? 'MessageLens could not prepare a diagnostic report right now.'
      : attachedToMailDraft
      ? 'MessageLens prepared a support bundle and attached it to a draft email.'
      : 'MessageLens prepared a support bundle and opened it in Finder so it can be attached manually.';

  return showCupertinoDialog<void>(
    context: context,
    builder: (dialogContext) {
      return CupertinoAlertDialog(
        title: const Text('Diagnostic Report'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

HistoricalArchivesWorkflowPhaseViewModel? _currentPhase(
  List<HistoricalArchivesWorkflowPhaseViewModel> phases,
) {
  for (final phase in phases) {
    if (phase.status == HistoricalArchivesWorkflowPhaseStatus.running) {
      return phase;
    }
  }

  for (final phase in phases) {
    if (phase.status == HistoricalArchivesWorkflowPhaseStatus.failed) {
      return phase;
    }
  }

  return phases.isEmpty ? null : phases.last;
}

List<HistoricalArchivesWorkflowPhaseViewModel> _normalizeSequentialPhases(
  List<HistoricalArchivesWorkflowPhaseViewModel> phases,
) {
  var hasRunningPhase = false;

  return <HistoricalArchivesWorkflowPhaseViewModel>[
    for (final phase in phases)
      if (phase.status == HistoricalArchivesWorkflowPhaseStatus.running)
        if (!hasRunningPhase)
          (() {
            hasRunningPhase = true;
            return phase;
          })()
        else
          HistoricalArchivesWorkflowPhaseViewModel(
            label: phase.label,
            status: HistoricalArchivesWorkflowPhaseStatus.waiting,
            detail: phase.detail,
            progress: 0.0,
          )
      else
        phase,
  ];
}

enum _PhaseWatchdogState { normal, takingLonger, potentiallyStuck }

double _runningBarLeft({required double maxWidth, required int animationTick}) {
  final segmentWidth = maxWidth * 0.34;
  final travelWidth = maxWidth - segmentWidth;
  if (travelWidth <= 0) {
    return 0;
  }

  final progress = (animationTick % 12) / 11;
  return travelWidth * progress;
}

_PhaseWatchdogState _watchdogState(Duration? stalledFor) {
  if (stalledFor == null) {
    return _PhaseWatchdogState.normal;
  }
  if (stalledFor >= const Duration(minutes: 3)) {
    return _PhaseWatchdogState.potentiallyStuck;
  }
  if (stalledFor >= const Duration(minutes: 1)) {
    return _PhaseWatchdogState.takingLonger;
  }
  return _PhaseWatchdogState.normal;
}

String? _longRunningNote(Duration? stalledFor) {
  if (stalledFor == null) {
    return null;
  }
  return switch (_watchdogState(stalledFor)) {
    _PhaseWatchdogState.potentiallyStuck =>
      'This step may be stuck. MessageLens has not reported progress for ${DateConverter.formatDurationCompact(stalledFor)}. You can wait, cancel, or send a report.',
    _PhaseWatchdogState.takingLonger =>
      'This step is taking longer than usual. MessageLens has not reported progress for ${DateConverter.formatDurationCompact(stalledFor)}.',
    _PhaseWatchdogState.normal => null,
  };
}

String _formatElapsed(Duration duration) {
  return DateConverter.formatDurationCompact(duration);
}

String _reviewStatusLabel(HistoricalArchivesWorkflowPanelViewModel panelModel) {
  return switch (panelModel.preflight.status) {
    HistoricalArchivesPreflightStatus.running => 'Checking archive',
    HistoricalArchivesPreflightStatus.completeReadyToImport =>
      'Ready to import',
    HistoricalArchivesPreflightStatus.migrationCompleted =>
      'Imported successfully',
    HistoricalArchivesPreflightStatus.failed =>
      panelModel.preflight.statusLabel,
    HistoricalArchivesPreflightStatus.waitingForFolder => 'Choose a folder',
    HistoricalArchivesPreflightStatus.preparationRecorded =>
      'Import in progress',
  };
}

String _summaryValue(List<String> lines, String prefix) {
  for (final line in lines) {
    if (line.startsWith(prefix)) {
      return line.substring(prefix.length).trim();
    }
  }
  return 'Unavailable';
}

String _summaryValueWithFallback({
  required List<String> primaryLines,
  required String primaryPrefix,
  required List<String> fallbackLines,
  required String fallbackPrefix,
}) {
  final primaryValue = _summaryValue(primaryLines, primaryPrefix);
  if (primaryValue != 'Unavailable') {
    return primaryValue;
  }

  return _summaryValue(fallbackLines, fallbackPrefix);
}

String _dateRangeSummary(HistoricalArchivesWorkflowPanelViewModel panelModel) {
  final earliest = _summaryValue(
    panelModel.preflightSummaryLines,
    'Earliest message:',
  );
  final latest = _summaryValue(
    panelModel.preflightSummaryLines,
    'Latest message:',
  );

  if (earliest == 'Unavailable' && latest == 'Unavailable') {
    return 'Unavailable';
  }

  return '$earliest to $latest';
}

String _importStepDescription(
  HistoricalArchivesWorkflowPanelViewModel panelModel,
) {
  return switch (panelModel.executionGate.status) {
    HistoricalArchivesExecutionGateStatus.blocked =>
      'Import is unavailable while MessageLens is performing message-data maintenance.',
    HistoricalArchivesExecutionGateStatus.busy =>
      'Import is unavailable while another import or migration is already running.',
    HistoricalArchivesExecutionGateStatus.available => switch (panelModel
        .preflight
        .status) {
      HistoricalArchivesPreflightStatus.waitingForFolder =>
        'Choose a folder first.',
      HistoricalArchivesPreflightStatus.running =>
        'MessageLens is still checking this archive.',
      HistoricalArchivesPreflightStatus.completeReadyToImport =>
        'When you begin, MessageLens will import this archive and then update your timeline, search, and heatmap.',
      HistoricalArchivesPreflightStatus.migrationCompleted =>
        'This archive has already been imported successfully.',
      HistoricalArchivesPreflightStatus.failed =>
        panelModel.preflight.statusLabel ==
                'Migration failed after archive import'
            ? 'The archive was read, but migration did not complete successfully.'
            : 'Resolve the archive check issue before importing.',
      HistoricalArchivesPreflightStatus.preparationRecorded =>
        'This archive is already in progress.',
    },
  };
}

Color _preflightTone(HistoricalArchivesPreflightStatus status) {
  return switch (status) {
    HistoricalArchivesPreflightStatus.waitingForFolder => const Color(
      0xFF7A7D84,
    ),
    HistoricalArchivesPreflightStatus.preparationRecorded => const Color(
      0xFF7A7D84,
    ),
    HistoricalArchivesPreflightStatus.running => const Color(0xFFB36A00),
    HistoricalArchivesPreflightStatus.completeReadyToImport => const Color(
      0xFF1F8A52,
    ),
    HistoricalArchivesPreflightStatus.migrationCompleted => const Color(
      0xFF1F8A52,
    ),
    HistoricalArchivesPreflightStatus.failed => const Color(0xFFC03A2B),
  };
}
