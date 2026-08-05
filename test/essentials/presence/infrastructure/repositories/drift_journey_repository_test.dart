import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/journey.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/essentials/presence/domain/repositories/journey_repository.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/data_sources/local/journey_definition_store.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/repositories/drift_journey_repository.dart';
import 'package:remember_this_text/features/presence_iteration_simple/infrastructure/development/journey_42_fixture.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late JourneyDefinitionStore store;
  late JourneyRepository repository;

  setUp(() {
    store = JourneyDefinitionStore(NativeDatabase.memory());
    repository = DriftJourneyRepository(store: store);
  });

  tearDown(() async {
    await store.close();
  });

  test('loads the four onboarding Tells in persisted position order', () async {
    await seedJourney42(store);

    final journey = await repository.loadJourney(42);

    expect(journey, isA<Journey>());
    expect(journey.id, 42);
    expect(journey.name, 'MessageLens onboarding introduction');
    expect(journey.steps, hasLength(4));
    expect(
      journey.steps.map((Step step) => step.id),
      orderedEquals(<int>[1, 2, 3, 4]),
    );
    expect(journey.steps, everyElement(isA<TellStep>()));

    final tells = journey.steps.cast<TellStep>();
    expect(
      tells.map((step) => step.text),
      orderedEquals(<String>[
        'Welcome to MessageLens.',
        <String>[
          'Before you get started, I need to make sure I can access the ',
          'databases on your Mac that store information about your contacts ',
          'and messages.',
        ].join(),
        <String>[
          'Apple requires you to give MessageLens what it calls Full Disk ',
          'Access.\n\nDespite the name, this does not mean MessageLens can ',
          'simply browse through all of your personal files. As Apple explains:',
          '\n\n\u201cFull Disk Access allows applications to access data like ',
          'Mail, Messages, Safari, Home, Time Machine backups, and certain ',
          'administrative settings.\u201d',
        ].join(),
        <String>[
          'I need this access to read your chat database, which stores your ',
          'messages, and your Address Book database, which lets me match ',
          'those messages with the people in your contacts.',
        ].join(),
      ]),
    );
    expect(
      tells.map((step) => step.advancesAutomatically),
      orderedEquals(<bool>[true, true, true, false]),
    );
    expect(
      tells.map((step) => step.holdDuration),
      orderedEquals(<Duration>[
        const Duration(seconds: 2),
        const Duration(seconds: 4),
        const Duration(seconds: 10),
        const Duration(seconds: 6),
      ]),
    );
  });

  test('rejects duplicate positions within one Journey', () async {
    await _insertJourney(store);
    await _insertTellStep(
      store,
      id: 1,
      position: 0,
      text: 'Hello one',
      advancesAutomatically: true,
    );

    await expectLater(
      _insertTellStep(
        store,
        id: 2,
        position: 0,
        text: 'Hello two',
        advancesAutomatically: true,
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('rejects an orphan base Step', () async {
    await expectLater(
      _insertBaseStep(
        store,
        id: 1,
        journeyId: 404,
        position: 0,
        type: tellStepType,
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('rejects orphan Tell and Ask subtype rows', () async {
    await expectLater(
      _insertTellSubtype(store, stepId: 1, text: 'Hello'),
      throwsA(isA<SqliteException>()),
    );
    await expectLater(
      _insertAskSubtype(store, stepId: 2, question: 'Question?'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('rejects a negative Step position', () async {
    await _insertJourney(store);

    await expectLater(
      _insertBaseStep(
        store,
        id: 1,
        journeyId: 42,
        position: -1,
        type: tellStepType,
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('rejects a negative Tell hold duration', () async {
    await _insertJourney(store);
    await _insertBaseStep(
      store,
      id: 1,
      journeyId: 42,
      position: 0,
      type: tellStepType,
    );

    await expectLater(
      _insertTellSubtype(store, stepId: 1, text: 'Hello', holdDurationMs: -1),
      throwsA(isA<SqliteException>()),
    );
  });

  test('rejects an unknown discriminator', () async {
    await _insertJourney(store);

    await expectLater(
      _insertBaseStep(
        store,
        id: 1,
        journeyId: 42,
        position: 0,
        type: 'unknown',
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('rejects a Tell base row missing its expected subtype', () async {
    await _insertJourney(store);
    await _insertBaseStep(
      store,
      id: 1,
      journeyId: 42,
      position: 0,
      type: tellStepType,
    );

    await expectLater(repository.loadJourney(42), throwsA(isA<StateError>()));
  });

  test('rejects an Ask base row missing its expected subtype', () async {
    await _insertJourney(store);
    await _insertBaseStep(
      store,
      id: 1,
      journeyId: 42,
      position: 0,
      type: askStepType,
    );

    await expectLater(repository.loadJourney(42), throwsA(isA<StateError>()));
  });

  test('rejects a Tell discriminator with Ask subtype data', () async {
    await _insertJourney(store);
    await _insertBaseStep(
      store,
      id: 1,
      journeyId: 42,
      position: 0,
      type: tellStepType,
    );
    await _insertAskSubtype(store, stepId: 1, question: 'Wrong subtype?');

    await expectLater(repository.loadJourney(42), throwsA(isA<StateError>()));
  });

  test('rejects an Ask discriminator with Tell subtype data', () async {
    await _insertJourney(store);
    await _insertBaseStep(
      store,
      id: 1,
      journeyId: 42,
      position: 0,
      type: askStepType,
    );
    await _insertTellSubtype(store, stepId: 1, text: 'Wrong subtype');

    await expectLater(repository.loadJourney(42), throwsA(isA<StateError>()));
  });

  test('rejects a base row with both subtype rows', () async {
    await _insertJourney(store);
    await _insertBaseStep(
      store,
      id: 1,
      journeyId: 42,
      position: 0,
      type: tellStepType,
    );
    await _insertTellSubtype(store, stepId: 1, text: 'Hello');
    await _insertAskSubtype(store, stepId: 1, question: 'Question?');

    await expectLater(repository.loadJourney(42), throwsA(isA<StateError>()));
  });
}

Future<void> _insertJourney(JourneyDefinitionStore store) async {
  await store
      .into(store.journeys)
      .insert(
        JourneysCompanion.insert(
          id: const Value<int>(42),
          name: 'Test Journey',
        ),
      );
}

Future<void> _insertBaseStep(
  JourneyDefinitionStore store, {
  required int id,
  required int journeyId,
  required int position,
  required String type,
}) async {
  await store
      .into(store.steps)
      .insert(
        StepsCompanion.insert(
          id: Value<int>(id),
          journeyId: journeyId,
          position: position,
          stepType: type,
        ),
      );
}

Future<void> _insertTellSubtype(
  JourneyDefinitionStore store, {
  required int stepId,
  required String text,
  bool advancesAutomatically = true,
  int holdDurationMs = 1000,
}) async {
  await store
      .into(store.tellSteps)
      .insert(
        TellStepsCompanion.insert(
          stepId: Value<int>(stepId),
          stepText: text,
          advancesAutomatically: advancesAutomatically,
          holdDurationMs: holdDurationMs,
        ),
      );
}

Future<void> _insertAskSubtype(
  JourneyDefinitionStore store, {
  required int stepId,
  required String question,
}) async {
  await store
      .into(store.askSteps)
      .insert(
        AskStepsCompanion.insert(
          stepId: Value<int>(stepId),
          question: question,
        ),
      );
}

Future<void> _insertTellStep(
  JourneyDefinitionStore store, {
  required int id,
  required int position,
  required String text,
  required bool advancesAutomatically,
}) async {
  await _insertBaseStep(
    store,
    id: id,
    journeyId: 42,
    position: position,
    type: tellStepType,
  );
  await _insertTellSubtype(
    store,
    stepId: id,
    text: text,
    advancesAutomatically: advancesAutomatically,
  );
}
