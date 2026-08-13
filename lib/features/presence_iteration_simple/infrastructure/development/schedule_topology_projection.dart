import '../../../../essentials/presence/domain/entities/trip_definition_id.dart';

enum ScheduleTopologyEdgeKind { defaultNext, explicit }

final class ScheduleTopologyTrip {
  const ScheduleTopologyTrip({
    required this.occurrenceId,
    required this.position,
    required this.tripDefinitionId,
    required this.name,
    required this.stepSummary,
    required this.usesDecisionShape,
  });

  final int occurrenceId;
  final int position;
  final TripDefinitionId tripDefinitionId;
  final String name;
  final String stepSummary;
  final bool usesDecisionShape;
}

final class ScheduleTopologyEdge {
  const ScheduleTopologyEdge({
    required this.sourceTripOccurrenceId,
    required this.destinationTripOccurrenceId,
    required this.routingResultTripDefinitionId,
    required this.label,
    required this.kind,
    required this.isConditional,
    required this.isBackward,
    required this.isSelf,
  });

  final int sourceTripOccurrenceId;
  final int? destinationTripOccurrenceId;
  final TripDefinitionId? routingResultTripDefinitionId;
  final String label;
  final ScheduleTopologyEdgeKind kind;
  final bool isConditional;
  final bool isBackward;
  final bool isSelf;
}

final class ScheduleTopologyProjection {
  ScheduleTopologyProjection({
    required this.scheduleDefinitionId,
    required this.scheduleName,
    required List<ScheduleTopologyTrip> trips,
    required List<ScheduleTopologyEdge> edges,
  }) : trips = List<ScheduleTopologyTrip>.unmodifiable(trips),
       edges = List<ScheduleTopologyEdge>.unmodifiable(edges);

  final int scheduleDefinitionId;
  final String scheduleName;
  final List<ScheduleTopologyTrip> trips;
  final List<ScheduleTopologyEdge> edges;
}
