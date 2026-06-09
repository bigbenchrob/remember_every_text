import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_favourites/conversation_favourites_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import 'package:remember_this_text/features/chats/presentation/view/conversation_browser_view.dart';
import 'package:remember_this_text/features/chats/presentation/view_model/recent_chats_provider.dart';

void main() {
  testWidgets('renders graph conversation browser and filters groups', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recentChatsProvider(limit: 500).overrideWith((ref) async {
            return [
              _summary(id: 1, participants: ['+1'], messageCount: 10),
              _summary(
                id: 2,
                participants: ['+1', '+2'],
                messageCount: 20,
                attachmentCount: 4,
              ),
            ];
          }),
          conversationFavouritesControllerProvider.overrideWith(
            _TestConversationFavouritesController.new,
          ),
        ],
        child: _wrapWithTextEditingShell(const ConversationBrowserView()),
      ),
    );

    await tester.pump();

    expect(find.text('Conversations'), findsOneWidget);
    expect(find.text('total conversations: 2'), findsOneWidget);
    expect(find.text('groups: 1 | singles: 1'), findsOneWidget);
    expect(
      find.text('zero participants: 0 | zero messages: 0'),
      findsOneWidget,
    );
    expect(find.text('with attachments: 1'), findsOneWidget);
    expect(find.text('+1'), findsWidgets);
    expect(find.text('+1 | +2', findRichText: true), findsOneWidget);

    await tester.tap(find.text('Groups'));
    await tester.pump();

    expect(find.text('filter: Groups'), findsOneWidget);
    expect(find.text('visible conversations: 1'), findsOneWidget);
    expect(find.text('+1 | +2', findRichText: true), findsOneWidget);
    expect(find.text('attachments: 4'), findsOneWidget);

    await tester.tap(find.text('With attachments'));
    await tester.pump();

    expect(find.text('filter: With attachments'), findsOneWidget);
    expect(find.text('visible conversations: 1'), findsOneWidget);
    expect(find.text('attachments: 4'), findsOneWidget);
  });

  testWidgets('filters visible conversations by participants', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recentChatsProvider(limit: 500).overrideWith((ref) async {
            return [
              _summary(
                id: 1,
                participants: ['claire@example.com'],
                messageCount: 10,
                preview: 'airport pickup',
              ),
              _summary(
                id: 2,
                participants: ['rusung@example.com'],
                messageCount: 20,
                preview: 'dinner',
              ),
            ];
          }),
          conversationFavouritesControllerProvider.overrideWith(
            _TestConversationFavouritesController.new,
          ),
        ],
        child: _wrapWithTextEditingShell(const ConversationBrowserView()),
      ),
    );

    await tester.pump();
    await tester.enterText(
      find.descendant(
        of: find.byKey(
          const ValueKey<String>('conversation-browser-search-include'),
        ),
        matching: find.byType(CupertinoTextField),
      ),
      'claire',
    );
    await tester.pump();

    expect(find.text('visible conversations: 1'), findsOneWidget);
    expect(find.text('claire@example.com', findRichText: true), findsWidgets);
    expect(find.text('rusung@example.com'), findsNothing);

    expect(find.text('Message text contains'), findsOneWidget);
    expect(find.text('Any conversation text'), findsNothing);
  });

  testWidgets('keeps message text search stable and annotates matches', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recentChatsProvider(limit: 500).overrideWith((ref) async {
            return [
              _summary(
                id: 1,
                participants: ['claire@example.com'],
                messageCount: 10,
                preview: 'airport pickup',
              ),
              _summary(
                id: 2,
                participants: ['rusung@example.com'],
                messageCount: 20,
                preview: 'dinner',
              ),
            ];
          }),
          conversationMessageTextMatchesProvider(
            query: 'settlement',
            limit: 500,
          ).overrideWith((ref) async {
            return const <int, ConversationMessageTextMatch>{
              1: ConversationMessageTextMatch(
                conversationId: 1,
                matchCount: 3,
                sampleText: 'The settlement term appears here.',
                snippets: [
                  ConversationMessageTextSnippet(
                    messageId: 101,
                    dateUtc: '2026-05-20T10:00:00.000Z',
                    text: 'The settlement term appears here.',
                  ),
                  ConversationMessageTextSnippet(
                    messageId: 102,
                    dateUtc: '2026-05-19T10:00:00.000Z',
                    text: 'A second settlement message appears here.',
                  ),
                ],
              ),
            };
          }),
          conversationFavouritesControllerProvider.overrideWith(
            _TestConversationFavouritesController.new,
          ),
        ],
        child: _wrapWithTextEditingShell(const ConversationBrowserView()),
      ),
    );

    await tester.pump();
    await tester.enterText(
      find.descendant(
        of: find.byKey(
          const ValueKey<String>('conversation-browser-search-message-text'),
        ),
        matching: find.byType(CupertinoTextField),
      ),
      'settlement',
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('visible conversations: 2'), findsOneWidget);
    expect(find.text('message text matches: 1'), findsOneWidget);
    expect(find.text('matching messages: 3'), findsOneWidget);
    expect(
      find.text('The settlement term appears here.', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.text(
        'A second settlement message appears here.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.textContaining('message 101'), findsOneWidget);
    expect(find.text('rusung@example.com', findRichText: true), findsOneWidget);
  });
}

Widget _wrapWithTextEditingShell(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Overlay(initialEntries: [OverlayEntry(builder: (context) => child)]),
  );
}

class _TestConversationFavouritesController
    extends ConversationFavouritesController {
  @override
  ConversationFavourites build() {
    return const ConversationFavourites();
  }

  @override
  Future<void> toggleCoreFavourite(int conversationId) async {}
}

RecentChatSummary _summary({
  required int id,
  required List<String> participants,
  required int messageCount,
  int attachmentCount = 0,
  String? preview,
}) {
  return RecentChatSummary(
    chatId: id,
    title: participants.join(' and '),
    messageCount: messageCount,
    attachmentCount: attachmentCount,
    firstMessageDate: null,
    lastMessageDate: DateTime.utc(2026, 5, 20).subtract(Duration(days: id)),
    isGroup: participants.length > 1,
    participants: participants,
    handles: participants,
    lastMessagePreview: preview ?? 'preview $id',
  );
}
