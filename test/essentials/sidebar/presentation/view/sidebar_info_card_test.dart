import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/presentation/view/sidebar_info_card.dart';

void main() {
  group('SidebarInfoCard', () {
    testWidgets('renders body text with start alignment', (tester) async {
      const bodyText =
          'MessageLens compares the messages stored on this Mac with imported messages.';

      await tester.pumpWidget(
        const ProviderScope(
          child: CupertinoApp(
            home: SidebarInfoCard(
              title: 'Message History Coverage',
              bodyText: bodyText,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(bodyText));

      expect(textWidget.textAlign, TextAlign.start);
    });

    testWidgets('renders bullet items with hanging-indent layout', (
      tester,
    ) async {
      const bulletText =
          'The coverage report shows how those messages are accounted for:\n\n'
          '• Messages visible in your chat timelines\n'
          '• Messages recovered but not linked to a conversation\n'
          '• Any messages that could not be accounted for';

      await tester.pumpWidget(
        const ProviderScope(
          child: CupertinoApp(
            home: SizedBox(
              width: 200,
              child: SidebarInfoCard(
                title: 'Message History Coverage',
                bodyText: bulletText,
              ),
            ),
          ),
        ),
      );

      expect(find.text('•'), findsNWidgets(3));

      final wrappedBulletText = find.text(
        'Messages recovered but not linked to a conversation',
      );
      expect(wrappedBulletText, findsOneWidget);

      final bulletRow = find.ancestor(
        of: wrappedBulletText,
        matching: find.byType(Row),
      );
      expect(bulletRow, findsOneWidget);

      final expanded = find.descendant(
        of: bulletRow,
        matching: find.byType(Expanded),
      );
      expect(expanded, findsOneWidget);
    });
  });
}
