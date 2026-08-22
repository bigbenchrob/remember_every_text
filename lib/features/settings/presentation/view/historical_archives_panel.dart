import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/page_track_layout_matrix.dart';
import '../../../../config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import '../../../../config/theme/widgets/theme_widgets.dart';
import '../../../../essentials/debug/feature_level_providers.dart'
    show DeveloperModeValue, developerModeProvider;
import '../../../../essentials/source_scoped_import/domain/messages_lineage_admission.dart'
    show MessagesLineageAdmissionStatus;
import '../../application/historical_archives_workflow_actions_provider.dart';
import '../../application/historical_archives_workflow_panel_model_provider.dart';
import '../layout/historical_archives_track_occupants.dart';

Future<void> _waitForHistoricalArchiveOperationFrame() {
  return SchedulerBinding.instance.endOfFrame;
}

class HistoricalArchivesPanel extends ConsumerStatefulWidget {
  const HistoricalArchivesPanel({super.key});

  @override
  ConsumerState<HistoricalArchivesPanel> createState() =>
      _HistoricalArchivesPanelState();
}

class _HistoricalArchivesPanelState
    extends ConsumerState<HistoricalArchivesPanel> {
  int? _presentedDuplicateNoticeOccurrence;
  int? _presentedInvalidFolderNoticeOccurrence;
  int? _presentedLineageNoticeOccurrence;
  int? _presentedImportSuccessNoticeOccurrence;
  int? _presentedMessageLensNoticeOccurrence;

  @override
  Widget build(BuildContext context) {
    ref.listen<HistoricalArchivesDuplicateFolderNotice?>(
      historicalArchivesWorkflowProvider.select(
        (state) => state.duplicateFolderNotice,
      ),
      (previous, next) {
        if (next == null ||
            next.noticeOccurrence == _presentedDuplicateNoticeOccurrence) {
          return;
        }
        _presentedDuplicateNoticeOccurrence = next.noticeOccurrence;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          final currentNotice = ref
              .read(historicalArchivesWorkflowProvider)
              .duplicateFolderNotice;
          if (currentNotice?.noticeOccurrence != next.noticeOccurrence ||
              currentNotice?.presentationSessionOccurrence !=
                  next.presentationSessionOccurrence) {
            return;
          }
          unawaited(_showDuplicateFolderDialog(next));
        });
      },
    );
    ref.listen<HistoricalArchivesInvalidFolderNotice?>(
      historicalArchivesWorkflowProvider.select(
        (state) => state.invalidFolderNotice,
      ),
      (previous, next) {
        if (next == null ||
            next.noticeOccurrence == _presentedInvalidFolderNoticeOccurrence) {
          return;
        }
        _presentedInvalidFolderNoticeOccurrence = next.noticeOccurrence;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          final currentNotice = ref
              .read(historicalArchivesWorkflowProvider)
              .invalidFolderNotice;
          if (currentNotice?.noticeOccurrence != next.noticeOccurrence ||
              currentNotice?.presentationSessionOccurrence !=
                  next.presentationSessionOccurrence) {
            return;
          }
          unawaited(_showInvalidFolderDialog(next));
        });
      },
    );
    ref.listen<HistoricalArchivesLineageNotice?>(
      historicalArchivesWorkflowProvider.select((state) => state.lineageNotice),
      (previous, next) {
        if (next == null ||
            next.noticeOccurrence == _presentedLineageNoticeOccurrence) {
          return;
        }
        _presentedLineageNoticeOccurrence = next.noticeOccurrence;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          final currentNotice = ref
              .read(historicalArchivesWorkflowProvider)
              .lineageNotice;
          if (currentNotice?.noticeOccurrence != next.noticeOccurrence ||
              currentNotice?.presentationSessionOccurrence !=
                  next.presentationSessionOccurrence) {
            return;
          }
          unawaited(_showLineageDialog(next));
        });
      },
    );
    ref.listen<HistoricalArchivesImportSuccessNotice?>(
      historicalArchivesWorkflowProvider.select(
        (state) => state.importSuccessNotice,
      ),
      (previous, next) {
        if (next == null ||
            next.noticeOccurrence == _presentedImportSuccessNoticeOccurrence) {
          return;
        }
        _presentedImportSuccessNoticeOccurrence = next.noticeOccurrence;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          final currentNotice = ref
              .read(historicalArchivesWorkflowProvider)
              .importSuccessNotice;
          if (currentNotice?.noticeOccurrence != next.noticeOccurrence ||
              currentNotice?.presentationSessionOccurrence !=
                  next.presentationSessionOccurrence) {
            return;
          }
          unawaited(_showImportSuccessDialog(next));
        });
      },
    );
    ref.listen<HistoricalArchivesMessageLensNotice?>(
      historicalArchivesWorkflowProvider.select(
        (state) => state.messageLensNotice,
      ),
      (previous, next) {
        if (next == null ||
            next.noticeOccurrence == _presentedMessageLensNoticeOccurrence) {
          return;
        }
        _presentedMessageLensNoticeOccurrence = next.noticeOccurrence;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          final currentNotice = ref
              .read(historicalArchivesWorkflowProvider)
              .messageLensNotice;
          if (currentNotice?.noticeOccurrence != next.noticeOccurrence ||
              currentNotice?.presentationSessionOccurrence !=
                  next.presentationSessionOccurrence) {
            return;
          }
          unawaited(_showMessageLensNoticeDialog(next));
        });
      },
    );
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final panelModel = ref.watch(historicalArchivesWorkflowPanelModelProvider);
    final developerMode = ref.watch(developerModeProvider);
    final showDeveloperControls =
        developerMode.valueOrNull == DeveloperModeValue.developer;
    final narratorPresentation = panelModel.narratorPresentation;
    final existingSourcePresentation = panelModel.existingSourcePresentation;

    if (panelModel.isHub) {
      return const _HistoricalArchivesCenterTrackScaffold(
        surfaceKey: Key('historical-archives-empty-hub'),
      );
    }

    if (existingSourcePresentation != null) {
      return _ExistingHistoricalArchiveSourcePanel(
        panelModel: panelModel,
        presentation: existingSourcePresentation,
      );
    }

    if (narratorPresentation != null) {
      return _NarratorHistoricalArchivesPanel(
        panelModel: panelModel,
        presentation: narratorPresentation,
      );
    }

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
                          _HistoricalArchiveActionButton(
                            label: 'Choose Messages Folder...',
                            enabled: true,
                            onPressed: () {
                              ref
                                  .read(
                                    historicalArchivesWorkflowActionsProvider
                                        .notifier,
                                  )
                                  .chooseMessagesFolder();
                            },
                          ),
                          _HistoricalArchiveActionButton(
                            label: 'Clear Selected Folder',
                            enabled: panelModel.selectedFolderPath != null,
                            onPressed: panelModel.selectedFolderPath == null
                                ? null
                                : () {
                                    ref
                                        .read(
                                          historicalArchivesWorkflowActionsProvider
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
                        tone: _preflightTone(
                          panelModel.preflight.status,
                          colors: colors,
                        ),
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
                      _HistoricalArchiveActionButton(
                        label: 'Begin Import',
                        enabled: panelModel.importButtonEnabled,
                        onPressed: panelModel.importButtonEnabled
                            ? () {
                                ref
                                    .read(
                                      historicalArchivesWorkflowActionsProvider
                                          .notifier,
                                    )
                                    .beginImportForSelectedSource(
                                      waitForOperationPresentation:
                                          _waitForHistoricalArchiveOperationFrame,
                                    );
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
                      const SizedBox(height: 12),
                      Text(
                        'Import safety',
                        style: typography.controlValue.copyWith(
                          color: colors.content.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final line
                          in panelModel.importSafetySummaryLines) ...[
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
                if (showDeveloperControls) ...[
                  const SizedBox(height: 16),
                  _ShellSectionCard(
                    title: 'Developer Testing Controls',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HistoricalArchiveActionButton(
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
                          'Developer/testing only. This deletes source-scoped import rows from MessageLens for the selected archive source, then reprojects the conversation graph.',
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
                ],
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

  Future<void> _showDuplicateFolderDialog(
    HistoricalArchivesDuplicateFolderNotice notice,
  ) async {
    await showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text(
            'This folder has already been added to MessageLens.',
          ),
          content: const Text('You can find it under Folders Already Added.'),
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

    if (!mounted) {
      return;
    }
    ref
        .read(historicalArchivesWorkflowActionsProvider.notifier)
        .dismissDuplicateFolderNotice(
          noticeOccurrence: notice.noticeOccurrence,
          presentationSessionOccurrence: notice.presentationSessionOccurrence,
        );
  }

  Future<void> _showInvalidFolderDialog(
    HistoricalArchivesInvalidFolderNotice notice,
  ) async {
    await showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text(
            'This folder doesn’t appear to contain a Messages archive.',
          ),
          content: const Text(
            'Choose a folder that contains Messages data. It must contain the file chat.db.',
          ),
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

    if (!mounted) {
      return;
    }
    ref
        .read(historicalArchivesWorkflowActionsProvider.notifier)
        .dismissInvalidFolderNotice(
          noticeOccurrence: notice.noticeOccurrence,
          presentationSessionOccurrence: notice.presentationSessionOccurrence,
        );
  }

  Future<void> _showImportSuccessDialog(
    HistoricalArchivesImportSuccessNotice notice,
  ) async {
    await showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Messages folder added'),
          content: const Text(
            'The Messages folder you selected has been successfully added to MessageLens.\n\n'
            'You should now see the additional messages in your message timelines and heatmaps.',
          ),
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

    if (!mounted) {
      return;
    }
    ref
        .read(historicalArchivesWorkflowActionsProvider.notifier)
        .dismissImportSuccessNotice(
          noticeOccurrence: notice.noticeOccurrence,
          presentationSessionOccurrence: notice.presentationSessionOccurrence,
        );
  }

  Future<void> _showLineageDialog(
    HistoricalArchivesLineageNotice notice,
  ) async {
    final contradiction =
        notice.status == MessagesLineageAdmissionStatus.contradictoryLineage;
    await showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text(
            contradiction
                ? 'This Messages folder belongs to a different Messages history and can’t be added here.'
                : 'MessageLens couldn’t verify that this folder came from the same Messages history.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (!mounted) {
      return;
    }
    ref
        .read(historicalArchivesWorkflowActionsProvider.notifier)
        .dismissLineageNotice(
          noticeOccurrence: notice.noticeOccurrence,
          presentationSessionOccurrence: notice.presentationSessionOccurrence,
        );
  }

  Future<void> _showMessageLensNoticeDialog(
    HistoricalArchivesMessageLensNotice notice,
  ) async {
    final (title, content) = switch (notice.kind) {
      HistoricalArchivesMessageLensNoticeKind.invalidFolder => (
        'This doesn’t appear to be a MessageLens data folder.',
        'Choose an older MessageLens data folder and try again.',
      ),
      HistoricalArchivesMessageLensNoticeKind.incompatibleArchive => (
        'MessageLens can’t safely inspect this data folder.',
        'This appears to be a MessageLens folder, but its recovery evidence is not compatible with this version.',
      ),
      HistoricalArchivesMessageLensNoticeKind.contradictoryLineage => (
        'This MessageLens folder belongs to a different Messages history.',
        'It can’t be used to recover attachments here.',
      ),
      HistoricalArchivesMessageLensNoticeKind.insufficientLineage => (
        'MessageLens couldn’t verify this folder’s Messages history.',
        'Attachment recovery requires proof that both folders came from the same Messages history.',
      ),
      HistoricalArchivesMessageLensNoticeKind.nothingRecoverable => (
        'No missing attachments were found.',
        'There are no missing attachments in this folder that MessageLens can safely recover.',
      ),
    };
    await showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (!mounted) {
      return;
    }
    ref
        .read(historicalArchivesWorkflowActionsProvider.notifier)
        .dismissMessageLensNotice(
          noticeOccurrence: notice.noticeOccurrence,
          presentationSessionOccurrence: notice.presentationSessionOccurrence,
        );
  }
}

class _ExistingHistoricalArchiveSourcePanel extends ConsumerWidget {
  const _ExistingHistoricalArchiveSourcePanel({
    required this.panelModel,
    required this.presentation,
  });

  final HistoricalArchivesWorkflowPanelViewModel panelModel;
  final HistoricalArchivesExistingSourcePresentationViewModel presentation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final story = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          key: const Key('historical-archives-existing-source-story'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              presentation.sourceTypeStatement,
              style: typography.title2.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            if (presentation.importDateStatement
                case final importDateStatement?) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                importDateStatement,
                style: typography.body.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ],
            if (presentation.contentsStatement
                case final contentsStatement?) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                contentsStatement,
                style: typography.title3.copyWith(
                  color: colors.content.textPrimary,
                ),
              ),
            ],
            if (presentation.removalFailureStatement
                case final failureStatement?) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                failureStatement,
                key: const Key('historical-archives-removal-failure-statement'),
                style: typography.body.copyWith(color: colors.status.error),
              ),
            ],
            if (presentation.detailsLines.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              _HistoricalArchivesDetailsDisclosure(
                label: 'More Details',
                lines: presentation.detailsLines,
              ),
            ],
            if (panelModel.removeImportedArchiveDataEnabled) ...[
              const SizedBox(height: AppSpacing.xxl),
              _HistoricalArchiveActionButton(
                label: 'Remove this folder…',
                enabled: true,
                destructive: true,
                onPressed: () {
                  unawaited(
                    _showRemoveImportedArchiveDataConfirmationDialog(
                      context: context,
                      ref: ref,
                      panelModel: panelModel,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
    return _HistoricalArchivesCenterTrackScaffold(
      nativeFlowKey: const Key(
        'historical-archives-existing-source-native-flow',
      ),
      nativeFlowBody: story,
    );
  }
}

class _NarratorHistoricalArchivesPanel extends ConsumerWidget {
  const _NarratorHistoricalArchivesPanel({
    required this.panelModel,
    required this.presentation,
  });

  final HistoricalArchivesWorkflowPanelViewModel panelModel;
  final HistoricalArchivesNarratorPresentationViewModel presentation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final narratorText = presentation.narratorText;

    final instrumentationContent = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: historicalArchivesCenterMaximumReadableWidth,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (presentation.instrumentationRows.isNotEmpty) ...[
              Text(
                panelModel.sourceType ==
                        HistoricalArchiveSourceType.messageLensDataFolders
                    ? 'MESSAGELENS ATTACHMENT RECOVERY'
                    : presentation.kind ==
                              HistoricalArchivesNarratorPresentationKind
                                  .removingSource ||
                          presentation.kind ==
                              HistoricalArchivesNarratorPresentationKind
                                  .removalFailed
                    ? 'REMOVING MESSAGES FOLDER'
                    : presentation.kind ==
                              HistoricalArchivesNarratorPresentationKind
                                  .importingArchive ||
                          presentation.kind ==
                              HistoricalArchivesNarratorPresentationKind
                                  .importFailed
                    ? 'ADDING MESSAGES FOLDER'
                    : 'MESSAGES ARCHIVE',
                style: typography.caption.copyWith(
                  color: colors.content.textTertiary,
                ),
              ),
              const SizedBox(height: 14),
              _DirectedInstrumentation(rows: presentation.instrumentationRows),
            ],
            if (_hasNarratorDecision(presentation.kind)) ...[
              const SizedBox(height: 36),
              _NarratorDecision(
                panelModel: panelModel,
                presentation: presentation,
              ),
            ],
            if (presentation.detailsLines.isNotEmpty) ...[
              const SizedBox(height: 28),
              _HistoricalArchivesDetailsDisclosure(
                key: ValueKey<HistoricalArchivesNarratorPresentationKind>(
                  presentation.kind,
                ),
                lines: presentation.detailsLines,
              ),
            ],
          ],
        ),
      ),
    );
    final isRemoval =
        presentation.kind ==
            HistoricalArchivesNarratorPresentationKind.removingSource ||
        presentation.kind ==
            HistoricalArchivesNarratorPresentationKind.removalFailed;

    return _HistoricalArchivesCenterTrackScaffold(
      nativeFlowKey: Key(
        isRemoval
            ? 'historical-archives-removal-native-flow'
            : 'historical-archives-narrator-native-flow',
      ),
      nativeFlowBody: instrumentationContent,
      fallbackBody: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: historicalArchivesCenterMaximumReadableWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historical Archives',
                key: const Key('historical-archives-page-title'),
                style: typography.title1.copyWith(
                  color: colors.content.textPrimary,
                ),
              ),
              const SizedBox(height: historicalArchivesTitleToNarratorGap),
              if (narratorText != null)
                Text(
                  narratorText,
                  key: const Key('historical-archives-narrator'),
                  style: typography.title1.copyWith(
                    color: colors.content.textPrimary,
                  ),
                ),
              const SizedBox(
                height: historicalArchivesNarratorToInstrumentationGap,
              ),
              instrumentationContent,
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoricalArchivesCenterTrackScaffold extends ConsumerWidget {
  const _HistoricalArchivesCenterTrackScaffold({
    this.surfaceKey,
    this.nativeFlowKey,
    this.nativeFlowBody,
    this.fallbackBody,
  });

  final Key? surfaceKey;
  final Key? nativeFlowKey;
  final Widget? nativeFlowBody;
  final Widget? fallbackBody;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final resolvedMatrix = ResolvedTrackLayoutMatrixScope.maybeOf(context);
    final body = nativeFlowBody;

    if (resolvedMatrix == null) {
      return ColoredBox(
        key: surfaceKey,
        color: colors.surfaces.canvas,
        child: body == null && fallbackBody == null
            ? const SizedBox.expand()
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: historicalArchivesCenterHorizontalInset,
                  vertical: 36,
                ),
                child: fallbackBody ?? body,
              ),
      );
    }

    return ColoredBox(
      key: surfaceKey,
      color: colors.surfaces.canvas,
      child: SingleChildScrollView(
        child: Column(
          key: const Key('historical-archives-center-track-skeleton'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final trackId in resolvedMatrix.trackIds)
              TrackCellView(
                cellId: CellId(
                  trackId: trackId,
                  columnId: TrackColumnId.column2,
                ),
              ),
            if (body != null)
              Padding(
                key: nativeFlowKey,
                padding: const EdgeInsets.fromLTRB(
                  historicalArchivesCenterHorizontalInset,
                  0,
                  historicalArchivesCenterHorizontalInset,
                  36,
                ),
                child: body,
              ),
          ],
        ),
      ),
    );
  }
}

bool _hasNarratorDecision(HistoricalArchivesNarratorPresentationKind kind) {
  return switch (kind) {
    HistoricalArchivesNarratorPresentationKind.noSource ||
    HistoricalArchivesNarratorPresentationKind.inspectingSource ||
    HistoricalArchivesNarratorPresentationKind.inspectingMessageLensSource ||
    HistoricalArchivesNarratorPresentationKind.importingArchive ||
    HistoricalArchivesNarratorPresentationKind.removingSource ||
    HistoricalArchivesNarratorPresentationKind.removalFailed => false,
    HistoricalArchivesNarratorPresentationKind.inspectionFailed ||
    HistoricalArchivesNarratorPresentationKind.readyForImport ||
    HistoricalArchivesNarratorPresentationKind.messageLensReady ||
    HistoricalArchivesNarratorPresentationKind.importFailed ||
    HistoricalArchivesNarratorPresentationKind.knownSource => true,
  };
}

class _DirectedInstrumentation extends ConsumerWidget {
  const _DirectedInstrumentation({required this.rows});

  final List<HistoricalArchivesInstrumentationRowViewModel> rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Column(
      key: const Key('historical-archives-directed-instrumentation'),
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          Padding(
            padding: EdgeInsets.only(
              left: rows[index].indentationLevel * 32,
              top: 9,
              bottom: 9,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: _InstrumentationStatusMark(status: rows[index].status),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rows[index].label,
                    style: typography.body.copyWith(
                      color: colors.content.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Text(
                  rows[index].value,
                  style: typography.controlValue.copyWith(
                    color: _instrumentationValueColor(
                      rows[index].status,
                      colors: colors,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (index < rows.length - 1)
            Padding(
              padding: EdgeInsets.only(left: rows[index].indentationLevel * 32),
              child: ColoredBox(
                color: colors.lines.borderSubtle,
                child: const SizedBox(height: 1),
              ),
            ),
        ],
      ],
    );
  }
}

class _InstrumentationStatusMark extends ConsumerWidget {
  const _InstrumentationStatusMark({required this.status});

  final HistoricalArchivesInstrumentationStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return switch (status) {
      HistoricalArchivesInstrumentationStatus.waiting => Icon(
        CupertinoIcons.circle,
        size: 18,
        color: colors.content.textTertiary,
      ),
      HistoricalArchivesInstrumentationStatus.working =>
        const CupertinoActivityIndicator(radius: 8),
      HistoricalArchivesInstrumentationStatus.resolved => Icon(
        CupertinoIcons.check_mark_circled_solid,
        size: 18,
        color: colors.status.success,
      ),
      HistoricalArchivesInstrumentationStatus.failed => Icon(
        CupertinoIcons.exclamationmark_circle_fill,
        size: 18,
        color: colors.status.error,
      ),
    };
  }
}

class _NarratorDecision extends ConsumerWidget {
  const _NarratorDecision({
    required this.panelModel,
    required this.presentation,
  });

  final HistoricalArchivesWorkflowPanelViewModel panelModel;
  final HistoricalArchivesNarratorPresentationViewModel presentation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.read(
      historicalArchivesWorkflowActionsProvider.notifier,
    );

    return switch (presentation.kind) {
      HistoricalArchivesNarratorPresentationKind.noSource =>
        const SizedBox.shrink(),
      HistoricalArchivesNarratorPresentationKind.inspectingSource =>
        const SizedBox.shrink(),
      HistoricalArchivesNarratorPresentationKind.inspectingMessageLensSource =>
        const SizedBox.shrink(),
      HistoricalArchivesNarratorPresentationKind.importingArchive =>
        const SizedBox.shrink(),
      HistoricalArchivesNarratorPresentationKind.removingSource ||
      HistoricalArchivesNarratorPresentationKind.removalFailed =>
        const SizedBox.shrink(),
      HistoricalArchivesNarratorPresentationKind.inspectionFailed => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          if (presentation.retryInspectionEnabled)
            _HistoricalArchiveActionButton(
              label: 'Retry',
              enabled: true,
              onPressed: actions.retrySelectedFolderInspection,
            ),
          _HistoricalArchiveActionButton(
            label: 'Choose Another Folder',
            enabled: true,
            onPressed: actions.chooseMessagesFolder,
          ),
        ],
      ),
      HistoricalArchivesNarratorPresentationKind.readyForImport => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _HistoricalArchiveActionButton(
            label: 'Add Messages to MessageLens',
            enabled: panelModel.importButtonEnabled,
            primary: true,
            onPressed: () {
              actions.beginImportForSelectedSource(
                waitForOperationPresentation:
                    _waitForHistoricalArchiveOperationFrame,
              );
            },
          ),
          _HistoricalArchiveActionButton(
            label: 'Cancel',
            enabled: true,
            onPressed: actions.cancelAddArchive,
          ),
        ],
      ),
      HistoricalArchivesNarratorPresentationKind.messageLensReady => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _HistoricalArchiveActionButton(
            label: 'Cancel',
            enabled: true,
            onPressed: actions.cancelAddArchive,
          ),
        ],
      ),
      HistoricalArchivesNarratorPresentationKind.importFailed => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          if (panelModel.importButtonEnabled)
            _HistoricalArchiveActionButton(
              label: 'Try Again',
              enabled: true,
              onPressed: () {
                actions.beginImportForSelectedSource(
                  waitForOperationPresentation:
                      _waitForHistoricalArchiveOperationFrame,
                );
              },
            ),
          _HistoricalArchiveActionButton(
            label: 'Choose Another Folder',
            enabled: true,
            onPressed: actions.chooseMessagesFolder,
          ),
        ],
      ),
      HistoricalArchivesNarratorPresentationKind.knownSource =>
        _HistoricalArchiveActionButton(
          label: 'Choose Archive Folder',
          enabled: true,
          onPressed: actions.chooseMessagesFolder,
        ),
    };
  }
}

