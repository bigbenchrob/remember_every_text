import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/message_evidence_spine_provider.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_row_data.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_scope.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_skeleton.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_evidence/message_evidence_header.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_evidence/message_evidence_timeline_view.dart';

void main() {
  testWidgets('renders hydrated rows from the shared skeleton', (tester) async {
    const scope = ContactAllMessagesEvidenceScope(contactId: 24);
    final visibleMonthWrites = <String?>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messageEvidenceRowProvider(scope: scope, messageId: 1).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceRowData(
              messageId: 1,
              dateUtc: '2026-05-20T10:00:00.000Z',
              isFromMe: false,
              text: 'shared evidence row',
              associatedMessageId: null,
              attachmentCount: 0,
            );
          }),
        ],
        child: CupertinoApp(
          home: MessageEvidenceTimelineView(
            evidenceScope: scope,
            skeleton: const MessageEvidenceTimelineSkeleton(
              entries: [
                MessageEvidenceSkeletonEntry(
                  messageId: 1,
                  dateUtc: '2026-05-20T10:00:00.000Z',
                  monthKey: '2026-05',
                ),
              ],
            ),
            headerData: const MessageEvidenceHeaderModel(
              title: 'All messages from Claire',
              countLabel: '1 message',
            ),
            emptyMessage: 'No messages',
            onVisibleMonthChanged: visibleMonthWrites.add,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('All messages from Claire'), findsOneWidget);
    expect(find.text('shared evidence row'), findsOneWidget);
    expect(visibleMonthWrites, contains('2026-05'));
  });

  testWidgets('renders empty state without hydrating rows', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(
          home: MessageEvidenceTimelineView(
            evidenceScope: ContactAllMessagesEvidenceScope(contactId: 24),
            skeleton: MessageEvidenceTimelineSkeleton(entries: []),
            headerData: MessageEvidenceHeaderModel(title: 'Empty scope'),
            emptyMessage: 'No graph evidence',
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Empty scope'), findsOneWidget);
    expect(find.text('No graph evidence'), findsOneWidget);
  });

  testWidgets('anchors and highlights a matching message', (tester) async {
    const scope = ConversationEvidenceScope(conversationId: 42);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messageEvidenceRowProvider(scope: scope, messageId: 1).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceRowData(
              messageId: 1,
              dateUtc: '2026-05-18T10:00:00.000Z',
              isFromMe: false,
              text: 'ordinary row',
              associatedMessageId: null,
              attachmentCount: 0,
            );
          }),
          messageEvidenceRowProvider(scope: scope, messageId: 2).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceRowData(
              messageId: 2,
              dateUtc: '2026-05-20T10:00:00.000Z',
              isFromMe: true,
              text: 'settlement row',
              associatedMessageId: null,
              attachmentCount: 0,
            );
          }),
        ],
        child: const CupertinoApp(
          home: MessageEvidenceTimelineView(
            evidenceScope: scope,
            skeleton: MessageEvidenceTimelineSkeleton(
              entries: [
                MessageEvidenceSkeletonEntry(
                  messageId: 1,
                  dateUtc: '2026-05-18T10:00:00.000Z',
                  monthKey: '2026-05',
                ),
                MessageEvidenceSkeletonEntry(
                  messageId: 2,
                  dateUtc: '2026-05-20T10:00:00.000Z',
                  monthKey: '2026-05',
                ),
              ],
            ),
            headerData: MessageEvidenceHeaderModel(title: 'Conversation'),
            emptyMessage: 'No messages',
            anchorMessageId: 2,
            highlightQuery: 'settlement',
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('settlement row'), findsOneWidget);
    expect(find.text('ordinary row'), findsNothing);
  });
}
