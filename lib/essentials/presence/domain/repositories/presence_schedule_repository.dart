import '../entities/execution_trace_event.dart';
import '../entities/schedule_definition.dart';
import '../entities/schedule_run.dart';
import '../entities/trip_definition_id.dart';

abstract interface class PresenceScheduleRepository {
  Future<bool> definitionExists(int scheduleDefinitionId);

  Future<void> insertDefinition(ScheduleDefinition definition);

  /// Installs a new definition or applies a run-preserving additive extension.
  ///
  /// Existing occurrence identities and their associated Trip identities must
  /// remain stable. Implementations must reject removals or semantic remapping
  /// rather than resetting active or completed runs.
  Future<void> installOrExtendDefinition(ScheduleDefinition definition);

  /// Loads one complete executable definition without reading or changing runs.
  Future<ScheduleDefinition> loadDefinition(int scheduleDefinitionId);

  Future<ScheduleRun> startOrLoadRun(int scheduleDefinitionId);

  /// Watches whether the latest run for [scheduleDefinitionId] is complete.
  ///
  /// A missing run is not complete. Completion comes only from the durable run
  /// checkpoint; execution trace and Step-specific values are not consulted.
  Stream<bool> watchLatestRunCompletion(int scheduleDefinitionId);

  /// Starts a fresh experimental run at the first Trip after completion.
  Future<ScheduleRun> replaceRunFromBeginning(int scheduleDefinitionId);

  Future<ScheduleRun> loadRun(int scheduleRunId);

  Future<void> recordTripStarted({
    required int scheduleRunId,
    required int expectedCurrentTripOccurrenceId,
  });

  Future<void> recordStepStarted({
    required int scheduleRunId,
    required int expectedCurrentTripOccurrenceId,
    required int stepPosition,
    required int expectedStepDefinitionId,
  });

  Future<void> recordStepCompleted({
    required int scheduleRunId,
    required int expectedCurrentTripOccurrenceId,
    required int stepPosition,
    required int expectedStepDefinitionId,
  });

  Future<ScheduleRun> checkpointTripCompletion({
    required int scheduleRunId,
    required int expectedCurrentTripOccurrenceId,
    required TripDefinitionId? routingResultTripDefinitionId,
  });

  Future<List<ExecutionTraceEvent>> loadExecutionTrace(int scheduleRunId);
}