class _HistoricalArchivesDetailsDisclosure extends ConsumerStatefulWidget {
  const _HistoricalArchivesDetailsDisclosure({
    required this.lines,
    this.label = 'Details',
    super.key,
  });

  final List<String> lines;
  final String label;

  @override
  ConsumerState<_HistoricalArchivesDetailsDisclosure> createState() =>
      _HistoricalArchivesDetailsDisclosureState();
}

class _HistoricalArchivesDetailsDisclosureState
    extends ConsumerState<_HistoricalArchivesDetailsDisclosure> {
  var _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            key: const Key('historical-archives-details-toggle'),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isExpanded
                      ? CupertinoIcons.chevron_down
                      : CupertinoIcons.chevron_right,
                  size: 14,
                  color: colors.content.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: typography.controlValue.copyWith(
                    color: colors.content.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 14),
          for (final line in widget.lines) ...[
            Text(
              line,
              key: ValueKey<String>('historical-archives-detail-$line'),
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
            const SizedBox(height: 7),
          ],
        ],
      ],
    );
  }
}

Color _instrumentationValueColor(
  HistoricalArchivesInstrumentationStatus status, {
  required ThemeColors colors,
}) {
  return switch (status) {
    HistoricalArchivesInstrumentationStatus.waiting =>
      colors.content.textTertiary,
    HistoricalArchivesInstrumentationStatus.working => colors.status.warning,
    HistoricalArchivesInstrumentationStatus.resolved => colors.status.success,
    HistoricalArchivesInstrumentationStatus.failed => colors.status.error,
  };
}

