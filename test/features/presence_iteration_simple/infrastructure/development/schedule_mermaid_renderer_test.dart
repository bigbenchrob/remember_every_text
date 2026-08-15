import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_test_agent_bindings.dart';
import 'package:remember_this_text/essentials/onboarding/application/required_sources_readiness_schedule.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/schedule_definition.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';
import 'package:remember_this_text/essentials/presence/domain/services/fda_settings_opening_authority.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent_resolver.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/data_sources/local/presence_database.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/repositories/drift_presence_schedule_repository.dart';
import 'package:remember_this_text/features/presence_iteration_simple/infrastructure/development/schedule_mermaid_renderer.dart';

const String _generatedArtifactPath =
    '_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/'
    '21-PRESENCE-ITERATION-SIMPLE/03-SCHEDULE-TRIP-EXPERIMENT/generated/'
    'required_sources_readiness_onboarding_experiment.md';

void main() {
  const renderer = ScheduleMermaidRenderer();

  test('linear Tell Schedule emits default edges through completion', () {
    final document = renderer.render(
      _schedule(
        id: 1,
        trips: <ScheduleTripDefinition>[
          _tellTrip(1, 0),
          _tellTrip(2, 1),
          _tellTrip(3, 2),
        ],
      ),
    );

    expect(document.mermaid, startsWith('flowchart TD\n'));
    expect(document.mermaid, contains('T1 -->|"default"| T2'));
    expect(document.mermaid, contains('T2 -->|"default"| T3'));
    expect(document.mermaid, contains('T3 -->|"default"| Complete'));
  });

  test('fixed destination replaces the batting-order edge', () {
    final document = renderer.render(
      _schedule(
        id: 2,
        trips: <ScheduleTripDefinition>[
          _tellTrip(1, 0),
          _fixedTrip(2, 1, destination: 4),
          _tellTrip(3, 2),
          _tellTrip(4, 3),
        ],
      ),
    );

    expect(document.mermaid, contains('T2 -->|"explicit: Trip 4"| T4'));
    expect(document.mermaid, isNot(contains('T2 -->|"default"| T3')));
  });

  test(
    'persisted source-readiness fixture generates its possible topology',
    () async {
      final database = PresenceDatabase(NativeDatabase.memory());
      final messagesAgent = _CountingTestAgent();
      final contactsAgent = _CountingTestAgent();
      final settingsAuthority = _CountingFdaSettingsOpeningAuthority();
      final testAgentResolver = ImmutableTestAgentResolver(
        buildOnboardingTestAgentBindings(
          messagesSourceReadinessTestAgent: messagesAgent,
          messagesSourceAccessDeniedTestAgent: messagesAgent,
          contactsSourceReadinessTestAgent: contactsAgent,
          messagesSourceHistorySufficiencyTestAgent: messagesAgent,
        ),
      );
      final repository = DriftPresenceScheduleRepository(
        database: database,
        testAgentResolver: testAgentResolver,
        fdaSettingsOpeningAuthority: settingsAuthority,
      );
      try {
        final fixture = buildRequiredSourcesReadinessDefinition(
          testAgentResolver: testAgentResolver,
          fdaSettingsOpeningAuthority: settingsAuthority,
        );
        await repository.insertDefinition(fixture);
        await repository.startOrLoadRun(fixture.id);
        final runRowsBefore = await database
            .select(database.scheduleRuns)
            .get();
        final persisted = await repository.loadDefinition(fixture.id);
        final runtimeTrip = Trip(persisted.trips.first.trip);

        final document = renderer.render(persisted);

        expect(document.battingOrder, <int>[
          301,
          302,
          303,
          304,
          305,
          306,
          308,
          309,
          310,
          311,
          307,
        ]);
        expect(document.mermaid, contains('T302 -->|"True: Trip 305"| T305'));
        expect(document.mermaid, contains('T302 -->|"False: Trip 310"| T310'));
        expect(document.mermaid, contains('T303 -->|"default"| T304'));
        expect(document.mermaid, contains('T304 -->|"True: default"| T305'));
        expect(document.mermaid, contains('T304 -->|"False: Trip 310"| T310'));
        expect(document.mermaid, contains('T305 -->|"True: Trip 308"| T308'));
        expect(document.mermaid, contains('T305 -->|"False: default"| T306'));
        expect(
          document.mermaid,
          contains('T306 -->|"explicit: Trip 305"| T305'),
        );
        expect(document.mermaid, contains('T308 -->|"True: Trip 307"| T307'));
        expect(document.mermaid, contains('T308 -->|"False: Trip 309"| T309'));
        expect(
          document.mermaid,
          contains('T309 -->|"Re-check: Trip 308"| T308'),
        );
        expect(
          document.mermaid,
          contains('T309 -->|"Import Anyway: Trip 307"| T307'),
        );
        expect(document.mermaid, contains('T310 -->|"True: Trip 303"| T303'));
        expect(document.mermaid, contains('T310 -->|"False: Trip 311"| T311'));
        expect(
          document.mermaid,
          contains('T311 -->|"explicit: Trip 302"| T302'),
        );
        expect(document.mermaid, contains('T307 -->|"default"| Complete'));
        expect(document.mermaid, isNot(contains('null')));
        expect(document.facts.tripCount, 11);
        expect(document.facts.conditionalAlternativeCount, 12);
        expect(document.facts.backwardEdgeCount, 4);
        expect(messagesAgent.invocationCount, 0);
        expect(contactsAgent.invocationCount, 0);
        expect(settingsAuthority.invocationCount, 0);
        expect(runtimeTrip.currentStepIndex, 0);
        expect(
          runtimeTrip.currentStep,
          same(runtimeTrip.definition.steps.first),
        );
        expect(
          await database.select(database.scheduleRuns).get(),
          runRowsBefore,
        );
        expect(
          File(_generatedArtifactPath).readAsStringSync(),
          document.markdown,
        );
      } finally {
        await database.close();
      }
    },
  );

  test('escapes quoted, punctuated, multiline labels for Mermaid', () {
    final document = renderer.render(
      _schedule(
        id: 3,
        trips: <ScheduleTripDefinition>[
          ScheduleTripDefinition(
            occurrenceId: 301,
            position: 0,
            trip: TripDefinition(
              id: const TripDefinitionId(1),
              name: 'Quoted "Trip" <one>',
              steps: const <Step>[
                TellStep(
                  id: 3011,
                  name: 'quoted_tell',
                  text: 'Line "one" & ready\nLine <two>.',
                ),
              ],
            ),
          ),
        ],
      ),
    );

    expect(document.mermaid, contains('&quot;Trip&quot; &lt;one&gt;'));
    expect(
      document.mermaid,
      contains('Line &quot;one&quot; &amp; ready<br/>Line &lt;two&gt;.'),
    );
  });

  test('fails closed when an explicit destination is absent', () {
    final malformed = _schedule(
      id: 4,
      trips: <ScheduleTripDefinition>[_fixedTrip(1, 0, destination: 99)],
    );

    expect(() => renderer.render(malformed), throwsA(isA<StateError>()));
  });
}

