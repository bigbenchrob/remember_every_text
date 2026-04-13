import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/features/messages/application/view_spec/resolver_tools/message_context_anchor_provider.dart';
import 'package:remember_this_text/features/messages/application/view_spec/resolver_tools/search_result_context_provider.dart';
import 'package:remember_this_text/features/messages/presentation/view/search_result_context_sidebar_view.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/shared/hydration/messages_for_handle_provider.dart';

void main() {
  testWidgets('scrolls the anchor away from the top and shows anchor chrome', (
    tester,
  ) async {
    const messageId = 500;
    const chatId = 12;
    final state = SearchResultContextState(
      selectedMessage: _message(
        id: messageId,
        chatId: chatId,
        text: 'Anchor message',
      ),
      beforeMessages: <MessageListItem>[
        _message(id: 490, chatId: chatId, text: 'Before 1'),
        _message(id: 491, chatId: chatId, text: 'Before 2'),
        _message(id: 492, chatId: chatId, text: 'Before 3'),
        _message(id: 493, chatId: chatId, text: 'Before 4'),
        _message(id: 494, chatId: chatId, text: 'Before 5'),
        _message(id: 495, chatId: chatId, text: 'Before 6'),
      ],
      afterMessages: <MessageListItem>[
        _message(id: 501, chatId: chatId, text: 'After 1'),
        _message(id: 502, chatId: chatId, text: 'After 2'),
        _message(id: 503, chatId: chatId, text: 'After 3'),
        _message(id: 504, chatId: chatId, text: 'After 4'),
        _message(id: 505, chatId: chatId, text: 'After 5'),
        _message(id: 506, chatId: chatId, text: 'After 6'),
      ],
      hasMoreBefore: true,
      hasMoreAfter: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messageContextAnchorProvider.overrideWith(
            (ref) => const MessageContextAnchor(
              messageId: messageId,
              chatId: chatId,
              beforeCount: 10,
              afterCount: 10,
            ),
          ),
          searchResultContextProvider(
            messageId: messageId,
            chatId: chatId,
            beforeCount: 10,
            afterCount: 10,
          ).overrideWith((ref) async => state),
        ],
        child: const MacosApp(
          home: MacosWindow(
            child: SizedBox(
              width: 360,
              height: 520,
              child: SearchResultContextSidebarView(
                messageId: messageId,
                chatId: chatId,
                beforeCount: 10,
                afterCount: 10,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final listTop = tester.getTopLeft(
      find.byKey(const ValueKey<String>('search-result-context-list')),
    );
    final anchorTop = tester.getTopLeft(
      find.byKey(
        const ValueKey<String>(
          'message-context-anchor-card-search-context-500',
        ),
      ),
    );

    expect(find.text('Anchor message'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey<String>(
          'message-context-anchor-badge-search-context-500',
        ),
      ),
      findsOneWidget,
    );
    expect(anchorTop.dy, greaterThan(listTop.dy + 40));
  });
}

MessageListItem _message({
  required int id,
  required int chatId,
  required String text,
}) {
  return MessageListItem(
    id: id,
    chatId: chatId,
    guid: 'guid-$id',
    senderName: 'Alex',
    text: text,
    isFromMe: false,
    sentAt: DateTime(2026, 4, 11, 12, id % 60),
    hasAttachments: false,
  );
}
