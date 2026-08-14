import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/presence/application/presence_step_presentation.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_value.dart';
import 'package:remember_this_text/essentials/presence/presentation/presence_step_presenter.dart';

void main() {
  Future<void> pumpPresentation(
    WidgetTester tester,
    PresenceStepPresentation presentation, {
    WidgetBuilder? specialistBuilder,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MacosApp(
          home: Center(
            child: PresenceStepPresenter(
              presentation: presentation,
              specialistBuilder:
                  specialistBuilder ?? (_) => const Text('Specialist'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders Choice labels in persisted order', (tester) async {
    await pumpPresentation(
      tester,
      _choice(<(String, String)>[
        ('Blue', 'blue'),
        ('Pink', 'pink'),
        ('Purple', 'purple'),
      ]),
    );

    expect(
      tester
          .widgetList<Text>(find.byType(Text))
          .map((widget) => widget.data)
          .whereType<String>(),
      containsAllInOrder(<String>['Blue', 'Pink', 'Purple']),
    );
  });

  testWidgets('returns the opaque value rather than the visible label', (
    tester,
  ) async {
    ChoiceValue? selected;
    await pumpPresentation(
      tester,
      _choice(
        <(String, String)>[('Blue', 'blue'), ('Pink', 'pink')],
        select: (value) async {
          selected = value;
        },
      ),
    );

    await tester.tap(find.text('Pink'));
    await tester.pump();

    expect(selected, ChoiceValue('pink'));
  });

  testWidgets('label copy can change without changing the execution value', (
    tester,
  ) async {
    await pumpPresentation(
      tester,
      _choice(<(String, String)>[
        ("That's good for now", 'pause'),
        ('Continue', 'continue'),
      ]),
    );
    expect(find.text("That's good for now"), findsOneWidget);

    await pumpPresentation(
      tester,
      _choice(<(String, String)>[
        ('Finish for now', 'pause'),
        ('Continue', 'continue'),
      ]),
    );

    expect(find.text("That's good for now"), findsNothing);
    expect(find.text('Finish for now'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('presence-choice-pause')),
      findsOneWidget,
    );
  });

  testWidgets('renders two and four choices through the same widget', (
    tester,
  ) async {
    await pumpPresentation(
      tester,
      _choice(<(String, String)>[('One', 'one'), ('Two', 'two')]),
    );
    expect(find.byType(PushButton), findsNWidgets(2));

    await pumpPresentation(
      tester,
      _choice(<(String, String)>[
        ('One', 'one'),
        ('Two', 'two'),
        ('Three', 'three'),
        ('Four', 'four'),
      ]),
    );
    expect(find.byType(PushButton), findsNWidgets(4));
  });

  testWidgets('duplicate labels retain distinct opaque values', (tester) async {
    final selections = <ChoiceValue>[];
    await pumpPresentation(
      tester,
      _choice(
        <(String, String)>[('Continue', 'first'), ('Continue', 'second')],
        select: (value) async {
          selections.add(value);
        },
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('presence-choice-second')),
    );
    await tester.pump();

    expect(selections, <ChoiceValue>[ChoiceValue('second')]);
  });

  testWidgets('disables every option while one submission is in flight', (
    tester,
  ) async {
    final pending = Completer<void>();
    var submissions = 0;
    await pumpPresentation(
      tester,
      _choice(
        <(String, String)>[('Blue', 'blue'), ('Pink', 'pink')],
        select: (_) {
          submissions += 1;
          return pending.future;
        },
      ),
    );

    await tester.tap(find.text('Pink'));
    await tester.pump();

    final buttons = tester.widgetList<PushButton>(find.byType(PushButton));
    expect(buttons.every((button) => button.onPressed == null), isTrue);
    await tester.tap(find.text('Pink'), warnIfMissed: false);
    expect(submissions, 1);

    pending.complete();
    await tester.pump();
  });

  testWidgets('surfaces stale failure without performing another action', (
    tester,
  ) async {
    var submissions = 0;
    await pumpPresentation(
      tester,
      _choice(
        <(String, String)>[('Blue', 'blue'), ('Pink', 'pink')],
        select: (_) async {
          submissions += 1;
          throw StateError('This Choice interaction is no longer current.');
        },
      ),
    );

    await tester.tap(find.text('Pink'));
    await tester.pump();

    expect(submissions, 1);
    expect(find.textContaining('no longer current'), findsOneWidget);
  });

  testWidgets('dispatches Tell, Test, Fixed, and specialist presentations', (
    tester,
  ) async {
    for (final presentation in <PresenceStepPresentation>[
      TellStepPresentation(text: 'Tell copy', complete: () async {}),
      TestStepPresentation(label: 'Opaque test', complete: () async {}),
      FixedDestinationStepPresentation(
        label: 'Configured progression',
        complete: () async {},
      ),
    ]) {
      await pumpPresentation(tester, presentation);
      expect(find.byType(PushButton), findsOneWidget);
    }

    await pumpPresentation(
      tester,
      const SpecialistStepPresentation(),
      specialistBuilder: (_) => const Text('FDA specialist boundary'),
    );
    expect(find.text('FDA specialist boundary'), findsOneWidget);
  });
}

ChoiceStepPresentation _choice(
  List<(String, String)> definitions, {
  Future<void> Function(ChoiceValue value)? select,
}) {
  return ChoiceStepPresentation(
    items: definitions
        .map(
          (definition) => ChoicePresentationItem(
            label: definition.$1,
            value: ChoiceValue(definition.$2),
          ),
        )
        .toList(growable: false),
    select: select ?? (_) async {},
  );
}