Future<void> _showRemoveImportedArchiveDataConfirmationDialog({
  required BuildContext context,
  required WidgetRef ref,
  required HistoricalArchivesWorkflowPanelViewModel panelModel,
}) async {
  final targetPath = panelModel.archiveRemovalTargetChatDbPath;
  if (targetPath == null) {
    return;
  }

  final confirmed = await showCupertinoDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return CupertinoAlertDialog(
        title: const Text('Remove this folder from MessageLens?'),
        content: const Text(
          'The messages added from this folder will be removed from MessageLens. Your original Messages folder will not be changed.',
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
            child: const Text('Remove Folder'),
          ),
        ],
      );
    },
  );

  if (confirmed == true) {
    await ref
        .read(historicalArchivesWorkflowActionsProvider.notifier)
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
              'Import historical Messages folders without replacing current message data.',
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
                    tone: _executionGateTone(
                      executionGate.status,
                      colors: colors,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusSummaryTile(
                    title: 'Preflight',
                    statusLabel: preflight.statusLabel,
                    detail: preflight.detail,
                    tone: _preflightTone(preflight.status, colors: colors),
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

class _HistoricalArchiveActionButton extends ConsumerWidget {
  const _HistoricalArchiveActionButton({
    required this.label,
    this.enabled = false,
    this.destructive = false,
    this.primary = false,
    this.onPressed,
  });

  final String label;
  final bool enabled;
  final bool destructive;
  final bool primary;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final isInteractive = enabled && onPressed != null;

    if (primary) {
      return AppThemeWidgets.primaryButton(
        ref: ref,
        label: label,
        onPressed: isInteractive ? onPressed : null,
      );
    }

    return MouseRegion(
      cursor: isInteractive
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isInteractive ? onPressed : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: destructive
                ? colors.surfaces.control
                : enabled
                ? colors.accents.primary.withValues(alpha: 0.10)
                : colors.surfaces.control,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: destructive
                  ? colors.buttons.destructiveBorder
                  : enabled
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
                color: destructive
                    ? colors.buttons.destructiveForeground
                    : enabled
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

Color _executionGateTone(
  HistoricalArchivesExecutionGateStatus status, {
  required ThemeColors colors,
}) {
  return switch (status) {
    HistoricalArchivesExecutionGateStatus.available => colors.status.success,
    HistoricalArchivesExecutionGateStatus.busy => colors.status.warning,
    HistoricalArchivesExecutionGateStatus.blocked => colors.status.error,
  };
}

Color _preflightTone(
  HistoricalArchivesPreflightStatus status, {
  required ThemeColors colors,
}) {
  return switch (status) {
    HistoricalArchivesPreflightStatus.waitingForFolder =>
      colors.content.textTertiary,
    HistoricalArchivesPreflightStatus.running => colors.status.warning,
    HistoricalArchivesPreflightStatus.completeReadyToImport =>
      colors.status.success,
    HistoricalArchivesPreflightStatus.failed => colors.status.error,
  };
}
