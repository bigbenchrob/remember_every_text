import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';

void main() {
  test('equal Tell Steps compare equal', () {
    const first = Step.tell(
      id: 1,
      text: 'Hello',
      advancesAutomatically: true,
      holdDuration: Duration(seconds: 2),
    );
    const second = Step.tell(
      id: 1,
      text: 'Hello',
      advancesAutomatically: true,
      holdDuration: Duration(seconds: 2),
    );

    expect(first, second);
    expect(first.hashCode, second.hashCode);
  });

  test('Tell Steps with different fields compare unequal', () {
    const original = Step.tell(
      id: 1,
      text: 'Hello',
      advancesAutomatically: true,
      holdDuration: Duration(seconds: 2),
    );

    expect(
      original,
      isNot(
        const Step.tell(
          id: 2,
          text: 'Hello',
          advancesAutomatically: true,
          holdDuration: Duration(seconds: 2),
        ),
      ),
    );
    expect(
      original,
      isNot(
        const Step.tell(
          id: 1,
          text: 'Goodbye',
          advancesAutomatically: true,
          holdDuration: Duration(seconds: 2),
        ),
      ),
    );
    expect(
      original,
      isNot(
        const Step.tell(
          id: 1,
          text: 'Hello',
          advancesAutomatically: false,
          holdDuration: Duration(seconds: 2),
        ),
      ),
    );
    expect(
      original,
      isNot(
        const Step.tell(
          id: 1,
          text: 'Hello',
          advancesAutomatically: true,
          holdDuration: Duration(seconds: 3),
        ),
      ),
    );
  });

  test('equal Ask Steps compare equal', () {
    const first = Step.ask(id: 2, question: 'What should I call you?');
    const second = Step.ask(id: 2, question: 'What should I call you?');

    expect(first, second);
    expect(first.hashCode, second.hashCode);
  });

  test('Ask Steps with different fields compare unequal', () {
    const original = Step.ask(id: 2, question: 'What should I call you?');

    expect(
      original,
      isNot(const Step.ask(id: 3, question: 'What should I call you?')),
    );
    expect(original, isNot(const Step.ask(id: 2, question: 'Ready?')));
  });

  test('TellStep and AskStep remain distinct runtime variants', () {
    const tell = Step.tell(
      id: 1,
      text: 'Hello',
      advancesAutomatically: true,
      holdDuration: Duration(seconds: 2),
    );
    const ask = Step.ask(id: 2, question: 'Ready?');

    expect(tell, isA<TellStep>());
    expect(tell, isNot(isA<AskStep>()));
    expect(ask, isA<AskStep>());
    expect(ask, isNot(isA<TellStep>()));
  });
}
