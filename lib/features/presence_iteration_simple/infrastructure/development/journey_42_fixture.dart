import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../../../../essentials/presence/domain/entities/journey.dart';
import '../../../../essentials/presence/infrastructure/data_sources/local/journey_definition_store.dart';
import '../../../../essentials/presence/infrastructure/repositories/drift_journey_repository.dart';

Future<Journey> loadDevelopmentJourney42() async {
  final store = JourneyDefinitionStore(NativeDatabase.memory());
  try {
    await seedJourney42(store);
    return await DriftJourneyRepository(store: store).loadJourney(42);
  } finally {
    await store.close();
  }
}

Future<void> seedJourney42(JourneyDefinitionStore store) async {
  await store
      .into(store.journeys)
      .insert(
        JourneysCompanion.insert(
          id: const Value<int>(42),
          name: 'MessageLens onboarding introduction',
        ),
      );

  await _insertTellStep(
    store,
    id: 4,
    journeyId: 42,
    position: 3,
    text:
        'I need this access to read your chat database, which stores your '
        'messages, and your Address Book database, which lets me match those '
        'messages with the people in your contacts.',
    advancesAutomatically: false,
    holdDuration: const Duration(seconds: 6),
  );
  await _insertTellStep(
    store,
    id: 1,
    journeyId: 42,
    position: 0,
    text: 'Welcome to MessageLens.',
    advancesAutomatically: true,
    holdDuration: const Duration(seconds: 2),
  );
  await _insertTellStep(
    store,
    id: 2,
    journeyId: 42,
    position: 1,
    text:
        'Before you get started, I need to make sure I can access the '
        'databases on your Mac that store information about your contacts '
        'and messages.',
    advancesAutomatically: true,
    holdDuration: const Duration(seconds: 4),
  );
  await _insertTellStep(
    store,
    id: 3,
    journeyId: 42,
    position: 2,
    text:
        'Apple requires you to give MessageLens what it calls Full Disk '
        'Access.\n\nDespite the name, this does not mean MessageLens can '
        'simply browse through all of your personal files. As Apple explains:'
        '\n\n\u201cFull Disk Access allows applications to access data like '
        'Mail, Messages, Safari, Home, Time Machine backups, and certain '
        'administrative settings.\u201d',
    advancesAutomatically: true,
    holdDuration: const Duration(seconds: 10),
  );
}

Future<void> _insertTellStep(
  JourneyDefinitionStore store, {
  required int id,
  required int journeyId,
  required int position,
  required String text,
  required bool advancesAutomatically,
  required Duration holdDuration,
}) async {
  await store
      .into(store.steps)
      .insert(
        StepsCompanion.insert(
          id: Value<int>(id),
          journeyId: journeyId,
          position: position,
          stepType: tellStepType,
        ),
      );
  await store
      .into(store.tellSteps)
      .insert(
        TellStepsCompanion.insert(
          stepId: Value<int>(id),
          stepText: text,
          advancesAutomatically: advancesAutomatically,
          holdDurationMs: holdDuration.inMilliseconds,
        ),
      );
}
