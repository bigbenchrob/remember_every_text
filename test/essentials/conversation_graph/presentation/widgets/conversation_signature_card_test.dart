import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_signatures/conversation_signature.dart';
import 'package:remember_this_text/essentials/conversation_graph/presentation/widgets/conversation_signature_card.dart';

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
    expect(find.text('12 messages • 2026-05-01 - 2026-05-20'), findsOneWidget);
    expect(find.text('action'), findsOneWidget);

    await tester.tap(find.byType(ConversationSignatureCard));
    expect(tapCount, 1);
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
  participantSuffixStyle: TextStyle(color: Color(0xFF777777), fontSize: 10),
  summaryStyle: TextStyle(color: Color(0xFF555555), fontSize: 11),
  emptyMonthBorderColor: Color(0xFF999999),
);
