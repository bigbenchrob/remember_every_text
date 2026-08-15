import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/schedule_definition.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/test_agent_id.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';
import 'package:remember_this_text/essentials/presence/domain/services/fda_settings_opening_authority.dart';
import 'package:remember_this_text/essentials/presence/domain/services/presence_scheduler.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent_resolver.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/data_sources/local/presence_database.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/repositories/drift_presence_schedule_repository.dart';
import 'package:remember_this_text/essentials/presence/presentation/presence_runner.dart';
import 'package:remember_this_text/essentials/presence/presentation/presence_step_presenter.dart';

void main() {
  late PresenceDatabase database;

  setUp(() {
    database = PresenceDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('renders Tell through the permanent generic presenter', (
    tester,
  ) async {
    final scheduler = await _start(
      database,
      _tellSchedule(),
      ImmutableTestAgentResolver(const <TestAgentBinding>[]),
    );

    await _pumpRunner(tester, scheduler);

    expect(find.byType(PresenceStepPresenter), findsOneWidget);
    expect(find.text('A generic Tell'), findsOneWidget);
  });

  testWidgets('Test and fixed destination Steps advance autonomously', (
    tester,
  ) async {
    final scheduler = await _start(
      database,
      _automaticSchedule(),
      ImmutableTestAgentResolver(<TestAgentBinding>[
        TestAgentBinding(
          id: TestAgentId('test.ready'),
          agent: const _ConstantTestAgent(result: true),
        ),
      ]),
    );

    await _pumpRunner(tester, scheduler);
    await _pumpUntilFound(tester, find.text('Automatic route complete'));

    expect(find.text('Complete Step'), findsOneWidget);
    expect(scheduler.currentTrip?.definition.id, const TripDefinitionId(30));
  });

  testWidgets('delegates only specialist presentation to its host', (
    tester,
  ) async {
    final scheduler = await _start(
      database,
      _specialistSchedule(),
      ImmutableTestAgentResolver(const <TestAgentBinding>[]),
    );

    await _pumpRunner(
      tester,
      scheduler,
      specialistBuilder: (context, complete) {
        return PushButton(
          controlSize: ControlSize.regular,
          onPressed: complete,
          child: const Text('Specialist operation'),
        );
      },
    );

    expect(find.text('Specialist operation'), findsOneWidget);
  });
}

Future<PresenceScheduler> _start(
  PresenceDatabase database,
  ScheduleDefinition definition,
  TestAgentResolver resolver,
) async {
  final repository = DriftPresenceScheduleRepository(
    database: database,
    testAgentResolver: resolver,
  );
  await repository.insertDefinition(definition);
  final scheduler = PresenceScheduler(
    repository: repository,
    scheduleDefinitionId: definition.id,
  );
  await scheduler.initialize();
  return scheduler;
}

Future<void> _pumpRunner(
  WidgetTester tester,
  PresenceScheduler scheduler, {
  PresenceSpecialistStepBuilder? specialistBuilder,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MacosApp(
        home: Center(
          child: PresenceRunner(
            scheduler: scheduler,
            specialistBuilder:
                specialistBuilder ??
                (context, complete) => const Text('Specialist'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 10));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Expected widget was not rendered.');
}

ScheduleDefinition _tellSchedule() {
  return ScheduleDefinition(
    id: 1,
    name: 'tell',
    trips: <ScheduleTripDefinition>[
      ScheduleTripDefinition(
        occurrenceId: 101,
        position: 0,
        trip: TripDefinition(
          id: const TripDefinitionId(10),
          name: 'tell_trip',
          steps: const <Step>[
            TellStep(id: 1001, name: 'tell', text: 'A generic Tell'),
          ],
        ),
      ),
    ],
  );
}

ScheduleDefinition _automaticSchedule() {
  return ScheduleDefinition(
    id: 2,
    name: 'automatic',
    trips: <ScheduleTripDefinition>[
      ScheduleTripDefinition(
        occurrenceId: 201,
        position: 0,
        trip: TripDefinition(
          id: const TripDefinitionId(10),
          name: 'test_trip',
          steps: <Step>[
            TestStep(
              id: 2001,
              name: 'test',
              testAgentId: TestAgentId('test.ready'),
              testAgent: const _ConstantTestAgent(result: true),
              trueDestinationTripDefinitionId: const TripDefinitionId(20),
              falseDestinationTripDefinitionId: null,
            ),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 202,
        position: 1,
        trip: TripDefinition(
          id: const TripDefinitionId(20),
          name: 'fixed_trip',
          steps: const <Step>[
            FixedDestinationStep(
              id: 2002,
              name: 'fixed',
              destinationTripDefinitionId: TripDefinitionId(30),
            ),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 203,
        position: 2,
        trip: TripDefinition(
          id: const TripDefinitionId(30),
          name: 'destination',
          steps: const <Step>[
            TellStep(
              id: 2003,
              name: 'destination_tell',
              text: 'Automatic route complete',
            ),
          ],
        ),
      ),
    ],
  );
}

ScheduleDefinition _specialistSchedule() {
  return ScheduleDefinition(
    id: 3,
    name: 'specialist',
    trips: <ScheduleTripDefinition>[
      ScheduleTripDefinition(
        occurrenceId: 301,
        position: 0,
        trip: TripDefinition(
          id: const TripDefinitionId(10),
          name: 'specialist_trip',
          steps: const <Step>[
            OpenFdaSettingsStep(
              id: 3001,
              name: 'specialist',
              settingsOpeningAuthority: _NoOpFdaSettingsAuthority(),
            ),
          ],
        ),
      ),
    ],
  );
}

final class _ConstantTestAgent implements TestAgent {
  const _ConstantTestAgent({required this.result});

  final bool result;

  @override
  Future<bool> evaluate() async => result;
}

final class _NoOpFdaSettingsAuthority implements FdaSettingsOpeningAuthority {
  const _NoOpFdaSettingsAuthority();

  @override
  Future<void> openSettings() async {}
}
