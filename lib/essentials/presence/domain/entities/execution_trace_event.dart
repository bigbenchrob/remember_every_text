import 'trip_definition_id.dart';

enum ExecutionTraceEventType {
  scheduleRunStarted,
  tripStarted,
  stepStarted,
  stepCompleted,
  tripCompleted,
  routeDecision,
  scheduleRunCompleted,
}

/// One append-only observation of Schedule execution.
final class ExecutionTraceEvent {
  const ExecutionTraceEvent({
    required this.id,
    required this.scheduleRunId,
    required this.sequence,
    required this.type,
    required this.tripOccurrenceId,
    required this.stepOccurrenceId,
    required this.routingResultTripDefinitionId,
    required this.selectedDestinationTripOccurrenceId,
    required this.occurredAtUtcUs,
  });

  final int id;
  final int scheduleRunId;
  final int sequence;
  final ExecutionTraceEventType type;
  final int? tripOccurrenceId;
  final int? stepOccurrenceId;
  final TripDefinitionId? routingResultTripDefinitionId;
  final int? selectedDestinationTripOccurrenceId;
  final int occurredAtUtcUs;
}
