import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_option.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_value.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/schedule_definition.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/data_sources/local/presence_database.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/repositories/drift_presence_schedule_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

void main() {
  group('ChoiceStep persistence', () {
    late PresenceDatabase database;
    late DriftPresenceScheduleRepository repository;

    setUp(() async {
      database = PresenceDatabase(NativeDatabase.memory());
      await database.customSelect('SELECT 1').get();
      repository = DriftPresenceScheduleRepository(database: database);
    });

    tearDown(() => database.close());

    test(
      'writes and reconstructs the complete generic Choice grammar',
      () async {
        await repository.insertDefinition(_choiceSchedule());

        final base = await (database.select(
          database.stepDefinitions,
        )..where((table) => table.id.equals(_choiceStepId))).getSingle();
        final marker = await database
            .select(database.choiceStepDefinitions)
            .getSingle();
        final storedOptions =
            await (database.select(database.choiceStepOptions)
                  ..orderBy(<OrderClauseGenerator<ChoiceStepOptions>>[
                    (table) => OrderingTerm.asc(table.position),
                  ]))
                .get();
        final loaded = await repository.loadDefinition(_scheduleId);
        final choice = loaded.trips.first.trip.steps.single as ChoiceStep;

        expect(base.stepType, choiceStepType);
        expect(marker.stepDefinitionId, _choiceStepId);
        expect(
          storedOptions
              .map(
                (option) => (
                  option.value,
                  option.position,
                  option.label,
                  option.destinationTripDefinitionId,
                ),
              )
              .toList(),
          <(String, int, String, int)>[
            ('blue', 0, 'Blue', 12),
            ('pink', 1, 'Pink', 15),
            ('purple', 2, 'Purple', 19),
          ],
        );
        expect(
          choice.destinationFor(ChoiceValue('pink')),
          const TripDefinitionId(15),
        );
      },
    );

    test(
      'reconstructs option order from position rather than row order',
      () async {
        await repository.insertDefinition(_choiceSchedule());
        await database.delete(database.choiceStepOptions).go();

        await _insertStoredOption(
          database,
          value: 'purple',
          position: 2,
          label: 'Purple',
          destination: 19,
        );
        await _insertStoredOption(
          database,
          value: 'blue',
          position: 0,
          label: 'Blue',
          destination: 12,
        );
        await _insertStoredOption(
          database,
          value: 'pink',
          position: 1,
          label: 'Pink',
          destination: 15,
        );

        final loaded = await repository.loadDefinition(_scheduleId);
        final choice = loaded.trips.first.trip.steps.single as ChoiceStep;

        expect(
          choice.options.map((option) => option.value.value),
          orderedEquals(<String>['blue', 'pink', 'purple']),
        );
      },
    );

    test('label revisions preserve durable value and destination', () async {
      await repository.insertDefinition(
        _choiceSchedule(
          options: <ChoiceOption>[
            _option('pause', "That's good for now", 12),
            _option('continue', 'Continue', 15),
          ],
        ),
      );
      await (database.update(
        database.choiceStepOptions,
      )..where((table) => table.value.equals('pause'))).write(
        const ChoiceStepOptionsCompanion(
          label: Value<String>('Finish for now'),
        ),
      );

      final loaded = await repository.loadDefinition(_scheduleId);
      final choice = loaded.trips.first.trip.steps.single as ChoiceStep;
      final pause = choice.options.firstWhere(
        (option) => option.value == ChoiceValue('pause'),
      );

      expect(pause.label, 'Finish for now');
      expect(
        choice.destinationFor(ChoiceValue('pause')),
        const TripDefinitionId(12),
      );
    });

    test('round-trips duplicate labels and shared destinations', () async {
      await repository.insertDefinition(
        _choiceSchedule(
          options: <ChoiceOption>[
            _option('choice_a', 'Continue', 12),
            _option('choice_b', 'Continue', 12),
          ],
        ),
      );

      final loaded = await repository.loadDefinition(_scheduleId);
      final choice = loaded.trips.first.trip.steps.single as ChoiceStep;

      expect(
        choice.options.map((option) => option.label),
        orderedEquals(<String>['Continue', 'Continue']),
      );
      expect(
        choice.options.map((option) => option.destinationTripDefinitionId),
        everyElement(const TripDefinitionId(12)),
      );
    });

    test('database rejects duplicate values within one ChoiceStep', () async {
      await repository.insertDefinition(_choiceSchedule());

      await expectLater(
        _insertStoredOption(
          database,
          value: 'blue',
          position: 3,
          label: 'Another Blue',
          destination: 12,
        ),
        throwsA(isA<sqlite3.SqliteException>()),
      );
    });

    test(
      'database rejects duplicate positions within one ChoiceStep',
      () async {
        await repository.insertDefinition(_choiceSchedule());

        await expectLater(
          _insertStoredOption(
            database,
            value: 'green',
            position: 0,
            label: 'Green',
            destination: 12,
          ),
          throwsA(isA<sqlite3.SqliteException>()),
        );
      },
    );

    test('reconstruction rejects a ChoiceStep with no options', () async {
      await repository.insertDefinition(_choiceSchedule());
      await database.delete(database.choiceStepOptions).go();

      await expectLater(
        repository.loadDefinition(_scheduleId),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('reconstruction rejects a ChoiceStep with one option', () async {
      await repository.insertDefinition(_choiceSchedule());
      await (database.delete(
        database.choiceStepOptions,
      )..where((table) => table.position.isBiggerThanValue(0))).go();

      await expectLater(
        repository.loadDefinition(_scheduleId),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('reconstruction rejects a missing Choice subtype marker', () async {
      await repository.insertDefinition(_choiceSchedule());
      await database.delete(database.choiceStepOptions).go();
      await database.delete(database.choiceStepDefinitions).go();

      await expectLater(
        repository.loadDefinition(_scheduleId),
        throwsA(isA<StateError>()),
      );
    });

    test('reconstruction rejects orphan Choice option rows', () async {
      await repository.insertDefinition(_choiceSchedule());
      await database.customStatement('PRAGMA foreign_keys = OFF');
      await database.delete(database.choiceStepDefinitions).go();
      await database.customStatement('PRAGMA foreign_keys = ON');

      await expectLater(
        repository.loadDefinition(_scheduleId),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('options without a subtype marker'),
          ),
        ),
      );
    });

    test('Schedule reconstruction rejects an outside destination', () async {
      await repository.insertDefinition(_choiceSchedule());
      await database
          .into(database.tripDefinitions)
          .insert(
            TripDefinitionsCompanion.insert(
              id: const Value<int>(999),
              name: 'outside_schedule',
            ),
          );
      await (database.update(
        database.choiceStepOptions,
      )..where((table) => table.value.equals('pink'))).write(
        const ChoiceStepOptionsCompanion(
          destinationTripDefinitionId: Value<int>(999),
        ),
      );

      await expectLater(
        repository.loadDefinition(_scheduleId),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains('absent from Schedule'),
          ),
        ),
      );
    });

    test('reconstruction rejects contradictory active subtype rows', () async {
      await repository.insertDefinition(_choiceSchedule());
      await database
          .into(database.tellStepDefinitions)
          .insert(
            TellStepDefinitionsCompanion.insert(
              stepDefinitionId: const Value<int>(_choiceStepId),
              stepText: 'Contradictory Tell',
            ),
          );

      await expectLater(
        repository.loadDefinition(_scheduleId),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('exactly one active subtype row'),
          ),
        ),
      );
    });

    test('write validation rejects an outside destination', () async {
      final definition = _choiceSchedule(
        options: <ChoiceOption>[
          _option('inside', 'Inside', 12),
          _option('outside', 'Outside', 999),
        ],
      );

      await expectLater(
        repository.insertDefinition(definition),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('write validation requires ChoiceStep to be terminal', () async {
      final definition = _choiceSchedule(choiceIsTerminal: false);

      await expectLater(
        repository.insertDefinition(definition),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

const int _scheduleId = 100;
const int _choiceStepId = 1001;

ScheduleDefinition _choiceSchedule({
  List<ChoiceOption>? options,
  bool choiceIsTerminal = true,
}) {
  final choice = ChoiceStep(
    id: _choiceStepId,
    name: 'choose_color',
    options:
        options ??
        <ChoiceOption>[
          _option('blue', 'Blue', 12),
          _option('pink', 'Pink', 15),
          _option('purple', 'Purple', 19),
        ],
  );
  final choiceTripSteps = choiceIsTerminal
      ? <Step>[choice]
      : <Step>[
          choice,
          const TellStep(id: 1002, name: 'after_choice', text: 'Later'),
        ];

  return ScheduleDefinition(
    id: _scheduleId,
    name: 'choice_schedule',
    trips: <ScheduleTripDefinition>[
      ScheduleTripDefinition(
        occurrenceId: 101,
        position: 0,
        trip: TripDefinition(
          id: const TripDefinitionId(10),
          name: 'choice_trip',
          steps: choiceTripSteps,
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 102,
        position: 1,
        trip: TripDefinition(
          id: const TripDefinitionId(12),
          name: 'blue_trip',
          steps: const <Step>[
            TellStep(id: 1201, name: 'blue_tell', text: 'Blue'),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 103,
        position: 2,
        trip: TripDefinition(
          id: const TripDefinitionId(15),
          name: 'pink_trip',
          steps: const <Step>[
            TellStep(id: 1501, name: 'pink_tell', text: 'Pink'),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 104,
        position: 3,
        trip: TripDefinition(
          id: const TripDefinitionId(19),
          name: 'purple_trip',
          steps: const <Step>[
            TellStep(id: 1901, name: 'purple_tell', text: 'Purple'),
          ],
        ),
      ),
    ],
  );
}

ChoiceOption _option(String value, String label, int destination) {
  return ChoiceOption(
    value: ChoiceValue(value),
    label: label,
    destinationTripDefinitionId: TripDefinitionId(destination),
  );
}

Future<void> _insertStoredOption(
  PresenceDatabase database, {
  required String value,
  required int position,
  required String label,
  required int destination,
}) {
  return database
      .into(database.choiceStepOptions)
      .insert(
        ChoiceStepOptionsCompanion.insert(
          stepDefinitionId: _choiceStepId,
          value: value,
          position: position,
          label: label,
          destinationTripDefinitionId: destination,
        ),
      );
}
