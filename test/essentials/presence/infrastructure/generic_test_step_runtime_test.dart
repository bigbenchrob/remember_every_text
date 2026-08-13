import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/execution_trace_event.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/schedule_definition.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/test_agent_id.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';
import 'package:remember_this_text/essentials/presence/domain/services/presence_scheduler.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent_resolver.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/data_sources/local/presence_database.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/repositories/drift_presence_schedule_repository.dart';

void main() {
  final agentAId = TestAgentId('test.agent-a');
  final agentBId = TestAgentId('test.agent-b');

  group('TestStep', () {
    test('selects its true and false destinations', () async {
      final agent = _MutableTestAgent(value: true);
      final step = TestStep(
        id: 1,
        name: 'test',
        testAgentId: agentAId,
        testAgent: agent,
        trueDestinationTripDefinitionId: const TripDefinitionId(2),
        falseDestinationTripDefinitionId: const TripDefinitionId(3),
      );

      expect(await step.complete(), const TripDefinitionId(2));
      agent.value = false;
      expect(await step.complete(), const TripDefinitionId(3));
    });

    test('preserves null as default-next on either arm', () async {
      final agent = _MutableTestAgent(value: true);
      final step = TestStep(
        id: 1,
        name: 'test',
        testAgentId: agentAId,
        testAgent: agent,
        trueDestinationTripDefinitionId: null,
        falseDestinationTripDefinitionId: null,
      );

      expect(await step.complete(), isNull);
      agent.value = false;
      expect(await step.complete(), isNull);
    });

    test('propagates Agent failure', () async {
      final step = TestStep(
        id: 1,
        name: 'test',
        testAgentId: agentAId,
        testAgent: const _ThrowingTestAgent(),
        trueDestinationTripDefinitionId: null,
        falseDestinationTripDefinitionId: null,
      );

      await expectLater(step.complete(), throwsA(isA<StateError>()));
    });
  });

  group('generic TestStep reconstruction', () {
    late PresenceDatabase database;

    setUp(() {
      database = PresenceDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('uses the Agent returned by the resolver', () async {
      final insertedAgent = _MutableTestAgent(value: false);
      final resolvedAgent = _MutableTestAgent(value: true);
      final writer = _repository(database, <TestAgentBinding>[
        TestAgentBinding(id: agentAId, agent: insertedAgent),
      ]);
      await writer.insertDefinition(
        _schedule(id: 1, agentId: agentAId, agent: insertedAgent),
      );
      final reader = _repository(database, <TestAgentBinding>[
        TestAgentBinding(id: agentAId, agent: resolvedAgent),
      ]);

      final definition = await reader.loadDefinition(1);
      final step = definition.trips.first.trip.steps.single as TestStep;

      expect(step.testAgentId, agentAId);
      expect(await step.complete(), const TripDefinitionId(12));
      expect(insertedAgent.invocationCount, 0);
      expect(resolvedAgent.invocationCount, 1);
    });

    test('missing binding prevents run creation and start trace', () async {
      final agent = _MutableTestAgent(value: true);
      final writer = _repository(database, <TestAgentBinding>[
        TestAgentBinding(id: agentAId, agent: agent),
      ]);
      await writer.insertDefinition(
        _schedule(id: 1, agentId: agentAId, agent: agent),
      );
      final unbound = _repository(database, const <TestAgentBinding>[]);

      await expectLater(
        unbound.startOrLoadRun(1),
        throwsA(isA<MissingTestAgentBindingException>()),
      );
      expect(await database.select(database.scheduleRuns).get(), isEmpty);
      expect(
        await database.select(database.executionTraceEvents).get(),
        isEmpty,
      );
    });

    test('resolution is scoped to the requested Schedule', () async {
      final agentA = _MutableTestAgent(value: true);
      final agentB = _MutableTestAgent(value: false);
      final writer = _repository(database, <TestAgentBinding>[
        TestAgentBinding(id: agentAId, agent: agentA),
        TestAgentBinding(id: agentBId, agent: agentB),
      ]);
      await writer.insertDefinition(
        _schedule(id: 1, agentId: agentAId, agent: agentA),
      );
      await writer.insertDefinition(
        _schedule(id: 2, agentId: agentBId, agent: agentB),
      );
      final onlyA = _repository(database, <TestAgentBinding>[
        TestAgentBinding(id: agentAId, agent: agentA),
      ]);

      expect(await onlyA.loadDefinition(1), isA<ScheduleDefinition>());
      await expectLater(
        onlyA.loadDefinition(2),
        throwsA(isA<MissingTestAgentBindingException>()),
      );
    });

    test('missing binding prevents an existing run from advancing', () async {
      final agent = _MutableTestAgent(value: true);
      final writer = _repository(database, <TestAgentBinding>[
        TestAgentBinding(id: agentAId, agent: agent),
      ]);
      await writer.insertDefinition(
        _schedule(id: 1, agentId: agentAId, agent: agent),
      );
      final run = await writer.startOrLoadRun(1);
      final traceBefore = await writer.loadExecutionTrace(run.id);
      final unbound = _repository(database, const <TestAgentBinding>[]);

      await expectLater(
        unbound.recordStepStarted(
          scheduleRunId: run.id,
          expectedCurrentTripOccurrenceId: run.currentTripOccurrenceId!,
          stepPosition: 0,
          expectedStepDefinitionId: 101,
        ),
        throwsA(isA<MissingTestAgentBindingException>()),
      );
      final unchanged = await writer.loadRun(run.id);
      expect(unchanged.currentTripOccurrenceId, run.currentTripOccurrenceId);
      final traceAfter = await writer.loadExecutionTrace(run.id);
      expect(traceAfter.length, traceBefore.length);
      expect(
        traceAfter.map((event) => (event.id, event.sequence, event.type)),
        traceBefore.map((event) => (event.id, event.sequence, event.type)),
      );
    });

    test('Agent failure records no completion or route checkpoint', () async {
      const agent = _ThrowingTestAgent();
      final repository = _repository(database, <TestAgentBinding>[
        TestAgentBinding(id: agentAId, agent: agent),
      ]);
      await repository.insertDefinition(
        _schedule(id: 1, agentId: agentAId, agent: agent),
      );
      final scheduler = PresenceScheduler(
        repository: repository,
        scheduleDefinitionId: 1,
      );
      await scheduler.initialize();
      final occurrenceBefore = scheduler.run!.currentTripOccurrenceId;

      await expectLater(
        scheduler.completeCurrentStep(),
        throwsA(isA<StateError>()),
      );

      expect(scheduler.run!.currentTripOccurrenceId, occurrenceBefore);
      final trace = await repository.loadExecutionTrace(scheduler.run!.id);
      expect(
        trace.where(
          (event) => event.type == ExecutionTraceEventType.stepStarted,
        ),
        hasLength(1),
      );
      expect(
        trace.where(
          (event) => event.type == ExecutionTraceEventType.stepCompleted,
        ),
        isEmpty,
      );
      expect(
        trace.where(
          (event) => event.type == ExecutionTraceEventType.routeDecision,
        ),
        isEmpty,
      );
    });
  });
}

DriftPresenceScheduleRepository _repository(
  PresenceDatabase database,
  List<TestAgentBinding> bindings,
) {
  return DriftPresenceScheduleRepository(
    database: database,
    testAgentResolver: ImmutableTestAgentResolver(bindings),
  );
}

ScheduleDefinition _schedule({
  required int id,
  required TestAgentId agentId,
  required TestAgent agent,
}) {
  return ScheduleDefinition(
    id: id,
    name: 'schedule_$id',
    trips: <ScheduleTripDefinition>[
      ScheduleTripDefinition(
        occurrenceId: id * 1000 + 1,
        position: 0,
        trip: TripDefinition(
          id: TripDefinitionId(id * 10 + 1),
          name: 'schedule_${id}_test_trip',
          steps: <Step>[
            TestStep(
              id: id * 100 + 1,
              name: 'schedule_${id}_test',
              testAgentId: agentId,
              testAgent: agent,
              trueDestinationTripDefinitionId: TripDefinitionId(id * 10 + 2),
              falseDestinationTripDefinitionId: null,
            ),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: id * 1000 + 2,
        position: 1,
        trip: TripDefinition(
          id: TripDefinitionId(id * 10 + 2),
          name: 'schedule_${id}_destination_trip',
          steps: <Step>[
            TellStep(
              id: id * 100 + 2,
              name: 'schedule_${id}_done',
              text: 'Done',
            ),
          ],
        ),
      ),
    ],
  );
}

final class _MutableTestAgent implements TestAgent {
  _MutableTestAgent({required this.value});

  bool value;
  int invocationCount = 0;

  @override
  Future<bool> evaluate() async {
    invocationCount += 1;
    return value;
  }
}

final class _ThrowingTestAgent implements TestAgent {
  const _ThrowingTestAgent();

  @override
  Future<bool> evaluate() {
    return Future<bool>.error(StateError('Agent failed.'));
  }
}
