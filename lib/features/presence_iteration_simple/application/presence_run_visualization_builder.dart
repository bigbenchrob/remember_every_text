import '../../../essentials/presence/domain/entities/execution_trace_event.dart';
import '../../../essentials/presence/domain/entities/schedule_run.dart';
import '../infrastructure/development/schedule_topology_projection.dart';
import 'presence_run_visualization.dart';

/// Combines three read authorities without granting any one another's role.
final class PresenceRunVisualizationBuilder {
  const PresenceRunVisualizationBuilder();

  PresenceRunVisualization build({
    required ScheduleTopologyProjection topology,
    required ScheduleRun run,
    required List<ExecutionTraceEvent> trace,
  }) {
    if (run.scheduleDefinitionId != topology.scheduleDefinitionId) {
      throw StateError(
        'Schedule run ${run.id} belongs to definition '
        '${run.scheduleDefinitionId}, not ${topology.scheduleDefinitionId}.',
      );
    }

    final knownOccurrences = topology.trips
        .map((trip) => trip.occurrenceId)
        .toSet();
    final currentOccurrenceId = run.currentTripOccurrenceId;
    if (currentOccurrenceId != null &&
        !knownOccurrences.contains(currentOccurrenceId)) {
      throw StateError(
        'Current Trip occurrence $currentOccurrenceId is absent from '
        'Schedule ${topology.scheduleDefinitionId}.',
      );
    }

    final visitCounts = <int, int>{};
    final routeTraversalCounts = <ScheduleRouteTransition, int>{};
    for (final event in trace) {
      if (event.scheduleRunId != run.id) {
        throw StateError(
          'Trace event ${event.id} belongs to run ${event.scheduleRunId}, '
          'not ${run.id}.',
        );
      }
      switch (event.type) {
        case ExecutionTraceEventType.tripStarted:
          final occurrenceId = event.tripOccurrenceId!;
          if (!knownOccurrences.contains(occurrenceId)) {
            throw StateError(
              'Traced Trip occurrence $occurrenceId is absent from Schedule '
              '${topology.scheduleDefinitionId}.',
            );
          }
          visitCounts.update(
            occurrenceId,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
        case ExecutionTraceEventType.routeDecision:
          final transition = ScheduleRouteTransition(
            sourceTripOccurrenceId: event.tripOccurrenceId!,
            routingResultTripDefinitionId: event.routingResultTripDefinitionId,
            selectedDestinationTripOccurrenceId:
                event.selectedDestinationTripOccurrenceId,
          );
          if (!_isPossibleTransition(topology.edges, transition)) {
            throw StateError(
              'Trace event ${event.id} records a route absent from Schedule '
              '${topology.scheduleDefinitionId}.',
            );
          }
          routeTraversalCounts.update(
            transition,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
        case ExecutionTraceEventType.scheduleRunStarted:
        case ExecutionTraceEventType.stepStarted:
        case ExecutionTraceEventType.stepCompleted:
        case ExecutionTraceEventType.tripCompleted:
        case ExecutionTraceEventType.scheduleRunCompleted:
          break;
      }
    }

    return PresenceRunVisualization(
      scheduleRunId: run.id,
      topology: topology,
      currentTripOccurrenceId: currentOccurrenceId,
      visitCounts: visitCounts,
      routeTraversalCounts: routeTraversalCounts,
    );
  }

  bool _isPossibleTransition(
    List<ScheduleTopologyEdge> edges,
    ScheduleRouteTransition transition,
  ) {
    return edges.any(
      (edge) =>
          edge.sourceTripOccurrenceId == transition.sourceTripOccurrenceId &&
          edge.routingResultTripDefinitionId ==
              transition.routingResultTripDefinitionId &&
          edge.destinationTripOccurrenceId ==
              transition.selectedDestinationTripOccurrenceId,
    );
  }
}
