import 'package:drift/drift.dart';

import '../../domain/entities/journey.dart';
import '../../domain/entities/step.dart';
import '../../domain/repositories/journey_repository.dart';
import '../data_sources/local/journey_definition_store.dart';

class DriftJourneyRepository implements JourneyRepository {
  const DriftJourneyRepository({required JourneyDefinitionStore store})
    : _store = store;

  final JourneyDefinitionStore _store;

  @override
  Future<Journey> loadJourney(int id) async {
    final journeyRow = await (_store.select(
      _store.journeys,
    )..where((table) => table.id.equals(id))).getSingle();

    final stepRows =
        await (_store.select(_store.steps)
              ..where((table) => table.journeyId.equals(id))
              ..orderBy(<OrderClauseGenerator<Steps>>[
                (table) => OrderingTerm.asc(table.position),
              ]))
            .join([
              leftOuterJoin(
                _store.tellSteps,
                _store.tellSteps.stepId.equalsExp(_store.steps.id),
              ),
              leftOuterJoin(
                _store.askSteps,
                _store.askSteps.stepId.equalsExp(_store.steps.id),
              ),
            ])
            .get();

    return Journey(
      id: journeyRow.id,
      name: journeyRow.name,
      steps: <Step>[
        for (final result in stepRows)
          _mapStep(
            result.readTable(_store.steps),
            result.readTableOrNull(_store.tellSteps),
            result.readTableOrNull(_store.askSteps),
          ),
      ],
    );
  }

  Step _mapStep(StepRow step, TellStepRow? tell, AskStepRow? ask) {
    if (tell != null && ask != null) {
      throw StateError('Step ${step.id} has both Tell and Ask subtype data.');
    }

    switch (step.stepType) {
      case tellStepType:
        if (tell == null) {
          throw StateError('Tell Step ${step.id} has no Tell subtype data.');
        }
        if (ask != null) {
          throw StateError('Tell Step ${step.id} has Ask subtype data.');
        }
        return Step.tell(
          id: step.id,
          text: tell.stepText,
          advancesAutomatically: tell.advancesAutomatically,
          holdDuration: Duration(milliseconds: tell.holdDurationMs),
        );
      case askStepType:
        if (ask == null) {
          throw StateError('Ask Step ${step.id} has no Ask subtype data.');
        }
        if (tell != null) {
          throw StateError('Ask Step ${step.id} has Tell subtype data.');
        }
        return Step.ask(id: step.id, question: ask.question);
      default:
        throw StateError('Step ${step.id} has unknown type ${step.stepType}.');
    }
  }
}