final class _CountingFdaSettingsOpeningAuthority
    implements FdaSettingsOpeningAuthority {
  int invocationCount = 0;

  @override
  Future<void> openSettings() async {
    invocationCount += 1;
  }
}

final class _CountingTestAgent implements TestAgent {
  int invocationCount = 0;

  @override
  Future<bool> evaluate() async {
    invocationCount += 1;
    return true;
  }
}

ScheduleDefinition _schedule({
  required int id,
  required List<ScheduleTripDefinition> trips,
}) {
  return ScheduleDefinition(id: id, name: 'Schedule $id', trips: trips);
}

ScheduleTripDefinition _tellTrip(int tripId, int position) {
  return ScheduleTripDefinition(
    occurrenceId: (tripId * 100) + position,
    position: position,
    trip: TripDefinition(
      id: TripDefinitionId(tripId),
      name: 'Trip $tripId',
      steps: <Step>[
        TellStep(
          id: (tripId * 1000) + 1,
          name: 'tell_$tripId',
          text: 'Tell $tripId',
        ),
      ],
    ),
  );
}

ScheduleTripDefinition _fixedTrip(
  int tripId,
  int position, {
  required int destination,
}) {
  return ScheduleTripDefinition(
    occurrenceId: (tripId * 100) + position,
    position: position,
    trip: TripDefinition(
      id: TripDefinitionId(tripId),
      name: 'Trip $tripId',
      steps: <Step>[
        FixedDestinationStep(
          id: (tripId * 1000) + 1,
          name: 'fixed_$tripId',
          destinationTripDefinitionId: TripDefinitionId(destination),
        ),
      ],
    ),
  );
}
