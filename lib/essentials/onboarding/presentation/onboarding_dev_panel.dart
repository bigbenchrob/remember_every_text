import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/theme_typography.dart';
import '../../db_importers/domain/entities/db_import_result.dart';
import '../../db_importers/presentation/view_model/db_import_control_provider.dart';
import '../../db_migrate/domain/entities/db_migration_result.dart';
import '../application/onboarding_environment_report_provider.dart';
import '../application/onboarding_gate_provider.dart';
import '../domain/onboarding_environment_report.dart';
import '../domain/onboarding_status.dart';
import 'onboarding_progress_view.dart';

/// Amber tone for FDA warning icon.
const _kWarningAmber = Color(0xFFFF9500);

/// Developer panel that mirrors the onboarding overlay UI in the center panel.
///
/// Includes a "Reset & Re-trigger" button that deletes both databases and
/// re-checks the onboarding gate, simulating a fresh first-run scenario.
class OnboardingDevPanel extends ConsumerWidget {
  const OnboardingDevPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final status = ref.watch(onboardingGateProvider);
    final report = ref.watch(onboardingEnvironmentReportProvider).valueOrNull;
    final controlState = ref.watch(dbImportControlViewModelProvider);

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status and reset button.
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Onboarding Dev Panel',
                        style: typography.headline.copyWith(
                          color: colors.content.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${status.name}',
                        style: typography.caption.copyWith(
                          color: colors.content.textSecondary,
                        ),
                      ),
                      if (report != null)
                        Text(
                          'Blocker: ${report.blockerKind.name} • Sync: ${report.syncPlausibility.name}${_pipelineSummary(report)}',
                          style: typography.caption.copyWith(
                            color: colors.content.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: colors.buttons.secondaryBackground,
                  onPressed: () {
                    ref
                        .read(onboardingGateProvider.notifier)
                        .refreshEnvironment();
                  },
                  child: Text(
                    'Refresh Diagnostics',
                    style: typography.body.copyWith(
                      color: colors.buttons.secondaryForeground,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: colors.buttons.destructiveForeground,
                  onPressed: controlState.isProcessing
                      ? null
                      : () async {
                          final notifier = ref.read(
                            dbImportControlViewModelProvider.notifier,
                          );
                          await notifier.resetAllDatabases();
                          // Re-evaluate the onboarding gate after DBs are deleted.
                          ref.invalidate(onboardingGateProvider);
                        },
                  child: Text(
                    'Reset DBs & Re-trigger',
                    style: typography.body.copyWith(
                      color: colors.buttons.primaryForeground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(color: colors.lines.borderSubtle),
            const SizedBox(height: 16),
            _DevSimulationControls(colors: colors, typography: typography),
            const SizedBox(height: 16),
            if (report != null) ...[
              _DevEnvironmentSummary(
                report: report,
                colors: colors,
                typography: typography,
              ),
              const SizedBox(height: 16),
            ],
            // Onboarding card content — same as the overlay.
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: switch (status) {
                    OnboardingStatus.recoveringFailedAttempt =>
                      _DevRecoveryContent(
                        colors: colors,
                        typography: typography,
                        controlState: controlState,
                        report: report,
                      ),
                    OnboardingStatus.awaitingFda => _DevFdaContent(
                      colors: colors,
                      typography: typography,
                    ),
                    OnboardingStatus.awaitingUserAction => _DevWelcomeContent(
                      colors: colors,
                      typography: typography,
                    ),
                    OnboardingStatus.importing ||
                    OnboardingStatus.migrating ||
                    OnboardingStatus.reimporting ||
                    OnboardingStatus.reimportMigrating => _DevProgressContent(
                      colors: colors,
                      typography: typography,
                      controlState: controlState,
                    ),
                    OnboardingStatus.complete ||
                    OnboardingStatus.reimportComplete => _DevCompleteContent(
                      colors: colors,
                      typography: typography,
                      controlState: controlState,
                    ),
                    OnboardingStatus.notNeeded => _DevNotNeededContent(
                      colors: colors,
                      typography: typography,
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DevSimulationControls extends ConsumerWidget {
  const _DevSimulationControls({
    required this.colors,
    required this.typography,
  });

  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overrides = ref.watch(onboardingDevOverridesProvider);
    final notifier = ref.read(onboardingDevOverridesProvider.notifier);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Simulation Controls',
                  style: typography.body.copyWith(
                    color: colors.content.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (overrides.hasAnyOverride)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: () {
                    notifier.clearAll();
                  },
                  child: Text(
                    'Clear Simulations',
                    style: typography.caption.copyWith(
                      color: colors.accents.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'These controls only simulate onboarding states inside the app. They do not change macOS permissions or source databases.',
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _SimulationToggleRow(
            label: 'Simulate Full Disk Access blocked',
            value: overrides.simulateFullDiskAccessBlocked,
            colors: colors,
            typography: typography,
            onChanged: (value) {
              notifier.setFullDiskAccessBlocked(enabled: value);
            },
          ),
          _SimulationToggleRow(
            label: 'Simulate Messages database missing',
            value: overrides.simulateMessagesDatabaseMissing,
            colors: colors,
            typography: typography,
            onChanged: (value) {
              notifier.setMessagesDatabaseMissing(enabled: value);
            },
          ),
          _SimulationToggleRow(
            label: 'Simulate Contacts source unavailable',
            value: overrides.simulateAddressBookUnavailable,
            colors: colors,
            typography: typography,
            onChanged: (value) {
              notifier.setAddressBookUnavailable(enabled: value);
            },
          ),
          _SimulationToggleRow(
            label: 'Simulate sparse local message history',
            value: overrides.simulateSparseSourceHistory,
            colors: colors,
            typography: typography,
            onChanged: (value) {
              notifier.setSparseSourceHistory(enabled: value);
            },
          ),
          _SimulationToggleRow(
            label: 'Simulate import failure',
            value: overrides.simulateImportFailure,
            colors: colors,
            typography: typography,
            onChanged: (value) {
              notifier.setImportFailure(enabled: value);
            },
          ),
          _SimulationToggleRow(
            label: 'Simulate migration failure',
            value: overrides.simulateMigrationFailure,
            colors: colors,
            typography: typography,
            onChanged: (value) {
              notifier.setMigrationFailure(enabled: value);
            },
          ),
        ],
      ),
    );
  }
}

class _SimulationToggleRow extends StatelessWidget {
  const _SimulationToggleRow({
    required this.label,
    required this.value,
    required this.colors,
    required this.typography,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ThemeColors colors;
  final ThemeTypography typography;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: typography.body.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _DevEnvironmentSummary extends StatelessWidget {
  const _DevEnvironmentSummary({
    required this.report,
    required this.colors,
    required this.typography,
  });

  final OnboardingEnvironmentReport report;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Environment Report',
            style: typography.body.copyWith(
              color: colors.content.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Messages: ${_probeSummary(report.messagesDatabase)}',
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          Text(
            'Contacts: ${report.addressBookDatabase == null ? report.addressBookFailureMessage ?? 'Unavailable' : _probeSummary(report.addressBookDatabase!)}',
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          Text(
            'Source-scoped import ledger: ${_probeSummary(report.importDatabase)}',
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          Text(
            'Conversation graph: ${_probeSummary(report.workingDatabase)}',
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          if (report.hasImportFailure)
            Text(
              'Last import error: ${report.importFailureMessage ?? 'Unknown error'}${_failureTimestampSuffix(report.lastImportFailureRecordedAt, persisted: report.usingPersistedImportFailure)}',
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          if (report.hasMigrationFailure)
            Text(
              'Last migration error: ${report.migrationFailureMessage ?? 'Unknown error'}${_failureTimestampSuffix(report.lastMigrationFailureRecordedAt, persisted: report.usingPersistedMigrationFailure)}',
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

String _pipelineSummary(OnboardingEnvironmentReport report) {
  if (report.hasMigrationFailure) {
    return ' • Pipeline: migration failed';
  }
  if (report.hasImportFailure) {
    return ' • Pipeline: import failed';
  }
  return '';
}

String _failureTimestampSuffix(DateTime? timestamp, {required bool persisted}) {
  if (timestamp == null) {
    return '';
  }

  final local = timestamp.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  final formatted = '${local.year}-$month-$day $hour:$minute';
  final now = DateTime.now().toLocal();
  final sameDay =
      local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;

  if (!persisted) {
    return ' at $formatted';
  }

  if (sameDay) {
    return ' persisted earlier today at $formatted';
  }

  return ' persisted on $formatted';
}

String _probeSummary(OnboardingDatabaseProbe probe) {
  if (!probe.exists) {
    return 'missing';
  }
  if (!probe.readable) {
    return 'blocked';
  }
  final rowCount = probe.rowCount;
  if (rowCount == null) {
    return 'readable';
  }
  return '$rowCount rows';
}

class _DevFdaContent extends ConsumerWidget {
  const _DevFdaContent({required this.colors, required this.typography});

  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock_outline_rounded, size: 56, color: _kWarningAmber),
        const SizedBox(height: 20),
        Text(
          'Full Disk Access Required',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'The app cannot read the Messages database.\n'
          'Grant Full Disk Access in System Settings, then relaunch the app.',
          style: typography.body.copyWith(color: colors.content.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () {
            ref.read(onboardingGateProvider.notifier).openFdaSettings();
          },
          style: FilledButton.styleFrom(
            backgroundColor: colors.buttons.primaryBackground,
            foregroundColor: colors.buttons.primaryForeground,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Open System Settings'),
        ),
      ],
    );
  }
}

class _DevWelcomeContent extends ConsumerWidget {
  const _DevWelcomeContent({required this.colors, required this.typography});

  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.message_rounded, size: 56, color: colors.accents.primary),
        const SizedBox(height: 20),
        Text(
          'Welcome to MessageLens',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'To get started, MessageLens needs to import your Messages '
          'and Contacts data. This is a one-time process.',
          style: typography.body.copyWith(color: colors.content.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: () {
            ref.read(onboardingGateProvider.notifier).startImportAndMigration();
          },
          style: FilledButton.styleFrom(
            backgroundColor: colors.buttons.primaryBackground,
            foregroundColor: colors.buttons.primaryForeground,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Import My Messages'),
        ),
      ],
    );
  }
}

class _DevProgressContent extends StatelessWidget {
  const _DevProgressContent({
    required this.colors,
    required this.typography,
    required this.controlState,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final DbImportControlState controlState;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controlState.selectedMode == DbImportMode.migration
              ? 'Migrating data…'
              : 'Importing data…',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
        ),
        if (controlState.statusMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            controlState.statusMessage!,
            style: typography.caption.copyWith(
              color: colors.content.textTertiary,
            ),
          ),
        ],
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: controlState.progress,
            backgroundColor: colors.lines.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(colors.accents.primary),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 16),
        Flexible(
          child: OnboardingProgressView(
            stages: controlState.stages,
            colors: colors,
            typography: typography,
          ),
        ),
      ],
    );
  }
}

class _DevRecoveryContent extends StatelessWidget {
  const _DevRecoveryContent({
    required this.colors,
    required this.typography,
    required this.controlState,
    required this.report,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final DbImportControlState controlState;
  final OnboardingEnvironmentReport? report;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cleaning up previous setup attempt…',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          report?.resetAppDatabasesReason ??
              'MessageLens is deleting stale app databases before allowing setup to continue.',
          style: typography.body.copyWith(color: colors.content.textSecondary),
        ),
        if (controlState.statusMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            controlState.statusMessage!,
            style: typography.caption.copyWith(
              color: colors.content.textTertiary,
            ),
          ),
        ],
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            backgroundColor: colors.lines.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(colors.accents.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _DevCompleteContent extends ConsumerWidget {
  const _DevCompleteContent({
    required this.colors,
    required this.typography,
    required this.controlState,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final DbImportControlState controlState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importResult = controlState.lastImportResult;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 56,
          color: Color(0xFF4CAF50),
        ),
        const SizedBox(height: 20),
        Text(
          'Import Complete!',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        if (importResult != null) ...[
          _SummaryMetrics(
            importResult: importResult,
            migrationResult: controlState.lastMigrationResult,
            colors: colors,
            typography: typography,
          ),
          const SizedBox(height: 24),
        ],
        FilledButton(
          onPressed: () {
            ref.read(onboardingGateProvider.notifier).dismiss();
          },
          style: FilledButton.styleFrom(
            backgroundColor: colors.buttons.primaryBackground,
            foregroundColor: colors.buttons.primaryForeground,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Get Started'),
        ),
      ],
    );
  }
}

class _DevNotNeededContent extends StatelessWidget {
  const _DevNotNeededContent({required this.colors, required this.typography});

  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 56,
          color: colors.content.textTertiary,
        ),
        const SizedBox(height: 20),
        Text(
          'Onboarding Not Needed',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Both databases exist and contain data.\n'
          'Use "Reset DBs & Re-trigger" above to simulate a fresh install.',
          style: typography.body.copyWith(color: colors.content.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SummaryMetrics extends StatelessWidget {
  const _SummaryMetrics({
    required this.importResult,
    required this.migrationResult,
    required this.colors,
    required this.typography,
  });

  final DbImportResult importResult;
  final DbMigrationResult? migrationResult;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    final metrics = <(String, int)>[
      ('Messages', importResult.messagesImported),
      ('Chats', importResult.chatsImported),
      ('Contacts', importResult.contactsImported),
      ('Attachments', importResult.attachmentsImported),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final (label, count) in metrics)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaces.control,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count.toString(),
                  style: typography.headline.copyWith(
                    color: colors.content.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: typography.caption.copyWith(
                    color: colors.content.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
