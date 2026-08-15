import '../../../../essentials/presence/domain/entities/schedule_definition.dart';
import '../../../../essentials/presence/domain/entities/trip_definition_id.dart';
import 'schedule_mermaid_document.dart';
import 'schedule_topology_projection.dart';
import 'schedule_topology_projector.dart';

/// Read-only development projection of one executable Schedule definition.
final class ScheduleMermaidRenderer {
  const ScheduleMermaidRenderer();

  ScheduleMermaidDocument render(ScheduleDefinition definition) {
    final topology = const ScheduleTopologyProjector().project(definition);
    final tripByOccurrenceId = <int, ScheduleTopologyTrip>{
      for (final trip in topology.trips) trip.occurrenceId: trip,
    };
    final nodes = topology.trips.map(_renderNode).toList();
    final renderedEdges = topology.edges
        .map(
          (edge) =>
              _renderEdge(edge: edge, tripByOccurrenceId: tripByOccurrenceId),
        )
        .toList(growable: false);

    nodes.add('    Complete["Schedule complete"]');
    final mermaid = <String>[
      'flowchart TD',
      '',
      ...nodes,
      '',
      ...renderedEdges,
    ].join('\n');
    final facts = ScheduleMermaidFacts(
      tripCount: topology.trips.length,
      defaultEdgeCount: topology.edges
          .where((edge) => edge.kind == ScheduleTopologyEdgeKind.defaultNext)
          .length,
      explicitEdgeCount: topology.edges
          .where((edge) => edge.kind == ScheduleTopologyEdgeKind.explicit)
          .length,
      conditionalAlternativeCount: topology.edges
          .where((edge) => edge.isConditional)
          .length,
      backwardEdgeCount: topology.edges.where((edge) => edge.isBackward).length,
      selfDestinationCount: topology.edges.where((edge) => edge.isSelf).length,
    );
    final battingOrder = topology.trips
        .map((trip) => trip.tripDefinitionId.value)
        .toList(growable: false);

    return ScheduleMermaidDocument(
      scheduleDefinitionId: definition.id,
      scheduleName: definition.name,
      battingOrder: battingOrder,
      mermaid: mermaid,
      facts: facts,
      markdown: _renderMarkdown(
        definition: definition,
        battingOrder: battingOrder,
        mermaid: mermaid,
        facts: facts,
      ),
    );
  }

  String _renderEdge({
    required ScheduleTopologyEdge edge,
    required Map<int, ScheduleTopologyTrip> tripByOccurrenceId,
  }) {
    final source = tripByOccurrenceId[edge.sourceTripOccurrenceId];
    if (source == null) {
      throw StateError(
        'Topology edge source ${edge.sourceTripOccurrenceId} is absent.',
      );
    }
    final destinationOccurrenceId = edge.destinationTripOccurrenceId;
    final destination = destinationOccurrenceId == null
        ? null
        : tripByOccurrenceId[destinationOccurrenceId];
    if (destinationOccurrenceId != null && destination == null) {
      throw StateError(
        'Topology edge destination $destinationOccurrenceId is absent.',
      );
    }
    final destinationNode = destination == null
        ? 'Complete'
        : _nodeId(destination.tripDefinitionId);
    return '    ${_nodeId(source.tripDefinitionId)} '
        '-->|"${_escape(edge.label)}"| $destinationNode';
  }

  String _renderNode(ScheduleTopologyTrip trip) {
    final label = <String>[
      'Trip ${trip.tripDefinitionId.value}',
      trip.name,
      trip.stepSummary,
    ].map(_escape).join('<br/>');
    final nodeId = _nodeId(trip.tripDefinitionId);
    return trip.usesDecisionShape
        ? '    $nodeId{"$label"}'
        : '    $nodeId["$label"]';
  }

  String _nodeId(TripDefinitionId id) => 'T${id.value}';

  String _escape(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('\r\n', '<br/>')
        .replaceAll('\n', '<br/>')
        .replaceAll('\r', '<br/>');
  }

  String _renderMarkdown({
    required ScheduleDefinition definition,
    required List<int> battingOrder,
    required String mermaid,
    required ScheduleMermaidFacts facts,
  }) {
    return '''
# ${definition.name}

> GENERATED FROM PRESENCE DEFINITIONS  
> DO NOT EDIT AS ROUTING AUTHORITY

Schedule identity: `${definition.id}`

Batting order: `${battingOrder.join(' -> ')}`

## Topology Facts

- Trips: ${facts.tripCount}
- Default edges: ${facts.defaultEdgeCount}
- Explicit edges: ${facts.explicitEdgeCount}
- Conditional alternatives: ${facts.conditionalAlternativeCount}
- Backward edges: ${facts.backwardEdgeCount}
- Self-destinations: ${facts.selfDestinationCount}

## Generated Mermaid

```mermaid
$mermaid
```
'''
        .trimLeft();
  }
}
