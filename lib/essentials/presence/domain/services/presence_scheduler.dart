import '../entities/choice_value.dart';
import '../entities/schedule_run.dart';
import '../entities/step.dart';
import '../entities/trip.dart';
import '../repositories/presence_schedule_repository.dart';

typedef CurrentChoiceSelection = Future<void> Function(ChoiceValue value);

typedef _CurrentStepExecution = ({
  ScheduleRun run,
  Trip trip,
  int occurrenceId,
  Step step,
  int stepPosition,
});

/// Runs one Schedule while persisting authority only at Trip boundaries.
final class PresenceScheduler {
  PresenceScheduler({
    required PresenceScheduleRepository repository,
    required this.scheduleDefinitionId,
  }) : _repository = repository;

  final PresenceScheduleRepository _repository;
  final int scheduleDefinitionId;

  ScheduleRun? _run;
  Trip? _currentTrip;
  Object _currentTripActivation = Object();
  bool _choiceSelectionInProgress = false;

  ScheduleRun? get run => _run;

  Trip? get currentTrip => _currentTrip;

  Step? get currentStep => _currentTrip?.currentStep;

  bool get isComplete => _run?.isComplete ?? false;

  Future<void> initialize() async {
    final run = await _repository.startOrLoadRun(scheduleDefinitionId);
    _install(run);
    await _recordCurrentTripStarted();
  }

  /// Explicitly starts a fresh experimental run from the first Trip.
  Future<void> replaceRunFromBeginning() async {
    final run = await _repository.replaceRunFromBeginning(scheduleDefinitionId);
    _install(run);
    await _recordCurrentTripStarted();
  }

  Future<void> completeCurrentStep() async {
    final execution = _requireCurrentStepExecution();
    if (execution.step is ChoiceStep) {
      throw StateError(
        'The current ChoiceStep requires a current Choice selection.',
      );
    }

    await _completeStep(execution, execution.trip.completeCurrentStep);
  }

  /// Issues a selection function bound to this exact ChoiceStep activation.
  ///
  /// The caller supplies only the opaque value selected by the human. Private
  /// activation evidence prevents this function from completing a later Step.
  CurrentChoiceSelection issueCurrentChoiceSelection() {
    final execution = _requireCurrentChoiceExecution();
    final activation = _currentTripActivation;
    return (ChoiceValue value) {
      return _selectCurrentChoice(
        value: value,
        expectedActivation: activation,
        expectedStep: execution.step as ChoiceStep,
      );
    };
  }

  Future<void> _selectCurrentChoice({
    required ChoiceValue value,
    required Object expectedActivation,
    required ChoiceStep expectedStep,
  }) async {
    if (!identical(expectedActivation, _currentTripActivation)) {
      throw StateError('This Choice interaction is no longer current.');
    }
    final execution = _requireCurrentChoiceExecution();
    if (!identical(execution.step, expectedStep)) {
      throw StateError('This Choice interaction is no longer current.');
    }

    expectedStep.destinationFor(value);
    if (_choiceSelectionInProgress) {
      throw StateError('The current Choice selection is already in progress.');
    }

    _choiceSelectionInProgress = true;
    try {
      await _completeStep(
        execution,
        () => execution.trip.completeCurrentChoice(value),
      );
    } finally {
      _choiceSelectionInProgress = false;
    }
  }

  Future<void> _completeStep(
    _CurrentStepExecution execution,
    Future<TripStepCompletion> Function() complete,
  ) async {
    await _repository.recordStepStarted(
      scheduleRunId: execution.run.id,
      expectedCurrentTripOccurrenceId: execution.occurrenceId,
      stepPosition: execution.stepPosition,
      expectedStepDefinitionId: execution.step.id,
    );
    final completion = await complete();
    await _repository.recordStepCompleted(
      scheduleRunId: execution.run.id,
      expectedCurrentTripOccurrenceId: execution.occurrenceId,
      stepPosition: execution.stepPosition,
      expectedStepDefinitionId: execution.step.id,
    );
    if (!completion.tripCompleted) {
      return;
    }

    final checkpointedRun = await _repository.checkpointTripCompletion(
      scheduleRunId: execution.run.id,
      expectedCurrentTripOccurrenceId: execution.occurrenceId,
      routingResultTripDefinitionId: completion.routingResultTripDefinitionId,
    );
    _install(checkpointedRun);
    await _recordCurrentTripStarted();
  }

  _CurrentStepExecution _requireCurrentChoiceExecution() {
    final execution = _requireCurrentStepExecution();
    if (execution.step is! ChoiceStep) {
      throw StateError('The current Step is not a ChoiceStep.');
    }
    if (execution.stepPosition != execution.trip.definition.steps.length - 1) {
      throw StateError('The current ChoiceStep is not terminal in its Trip.');
    }
    return execution;
  }

  _CurrentStepExecution _requireCurrentStepExecution() {
    final run = _run;
    final trip = _currentTrip;
    final occurrenceId = run?.currentTripOccurrenceId;
    if (run == null || trip == null || occurrenceId == null) {
      throw StateError('The Schedule has no current Step to complete.');
    }

    final step = trip.currentStep;
    if (step == null) {
      throw StateError('The current Trip has no Step to complete.');
    }
    return (
      run: run,
      trip: trip,
      occurrenceId: occurrenceId,
      step: step,
      stepPosition: trip.currentStepIndex,
    );
  }

  Future<void> _recordCurrentTripStarted() async {
    final run = _run;
    final occurrenceId = run?.currentTripOccurrenceId;
    if (run == null || occurrenceId == null) {
      return;
    }
    await _repository.recordTripStarted(
      scheduleRunId: run.id,
      expectedCurrentTripOccurrenceId: occurrenceId,
    );
  }

  void _install(ScheduleRun run) {
    _run = run;
    final definition = run.currentTripDefinition;
    _currentTrip = definition == null ? null : Trip(definition);
    _currentTripActivation = Object();
  }
}
