import '../../../../essentials/presence/domain/entities/schedule_definition.dart';
import '../../../../essentials/presence/domain/entities/step.dart';
import '../../../../essentials/presence/domain/entities/trip_definition_id.dart';
import 'schedule_topology_projection.dart';

/// Read-only projection of the possible topology encoded by one Schedule.
final class ScheduleTopologyProjector {
  const ScheduleTopologyProjector();

  ScheduleTopologyProjection project(ScheduleDefinition definition) {
    final ordered = List<ScheduleTripDefinition>.of(definition.trips)
      ..sort((left, right) => left.position.compareTo(right.position));
    final positions = <int>{};
    final byTripId = <TripDefinitionId, ScheduleTripDefinition>{};
    for (final occurrence in ordered) {
      if (!positions.add(occurrence.position)) {
        throw StateError(
          'Schedule ${definition.id} has duplicate position '
          '${occurrence.position}.',
        );
      }
      if (byTripId.putIfAbsent(occurrence.trip.id, () => occurrence) !=
          occurrence) {
        throw StateError(
          'Schedule ${definition.id} contains Trip ${occurrence.trip.id} '
          'more than once.',
        );
      }
      if (occurrence.trip.steps.isEmpty) {
        throw StateError('Trip ${occurrence.trip.id} has no terminal Step.');
      }
    }

    final trips = <ScheduleTopologyTrip>[];
    final edges = <ScheduleTopologyEdge>[];
    for (var index = 0; index < ordered.length; index += 1) {
      final occurrence = ordered[index];
      final terminalStep = occurrence.trip.steps.last;
      final defaultDestination = index + 1 < ordered.length
          ? ordered[index + 1]
          : null;
      trips.add(
        ScheduleTopologyTrip(
          occurrenceId: occurrence.occurrenceId,
          position: occurrence.position,
          tripDefinitionId: occurrence.trip.id,
          name: occurrence.trip.name,
          stepSummary: _stepSummary(occurrence.trip.steps),
          usesDecisionShape: terminalStep is TestStep,
        ),
      );

      switch (terminalStep) {
        case TellStep() || OpenFdaSettingsStep():
          edges.add(
            _edge(
              from: occurrence,
              to: defaultDestination,
              routingResultTripDefinitionId: null,
              label: 'default',
              kind: ScheduleTopologyEdgeKind.defaultNext,
            ),
          );
        case FixedDestinationStep():
          final destination = _resolveExplicit(
            definition: definition,
            byTripId: byTripId,
            destination: terminalStep.destinationTripDefinitionId,
          );
          edges.add(
            _edge(
              from: occurrence,
              to: destination,
              routingResultTripDefinitionId:
                  terminalStep.destinationTripDefinitionId,
              label: 'explicit: Trip ${destination.trip.id.value}',
              kind: ScheduleTopologyEdgeKind.explicit,
            ),
          );
        case TestStep():
          edges.add(
            _conditionEdge(
              definition: definition,
              byTripId: byTripId,
              from: occurrence,
              defaultDestination: defaultDestination,
              destination: terminalStep.trueDestinationTripDefinitionId,
              outcome: 'True',
            ),
          );
          edges.add(
            _conditionEdge(
              definition: definition,
              byTripId: byTripId,
              from: occurrence,
              defaultDestination: defaultDestination,
              destination: terminalStep.falseDestinationTripDefinitionId,
              outcome: 'False',
            ),
          );
      }
    }

    return ScheduleTopologyProjection(
      scheduleDefinitionId: definition.id,
      scheduleName: definition.name,
      trips: trips,
      edges: edges,
    );
  }

  ScheduleTopologyEdge _conditionEdge({
    required ScheduleDefinition definition,
    required Map<TripDefinitionId, ScheduleTripDefinition> byTripId,
    required ScheduleTripDefinition from,
    required ScheduleTripDefinition? defaultDestination,
    required TripDefinitionId? destination,
    required String outcome,
  }) {
    if (destination == null) {
      return _edge(
        from: from,
        to: defaultDestination,
        routingResultTripDefinitionId: null,
        label: '$outcome: default',
        kind: ScheduleTopologyEdgeKind.defaultNext,
        isConditional: true,
      );
    }
    final explicit = _resolveExplicit(
      definition: definition,
      byTripId: byTripId,
      destination: destination,
    );
    return _edge(
      from: from,
      to: explicit,
      routingResultTripDefinitionId: destination,
      label: '$outcome: Trip ${explicit.trip.id.value}',
      kind: ScheduleTopologyEdgeKind.explicit,
      isConditional: true,
    );
  }

  ScheduleTripDefinition _resolveExplicit({
    required ScheduleDefinition definition,
    required Map<TripDefinitionId, ScheduleTripDefinition> byTripId,
    required TripDefinitionId destination,
  }) {
    final occurrence = byTripId[destination];
    if (occurrence == null) {
      throw StateError(
        'Trip destination $destination is absent from Schedule '
        '${definition.id}.',
      );
    }
    return occurrence;
  }

  ScheduleTopologyEdge _edge({
    required ScheduleTripDefinition from,
    required ScheduleTripDefinition? to,
    required TripDefinitionId? routingResultTripDefinitionId,
    required String label,
    required ScheduleTopologyEdgeKind kind,
    bool isConditional = false,
  }) {
    return ScheduleTopologyEdge(
      sourceTripOccurrenceId: from.occurrenceId,
      destinationTripOccurrenceId: to?.occurrenceId,
      routingResultTripDefinitionId: routingResultTripDefinitionId,
      label: label,
      kind: kind,
      isConditional: isConditional,
      isBackward: to != null && to.position < from.position,
      isSelf: to != null && to.trip.id == from.trip.id,
    );
  }

  String _stepSummary(List<Step> steps) {
    if (steps.length > 1) {
      final types = steps.map(_stepTypeLabel).join(' &rarr; ');
      return '${steps.length} Steps: $types';
    }
    return switch (steps.single) {
      TellStep(text: final text) => 'Tell: $text',
      FixedDestinationStep() => 'Fixed destination',
      TestStep(testAgentId: final id) => 'Test: ${id.value}',
      OpenFdaSettingsStep() => 'Open FDA Settings',
    };
  }

  String _stepTypeLabel(Step step) {
    return switch (step) {
      TellStep() => 'Tell',
      FixedDestinationStep() => 'Fixed destination',
      TestStep(testAgentId: final id) => 'Test: ${id.value}',
      OpenFdaSettingsStep() => 'Open FDA Settings',
    };
  }
}
