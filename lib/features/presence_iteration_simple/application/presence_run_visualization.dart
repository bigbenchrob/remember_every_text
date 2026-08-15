import 'package:meta/meta.dart';

import '../../../essentials/presence/domain/entities/trip_definition_id.dart';
import '../infrastructure/development/schedule_topology_projection.dart';

@immutable
final class ScheduleRouteTransition {
  const ScheduleRouteTransition({
    required this.sourceTripOccurrenceId,
    required this.routingResultTripDefinitionId,
    required this.selectedDestinationTripOccurrenceId,
  });

  final int sourceTripOccurrenceId;
  final TripDefinitionId? routingResultTripDefinitionId;
  final int? selectedDestinationTripOccurrenceId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ScheduleRouteTransition &&
            other.sourceTripOccurrenceId == sourceTripOccurrenceId &&
            other.routingResultTripDefinitionId ==
                routingResultTripDefinitionId &&
            other.selectedDestinationTripOccurrenceId ==
                selectedDestinationTripOccurrenceId;
  }

  @override
  int get hashCode => Object.hash(
    sourceTripOccurrenceId,
    routingResultTripDefinitionId,
    selectedDestinationTripOccurrenceId,
  );
}

/// Read-only composition of possible, historical, and current Schedule state.
final class PresenceRunVisualization {
  PresenceRunVisualization({
    required this.scheduleRunId,
    required this.topology,
    required this.currentTripOccurrenceId,
    required Map<int, int> visitCounts,
    required Map<ScheduleRouteTransition, int> routeTraversalCounts,
  }) : visitCounts = Map<int, int>.unmodifiable(visitCounts),
       routeTraversalCounts = Map<ScheduleRouteTransition, int>.unmodifiable(
         routeTraversalCounts,
       );

  final int scheduleRunId;
  final ScheduleTopologyProjection topology;
  final int? currentTripOccurrenceId;
  final Map<int, int> visitCounts;
  final Map<ScheduleRouteTransition, int> routeTraversalCounts;

  bool get isComplete => currentTripOccurrenceId == null;

  int visitCountFor(int tripOccurrenceId) => visitCounts[tripOccurrenceId] ?? 0;

  int traversalCountFor(ScheduleTopologyEdge edge) {
    return routeTraversalCounts[ScheduleRouteTransition(
          sourceTripOccurrenceId: edge.sourceTripOccurrenceId,
          routingResultTripDefinitionId: edge.routingResultTripDefinitionId,
          selectedDestinationTripOccurrenceId: edge.destinationTripOccurrenceId,
        )] ??
        0;
  }
}
