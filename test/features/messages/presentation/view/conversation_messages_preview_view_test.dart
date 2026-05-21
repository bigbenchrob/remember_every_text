import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import 'package:remember_this_text/features/messages/presentation/view/conversation_messages_preview_view.dart';

void main() {
  testWidgets('renders graph conversation timeline details', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [
              ConversationOverview(
                conversationId: 42,
                participantHandles: ['+15551', '+15552'],
                participantCount: 2,
                isGroup: true,
                messageCount: 3,
                lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
                lastMessageText: 'newest',
              ),
            ];
          }),
          conversationMessagesProvider(
            conversationId: 42,
            limit: 100,
          ).overrideWith((ref) async {
            return const [
              ConversationMessage(
                messageId: 3,
                dateUtc: '2026-05-20T10:00:00.000Z',
                isFromMe: true,
                text: 'newest',
                associatedMessageId: 1,
              ),
              ConversationMessage(
                messageId: 2,
                dateUtc: '2026-05-19T10:00:00.000Z',
                isFromMe: false,
                text: null,
                associatedMessageId: null,
              ),
              ConversationMessage(
                messageId: 1,
                dateUtc: '2026-05-18T10:00:00.000Z',
                isFromMe: false,
                text: 'oldest',
                associatedMessageId: null,
              ),
            ];
          }),
        ],
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: ConversationMessagesPreviewView(conversationId: 42),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Conversation graph timeline'), findsOneWidget);
    expect(find.text('conversationId: 42'), findsOneWidget);
    expect(find.text('participants: +15551 | +15552'), findsOneWidget);
    expect(find.text('participant count: 2 | group'), findsOneWidget);
    expect(find.text('conversation message count: 3'), findsOneWidget);
    expect(find.text('loaded messages: 3'), findsOneWidget);
    expect(find.text('visible messages: 3'), findsOneWidget);
    expect(find.text('text-bearing: 2 | no text: 1'), findsOneWidget);
    expect(
      find.text('from me: 1 | received: 2 | associated: 1'),
      findsOneWidget,
    );
    expect(find.text('filter: All'), findsOneWidget);
    expect(find.text('order: oldest to newest'), findsOneWidget);
    expect(find.text('2026-05-18'), findsOneWidget);
    expect(find.text('2026-05-19'), findsOneWidget);
    expect(find.text('2026-05-20'), findsOneWidget);
    expect(find.text('associatedMessageId: 1'), findsOneWidget);
    expect(find.text('no text'), findsOneWidget);

    final oldestTopLeft = tester.getTopLeft(find.text('oldest'));
    final newestTopLeft = tester.getTopLeft(find.text('newest'));
    expect(oldestTopLeft.dy, lessThan(newestTopLeft.dy));
  });

  testWidgets('can switch timeline order', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [];
          }),
          conversationMessagesProvider(
            conversationId: 42,
            limit: 100,
          ).overrideWith((ref) async {
            return const [
              ConversationMessage(
                messageId: 3,
                dateUtc: '2026-05-20T10:00:00.000Z',
                isFromMe: true,
                text: 'newest',
                associatedMessageId: null,
              ),
              ConversationMessage(
                messageId: 1,
                dateUtc: '2026-05-18T10:00:00.000Z',
                isFromMe: false,
                text: 'oldest',
                associatedMessageId: null,
              ),
            ];
          }),
        ],
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: ConversationMessagesPreviewView(conversationId: 42),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Newest first'));
    await tester.pump();

    expect(find.text('order: newest to oldest'), findsOneWidget);
    final newestTopLeft = tester.getTopLeft(find.text('newest'));
    final oldestTopLeft = tester.getTopLeft(find.text('oldest'));
    expect(newestTopLeft.dy, lessThan(oldestTopLeft.dy));
  });

  testWidgets('can increase message limit', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [];
          }),
          conversationMessagesProvider(
            conversationId: 42,
            limit: 100,
          ).overrideWith((ref) async {
            return const [
              ConversationMessage(
                messageId: 1,
                dateUtc: '2026-05-18T10:00:00.000Z',
                isFromMe: false,
                text: 'limit 100 message',
                associatedMessageId: null,
              ),
            ];
          }),
          conversationMessagesProvider(
            conversationId: 42,
            limit: 500,
          ).overrideWith((ref) async {
            return const [
              ConversationMessage(
                messageId: 2,
                dateUtc: '2026-05-19T10:00:00.000Z',
                isFromMe: true,
                text: 'limit 500 message',
                associatedMessageId: null,
              ),
            ];
          }),
        ],
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: ConversationMessagesPreviewView(conversationId: 42),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('limit 100 message'), findsOneWidget);

    await tester.tap(find.text('Latest 500'));
    await tester.pump();
    await tester.pump();

    expect(find.text('limit 500 message'), findsOneWidget);
    expect(find.text('limit 100 message'), findsNothing);
    expect(find.text('loaded messages: 1'), findsOneWidget);
  });

  testWidgets('can filter visible messages', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [];
          }),
          conversationMessagesProvider(
            conversationId: 42,
            limit: 100,
          ).overrideWith((ref) async {
            return const [
              ConversationMessage(
                messageId: 1,
                dateUtc: '2026-05-18T10:00:00.000Z',
                isFromMe: false,
                text: null,
                associatedMessageId: null,
              ),
              ConversationMessage(
                messageId: 2,
                dateUtc: '2026-05-19T10:00:00.000Z',
                isFromMe: true,
                text: 'text message',
                associatedMessageId: null,
              ),
            ];
          }),
        ],
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: ConversationMessagesPreviewView(conversationId: 42),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('visible messages: 2'), findsOneWidget);

    await tester.tap(find.text('No text'));
    await tester.pump();

    expect(find.text('filter: No text'), findsOneWidget);
    expect(find.text('visible messages: 1'), findsOneWidget);
    expect(find.text('no text'), findsOneWidget);
    expect(find.text('text message'), findsNothing);
  });
}
