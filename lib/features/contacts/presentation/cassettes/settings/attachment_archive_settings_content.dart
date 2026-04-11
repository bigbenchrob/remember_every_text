import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' show ProgressBar;

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/debug/application/developer_mode_provider.dart';
import '../../../../attachments/application/archive_settings_provider.dart';
import '../../../../attachments/application/attachment_archive_service_provider.dart';
import '../../../../attachments/application/deterministic_recovery_provider.dart';

/// Lightweight state holder for inline status messages (replaces SnackBar).
class _ArchiveStatusMessageNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void show(String message) {
    state = message;
    Future<void>.delayed(const Duration(seconds: 4), () {
      if (state == message) {
        state = null;
      }
    });
  }
}

final _archiveStatusMessageProvider =
    NotifierProvider<_ArchiveStatusMessageNotifier, String?>(
      _ArchiveStatusMessageNotifier.new,
    );

/// Widget embedded inside the SidebarInfoCard for the attachment archive
/// settings cassette. Displays a toggle, archive statistics, and a clear
/// archive action.
class AttachmentArchiveSettingsContent extends ConsumerWidget {
  const AttachmentArchiveSettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final settingsAsync = ref.watch(archiveSettingsProvider);
    final developerMode = ref.watch(developerModeProvider);
    final showDeveloperSweepPanel =
        developerMode.valueOrNull == DeveloperModeValue.developer;

