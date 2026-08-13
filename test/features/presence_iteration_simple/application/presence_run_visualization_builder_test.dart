import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_test_agent_bindings.dart';
import 'package:remember_this_text/essentials/onboarding/application/required_sources_readiness_schedule.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/execution_trace_event.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/schedule_run.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';
import 'package:remember_this_text/essentials/presence/domain/services/fda_settings_opening_authority.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent_resolver.dart';
import 'package:remember_this_text/features/presence_iteration_simple/application/presence_run_visualization.dart';
import 'package:remember_this_text/features/presence_iteration_simple/application/presence_run_visualization_builder.dart';
import 'package:remember_this_text/features/presence_iteration_simple/infrastructure/development/schedule_topology_projection.dart';
import 'package:remember_this_text/features/presence_iteration_simple/infrastructure/development/schedule_topology_projector.dart';

void main() {
  late _RejectingCapabilities capabilities;
  late ScheduleTopologyProjection topology;

  setUp(() {
    capabilities = _RejectingCapabilities();
    final resolver = ImmutableTestAgentResolver(
      buildOnboardingTestAgentBindings(
        messagesSourceReadinessTestAgent: capabilities,
        contactsSourceReadinessTestAgent: capabilities,
        messagesSourceHistorySufficiencyTestAgent: capabilities,
      ),
    );
    topology = const ScheduleTopologyProjector().project(
      buildRequiredSourcesReadinessDefinition(
        testAgentResolver: resolver,
        fdaSettingsOpeningAuthority: capabilities,
      ),
    );
  });

  test('current Trip comes only from ScheduleRun', () {
    final visualization = _build(
      topology: topology,
      currentTripOccurrenceId: 6103,
      trace: <ExecutionTraceEvent>[
        _tripStarted(id: 1, sequence: 1, occurrenceId: 6104),
      ],
    );

    expect(visualization.currentTripOccurrenceId, 6103);
    expect(visualization.visitCountFor(6104), 1);
    expect(visualization.visitCountFor(6103), 0);
  });

  test('repeated ordinary events produce visit and edge counts', () {
    final trace = <ExecutionTraceEvent>[
      _tripStarted(id: 1, sequence: 1, occurrenceId: 6101),
      _route(id: 2, sequence: 2, source: 6101, destination: 6102),
      _tripStarted(id: 3, sequence: 3, occurrenceId: 6102),
      _route(id: 4, sequence: 4, source: 6102, destination: 6103),
      _tripStarted(id: 5, sequence: 5, occurrenceId: 6103),
      _route(id: 6, sequence: 6, source: 6103, destination: 6104),
      _tripStarted(id: 7, sequence: 7, occurrenceId: 6104),
      _route(
        id: 8,
        sequence: 8,
        source: 6104,
        routingResult: 303,
        destination: 6103,
      ),
      _tripStarted(id: 9, sequence: 9, occurrenceId: 6103),
      _route(id: 10, sequence: 10, source: 6103, destination: 6104),
      _tripStarted(id: 11, sequence: 11, occurrenceId: 6104),
    ];

    final visualization = _build(
      topology: topology,
      currentTripOccurrenceId: 6104,
      trace: trace,
    );

    expect(visualization.visitCountFor(6101), 1);
    expect(visualization.visitCountFor(6102), 1);
    expect(visualization.visitCountFor(6103), 2);
    expect(visualization.visitCountFor(6104), 2);
    expect(
      visualization.routeTraversalCounts[const ScheduleRouteTransition(
        sourceTripOccurrenceId: 6103,
        routingResultTripDefinitionId: null,
        selectedDestinationTripOccurrenceId: 6104,
      )],
      2,
    );
    expect(
      visualization.routeTraversalCounts[const ScheduleRouteTransition(
        sourceTripOccurrenceId: 6104,
        routingResultTripDefinitionId: TripDefinitionId(303),
        selectedDestinationTripOccurrenceId: 6103,
      )],
      1,
    );
    final untakenPresentEdge = topology.edges.singleWhere(
      (edge) =>
          edge.sourceTripOccurrenceId == 6102 &&
          edge.destinationTripOccurrenceId == 6105,
    );
    expect(visualization.traversalCountFor(untakenPresentEdge), 0);
  });

  test('restart adds another visit without changing checkpoint authority', () {
    final visualization = _build(
      topology: topology,
      currentTripOccurrenceId: 6103,
      trace: <ExecutionTraceEvent>[
        _tripStarted(id: 1, sequence: 1, occurrenceId: 6103),
        _tripStarted(id: 2, sequence: 2, occurrenceId: 6103),
      ],
    );

    expect(visualization.currentTripOccurrenceId, 6103);
    expect(visualization.visitCountFor(6103), 2);
  });

  test('completion has no current Trip and preserves history', () {
    final completionRoute = _route(
      id: 2,
      sequence: 2,
      source: 6107,
      destination: null,
    );
    final visualization = _build(
      topology: topology,
      currentTripOccurrenceId: null,
      trace: <ExecutionTraceEvent>[
        _tripStarted(id: 1, sequence: 1, occurrenceId: 6107),
        completionRoute,
      ],
    );

    expect(visualization.isComplete, isTrue);
    expect(visualization.currentTripOccurrenceId, isNull);
    expect(visualization.visitCountFor(6107), 1);
    final completionEdge = topology.edges.singleWhere(
      (edge) => edge.sourceTripOccurrenceId == 6107,
    );
    expect(visualization.traversalCountFor(completionEdge), 1);
  });

  test('projection and inspection never invoke FDA testing', () {
    _build(
      topology: topology,
      currentTripOccurrenceId: 6102,
      trace: <ExecutionTraceEvent>[
        _tripStarted(id: 1, sequence: 1, occurrenceId: 6102),
      ],
    );

    expect(capabilities.callCount, 0);
    expect(capabilities.settingsCallCount, 0);
    expect(topology.trips, hasLength(7));
    expect(topology.edges, hasLength(10));
  });
}

