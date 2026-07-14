import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_signatures/conversation_signature.dart';
import 'package:remember_this_text/features/conversations/presentation/widgets/conversation_signature_card.dart';

void main() {
  testWidgets('renders supplied data and slot without provider dependencies', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 260,
          child: ConversationSignatureCard(
            signature: const ConversationSignatureCardData(
              conversationId: 42,
              title: 'Claire and Cathie',
              titleContextLabel: 'Jun 2, 8:23 AM',
              summaryHighlight:
                  ConversationSignatureSummaryHighlight.messageCount,
              highlightedMonth: ConversationSignatureMonthMarker(
                year: 2026,
                month: 5,
              ),
              participantCount: 2,
              messageCount: 12,
              firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
              activityMonths: [
                ConversationSignatureMonth(
                  year: 2026,
                  month: 5,
                  messageCount: 12,
                ),
              ],
            ),
            style: _testStyle,
            monthColorForMessageCount: (_) => const Color(0xFF00AA00),
            trailing: const Text('action'),
            onPressed: () {
              tapCount++;
            },
          ),
        ),
      ),
    );

    expect(find.textContaining('Claire and Cathie'), findsOneWidget);
    expect(find.textContaining('+2'), findsOneWidget);
    expect(find.text('Jun 2, 8:23 AM'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('conversation-signature-highlighted-month-2026-5'),
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        '12 messages • 2026-05-01 - 2026-05-20',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.text('action'), findsOneWidget);

    await tester.tap(find.byType(ConversationSignatureCard));
    expect(tapCount, 1);
  });

  testWidgets('uses singular message label for one message', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 260,
          child: ConversationSignatureCard(
            signature: const ConversationSignatureCardData(
              conversationId: 42,
              title: 'Claire',
              participantCount: 1,
              messageCount: 1,
              firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-01T10:00:00.000Z',
              activityMonths: [],
            ),
            style: _testStyle,
            monthColorForMessageCount: (_) => const Color(0xFF00AA00),
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(
      find.textContaining('1 message • 2026-05-01', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('1 messages', findRichText: true), findsNothing);
  });

  testWidgets('renders supplied tag labels without provider dependencies', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 260,
          child: ConversationSignatureCard(
            signature: const ConversationSignatureCardData(
              conversationId: 42,
              title: 'Claire',
              participantCount: 1,
              messageCount: 10,
              firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-02T10:00:00.000Z',
              activityMonths: [],
              tagLabels: ['Family', 'Travel'],
            ),
            style: _testStyle,
            monthColorForMessageCount: (_) => const Color(0xFF00AA00),
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Family'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);
  });

  testWidgets('renders supplied chat hook as secondary identity line', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 260,
          child: ConversationSignatureCard(
            signature: const ConversationSignatureCardData(
              conversationId: 42,
              title: 'Claire',
              chatHookLabel: 'claire@student.ubco.ca',
              participantCount: 1,
              messageCount: 10,
              firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-02T10:00:00.000Z',
              activityMonths: [],
            ),
            style: _testStyle,
            monthColorForMessageCount: (_) => const Color(0xFF00AA00),
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Claire'), findsOneWidget);
    expect(find.text('claire@student.ubco.ca'), findsOneWidget);
  });
}

const _testStyle = ConversationSignatureCardStyle(
  backgroundColor: Color(0x00000000),
  hoverBackgroundColor: Color(0x11000000),
  selectedBackgroundColor: Color(0x22000000),
  borderColor: Color(0x33000000),
  hoverBorderColor: Color(0x44000000),
  selectedBorderColor: Color(0x55000000),
  titleStyle: TextStyle(color: Color(0xFF111111), fontSize: 13),
  selectedTitleStyle: TextStyle(color: Color(0xFF111111), fontSize: 13),
  titleContextStyle: TextStyle(color: Color(0xFFCC6600), fontSize: 10),
  chatHookStyle: TextStyle(color: Color(0xFF777777), fontSize: 10),
  participantSuffixStyle: TextStyle(color: Color(0xFF777777), fontSize: 10),
  summaryStyle: TextStyle(color: Color(0xFF555555), fontSize: 11),
  summaryHighlightStyle: TextStyle(color: Color(0xFFCC6600), fontSize: 11),
  tagTextStyle: TextStyle(color: Color(0xFF666666), fontSize: 10),
  tagBackgroundColor: Color(0x11000000),
  tagBorderColor: Color(0x22000000),
  emptyMonthBorderColor: Color(0xFF999999),
);
