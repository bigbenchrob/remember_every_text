import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/theme_typography.dart';
import '../../conversation_graph/feature_level_providers.dart'
    show
        ConversationGraphBuildReport,
        ConversationGraphBuildStatus,
        ConversationGraphBuildState,
        conversationGraphBuildControllerProvider;
import '../../logging/application/diagnostic_report_actions.dart';
import '../../logging/domain/diagnostic_report_presentation_result.dart';
import '../../logging/feature_level_providers.dart'
    show diagnosticReportExporterProvider;
import '../application/onboarding_environment_report_provider.dart';
import '../application/onboarding_gate_provider.dart';
import '../application/onboarding_overlay_actions_provider.dart';
import '../domain/onboarding_environment_report.dart';
import '../domain/onboarding_status.dart';

/// Full-window blocking overlay shown during first-run onboarding.
///
/// Renders a semi-transparent barrier over the entire app and presents
/// a centered card whose content switches based on [OnboardingStatus]:
///   - [awaitingUserAction] → welcome panel with "Import" button
///   - [importing] / [buildingGraph] → live stage progress
///   - [complete] → success summary with "Get Started" button
class OnboardingOverlay extends ConsumerWidget {
  const OnboardingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(onboardingGateProvider);
    final report = ref.watch(onboardingEnvironmentReportProvider).valueOrNull;
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Stack(
      children: [
        // Barrier: absorbs all input, semi-transparent dark background.
        ModalBarrier(
          dismissible: false,
          color: colors.surfaces.panel.withValues(alpha: 0.85),
        ),
        // Centered card.
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640, maxHeight: 920),
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colors.surfaces.surfaceRaised,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.lines.borderSubtle,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: switch (status) {
                OnboardingStatus.recoveringFailedAttempt => _RecoveryContent(
                  report: report,
                  colors: colors,
                  typography: typography,
                ),
                OnboardingStatus.awaitingFda => _FdaContent(
                  report: report,
                  colors: colors,
                  typography: typography,
                ),
                OnboardingStatus.awaitingUserAction => _WelcomeContent(
                  report: report,
                  colors: colors,
                  typography: typography,
                ),
                OnboardingStatus.importing ||
                OnboardingStatus.buildingGraph ||
                OnboardingStatus.reimporting ||
                OnboardingStatus.reimportBuildingGraph => _ProgressContent(
                  colors: colors,
                  typography: typography,
                  isReimport:
                      status == OnboardingStatus.reimporting ||
                      status == OnboardingStatus.reimportBuildingGraph,
                ),
                OnboardingStatus.complete => _CompleteContent(
                  colors: colors,
                  typography: typography,
                  dismissLabel: 'Get Started',
                ),
                OnboardingStatus.reimportComplete => _CompleteContent(
                  colors: colors,
                  typography: typography,
                  dismissLabel: 'Done',
                ),
                OnboardingStatus.notNeeded => const SizedBox.shrink(),
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// FDA instruction panel: explains why FDA is needed and how to grant it.
///
/// macOS requires an app restart after granting FDA, so this screen only
/// shows the "Open System Settings" button.  On relaunch the FDA check
/// in [OnboardingGate.build] will pass and the import welcome screen
/// appears automatically.
class _FdaContent extends ConsumerWidget {
  const _FdaContent({
    required this.report,
    required this.colors,
    required this.typography,
  });

  final OnboardingEnvironmentReport? report;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyText = _permissionBodyText(report);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 56,
          color: colors.status.warning,
        ),
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
          bodyText,
          style: typography.body.copyWith(color: colors.content.textSecondary),
          textAlign: TextAlign.center,
        ),
        if (report != null) ...[
          const SizedBox(height: 16),
          _EnvironmentSummaryCard(
            report: report!,
            colors: colors,
            typography: typography,
          ),
        ],
        const SizedBox(height: 20),
        // Step-by-step instructions.
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaces.control,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InstructionStep(
                number: '1',
                text: 'Click "Open System Settings" below',
                colors: colors,
                typography: typography,
              ),
              const SizedBox(height: 8),
              _InstructionStep(
                number: '2',
                text:
                    'Add MessageLens: click the "+" button and find it, '
                    'or drag the app onto the list',
                colors: colors,
                typography: typography,
              ),
              const SizedBox(height: 8),
              _InstructionStep(
                number: '3',
                text:
                    'Toggle MessageLens ON and enter your password '
                    'when prompted',
                colors: colors,
                typography: typography,
              ),
              const SizedBox(height: 8),
              _InstructionStep(
                number: '4',
                text:
                    'macOS will ask you to quit and reopen the app \u2014 '
                    'when it restarts, setup will continue automatically',
                colors: colors,
                typography: typography,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () async {
            await ref
                .read(onboardingOverlayActionsProvider.notifier)
                .openFullDiskAccessSettings();
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
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            ref
                .read(onboardingOverlayActionsProvider.notifier)
                .recheckEnvironment();
          },
          child: Text(
            'Re-check environment',
            style: typography.caption.copyWith(
              color: colors.content.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

class _InstructionStep extends StatelessWidget {
  const _InstructionStep({
    required this.number,
    required this.text,
    required this.colors,
    required this.typography,
  });

  final String number;
  final String text;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.accents.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: typography.caption.copyWith(
              color: colors.buttons.primaryForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: typography.body.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Welcome panel: app title + explanation + "Import My Messages" button.
class _WelcomeContent extends ConsumerWidget {
  const _WelcomeContent({
    required this.report,
    required this.colors,
    required this.typography,
  });

  final OnboardingEnvironmentReport? report;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentation = _awaitingUserActionPresentation(report);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          presentation.icon,
          size: 56,
          color: presentation.iconColor(colors),
        ),
        const SizedBox(height: 20),
        Text(
          presentation.title,
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          presentation.body,
          style: typography.body.copyWith(color: colors.content.textSecondary),
          textAlign: TextAlign.center,
        ),
        if (report != null) ...[
          const SizedBox(height: 16),
          _EnvironmentSummaryCard(
            report: report!,
            colors: colors,
            typography: typography,
          ),
        ],
        if (presentation.notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          _AdviceCard(
            notes: presentation.notes,
            colors: colors,
            typography: typography,
          ),
        ],
        const SizedBox(height: 32),
        if (presentation.canImportImmediately)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(onboardingOverlayActionsProvider.notifier)
                      .startImportAndGraphBuild();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.buttons.primaryBackground,
                  foregroundColor: colors.buttons.primaryForeground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(presentation.primaryActionLabel),
              ),
              if (presentation.canSendDiagnosticReport && report != null)
                OutlinedButton(
                  onPressed: () async {
                    final diagnosticReportExporter = await ref.read(
                      diagnosticReportExporterProvider.future,
                    );
                    final result =
                        await exportOnboardingFailureDiagnosticReport(
                          diagnosticReportExporter,
                          report: report!,
                        );
                    if (!context.mounted) {
                      return;
                    }
                    _showDiagnosticReportSnackBar(context, result: result);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.content.textPrimary,
                    side: BorderSide(color: colors.lines.borderSubtle),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Send Report To Developer'),
                ),
            ],
          )
        else ...[
          FilledButton(
            onPressed: () {
              ref
                  .read(onboardingOverlayActionsProvider.notifier)
                  .recheckEnvironment();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colors.buttons.primaryBackground,
              foregroundColor: colors.buttons.primaryForeground,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Re-check Environment'),
          ),
          if (presentation.allowsManualImport) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                await ref
                    .read(onboardingOverlayActionsProvider.notifier)
                    .startImportAndGraphBuild();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.content.textPrimary,
                side: BorderSide(color: colors.lines.borderSubtle),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Import Anyway'),
            ),
          ],
        ],
        if (presentation.canSendDiagnosticReport && report != null) ...[
          const SizedBox(height: 12),
          Text(
            'MessageLens will try to open an email draft to messagelens@gmail.com with the report already attached. If that is not possible, it will reveal the file in Finder so it can be attached manually.',
            style: typography.caption.copyWith(
              color: colors.content.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _EnvironmentSummaryCard extends StatelessWidget {
  const _EnvironmentSummaryCard({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Environment summary',
            style: typography.body.copyWith(
              color: colors.content.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _DiagnosticRow(
            label: 'Full Disk Access',
            value: report.hasFullDiskAccess
                ? 'Available'
                : 'Missing or blocked',
            colors: colors,
            typography: typography,
            isGood: report.hasFullDiskAccess,
          ),
          _DiagnosticRow(
            label: 'Messages database',
            value: _messagesValue(report),
            colors: colors,
            typography: typography,
            isGood: report.messagesDatabase.readable,
          ),
          _DiagnosticRow(
            label: 'Contacts database',
            value: _contactsValue(report),
            colors: colors,
            typography: typography,
            isGood: report.addressBookDatabase?.readable ?? false,
          ),
          _DiagnosticRow(
            label: 'Source-scoped import ledger',
            value: _appDbValue(report.sourceScopedImportDatabase),
            colors: colors,
            typography: typography,
            isGood: report.sourceScopedImportDatabase.hasData,
          ),
          _DiagnosticRow(
            label: 'Conversation graph',
            value: _appDbValue(report.conversationGraph),
            colors: colors,
            typography: typography,
            isGood: report.conversationGraph.hasData,
          ),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({
    required this.notes,
    required this.colors,
    required this.typography,
  });

  final List<String> notes;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What to check',
            style: typography.body.copyWith(
              color: colors.content.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          for (final note in notes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colors.accents.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      note,
                      style: typography.body.copyWith(
                        color: colors.content.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({
    required this.label,
    required this.value,
    required this.colors,
    required this.typography,
    required this.isGood,
  });

  final String label;
  final String value;
  final ThemeColors colors;
  final ThemeTypography typography;
  final bool isGood;

  @override
  Widget build(BuildContext context) {
    final statusColor = isGood ? colors.status.success : colors.status.warning;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isGood ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: typography.caption.copyWith(
                  color: colors.content.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: typography.caption.copyWith(
                      color: colors.content.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _permissionBodyText(OnboardingEnvironmentReport? report) {
  if (report == null) {
    return 'MessageLens needs Full Disk Access to read your Messages and '
        'Contacts databases. Without it, the app cannot import your data.';
  }

  if (!report.messagesDatabase.exists) {
    return 'MessageLens cannot find a local Messages database on this Mac yet. '
        'That can happen if Messages has not created local history here, or if '
        'privacy settings are still blocking access.';
  }

  return 'MessageLens cannot read the local Messages database yet. Grant Full '
      'Disk Access, then relaunch the app so setup can continue.';
}

_AwaitingUserActionPresentation _awaitingUserActionPresentation(
  OnboardingEnvironmentReport? report,
) {
  if (report == null) {
    return const _AwaitingUserActionPresentation(
      title: 'Welcome to MessageLens',
      body:
          'To get started, MessageLens needs to import your Messages and '
          'Contacts data. This is a one-time process.',
      notes: [],
      canImportImmediately: true,
      canSendDiagnosticReport: false,
      allowsManualImport: false,
      primaryActionLabel: 'Import My Messages',
      icon: Icons.message_rounded,
      iconKind: _PresentationIconKind.primary,
    );
  }

  switch (report.state) {
    case OnboardingEnvironmentState.readyToImport:
      return const _AwaitingUserActionPresentation(
        title: 'Ready to Import',
        body:
            'MessageLens can reach the local Messages and Contacts sources on '
            'this Mac. Importing will copy that data into the app.',
        notes: [],
        canImportImmediately: true,
        canSendDiagnosticReport: false,
        allowsManualImport: false,
        primaryActionLabel: 'Import My Messages',
        icon: Icons.message_rounded,
        iconKind: _PresentationIconKind.primary,
      );
    case OnboardingEnvironmentState.sourceUnavailable:
      return _AwaitingUserActionPresentation(
        title: 'Source Data Unavailable',
        body:
            'MessageLens cannot yet reach all of the local source data it '
            'needs on this Mac. Re-check the environment after resolving the '
            'issue below.',
        notes: _sourceUnavailableNotes(report),
        canImportImmediately: false,
        canSendDiagnosticReport: false,
        allowsManualImport: false,
        primaryActionLabel: 'Import My Messages',
        icon: Icons.storage_rounded,
        iconKind: _PresentationIconKind.warning,
      );
    case OnboardingEnvironmentState.sourceSparseOrUnsynced:
      return _AwaitingUserActionPresentation(
        title: 'Little Local Messages History Found',
        body:
            'MessageLens can read the Messages database, but this Mac appears '
            'to have little or no local message history right now.',
        notes: _sourceSparseNotes(report),
        canImportImmediately: false,
        canSendDiagnosticReport: false,
        allowsManualImport: true,
        primaryActionLabel: 'Import My Messages',
        icon: Icons.cloud_off_rounded,
        iconKind: _PresentationIconKind.warning,
      );
    case OnboardingEnvironmentState.importFailed:
      return _AwaitingUserActionPresentation(
        title: 'Import Attempt Failed',
        body:
            'MessageLens could reach your local sources, but the last import '
            'attempt did not finish successfully. You can retry now or send '
            'a report to the developer.',
        notes: _importFailureNotes(report),
        canImportImmediately: true,
        canSendDiagnosticReport: true,
        allowsManualImport: false,
        primaryActionLabel: 'Try Import Again',
        icon: Icons.error_outline_rounded,
        iconKind: _PresentationIconKind.warning,
      );
    case OnboardingEnvironmentState.graphProjectionFailed:
      return _AwaitingUserActionPresentation(
        title: 'Imported Data Could Not Be Prepared',
        body:
            'MessageLens imported source data, but the app could not finish '
            'preparing it for use. You can retry now or send a report to the '
            'developer.',
        notes: _graphProjectionFailureNotes(report),
        canImportImmediately: true,
        canSendDiagnosticReport: true,
        allowsManualImport: false,
        primaryActionLabel: 'Retry Import and Graph Build',
        icon: Icons.sync_problem_rounded,
        iconKind: _PresentationIconKind.warning,
      );
    case OnboardingEnvironmentState.permissionBlocked:
      return _AwaitingUserActionPresentation(
        title: 'Permission Required',
        body: _permissionBodyText(report),
        notes: const [],
        canImportImmediately: false,
        canSendDiagnosticReport: false,
        allowsManualImport: false,
        primaryActionLabel: 'Import My Messages',
        icon: Icons.lock_outline_rounded,
        iconKind: _PresentationIconKind.warning,
      );
    case OnboardingEnvironmentState.ready:
      return const _AwaitingUserActionPresentation(
        title: 'Environment Ready',
        body:
            'The environment looks healthy. MessageLens should be able to use '
            'its imported data on this Mac.',
        notes: [],
        canImportImmediately: false,
        canSendDiagnosticReport: false,
        allowsManualImport: false,
        primaryActionLabel: 'Import My Messages',
        icon: Icons.check_circle_outline,
        iconKind: _PresentationIconKind.success,
      );
  }
}

List<String> _importFailureNotes(OnboardingEnvironmentReport report) {
  final notes = <String>[];

  final recordedAt = report.lastImportFailureRecordedAt;
  if (report.usingPersistedImportFailure && recordedAt != null) {
    notes.add(
      _persistedFailureNote(
        kind: 'import',
        freshness: report.importFailureFreshness(),
        recordedAt: recordedAt,
      ),
    );
  }

  final message = report.importFailureMessage;
  if (message != null && message.isNotEmpty) {
    notes.add(message);
  }

  notes.add(
    'Confirm Messages and Contacts are still available on this Mac, then retry the import.',
  );
  notes.add(
    'If the import fails again, use "Send Report To Developer" to have MessageLens prepare an email with the diagnostic report attached when possible.',
  );

  if (!report.sourceScopedImportDatabase.exists ||
      !report.sourceScopedImportDatabase.hasData) {
    notes.add(
      'No usable import ledger was left behind, so the next retry will start from a clean import pass.',
    );
  }

  return notes;
}

List<String> _graphProjectionFailureNotes(OnboardingEnvironmentReport report) {
  final notes = <String>[];

  final recordedAt = report.lastGraphProjectionFailureRecordedAt;
  if (report.usingPersistedGraphProjectionFailure && recordedAt != null) {
    notes.add(
      _persistedFailureNote(
        kind: 'graph projection',
        freshness: report.graphProjectionFailureFreshness(),
        recordedAt: recordedAt,
      ),
    );
  }

  final message = report.graphProjectionFailureMessage;
  if (message != null && message.isNotEmpty) {
    notes.add(message);
  }

  if (report.sourceScopedImportDatabase.hasData) {
    notes.add(
      'The import ledger contains data, so the failure happened while preparing app-facing tables.',
    );
  }

  if (!report.conversationGraph.hasData) {
    notes.add(
      'The conversation graph is still empty or incomplete. Retrying will rerun the full import and graph build.',
    );
  }

  notes.add(
    'If this keeps happening, use "Send Report To Developer" to have MessageLens prepare an email with the support bundle attached when possible.',
  );

  return notes;
}

void _showDiagnosticReportSnackBar(
  BuildContext context, {
  required DiagnosticReportPresentationResult result,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    return;
  }

  final message = result.exportPath == null
      ? 'MessageLens could not prepare a diagnostic report right now.'
      : result.attachedToMailDraft
      ? 'Email draft prepared with the support bundle attached.'
      : 'Support bundle prepared. It was opened in Finder so it can be attached manually.';

  messenger.showSnackBar(SnackBar(content: Text(message)));
}

String _formatRecordedAt(DateTime timestamp) {
  final local = timestamp.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day $hour:$minute';
}

String _persistedFailureNote({
  required String kind,
  required OnboardingFailureFreshness freshness,
  required DateTime recordedAt,
}) {
  final formatted = _formatRecordedAt(recordedAt);

  return switch (freshness) {
    OnboardingFailureFreshness.today =>
      'This $kind failure was recorded earlier today at $formatted during a previous launch.',
    OnboardingFailureFreshness.older =>
      'This $kind failure was recorded during a previous launch on $formatted.',
    OnboardingFailureFreshness.unknown =>
      'This $kind failure was recorded during a previous launch.',
  };
}

List<String> _sourceUnavailableNotes(OnboardingEnvironmentReport report) {
  final notes = <String>[];

  if (!report.messagesDatabase.exists) {
    notes.add(
      'Open Messages on this Mac and confirm local history exists here before re-checking.',
    );
  }

  if (report.addressBookDatabase == null ||
      !report.addressBookDatabase!.readable) {
    notes.add(
      report.addressBookFailureMessage ??
          'The Contacts source could not be resolved. Verify that Contacts data is available on this Mac.',
    );
  }

  if (notes.isEmpty) {
    notes.add('Resolve the source-data issue, then re-check the environment.');
  }

  return notes;
}

List<String> _sourceSparseNotes(OnboardingEnvironmentReport report) {
  final notes = <String>[];

  notes.add(
    'Open Messages and confirm this Mac is signed into the Apple Account you expect to inspect.',
  );
  notes.add(
    'If you use Messages in iCloud, wait for local history to appear on this Mac, then re-check the environment.',
  );

  final rowCount = report.messagesDatabase.rowCount;
  if (rowCount != null) {
    notes.add(
      'MessageLens currently sees only $rowCount messages in the local Messages database on this Mac.',
    );
  }

  notes.add(
    'If this Mac genuinely has only a small local archive, you can still import it using "Import Anyway".',
  );

  return notes;
}

String _messagesValue(OnboardingEnvironmentReport report) {
  if (!report.messagesDatabase.exists) {
    return 'Not found';
  }
  if (!report.messagesDatabase.readable) {
    return 'Blocked';
  }

  final rowCount = report.messagesDatabase.rowCount;
  if (rowCount == null) {
    return 'Readable';
  }

  return '$rowCount messages detected';
}

String _contactsValue(OnboardingEnvironmentReport report) {
  final probe = report.addressBookDatabase;
  if (probe == null) {
    return report.addressBookFailureMessage ?? 'Unavailable';
  }
  if (!probe.exists) {
    return 'Not found';
  }
  if (!probe.readable) {
    return 'Blocked';
  }

  final rowCount = probe.rowCount;
  if (rowCount == null) {
    return 'Readable';
  }

  return '$rowCount contacts detected';
}

String _appDbValue(OnboardingDatabaseProbe probe) {
  if (!probe.exists) {
    return 'Not created yet';
  }
  if (!probe.readable) {
    return 'Unavailable';
  }

  final rowCount = probe.rowCount;
  if (rowCount == null) {
    return 'Created';
  }

  if (rowCount == 0) {
    return 'Created but empty';
  }

  return '$rowCount messages stored';
}

enum _PresentationIconKind { primary, warning, success }

class _AwaitingUserActionPresentation {
  const _AwaitingUserActionPresentation({
    required this.title,
    required this.body,
    required this.notes,
    required this.canImportImmediately,
    required this.canSendDiagnosticReport,
    required this.allowsManualImport,
    required this.primaryActionLabel,
    required this.icon,
    required this.iconKind,
  });

  final String title;
  final String body;
  final List<String> notes;
  final bool canImportImmediately;
  final bool canSendDiagnosticReport;
  final bool allowsManualImport;
  final String primaryActionLabel;
  final IconData icon;
  final _PresentationIconKind iconKind;

  Color iconColor(ThemeColors colors) {
    return switch (iconKind) {
      _PresentationIconKind.primary => colors.accents.primary,
      _PresentationIconKind.warning => colors.status.warning,
      _PresentationIconKind.success => colors.status.success,
    };
  }
}

/// Progress panel: overall progress bar + per-stage list.
class _ProgressContent extends ConsumerWidget {
  const _ProgressContent({
    required this.colors,
    required this.typography,
    this.isReimport = false,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final bool isReimport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphBuildState = ref.watch(conversationGraphBuildControllerProvider);
    final statusMessage = _progressStatusMessage(
      graphBuildState: graphBuildState,
      isReimport: isReimport,
    );
    final progressValue =
        graphBuildState.status == ConversationGraphBuildStatus.succeeded
        ? 1.0
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          statusMessage,
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressValue,
            backgroundColor: colors.lines.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(colors.accents.primary),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isReimport
              ? 'MessageLens is rebuilding the source-scoped import ledger and conversation graph from Messages.'
              : 'MessageLens is building the source-scoped import ledger and conversation graph from Messages.',
          style: typography.body.copyWith(color: colors.content.textSecondary),
          textAlign: TextAlign.center,
        ),
        if (!isReimport) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ref
                    .read(onboardingOverlayActionsProvider.notifier)
                    .abortImport();
              },
              child: Text(
                'Abort Import',
                style: typography.caption.copyWith(
                  color: colors.content.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

String _progressStatusMessage({
  required ConversationGraphBuildState graphBuildState,
  required bool isReimport,
}) {
  return switch (graphBuildState.status) {
    ConversationGraphBuildStatus.running =>
      isReimport
          ? 'Rebuilding conversation graph…'
          : 'Building conversation graph…',
    ConversationGraphBuildStatus.succeeded =>
      isReimport ? 'Conversation graph rebuilt' : 'Conversation graph built',
    ConversationGraphBuildStatus.failed =>
      graphBuildState.lastError ?? 'Conversation graph build failed',
    ConversationGraphBuildStatus.idle =>
      isReimport ? 'Preparing graph rebuild…' : 'Preparing graph build…',
  };
}

/// Success panel: summary metrics + dismiss button.
class _CompleteContent extends ConsumerWidget {
  const _CompleteContent({
    required this.colors,
    required this.typography,
    required this.dismissLabel,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final String dismissLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphBuildReport = ref
        .watch(conversationGraphBuildControllerProvider)
        .lastReport;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 56,
          color: colors.status.success,
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
        if (graphBuildReport != null) ...[
          _GraphBuildSummaryMetrics(
            report: graphBuildReport,
            colors: colors,
            typography: typography,
          ),
          const SizedBox(height: 24),
        ],
        FilledButton(
          onPressed: () {
            ref.read(onboardingOverlayActionsProvider.notifier).dismiss();
          },
          style: FilledButton.styleFrom(
            backgroundColor: colors.buttons.primaryBackground,
            foregroundColor: colors.buttons.primaryForeground,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(dismissLabel),
        ),
      ],
    );
  }
}

class _RecoveryContent extends ConsumerWidget {
  const _RecoveryContent({
    required this.report,
    required this.colors,
    required this.typography,
  });

  final OnboardingEnvironmentReport? report;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cleaning_services_outlined,
          size: 56,
          color: colors.accents.primary,
        ),
        const SizedBox(height: 20),
        Text(
          'Cleaning Up A Previous Setup Attempt',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'MessageLens detected signs that an earlier import or graph build left incomplete app databases. It is deleting the app databases now so setup can restart from a clean slate.',
          style: typography.body.copyWith(color: colors.content.textSecondary),
          textAlign: TextAlign.center,
        ),
        if (report?.resetAppDatabasesReason != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaces.control,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
            ),
            child: Text(
              report!.resetAppDatabasesReason!,
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.accents.primary,
          ),
        ),
      ],
    );
  }
}

/// Displays key counts from the source-scoped graph build result.
class _GraphBuildSummaryMetrics extends StatelessWidget {
  const _GraphBuildSummaryMetrics({
    required this.report,
    required this.colors,
    required this.typography,
  });

  final ConversationGraphBuildReport report;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    final metrics = <(String, int)>[
      ('Imported', report.messageImportResult.insertedMessageCount),
      ('Projected', report.messageProjectionResult.insertedMessageCount),
      ('Text enriched', report.richTextEnrichmentResult.enrichedMessageCount),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final (label, count) in metrics)
          _MetricChip(
            label: label,
            count: count,
            colors: colors,
            typography: typography,
          ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.count,
    required this.colors,
    required this.typography,
  });

  final String label;
  final int count;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