PresenceRunVisualization _build({
  required ScheduleTopologyProjection topology,
  required int? currentTripOccurrenceId,
  required List<ExecutionTraceEvent> trace,
}) {
  return const PresenceRunVisualizationBuilder().build(
    topology: topology,
    run: ScheduleRun(
      id: 42,
      scheduleDefinitionId: requiredSourcesReadinessScheduleId,
      scheduleName: 'required_sources_readiness_onboarding_experiment',
      currentTripOccurrenceId: currentTripOccurrenceId,
      currentTripDefinition: null,
    ),
    trace: trace,
  );
}

ExecutionTraceEvent _tripStarted({
  required int id,
  required int sequence,
  required int occurrenceId,
}) {
  return ExecutionTraceEvent(
    id: id,
    scheduleRunId: 42,
    sequence: sequence,
    type: ExecutionTraceEventType.tripStarted,
    tripOccurrenceId: occurrenceId,
    stepOccurrenceId: null,
    routingResultTripDefinitionId: null,
    selectedDestinationTripOccurrenceId: null,
    occurredAtUtcUs: sequence,
  );
}

ExecutionTraceEvent _route({
  required int id,
  required int sequence,
  required int source,
  required int? destination,
  int? routingResult,
}) {
  return ExecutionTraceEvent(
    id: id,
    scheduleRunId: 42,
    sequence: sequence,
    type: ExecutionTraceEventType.routeDecision,
    tripOccurrenceId: source,
    stepOccurrenceId: null,
    routingResultTripDefinitionId: routingResult == null
        ? null
        : TripDefinitionId(routingResult),
    selectedDestinationTripOccurrenceId: destination,
    occurredAtUtcUs: sequence,
  );
}

final class _RejectingCapabilities
    implements TestAgent, FdaSettingsOpeningAuthority {
  int callCount = 0;
  int settingsCallCount = 0;

  @override
  Future<bool> evaluate() async {
    callCount += 1;
    throw StateError('Visualization must not invoke source testing.');
  }

  @override
  Future<void> openSettings() async {
    settingsCallCount += 1;
    throw StateError('Visualization must not open System Settings.');
  }
}
