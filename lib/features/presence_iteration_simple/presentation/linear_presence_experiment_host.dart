import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../config/theme/theme_typography.dart';
import '../../../essentials/presence/domain/entities/execution_trace_event.dart';
import '../../../essentials/presence/domain/entities/step.dart';
import '../../../essentials/presence/domain/services/presence_scheduler.dart';
import '../application/development_contacts_source_provider.dart';
import '../application/linear_presence_experiment_diagram_provider.dart';
import '../application/linear_presence_experiment_provider.dart';
import '../application/linear_presence_experiment_trace_provider.dart';
import '../application/linear_presence_experiment_visualization_provider.dart';
import '../infrastructure/development/development_contacts_source_mode_store.dart';
import 'presence_presentation_tokens.dart';
import 'schedule_run_visualization_view.dart';

class LinearPresenceExperimentHost extends ConsumerStatefulWidget {
  const LinearPresenceExperimentHost({super.key});

  @override
  ConsumerState<LinearPresenceExperimentHost> createState() =>
      _LinearPresenceExperimentHostState();
}

class _LinearPresenceExperimentHostState
    extends ConsumerState<LinearPresenceExperimentHost> {
  bool _isCompleting = false;
  bool _isRestarting = false;
  bool _showDiagram = false;
  bool _showMap = false;
  bool _showTrace = false;
  Object? _completionError;

  Future<void> _completeCurrentStep(PresenceScheduler scheduler) async {
    if (_isCompleting) {
      return;
    }
    setState(() {
      _isCompleting = true;
      _completionError = null;
    });
    try {
      await scheduler.completeCurrentStep();
      final runId = scheduler.run?.id;
      if (_showTrace && runId != null) {
        await ref
            .read(linearPresenceExperimentTraceProvider(runId).notifier)
            .refresh();
      }
      if (_showMap && runId != null) {
        await ref
            .read(linearPresenceExperimentVisualizationProvider(runId).notifier)
            .refresh();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _completionError = error;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  Future<void> _runAgain(PresenceScheduler scheduler) async {
    if (_isRestarting) {
      return;
    }
    setState(() {
      _isRestarting = true;
    });
    try {
      await scheduler.replaceRunFromBeginning();
    } finally {
      if (mounted) {
        setState(() {
          _isRestarting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduler = ref.watch(linearPresenceExperimentProvider);
    return scheduler.when(
      loading: () => const Center(child: ProgressCircle()),
      error: (error, _) =>
          Center(child: Text('Unable to load the Presence experiment: $error')),
      data: _buildSchedule,
    );
  }

  Widget _buildSchedule(PresenceScheduler scheduler) {
    final typography = ref.watch(themeTypographyProvider);
    final contactsSourceMode = ref.watch(
      developmentContactsSourceSelectionProvider,
    );
    final run = scheduler.run;
    if (run == null) {
      return const Center(child: Text('Schedule is not initialized.'));
    }

    final trip = scheduler.currentTrip;
    final step = scheduler.currentStep;
    final diagram = _showDiagram
        ? ref.watch(linearPresenceExperimentDiagramProvider)
        : null;
    final trace = _showTrace
        ? ref.watch(linearPresenceExperimentTraceProvider(run.id))
        : null;
    final visualization = _showMap
        ? ref.watch(linearPresenceExperimentVisualizationProvider(run.id))
        : null;
    return Padding(
      padding: const EdgeInsets.all(PresencePresentationTokens.pageMargin),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: PresencePresentationTokens.maximumReadableWidth,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Contacts test source', style: typography.caption),
              const SizedBox(height: 8),
              contactsSourceMode.when(
                loading: () => const ProgressCircle(),
                error: (error, _) => Text(
                  'Unable to load Contacts test source: $error',
                  style: typography.caption,
                ),
                data: (mode) =>
                    CupertinoSlidingSegmentedControl<
                      DevelopmentContactsSourceMode
                    >(
                      groupValue: mode,
                      children: const <DevelopmentContactsSourceMode, Widget>{
                        DevelopmentContactsSourceMode.realSource: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Real Contacts source'),
                        ),
                        DevelopmentContactsSourceMode
                            .disposableUnavailableSource: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Disposable unavailable'),
                        ),
                      },
                      onValueChanged: (selectedMode) {
                        if (selectedMode == null) {
                          return;
                        }
                        ref
                            .read(
                              developmentContactsSourceSelectionProvider
                                  .notifier,
                            )
                            .select(selectedMode);
                      },
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  PushButton(
                    controlSize: ControlSize.regular,
                    onPressed: () {
                      setState(() {
                        _showDiagram = !_showDiagram;
                      });
                    },
                    child: Text(
                      _showDiagram
                          ? 'Hide Schedule Diagram'
                          : 'Generate Schedule Diagram',
                    ),
                  ),
                  const SizedBox(width: 12),
                  PushButton(
                    controlSize: ControlSize.regular,
                    onPressed: () {
                      setState(() {
                        _showMap = !_showMap;
                      });
                    },
                    child: Text(
                      _showMap ? 'Hide Schedule Map' : 'Show Schedule Map',
                    ),
                  ),
                  const SizedBox(width: 12),
                  PushButton(
                    controlSize: ControlSize.regular,
                    onPressed: () {
                      setState(() {
                        _showTrace = !_showTrace;
                      });
                    },
                    child: Text(
                      _showTrace
                          ? 'Hide Execution Trace'
                          : 'Show Execution Trace',
                    ),
                  ),
                ],
              ),
              if (diagram != null) ...<Widget>[
                const SizedBox(height: 16),
                diagram.when(
                  loading: () => const ProgressCircle(),
                  error: (error, _) => Text('Unable to generate: $error'),
                  data: (document) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: SingleChildScrollView(
                          child: Text(
                            document.mermaid,
                            style: typography.caption,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PushButton(
                        controlSize: ControlSize.small,
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: document.mermaid),
                          );
                        },
                        child: const Text('Copy Mermaid'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ] else
                const SizedBox(height: 32),
              if (visualization != null) ...<Widget>[
                visualization.when(
                  loading: () => const ProgressCircle(),
                  error: (error, _) =>
                      Text('Unable to load Schedule map: $error'),
                  data: (value) =>
                      ScheduleRunVisualizationView(visualization: value),
                ),
                const SizedBox(height: 32),
              ],
              if (trace != null) ...<Widget>[
                trace.when(
                  loading: () => const ProgressCircle(),
                  error: (error, _) => Text('Unable to load trace: $error'),
                  data: (events) => ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: SingleChildScrollView(
                      child: Text(
                        events.map(_formatTraceEvent).join('\n'),
                        style: typography.caption,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
              if (trip == null || step == null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${run.scheduleName} complete',
                      style: PresencePresentationTokens.primaryTellStyle(
                        typography,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    PushButton(
                      controlSize: ControlSize.regular,
                      onPressed: _isRestarting
                          ? null
                          : () => _runAgain(scheduler),
                      child: Text(_isRestarting ? 'Starting...' : 'Run Again'),
                    ),
                  ],
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      run.scheduleName,
                      style: typography.caption,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      trip.definition.name,
                      style: typography.title2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      step is TellStep ? step.text : step.name,
                      style: PresencePresentationTokens.primaryTellStyle(
                        typography,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Step ${trip.currentStepIndex + 1} of '
                      '${trip.definition.steps.length}',
                      style: typography.caption,
                    ),
                    const SizedBox(height: 24),
                    if (_completionError case final error?) ...<Widget>[
                      Text(
                        'Step did not complete: $error',
                        style: typography.caption,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                    PushButton(
                      controlSize: ControlSize.regular,
                      onPressed: _isCompleting
                          ? null
                          : () => _completeCurrentStep(scheduler),
                      child: Text(
                        _isCompleting
                            ? 'Checkpointing...'
                            : step is OpenFdaSettingsStep
                            ? 'Open System Settings'
                            : 'Complete Step',
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTraceEvent(ExecutionTraceEvent event) {
    final sequence = event.sequence.toString().padLeft(2, '0');
    final description = switch (event.type) {
      ExecutionTraceEventType.scheduleRunStarted => 'Schedule started',
      ExecutionTraceEventType.tripStarted =>
        'Trip occurrence ${event.tripOccurrenceId} started',
      ExecutionTraceEventType.stepStarted =>
        'Step occurrence ${event.stepOccurrenceId} started',
      ExecutionTraceEventType.stepCompleted =>
        'Step occurrence ${event.stepOccurrenceId} completed',
      ExecutionTraceEventType.tripCompleted =>
        'Trip occurrence ${event.tripOccurrenceId} completed',
      ExecutionTraceEventType.routeDecision => _formatRouteDecision(event),
      ExecutionTraceEventType.scheduleRunCompleted => 'Schedule completed',
    };
    return '#$sequence $description';
  }

  String _formatRouteDecision(ExecutionTraceEvent event) {
    final result = event.routingResultTripDefinitionId == null
        ? 'default'
        : 'Trip ${event.routingResultTripDefinitionId?.value}';
    final destination = event.selectedDestinationTripOccurrenceId == null
        ? 'complete'
        : 'occurrence ${event.selectedDestinationTripOccurrenceId}';
    return 'Route: $result -> $destination';
  }
}
