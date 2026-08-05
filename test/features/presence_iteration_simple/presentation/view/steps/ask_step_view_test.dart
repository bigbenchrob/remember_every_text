import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/features/presence_iteration_simple/presentation/view/steps/ask_step_view.dart';
import 'package:remember_this_text/features/presence_iteration_simple/presentation/view_model/steps/ask_step_view_model.dart';

void main() {
  testWidgets('rejects blank and whitespace-only answers', (tester) async {
    var submissionCount = 0;

    await tester.pumpWidget(
      MacosApp(
        home: AskStepView(
          viewModel: const AskStepViewModel(
            AskStep(id: 2, question: 'What should I call you?'),
          ),
          onAnswered: (_) {
            submissionCount += 1;
          },
        ),
      ),
    );

    expect(find.text('What should I call you?'), findsOneWidget);
    expect(_continueButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(MacosTextField), '   ');
    await tester.pump();

    expect(_continueButton(tester).onPressed, isNull);
    await tester.tap(find.text('Continue'), warnIfMissed: false);
    expect(submissionCount, 0);
  });

  testWidgets('reports one accepted answer upward exactly once', (
    tester,
  ) async {
    var submissionCount = 0;
    String? receivedAnswer;

    await tester.pumpWidget(
      MacosApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: <Widget>[
                AskStepView(
                  viewModel: const AskStepViewModel(
                    AskStep(id: 2, question: 'What should I call you?'),
                  ),
                  onAnswered: (answer) {
                    submissionCount += 1;
                    setState(() {
                      receivedAnswer = answer;
                    });
                  },
                ),
                if (receivedAnswer != null)
                  Text('Answer received: $receivedAnswer'),
              ],
            );
          },
        ),
      ),
    );

    await tester.enterText(find.byType(MacosTextField), '  Rob  ');
    await tester.pump();

    expect(_continueButton(tester).onPressed, isNotNull);
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(receivedAnswer, 'Rob');
    expect(find.text('Answer received: Rob'), findsOneWidget);
    expect(submissionCount, 1);
    expect(_continueButton(tester).onPressed, isNull);

    await tester.tap(find.text('Continue'), warnIfMissed: false);
    await tester.pump();

    expect(submissionCount, 1);
  });
}

PushButton _continueButton(WidgetTester tester) {
  return tester.widget<PushButton>(find.byType(PushButton));
}
