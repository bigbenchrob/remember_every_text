import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../onboarding/feature_level_providers.dart'
    show onboardingDevOverridesProvider, onboardingReadinessActionsProvider;
import '../../application/panel_actions_provider.dart';
import '../../application/panel_widget_providers.dart';
import '../../domain/entities/view_spec.dart';
import '../../domain/sidebar_mode.dart';

/// Overlay displayed in the sidebar when the center panel is showing
/// content that operates independently of the cassette rack (e.g.
/// maintenance and diagnostic controls).
///
/// Provides a prominent Cancel button so the user can dismiss the
/// center panel operation and return to normal sidebar navigation.
class SidebarParkedOverlay extends ConsumerWidget {
  const SidebarParkedOverlay({super.key, required this.mode});

  final SidebarMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    final spec = ref.watch(effectiveCenterPanelSpecProvider(mode));
    final hasSimulatedOnboardingOverride = ref.watch(
      onboardingDevOverridesProvider.select(
        (overrides) => overrides.hasAnyOverride,
      ),
    );
    final label = _labelForSpec(spec);
    final isReadinessSpec =
        spec?.maybeWhen(
          environmentReadiness: (_) => true,
          orElse: () => false,
        ) ??
        false;
    final sidebarMessage = isReadinessSpec
        ? hasSimulatedOnboardingOverride
              ? 'A developer simulation is pinning this readiness screen.'
              : 'The sidebar will unlock when these required checks pass.'
        : 'The sidebar is unavailable while\nthis operation is active.';
    final actionLabel = isReadinessSpec
        ? hasSimulatedOnboardingOverride
              ? 'Clear Simulation'
              : 'Re-check'
        : 'Cancel';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          const Spacer(),
          Icon(
            _iconForSpec(spec),
            size: 48,
            color: colors.content.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: typography.cassetteCardTitle.copyWith(
              color: colors.content.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            sidebarMessage,
            style: typography.cassetteCardSubtitle.copyWith(
              color: colors.content.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              onPressed: () => _dismiss(
                ref,
                spec: spec,
                hasSimulatedOnboardingOverride: hasSimulatedOnboardingOverride,
              ),
              child: Text(actionLabel),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  void _dismiss(
    WidgetRef ref, {
    required ViewSpec? spec,
    required bool hasSimulatedOnboardingOverride,
  }) {
    final isReadinessSpec =
        spec?.maybeWhen(
          environmentReadiness: (_) => true,
          orElse: () => false,
        ) ??
        false;

    if (isReadinessSpec) {
      ref
          .read(onboardingReadinessActionsProvider.notifier)
          .recheckReadiness(
            clearSimulationOverride: hasSimulatedOnboardingOverride,
          );
      return;
    }

    ref
        .read(panelActionsProvider.notifier)
        .cancelParkedCenterOperation(mode: mode);
  }

  static String _labelForSpec(ViewSpec? spec) {
    if (spec == null) {
      return 'Operation in Progress';
    }
    return spec.when(
      messages: (_) => 'Operation in Progress',
      settings: (_) => 'Settings',
      environmentReadiness: (_) => 'Environment Readiness',
      onboarding: (_) => 'Onboarding',
    );
  }

  static IconData _iconForSpec(ViewSpec? spec) {
    if (spec == null) {
      return CupertinoIcons.gear_alt;
    }
    return spec.when(
      messages: (_) => CupertinoIcons.gear_alt,
      settings: (_) => CupertinoIcons.gear,
      environmentReadiness: (_) => CupertinoIcons.check_mark_circled,
      onboarding: (_) => CupertinoIcons.rocket,
    );
  }
}
