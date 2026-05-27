import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_evidence/message_evidence_header.dart';

void main() {
  testWidgets('renders typed message evidence header data and slots', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(
          home: MessageEvidenceHeader(
            data: MessageEvidenceHeaderData(
              title: 'Conversation: Claire and Cathie',
              subtitleParts: ['Jan 2014 to May 2026', '86,563 messages'],
              statusLine: 'Selected conversation',
            ),
            actionStrip: Text('Copy evidence summary'),
            details: Text('Showing 100 loaded messages'),
          ),
        ),
      ),
    );

    expect(find.text('Conversation: Claire and Cathie'), findsOneWidget);
    expect(find.text('Jan 2014 to May 2026'), findsOneWidget);
    expect(find.text('86,563 messages'), findsOneWidget);
    expect(find.text('Selected conversation'), findsOneWidget);
    expect(find.text('Copy evidence summary'), findsOneWidget);
    expect(find.text('Showing 100 loaded messages'), findsOneWidget);
  });
}
