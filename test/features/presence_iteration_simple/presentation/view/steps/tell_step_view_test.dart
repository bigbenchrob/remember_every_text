import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/features/presence_iteration_simple/presentation/presence_presentation_tokens.dart';
import 'package:remember_this_text/features/presence_iteration_simple/presentation/view/steps/tell_step_view.dart';
import 'package:remember_this_text/features/presence_iteration_simple/presentation/view_model/steps/tell_step_view_model.dart';

void main() {
  testWidgets('automatic Tell supplies hold duration to one lifecycle', (
    tester,
  ) async {
    var completionCount = 0;
    const viewModel = TellStepViewModel(
      TellStep(
        id: 1,
        text: 'A Tell owned by one Step',
        advancesAutomatically: true,
        holdDuration: Duration(seconds: 2),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MacosApp(
          home: TellStepView(
            viewModel: viewModel,
            onFinished: () {
              completionCount += 1;
            },
          ),
        ),
      ),
    );

    expect(find.text('A Tell owned by one Step'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
    expect(find.text('Continue'), findsNothing);
    expect(_opacity(tester), 0);

    await tester.pump();
    expect(_opacity(tester), 1);

    await tester.pump(const Duration(milliseconds: 1001));
    await tester.pump();
    expect(completionCount, 0);

    await tester.pump(const Duration(milliseconds: 1999));
    expect(_opacity(tester), 1);
    expect(completionCount, 0);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(_opacity(tester), 0);
    expect(completionCount, 0);

    await tester.pump(const Duration(milliseconds: 1001));
    await tester.pump();
    expect(completionCount, 0);

    await tester.pump(const Duration(milliseconds: 499));
    expect(completionCount, 0);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(completionCount, 1);

    await tester.pump(const Duration(seconds: 20));
    expect(completionCount, 1);
  });

  testWidgets('held Tell fades in and remains current without completion', (
    tester,
  ) async {
    var completionCount = 0;
    const viewModel = TellStepViewModel(
      TellStep(
        id: 4,
        text: 'The current edge of the story',
        advancesAutomatically: false,
        holdDuration: Duration(milliseconds: 1),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MacosApp(
          home: TellStepView(
            viewModel: viewModel,
            onFinished: () {
              completionCount += 1;
            },
          ),
        ),
      ),
    );

    expect(_opacity(tester), 0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1001));
    await tester.pump();

    expect(_opacity(tester), 1);
    expect(find.text('The current edge of the story'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
    expect(find.text('Continue'), findsNothing);

    await tester.pump(const Duration(minutes: 1));

    expect(_opacity(tester), 1);
    expect(completionCount, 0);
  });

  testWidgets('rebuilds do not create a second automatic completion', (
    tester,
  ) async {
    var completionCount = 0;
    var rebuild = 0;

    await tester.pumpWidget(
      ProviderScope(
        child: MacosApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: <Widget>[
                  Text('Rebuild $rebuild'),
                  TellStepView(
                    viewModel: const TellStepViewModel(
                      TellStep(
                        id: 1,
                        text: 'One lifecycle',
                        advancesAutomatically: true,
                        holdDuration: Duration(seconds: 2),
                      ),
                    ),
                    onFinished: () {
                      completionCount += 1;
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        rebuild += 1;
                      });
                    },
                    child: const Text('Rebuild'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1001));
    await tester.pump();
    await tester.tap(find.text('Rebuild'));
    await tester.pump();
    await tester.tap(find.text('Rebuild'));
    await tester.pump();

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1001));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.pump(const Duration(seconds: 20));

    expect(completionCount, 1);
  });

  testWidgets('uses provisional paragraph hierarchy for onboarding copy', (
    tester,
  ) async {
    const primary = 'Apple requires Full Disk Access.';
    const supporting = 'This explanation supplies supporting context.';
    const quotation = '\u201cApple supporting evidence.\u201d';

    await tester.pumpWidget(
      const ProviderScope(
        child: MacosApp(
          home: TellStepView(
            viewModel: TellStepViewModel(
              TellStep(
                id: 3,
                text: '$primary\n\n$supporting\n\n$quotation',
                advancesAutomatically: false,
                holdDuration: Duration(seconds: 10),
              ),
            ),
            onFinished: _doNothing,
          ),
        ),
      ),
    );

    final primaryText = tester.widget<Text>(find.text(primary));
    final supportingText = tester.widget<Text>(find.text(supporting));
    final quotationText = tester.widget<Text>(find.text(quotation));

    expect(primaryText.style?.fontSize, 28);
    expect(primaryText.style?.fontWeight, FontWeight.w400);
    expect(primaryText.textAlign, TextAlign.center);
    expect(supportingText.style?.fontSize, 17);
    expect(supportingText.style?.fontStyle, isNot(FontStyle.italic));
    expect(supportingText.textAlign, TextAlign.center);
    expect(quotationText.style?.fontSize, 17);
    expect(quotationText.style?.fontStyle, FontStyle.italic);
    expect(quotationText.textAlign, TextAlign.start);

    final quotationPadding = tester.widget<Padding>(
      find.ancestor(of: find.text(quotation), matching: find.byType(Padding)),
    );
    expect(
      quotationPadding.padding,
      const EdgeInsets.symmetric(
        horizontal: PresencePresentationTokens.quotationInset,
      ),
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox &&
            widget.height == PresencePresentationTokens.paragraphSpacing,
      ),
      findsNWidgets(2),
    );
  });
}

void _doNothing() {}

double _opacity(WidgetTester tester) {
  return tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;
}
