import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/features/presence_iteration_simple/presentation/presence_iteration_simple_host.dart';

void main() {
  testWidgets('loads the onboarding fixture and remains on its fourth Tell', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MacosApp(home: PresenceIterationSimpleHost())),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Welcome to MessageLens.'), findsOneWidget);

    await _completeAutomaticTell(tester, const Duration(seconds: 2));
    await _completeAutomaticTell(tester, const Duration(seconds: 4));
    await _completeAutomaticTell(tester, const Duration(seconds: 10));

    expect(
      find.textContaining('I need this access to read your chat database'),
      findsOneWidget,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1001));
    await tester.pump();
    await tester.pump(const Duration(minutes: 1));

    expect(
      find.textContaining('I need this access to read your chat database'),
      findsOneWidget,
    );
    expect(find.text('Done'), findsNothing);
    expect(find.text('Next'), findsNothing);
    expect(find.text('Continue'), findsNothing);
    expect(find.textContaining('Answer received:'), findsNothing);
    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      1,
    );
  });
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