    return settingsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CupertinoActivityIndicator(),
        ),
      ),
      error: (error, _) => Text(
        'Failed to load archive settings',
        style: typography.infoCardBody.copyWith(
          color: colors.content.textTertiary,
        ),
      ),
      data: (settings) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enable / Disable toggle
          Row(
            children: [
              Expanded(
                child: Text(
                  'Auto-archive attachments',
                  style: typography.infoCardBody.copyWith(
                    color: colors.content.textPrimary,
                  ),
                ),
              ),
              CupertinoSwitch(
                value: settings.isEnabled,
                onChanged: (value) {
                  ref
                      .read(archiveSettingsProvider.notifier)
                      .setEnabled(enabled: value);
                },
              ),
            ],
          ),

          if (settings.isEnabled) ...[const SizedBox(height: 12)],

          // Stats row
          Text(
            '${settings.archivedCount} attachments archived'
            '  \u00B7  ${settings.formattedSize}',
            style: typography.infoCardBody.copyWith(
              color: colors.content.textTertiary,
              fontSize: 11,
            ),
          ),

          // Bulk archive progress indicator
          _BulkArchiveProgressSection(colors: colors, typography: typography),

          // Deterministic historical recovery section
          const SizedBox(height: 12),
          _DeterministicRecoverySection(colors: colors, typography: typography),

          if (settings.isEnabled && showDeveloperSweepPanel) ...[
            const SizedBox(height: 12),
            _ArchiveSweepDeveloperPanel(
              colors: colors,
              typography: typography,
              settings: settings,
            ),
          ],

          // Clear archive button (only if there are archived files)
          if (settings.archivedCount > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final result = await ref
                        .read(attachmentArchiveServiceProvider.notifier)
                        .verifyIntegrity();
                    if (!context.mounted) {
                      return;
                    }
                    ref
                        .read(_archiveStatusMessageProvider.notifier)
                        .show(
                          result.allGood
                              ? '\u2705 ${result.verified} files verified OK'
                                    '${result.noHash > 0 ? ' (${result.noHash} without hash)' : ''}'
                              : '\u26A0\uFE0F ${result.hashMismatch} corrupted, '
                                    '${result.fileMissing} missing '
                                    'of ${result.totalRecords} records',
                        );
                  },
                  child: Text(
                    'Verify Archive',
                    style: typography.infoCardBody.copyWith(
                      color: colors.accents.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () async {
                    final count = await ref
                        .read(archiveSettingsProvider.notifier)
                        .exportArchive();
                    if (!context.mounted || count == null) {
                      return;
                    }
                    ref
                        .read(_archiveStatusMessageProvider.notifier)
                        .show('Exported $count files');
                  },
                  child: Text(
                    'Export\u2026',
                    style: typography.infoCardBody.copyWith(
                      color: colors.accents.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () async {
                    await ref
                        .read(archiveSettingsProvider.notifier)
                        .clearArchive();
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.buttons.destructiveForeground.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        'Clear Archive\u2026',
                        style: typography.infoCardBody.copyWith(
                          color: colors.buttons.destructiveForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Inline status message (replaces SnackBar)
          _ArchiveStatusMessage(colors: colors, typography: typography),
        ],
      ),
    );
  }
}

class _ArchiveSweepDeveloperPanel extends ConsumerWidget {
  const _ArchiveSweepDeveloperPanel({
    required this.colors,
    required this.typography,
    required this.settings,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final ArchiveSettingsState settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sweepDebug = settings.sweepDebug;
    final manualSweepDebug = settings.manualSweepDebug;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Developer Sweep Panel',
              style: typography.infoCardBody.copyWith(
                color: colors.content.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Background sweep checks a small rolling chunk of unarchived '
              'image attachments about every 5 minutes.',
              style: typography.infoCardBody.copyWith(
                color: colors.content.textTertiary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last background chunk started: ${sweepDebug.lastStartedLabel}',
              style: typography.infoCardBody.copyWith(
                color: colors.content.textSecondary,
                fontSize: 11,
              ),
            ),
            Text(
              'Last background chunk completed: ${sweepDebug.lastCompletedLabel}',
              style: typography.infoCardBody.copyWith(
                color: colors.content.textSecondary,
                fontSize: 11,
              ),
            ),
            Text(
              sweepDebug.hasCompletedRun
                  ? 'Last background chunk result: ${sweepDebug.lastResultLabel}'
                  : 'Last background chunk result: No maintenance chunk has completed yet.',
              style: typography.infoCardBody.copyWith(
                color: colors.content.textSecondary,
                fontSize: 11,
              ),
            ),
            Text(
              'Current cursor: ${sweepDebug.cursor}',
              style: typography.infoCardBody.copyWith(
                color: colors.content.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Last manual burst started: ${manualSweepDebug.lastStartedLabel}',
              style: typography.infoCardBody.copyWith(
                color: colors.content.textSecondary,
                fontSize: 11,
              ),
            ),
            Text(
              'Last manual burst completed: ${manualSweepDebug.lastCompletedLabel}',
              style: typography.infoCardBody.copyWith(
                color: colors.content.textSecondary,
                fontSize: 11,
              ),
            ),
            Text(
              manualSweepDebug.hasCompletedRun
                  ? 'Last manual burst result: ${manualSweepDebug.lastResultLabel}'
                  : 'Last manual burst result: No manual burst has completed yet.',
              style: typography.infoCardBody.copyWith(
                color: colors.content.textSecondary,
                fontSize: 11,
              ),
            ),
            if (manualSweepDebug.lastSkippedSamples.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Sample skipped rows:',
                style: typography.infoCardBody.copyWith(
                  color: colors.content.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              for (final sample in manualSweepDebug.lastSkippedSamples)
                Text(
                  sample,
                  style: typography.infoCardBody.copyWith(
                    color: colors.content.textTertiary,
                    fontSize: 10,
                  ),
                ),
            ],
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final result = await ref
                    .read(attachmentArchiveServiceProvider.notifier)
                    .archiveWorkingSweepBurst();
                if (!context.mounted) {
                  return;
                }
                ref
                    .read(_archiveStatusMessageProvider.notifier)
                    .show(
                      'Manual burst scanned ${result.totalScanned}, archived '
                      '${result.newlyArchived}, skipped ${result.skipped}, '
                      'failed ${result.failed}',
                    );
              },
              child: Text(
                'Run Sweep Now',
                style: typography.infoCardBody.copyWith(
                  color: colors.accents.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sub-widget: Bulk archive progress indicator with pause/resume/cancel.
///
/// Only visible when a bulk archive operation is running, paused, or just
/// completed. Hidden when idle.
class _BulkArchiveProgressSection extends ConsumerWidget {
  const _BulkArchiveProgressSection({
    required this.colors,
    required this.typography,
  });

  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(attachmentArchiveServiceProvider);

    if (progress.phase == BulkArchivePhase.idle) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: switch (progress.phase) {
        BulkArchivePhase.idle => const SizedBox.shrink(),
        BulkArchivePhase.running => _buildRunning(progress, ref),
        BulkArchivePhase.paused => _buildPaused(progress, ref),
        BulkArchivePhase.complete => _buildComplete(progress, ref),
      },
    );
  }

  Widget _buildRunning(BulkArchiveProgress progress, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const CupertinoActivityIndicator(radius: 8),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Archiving ${progress.processedItems} '
                'of ${progress.totalItems}\u2026',
                style: typography.infoCardBody.copyWith(
                  color: colors.content.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ProgressBar(
          value: progress.progress * 100,
          trackColor: colors.accents.primary,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _controlButton(
              label: 'Pause',
              onTap: () {
                ref.read(attachmentArchiveServiceProvider.notifier).pause();
              },
            ),
            const SizedBox(width: 12),
            _controlButton(
              label: 'Cancel',
              onTap: () {
                ref.read(attachmentArchiveServiceProvider.notifier).cancel();
              },
              isDestructive: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaused(BulkArchiveProgress progress, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Archiving paused \u2014 ${progress.processedItems} '
          'of ${progress.totalItems} '
          '(${progress.newlyArchived} new)',
          style: typography.infoCardBody.copyWith(
            color: colors.content.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        ProgressBar(
          value: progress.progress * 100,
          trackColor: colors.content.textTertiary,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _controlButton(
              label: 'Resume',
              onTap: () {
                ref.read(attachmentArchiveServiceProvider.notifier).resume();
              },
            ),
            const SizedBox(width: 12),
            _controlButton(
              label: 'Cancel',
              onTap: () {
                ref.read(attachmentArchiveServiceProvider.notifier).cancel();
              },
              isDestructive: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComplete(BulkArchiveProgress progress, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Archive complete \u2014 ${progress.newlyArchived} new '
          'of ${progress.totalItems} scanned',
          style: typography.infoCardBody.copyWith(
            color: colors.content.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            ref
                .read(attachmentArchiveServiceProvider.notifier)
                .dismissProgress();
          },
          child: Text(
            'Dismiss',
            style: typography.infoCardBody.copyWith(
              color: colors.accents.primary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _controlButton({
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: typography.infoCardBody.copyWith(
          color: isDestructive
              ? colors.buttons.destructiveForeground
              : colors.accents.primary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Sub-widget: Deterministic recovery from a historical Messages backup.
///
/// Allows the user to pick a chat.db file and an Attachments folder from a
/// Time Machine or manual backup, then runs the three-layer deterministic
/// pipeline (snapshot reader → cross-snapshot mapper → archive writer).
class _DeterministicRecoverySection extends ConsumerWidget {
  const _DeterministicRecoverySection({
    required this.colors,
    required this.typography,
  });

  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recoveryState = ref.watch(deterministicRecoveryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Recover from Historical Backup',
          style: typography.infoCardBody.copyWith(
            color: colors.content.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Recover attachments from a historical Messages backup '
          '(e.g. Time Machine). Select the chat.db file and '
          'Attachments folder from the backup.',
          style: typography.infoCardBody.copyWith(
            color: colors.content.textTertiary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),

        // Action / progress / result display
        switch (recoveryState.phase) {
          DeterministicRecoveryPhase.idle => _buildStartButton(ref),
          DeterministicRecoveryPhase.complete => _buildResult(
            recoveryState,
            ref,
          ),
          DeterministicRecoveryPhase.error => _buildError(recoveryState, ref),
          _ => _buildProgress(recoveryState, ref),
        },
      ],
    );
  }

  Widget _buildStartButton(WidgetRef ref) {
    return GestureDetector(
      onTap: () => _startRecovery(ref),
      child: Text(
        'Select Backup\u2026',
        style: typography.infoCardBody.copyWith(
          color: colors.accents.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _startRecovery(WidgetRef ref) async {
    // Step 1: Pick the chat.db file
    const dbTypeGroup = XTypeGroup(
      label: 'SQLite database',
      extensions: ['db'],
    );
    final chatDbPath = await FileSelectorPlatform.instance.openFile(
      acceptedTypeGroups: [dbTypeGroup],
      confirmButtonText: 'Select chat.db',
    );
    if (chatDbPath == null) {
      return;
    }

    // Step 2: Pick the Attachments folder
    final attachmentsFolder = await FileSelectorPlatform.instance
        .getDirectoryPathWithOptions(
          const FileDialogOptions(
            confirmButtonText: 'Select Attachments Folder',
          ),
        );
    if (attachmentsFolder == null) {
      return;
    }

    // Launch recovery
    await ref
        .read(deterministicRecoveryProvider.notifier)
        .recover(
          chatDbPath: chatDbPath.path,
          attachmentsFolderPath: attachmentsFolder,
        );
  }

  Widget _buildProgress(
    DeterministicRecoveryState recoveryState,
    WidgetRef ref,
  ) {
    final phaseLabel = switch (recoveryState.phase) {
      DeterministicRecoveryPhase.validating => 'Validating backup\u2026',
      DeterministicRecoveryPhase.readingSnapshot =>
        'Reading historical database\u2026',
      DeterministicRecoveryPhase.mapping => 'Mapping attachments\u2026',
      DeterministicRecoveryPhase.archiving =>
        'Archiving ${recoveryState.phaseProgress} '
            'of ${recoveryState.phaseTotal}\u2026',
      _ => '',
    };

    final hasProgress = recoveryState.phaseTotal > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const CupertinoActivityIndicator(radius: 8),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                phaseLabel,
                style: typography.infoCardBody.copyWith(
                  color: colors.content.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        if (hasProgress) ...[
          const SizedBox(height: 6),
          ProgressBar(
            value:
                (recoveryState.phaseProgress / recoveryState.phaseTotal) * 100,
            trackColor: colors.accents.primary,
          ),
        ],
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            ref.read(deterministicRecoveryProvider.notifier).cancel();
          },
          child: Text(
            'Cancel',
            style: typography.infoCardBody.copyWith(
              color: colors.buttons.destructiveForeground,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult(DeterministicRecoveryState recoveryState, WidgetRef ref) {
    final result = recoveryState.result!;
    final sizeStr = _formatBytes(result.totalBytesArchived);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Recovery complete \u2014 ${result.archivedNew} new files '
          'archived ($sizeStr)',
          style: typography.infoCardBody.copyWith(
            color: colors.content.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${result.totalHistoricalPairs} historical records  '
          '\u00B7  ${result.filesFound} files found  '
          '\u00B7  ${result.totalMapped} mapped\n'
          '${result.mappedByGuid} by GUID  '
          '\u00B7  ${result.mappedBySingleFallback} by single-attachment '
          'fallback\n'
          '${result.skippedAlreadyArchived} already archived  '
          '\u00B7  ${result.archiveFailed} failed',
          style: typography.infoCardBody.copyWith(
            color: colors.content.textTertiary,
            fontSize: 10,
          ),
        ),
        if (result.walDetected || result.shmDetected) ...[
          const SizedBox(height: 4),
          Text(
            '\u26A0\uFE0F WAL/SHM files detected alongside chat.db \u2014 '
            'backup may contain uncommitted transactions.',
            style: typography.infoCardBody.copyWith(
              color: colors.buttons.destructiveForeground,
              fontSize: 10,
            ),
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                ref.read(deterministicRecoveryProvider.notifier).reset();
              },
              child: Text(
                'Dismiss',
                style: typography.infoCardBody.copyWith(
                  color: colors.accents.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _startRecovery(ref),
              child: Text(
                'Run Again\u2026',
                style: typography.infoCardBody.copyWith(
                  color: colors.accents.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildError(DeterministicRecoveryState recoveryState, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '\u274C ${recoveryState.errorMessage ?? 'Recovery failed'}',
          style: typography.infoCardBody.copyWith(
            color: colors.buttons.destructiveForeground,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                ref.read(deterministicRecoveryProvider.notifier).reset();
              },
              child: Text(
                'Dismiss',
                style: typography.infoCardBody.copyWith(
                  color: colors.accents.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _startRecovery(ref),
              child: Text(
                'Try Again\u2026',
                style: typography.infoCardBody.copyWith(
                  color: colors.accents.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Inline status message that auto-dismisses after 4 seconds.
class _ArchiveStatusMessage extends ConsumerWidget {
  const _ArchiveStatusMessage({required this.colors, required this.typography});

  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(_archiveStatusMessageProvider);
    if (message == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        style: typography.infoCardBody.copyWith(
          color: colors.content.textSecondary,
          fontSize: 11,
        ),
      ),
    );
  }
}
