import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_repository.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/messages/presentation/view/search_result_context_sidebar_view.dart';

void main() {
  testWidgets('renders search result context through graph evidence spine', (
    tester,
  ) async {
    const messageId = 500;
    const chatId = 12;
    final anchorGraphId = _liveChatGraphId(messageId);
    final repository = _FakeMessageGraphRepository(
      contextTimeline: [
        ConversationMessageTimelineEntry(
          messageId: _liveChatGraphId(498),
          dateUtc: '2026-04-11T11:58:00.000Z',
          monthKey: '2026-04',
        ),
        ConversationMessageTimelineEntry(
          messageId: anchorGraphId,
          dateUtc: '2026-04-11T12:00:00.000Z',
          monthKey: '2026-04',
        ),
        ConversationMessageTimelineEntry(
          messageId: _liveChatGraphId(502),
          dateUtc: '2026-04-11T12:02:00.000Z',
          monthKey: '2026-04',
        ),
      ],
      messagesById: {
        _liveChatGraphId(498): _message(
          id: _liveChatGraphId(498),
          text: 'Before context',
        ),
        anchorGraphId: _message(id: anchorGraphId, text: 'Anchor message'),
        _liveChatGraphId(502): _message(
          id: _liveChatGraphId(502),
          text: 'After context',
        ),
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messageGraphReaderProvider.overrideWith((ref) async {
            return MessageGraphReader(repository: repository);
          }),
        ],
        child: const MacosApp(
          home: MacosWindow(
            child: SizedBox(
              width: 420,
              height: 620,
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

    await tester.pumpAndSettle();

    expect(find.text('Message context'), findsOneWidget);
    expect(find.text('Anchor message'), findsOneWidget);
    expect(find.text('Before context'), findsOneWidget);
    expect(find.text('After context'), findsOneWidget);
    expect(repository.contextRequest, const (messageId, chatId, 10, 10));
  });
}

ConversationMessage _message({required int id, required String text}) {
  return ConversationMessage(
    messageId: id,
    dateUtc: '2026-04-11T12:00:00.000Z',
    isFromMe: false,
    text: text,
    associatedMessageId: null,
    attachmentCount: 0,
    senderDisplayHandle: 'Alex',
  );
}

int _liveChatGraphId(int value) {
  return SourceScopedRowKey.pack(
    sourceId: liveChatDbSourceId,
    sourceRowId: value,
  );
}

class _FakeMessageGraphRepository implements MessageGraphRepository {
  _FakeMessageGraphRepository({
    required this.contextTimeline,
    required this.messagesById,
  });

  final List<ConversationMessageTimelineEntry> contextTimeline;
  final Map<int, ConversationMessage> messagesById;
  (int, int, int, int)? contextRequest;

  @override
  Future<List<ConversationMessageTimelineEntry>>
  readGlobalMessageTimeline() async {
    return const <ConversationMessageTimelineEntry>[];
  }

  @override
  Future<ConversationMessage?> readGlobalMessageById({
    required int messageId,
  }) async {
    return messagesById[messageId];
  }

  @override
  Future<List<int>> readGlobalMessageIdsMatchingText({
    required String query,
  }) async {
    return const <int>[];
  }

  @override
  Future<List<ConversationMessageTimelineEntry>> readHandleMessageTimeline({
    required int handleId,
  }) async {
    return const <ConversationMessageTimelineEntry>[];
  }

  @override
  Future<ConversationMessage?> readHandleMessageById({
    required int handleId,
    required int messageId,
  }) async {
    return null;
  }

  @override
  Future<List<ConversationMessageTimelineEntry>> readMessageContextTimeline({
    required int messageId,
    required int chatId,
    required int beforeCount,
    required int afterCount,
  }) async {
    contextRequest = (messageId, chatId, beforeCount, afterCount);
    return contextTimeline;
  }
}
