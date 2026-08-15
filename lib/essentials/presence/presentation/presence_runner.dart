import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

import '../application/presence_step_presentation.dart';
import '../domain/entities/choice_value.dart';
import '../domain/entities/step.dart';
import '../domain/services/presence_scheduler.dart';
import 'presence_step_presenter.dart';

typedef PresenceSpecialistStepBuilder =
    Widget Function(BuildContext context, PresenceStepCompletion complete);

/// Presents and advances one initialized Presence Schedule.
///
/// Test and fixed-destination Steps advance autonomously. Human-facing generic
/// Steps are projected through [PresenceStepPresenter]. The host supplies only
/// the explicit specialist presentation that generic Presence cannot own.
class PresenceRunner extends StatefulWidget {
  const PresenceRunner({
    required this.scheduler,
    required this.specialistBuilder,
    this.completedBuilder,
    this.onScheduleCompleted,
    super.key,
  });

  final PresenceScheduler scheduler;
  final PresenceSpecialistStepBuilder specialistBuilder;
  final WidgetBuilder? completedBuilder;
  final VoidCallback? onScheduleCompleted;

  @override
  State<PresenceRunner> createState() => _PresenceRunnerState();
}

class _PresenceRunnerState extends State<PresenceRunner> {
  Step? _scheduledAutomaticStep;
  Object? _automaticCompletionError;

  @override
  void didUpdateWidget(PresenceRunner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.scheduler, widget.scheduler)) {
      _scheduledAutomaticStep = null;
      _automaticCompletionError = null;
    }
  }

  Future<void> _completeCurrentStep() async {
    await widget.scheduler.completeCurrentStep();
    _executionChanged();
  }

  CurrentChoiceSelection _issueChoiceSelection() {
    final select = widget.scheduler.issueCurrentChoiceSelection();
    return (ChoiceValue value) async {
      await select(value);
      _executionChanged();
    };
  }

  void _executionChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      _scheduledAutomaticStep = null;
      _automaticCompletionError = null;
    });
    if (widget.scheduler.isComplete) {
      widget.onScheduleCompleted?.call();
    }
  }

  void _scheduleAutomaticCompletion(Step step) {
    if (identical(_scheduledAutomaticStep, step)) {
      return;
    }
    _scheduledAutomaticStep = step;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !identical(widget.scheduler.currentStep, step)) {
        return;
      }
      try {
        await widget.scheduler.completeCurrentStep();
        _executionChanged();
      } catch (error) {
        if (mounted) {
          setState(() {
            _automaticCompletionError = error;
          });
        }
      }
    });
  }

  void _retryAutomaticCompletion() {
    setState(() {
      _scheduledAutomaticStep = null;
      _automaticCompletionError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scheduler.isComplete) {
      return widget.completedBuilder?.call(context) ?? const SizedBox.shrink();
    }

    final step = widget.scheduler.currentStep;
    if (step == null) {
      return const Text('Presence has no current Step.');
    }

    if (step is TestStep || step is FixedDestinationStep) {
      _scheduleAutomaticCompletion(step);
      return _AutomaticStepProgress(
        error: _automaticCompletionError,
        retry: _retryAutomaticCompletion,
      );
    }

    final presentation = PresenceStepPresentationProjector.project(
      step: step,
      complete: _completeCurrentStep,
      issueChoiceSelection: _issueChoiceSelection,
    );
    return PresenceStepPresenter(
      key: ObjectKey(step),
      presentation: presentation,
      specialistBuilder: (context) {
        return widget.specialistBuilder(context, _completeCurrentStep);
      },
    );
  }
}

class _AutomaticStepProgress extends StatelessWidget {
  const _AutomaticStepProgress({required this.error, required this.retry});

  final Object? error;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    final completionError = error;
    if (completionError == null) {
      return const ProgressCircle(key: ValueKey('presence-auto-progress'));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Unable to continue: $completionError',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        PushButton(
          controlSize: ControlSize.regular,
          onPressed: retry,
          child: const Text('Try Again'),
        ),
      ],
    );
  }
}
