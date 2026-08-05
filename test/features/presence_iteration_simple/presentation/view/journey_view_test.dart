import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/journey.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/features/presence_iteration_simple/presentation/presence_presentation_tokens.dart';
import 'package:remember_this_text/features/presence_iteration_simple/presentation/view/journey_view.dart';
import 'package:remember_this_text/features/presence_iteration_simple/presentation/view/steps/tell_step_view.dart';

void main() {
  testWidgets('advances three automatic Tells and holds the fourth', (
    tester,
  ) async {
    final answers = <String>[];
    await tester.pumpWidget(
      ProviderScope(
        child: MacosApp(
          home: JourneyView(
            journey: _onboardingJourney(),
            onAnswer: answers.add,
          ),
        ),
      ),
    );

    final readableWidthBox = tester.widget<ConstrainedBox>(
      find.byWidgetPredicate(
        (widget) =>
            widget is ConstrainedBox &&
            widget.constraints.maxWidth ==
                PresencePresentationTokens.maximumReadableWidth,
      ),
    );
    expect(
      readableWidthBox.constraints.maxWidth,
      PresencePresentationTokens.maximumReadableWidth,
    );

    expect(find.text(_messages[0]), findsOneWidget);
    expect(find.byType(TellStepView), findsOneWidget);
    expect(find.text('Next'), findsNothing);
    expect(find.text('Continue'), findsNothing);
    expect(find.text('Done'), findsNothing);
    expect(answers, isEmpty);

    await _completeAutomaticTell(tester, _holdDurations[0]);
    expect(find.text(_messages[0]), findsNothing);
    expect(find.text(_messages[1]), findsOneWidget);

    await _completeAutomaticTell(tester, _holdDurations[1]);
    expect(find.text(_messages[1]), findsNothing);
    for (final paragraph in _messages[2].split('\n\n')) {
      expect(find.text(paragraph), findsOneWidget);
    }

    await _completeAutomaticTell(tester, _holdDurations[2]);
    for (final paragraph in _messages[2].split('\n\n')) {
      expect(find.text(paragraph), findsNothing);
    }
    expect(find.text(_messages[3]), findsOneWidget);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1001));
    await tester.pump();
    await tester.pump(const Duration(minutes: 1));

    expect(find.text(_messages[3]), findsOneWidget);
    expect(_opacity(tester), 1);
    expect(find.text('Done'), findsNothing);
    expect(find.text('Next'), findsNothing);
    expect(find.text('Continue'), findsNothing);
    expect(answers, isEmpty);
  });
}

final _messages = <String>[
  'Welcome to MessageLens.',
  <String>[
    'Before you get started, I need to make sure I can access the databases on ',
    'your Mac that store information about your contacts and messages.',
  ].join(),
  <String>[
    'Apple requires you to give MessageLens what it calls Full Disk Access.\n\n',
    'Despite the name, this does not mean MessageLens can simply browse ',
    'through all of your personal files. As Apple explains:\n\n',
    '\u201cFull Disk Access allows applications to access data like Mail, ',
    'Messages, Safari, Home, Time Machine backups, and certain administrative ',
    'settings.\u201d',
  ].join(),
  <String>[
    'I need this access to read your chat database, which stores your messages, ',
    'and your Address Book database, which lets me match those messages with ',
    'the people in your contacts.',
  ].join(),
];

const _holdDurations = <Duration>[
  Duration(seconds: 2),
  Duration(seconds: 4),
  Duration(seconds: 10),
  Duration(seconds: 6),
];

Journey _onboardingJourney() {
  return Journey(
    id: 42,
    name: 'MessageLens onboarding introduction',
    steps: <Step>[
      for (var index = 0; index < _messages.length; index += 1)
        Step.tell(
          id: index + 1,
          text: _messages[index],
          advancesAutomatically: index < _messages.length - 1,
          holdDuration: _holdDurations[index],
        ),
    ],
  );
}

Future<void> _completeAutomaticTell(
  WidgetTester tester,
  Duration holdDuration,
) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1001));
  await tester.pump();
  await tester.pump(holdDuration);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1001));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

double _opacity(WidgetTester tester) {
  return tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;
}
