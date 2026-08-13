import 'trip.dart';

final class ScheduleRun {
  const ScheduleRun({
    required this.id,
    required this.scheduleDefinitionId,
    required this.scheduleName,
    required this.currentTripOccurrenceId,
    required this.currentTripDefinition,
  });

  final int id;
  final int scheduleDefinitionId;
  final String scheduleName;
  final int? currentTripOccurrenceId;
  final TripDefinition? currentTripDefinition;

  bool get isComplete => currentTripOccurrenceId == null;
}
