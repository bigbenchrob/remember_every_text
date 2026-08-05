import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/journey.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/journey_progress.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';

void main() {
  test('advances through each Step and then remains Done', () {
    final journey = _threeStepJourney();
    final progress = JourneyProgress(journey);

    expect(progress.journey, same(journey));
    expect(progress.currentStep, same(journey.steps[0]));
    expect(progress.isDone, isFalse);

    progress.next();

    expect(progress.currentStep, same(journey.steps[1]));
    expect(progress.isDone, isFalse);

    progress.next();

    expect(progress.currentStep, same(journey.steps[2]));
    expect(progress.isDone, isFalse);

    progress.next();

    expect(progress.currentStep, isNull);
    expect(progress.isDone, isTrue);

    progress.next();

    expect(progress.currentStep, isNull);
    expect(progress.isDone, isTrue);
  });

  test('an empty Journey starts and remains Done', () {
    const journey = Journey(id: 0, name: 'Empty Journey', steps: <Step>[]);
    final progress = JourneyProgress(journey);

    expect(progress.currentStep, isNull);
    expect(progress.isDone, isTrue);

    progress.next();

    expect(progress.currentStep, isNull);
    expect(progress.isDone, isTrue);
  });

  test('advancing does not mutate the Journey definition', () {
    final journey = _threeStepJourney();
    final originalSteps = journey.steps;

    final progress = JourneyProgress(journey)
      ..next()
      ..next()
      ..next();

    expect(progress.isDone, isTrue);
    expect(journey.steps, same(originalSteps));
    expect(
      journey.steps.map((Step step) => step.id),
      orderedEquals(<int>[1, 2, 3]),
    );
    expect(journey.steps[0], isA<TellStep>());
    expect(journey.steps[1], isA<AskStep>());
    expect(journey.steps[2], isA<TellStep>());
  });
}

Journey _threeStepJourney() {
  return const Journey(
    id: 42,
    name: 'Three-step Tell and Ask Journey',
    steps: <Step>[
      Step.tell(
        id: 1,
        text: 'Hello one',
        advancesAutomatically: true,
        holdDuration: Duration(seconds: 1),
      ),
      Step.ask(id: 2, question: 'What should I call you?'),
      Step.tell(
        id: 3,
        text: 'Hello three',
        advancesAutomatically: false,
        holdDuration: Duration(seconds: 3),
      ),
    ],
  );
}
