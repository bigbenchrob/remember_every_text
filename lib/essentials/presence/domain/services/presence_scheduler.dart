import '../entities/schedule_run.dart';
import '../entities/step.dart';
import '../entities/trip.dart';
import '../repositories/presence_schedule_repository.dart';

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
    final stepPosition = trip.currentStepIndex;
    await _repository.recordStepStarted(
      scheduleRunId: run.id,
      expectedCurrentTripOccurrenceId: occurrenceId,
      stepPosition: stepPosition,
      expectedStepDefinitionId: step.id,
    );
    final completion = await trip.completeCurrentStep();
    await _repository.recordStepCompleted(
      scheduleRunId: run.id,
      expectedCurrentTripOccurrenceId: occurrenceId,
      stepPosition: stepPosition,
      expectedStepDefinitionId: step.id,
    );
    if (!completion.tripCompleted) {
      return;
    }

    final checkpointedRun = await _repository.checkpointTripCompletion(
      scheduleRunId: run.id,
      expectedCurrentTripOccurrenceId: occurrenceId,
      routingResultTripDefinitionId: completion.routingResultTripDefinitionId,
    );
    _install(checkpointedRun);
    await _recordCurrentTripStarted();
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
  }
}
