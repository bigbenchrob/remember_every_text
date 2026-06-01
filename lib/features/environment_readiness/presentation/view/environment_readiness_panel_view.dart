import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/db/application/database_health_audit/database_health_audit_service.dart';
import '../../../../essentials/logging/application/app_logger.dart';
import '../../../../essentials/logging/application/diagnostic_report_actions.dart';
import '../../../../essentials/logging/infrastructure/log_export_service.dart';
import '../../../../essentials/onboarding/application/onboarding_environment_report_provider.dart';
import '../../../../essentials/onboarding/application/onboarding_gate_provider.dart';
import '../../../../essentials/onboarding/domain/onboarding_environment_report.dart';
import '../../application/view_spec/resolver_tools/environment_readiness_surface_provider.dart';
import '../../domain/entities/environment_readiness_surface_view_model.dart';

const _kReadinessWarning = Color(0xFFFF9500);
const _kReadinessSuccess = Color(0xFF34C759);

class EnvironmentReadinessPanelView extends ConsumerStatefulWidget {
  const EnvironmentReadinessPanelView({super.key});

  @override
  ConsumerState<EnvironmentReadinessPanelView> createState() =>
      _EnvironmentReadinessPanelViewState();
}

class _EnvironmentReadinessPanelViewState
    extends ConsumerState<EnvironmentReadinessPanelView> {
  EnvironmentReadinessStepKey? _selectedStepKey;

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final report = ref.watch(onboardingEnvironmentReportProvider).valueOrNull;
    final surface = ref.watch(environmentReadinessSurfaceProvider);
    final selectedStepKey = _selectedStepKey ?? surface.activeStepKey;
    final detail = surface.detailsByStep[selectedStepKey] ?? surface.detail;

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isStacked = constraints.maxWidth < 980;

              if (isStacked) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(colors: colors, typography: typography),
                      const SizedBox(height: 24),
                      _SummaryRail(
                        steps: surface.steps,
                        selectedStepKey: selectedStepKey,
                        colors: colors,
                        typography: typography,
                        onStepPressed: (stepKey) {
                          setState(() {
                            _selectedStepKey = stepKey;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _DetailPane(
                        detail: detail,
                        report: report,
                        colors: colors,
                        typography: typography,
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(colors: colors, typography: typography),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 280,
                          child: _SummaryRail(
                            steps: surface.steps,
                            selectedStepKey: selectedStepKey,
                            colors: colors,
                            typography: typography,
                            onStepPressed: (stepKey) {
                              setState(() {
                                _selectedStepKey = stepKey;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _DetailPane(
                            detail: detail,
                            report: report,
                            colors: colors,
                            typography: typography,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.colors, required this.typography});

  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Environment Readiness',
          style: typography.headline.copyWith(
            color: colors.content.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "MessageLens is checking the local permissions and data sources it needs before import. Your Messages and Contacts data stays on this Mac, and MessageLens only reads Apple's databases during setup.",
          style: typography.body.copyWith(color: colors.content.textSecondary),
        ),
      ],
    );
  }
}

class _SummaryRail extends StatelessWidget {
  const _SummaryRail({
    required this.steps,
    required this.selectedStepKey,
    required this.colors,
    required this.typography,
    required this.onStepPressed,
  });

  final List<EnvironmentReadinessStepViewModel> steps;
  final EnvironmentReadinessStepKey selectedStepKey;
  final ThemeColors colors;
  final ThemeTypography typography;
  final ValueChanged<EnvironmentReadinessStepKey> onStepPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaces.surfaceRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Checks',
            style: typography.body.copyWith(
              color: colors.content.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          for (final step in steps) ...[
            _StepTile(
              step: step,
              isSelected: step.key == selectedStepKey,
              colors: colors,
              typography: typography,
              onPressed: () {
                onStepPressed(step.key);
              },
            ),
            if (step != steps.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.step,
    required this.isSelected,
    required this.colors,
    required this.typography,
    required this.onPressed,
  });

  final EnvironmentReadinessStepViewModel step;
  final bool isSelected;
  final ThemeColors colors;
  final ThemeTypography typography;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final background = switch (step.status) {
      EnvironmentReadinessStepStatus.success => _kReadinessSuccess.withValues(
        alpha: 0.12,
      ),
      EnvironmentReadinessStepStatus.active =>
        colors.accents.primary.withValues(alpha: 0.14),
      EnvironmentReadinessStepStatus.pending => colors.surfaces.control,
    };
    final foreground = switch (step.status) {
      EnvironmentReadinessStepStatus.success => _kReadinessSuccess,
      EnvironmentReadinessStepStatus.active => colors.accents.primary,
      EnvironmentReadinessStepStatus.pending => colors.content.textTertiary,
    };
    final borderColor = isSelected
        ? colors.accents.primary
        : step.status == EnvironmentReadinessStepStatus.pending
        ? colors.lines.borderSubtle
        : foreground.withValues(alpha: 0.35);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: isSelected ? 1 : 0.5),
          ),
          child: Row(
            children: [
              Icon(_iconFor(step.key), color: foreground, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: typography.body.copyWith(
                        color:
                            step.status ==
                                EnvironmentReadinessStepStatus.pending
                            ? colors.content.textSecondary
                            : colors.content.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.subtitle,
                      style: typography.caption.copyWith(
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
    );
  }
}

class _DetailPane extends ConsumerWidget {
  const _DetailPane({
    required this.detail,
    required this.report,
    required this.colors,
    required this.typography,
  });

  final EnvironmentReadinessDetailViewModel detail;
  final OnboardingEnvironmentReport? report;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devOverrides = ref.watch(onboardingDevOverridesProvider);
    final overridesNotifier = ref.read(onboardingDevOverridesProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaces.surfaceRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _accentColorFor(
                      detail.tone,
                      colors: colors,
                    ).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _iconFor(detail.stepKey),
                    color: _accentColorFor(detail.tone, colors: colors),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.title,
                        style: typography.headline.copyWith(
                          color: colors.content.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        detail.body,
                        style: typography.body.copyWith(
                          color: colors.content.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surfaces.control,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors.lines.borderSubtle,
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What to do',
                    style: typography.body.copyWith(
                      color: colors.content.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (
                    var index = 0;
                    index < detail.instructions.length;
                    index++
                  ) ...[
                    _InstructionRow(
                      number: index + 1,
                      text: detail.instructions[index],
                      colors: colors,
                      typography: typography,
                    ),
                    if (index < detail.instructions.length - 1)
                      const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            if (report != null) ...[
              const SizedBox(height: 18),
              _EvidenceCard(
                report: report!,
                colors: colors,
                typography: typography,
              ),
            ],
            if (devOverrides.hasAnyOverride) ...[
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.accents.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.accents.primary.withValues(alpha: 0.25),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developer simulation is active',
                      style: typography.body.copyWith(
                        color: colors.content.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Re-check will keep showing this blocker until you clear the active simulation in the dev panel or with the button below.',
                      style: typography.caption.copyWith(
                        color: colors.content.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        overridesNotifier.clearAll();
                        ref
                            .read(onboardingGateProvider.notifier)
                            .refreshEnvironment();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.content.textPrimary,
                        side: BorderSide(color: colors.lines.borderSubtle),
                      ),
                      child: const Text('Clear Simulations'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final action in detail.actions)
                  switch (action.kind) {
                    EnvironmentReadinessActionKind.openSettings => FilledButton(
                      onPressed: () {
                        ref
                            .read(onboardingGateProvider.notifier)
                            .openFdaSettings();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.buttons.primaryBackground,
                        foregroundColor: colors.buttons.primaryForeground,
                      ),
                      child: Text(action.label),
                    ),
                    EnvironmentReadinessActionKind.recheck => OutlinedButton(
                      onPressed: () {
                        ref
                            .read(onboardingGateProvider.notifier)
                            .refreshEnvironment();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.content.textPrimary,
                        side: BorderSide(color: colors.lines.borderSubtle),
                      ),
                      child: Text(action.label),
                    ),
                    EnvironmentReadinessActionKind.startImport => FilledButton(
                      onPressed: () {
                        ref
                            .read(onboardingGateProvider.notifier)
                            .startImportAndMigration();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.buttons.primaryBackground,
                        foregroundColor: colors.buttons.primaryForeground,
                      ),
                      child: Text(action.label),
                    ),
                    EnvironmentReadinessActionKind.sendReport => OutlinedButton(
                      onPressed: report == null
                          ? null
                          : () async {
                              final writer = ref
                                  .read(appLoggerProvider.notifier)
                                  .writer;
                              final databaseHealthAuditService = await ref.read(
                                databaseHealthAuditServiceProvider.future,
                              );
                              final result =
                                  await exportOnboardingFailureDiagnosticReport(
                                    writer,
                                    report: report!,
                                    databaseHealthAuditService:
                                        databaseHealthAuditService,
                                  );
                              if (!context.mounted) {
                                return;
                              }
                              _showDiagnosticReportSnackBar(
                                context,
                                result: result,
                              );
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.content.textPrimary,
                        side: BorderSide(color: colors.lines.borderSubtle),
                      ),
                      child: Text(action.label),
                    ),
                  },
              ],
            ),
          ],
        ),
      ),
    );
  }
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

class _InstructionRow extends StatelessWidget {
  const _InstructionRow({
    required this.number,
    required this.text,
    required this.colors,
    required this.typography,
  });

  final int number;
  final String text;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.accents.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: typography.caption.copyWith(
              color: colors.buttons.primaryForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
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

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current machine view',
            style: typography.body.copyWith(
              color: colors.content.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _EvidenceRow(
            label: 'Full Disk Access',
            value: report.hasFullDiskAccess
                ? 'Available'
                : 'Missing or blocked',
            colors: colors,
            typography: typography,
          ),
          _EvidenceRow(
            label: 'Messages database',
            value: report.messagesDatabase.readable
                ? 'Readable'
                : report.messagesDatabase.exists
                ? 'Present but blocked'
                : 'Missing',
            colors: colors,
            typography: typography,
          ),
          _EvidenceRow(
            label: 'Contacts database',
            value: report.addressBookDatabase?.readable == true
                ? 'Readable'
                : report.addressBookDatabase == null
                ? 'Unavailable'
                : 'Present but blocked',
            colors: colors,
            typography: typography,
          ),
          _EvidenceRow(
            label: 'Source-scoped import ledger',
            value: report.importDatabase.hasData ? 'Ready' : 'Not prepared yet',
            colors: colors,
            typography: typography,
          ),
          _EvidenceRow(
            label: 'Conversation graph',
            value: report.workingDatabase.hasData
                ? 'Ready'
                : 'Not prepared yet',
            colors: colors,
            typography: typography,
          ),
        ],
      ),
    );
  }
}

class _EvidenceRow extends StatelessWidget {
  const _EvidenceRow({
    required this.label,
    required this.value,
    required this.colors,
    required this.typography,
  });

  final String label;
  final String value;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
    );
  }
}

IconData _iconFor(EnvironmentReadinessStepKey stepKey) {
  return switch (stepKey) {
    EnvironmentReadinessStepKey.fullDiskAccess => CupertinoIcons.lock_shield,
    EnvironmentReadinessStepKey.messagesDatabase =>
      CupertinoIcons.chat_bubble_text,
    EnvironmentReadinessStepKey.contactsDatabase =>
      CupertinoIcons.person_crop_circle_badge_checkmark,
    EnvironmentReadinessStepKey.importReadiness =>
      CupertinoIcons.check_mark_circled,
  };
}

Color _accentColorFor(
  EnvironmentReadinessTone tone, {
  required ThemeColors colors,
}) {
  return switch (tone) {
    EnvironmentReadinessTone.primary => colors.accents.primary,
    EnvironmentReadinessTone.warning => _kReadinessWarning,
    EnvironmentReadinessTone.success => _kReadinessSuccess,
  };
}
