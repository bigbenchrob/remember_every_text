import '../entities/schedule_run.dart';

/// Narrow authority for superseding an incomplete Schedule run.
abstract interface class PresenceScheduleRunMaintenance {
  Future<bool> definitionExists(int scheduleDefinitionId);

  Future<ScheduleRun> supersedeRunFromBeginning(int scheduleDefinitionId);
}
