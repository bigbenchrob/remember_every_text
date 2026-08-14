import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/theme_typography.dart';
import '../../presence/application/presence_step_presentation.dart';
import '../../presence/domain/services/presence_scheduler.dart';
import '../../presence/presentation/presence_runner.dart';
import '../application/onboarding_environment_report_provider.dart';
import '../application/required_sources_readiness_scheduler_provider.dart';
import '../domain/onboarding_environment_report.dart';
import 'onboarding_overlay.dart';

/// Production host for the required-sources Presence Schedule.
class OnboardingPresenceHost extends ConsumerWidget {
  const OnboardingPresenceHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduler = ref.watch(requiredSourcesReadinessSchedulerProvider);
    return scheduler.when(
      loading: () => const _OnboardingPresenceFrame(child: ProgressCircle()),
      error: (error, _) => _OnboardingPresenceFrame(
        child: Text(
          'Unable to continue setup: $error',
          textAlign: TextAlign.center,
        ),
      ),
      data: (value) {
        if (value.isComplete) {
          return const SizedBox.shrink();
        }
        return OnboardingPresenceSurface(scheduler: value);
      },
    );
  }
}

/// Onboarding-owned shell around the permanent generic Presence runner.
class OnboardingPresenceSurface extends ConsumerStatefulWidget {
  const OnboardingPresenceSurface({required this.scheduler, super.key});

  final PresenceScheduler scheduler;

  @override
  ConsumerState<OnboardingPresenceSurface> createState() =>
      _OnboardingPresenceSurfaceState();
}

class _OnboardingPresenceSurfaceState
    extends ConsumerState<OnboardingPresenceSurface> {
  bool _isComplete = false;

  @override
  void didUpdateWidget(OnboardingPresenceSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.scheduler, widget.scheduler)) {
      _isComplete = widget.scheduler.isComplete;
    }
  }

  void _scheduleCompleted() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete || widget.scheduler.isComplete) {
      return const SizedBox.shrink();
    }

    final report = ref.watch(onboardingEnvironmentReportProvider).valueOrNull;
    return _OnboardingPresenceFrame(
      child: PresenceRunner(
        scheduler: widget.scheduler,
        onScheduleCompleted: _scheduleCompleted,
        specialistBuilder: (context, complete) {
          return _PresenceFdaSettingsContent(
            report: report,
            complete: complete,
          );
        },
      ),
    );
  }
}

class _OnboardingPresenceFrame extends ConsumerWidget {
  const _OnboardingPresenceFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Stack(
      children: <Widget>[
        ModalBarrier(
          dismissible: false,
          color: colors.surfaces.panel.withValues(alpha: 0.85),
        ),
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
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: colors.overlays.shadow,
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _PresenceFdaSettingsContent extends ConsumerStatefulWidget {
  const _PresenceFdaSettingsContent({
    required this.report,
    required this.complete,
  });

  final OnboardingEnvironmentReport? report;
  final PresenceStepCompletion complete;

  @override
  ConsumerState<_PresenceFdaSettingsContent> createState() =>
      _PresenceFdaSettingsContentState();
}

class _PresenceFdaSettingsContentState
    extends ConsumerState<_PresenceFdaSettingsContent> {
  bool _isOpening = false;
  Object? _openingError;

  Future<void> _openSettings() async {
    if (_isOpening) {
      return;
    }
    setState(() {
      _isOpening = true;
      _openingError = null;
    });
    try {
      await widget.complete();
    } catch (error) {
      if (mounted) {
        setState(() {
          _openingError = error;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOpening = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OnboardingFdaContent(
          report: widget.report,
          colors: colors,
          typography: typography,
          openSettings: _openSettings,
          recheckEnvironment: null,
          isOpeningSettings: _isOpening,
        ),
        if (_openingError case final error?) ...<Widget>[
          const SizedBox(height: 16),
          Text(
            'Unable to open System Settings: $error',
            style: typography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
