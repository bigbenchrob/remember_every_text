import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_repository.dart';
import 'package:remember_this_text/features/messages/presentation/view/handle_graph_messages_view.dart';

void main() {
  testWidgets('renders handle messages through evidence spine', (tester) async {
    const repository = _FakeMessageGraphRepository(
      timeline: [
        ConversationMessageTimelineEntry(
          messageId: 1,
          dateUtc: '2026-04-20T10:00:00.000Z',
          monthKey: '2026-04',
        ),
      ],
      hydratedMessage: ConversationMessage(
        messageId: 1,
        dateUtc: '2026-04-20T10:00:00.000Z',
        isFromMe: false,
        text: 'handle graph message',
        associatedMessageId: null,
        attachmentCount: 0,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messageGraphReaderProvider.overrideWith((ref) async {
            return const MessageGraphReader(repository: repository);
          }),
        ],
        child: const CupertinoApp(home: HandleGraphMessagesView(handleId: 12)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Handle messages'), findsOneWidget);
    expect(find.text('handle graph message'), findsOneWidget);
  });
}

class _FakeMessageGraphRepository implements MessageGraphRepository {
  const _FakeMessageGraphRepository({
    required this.timeline,
    required this.hydratedMessage,
  });

  final List<ConversationMessageTimelineEntry> timeline;
  final ConversationMessage hydratedMessage;

  @override
  Future<List<ConversationMessageTimelineEntry>>
  readGlobalMessageTimeline() async {
    return const <ConversationMessageTimelineEntry>[];
  }

  @override
  Future<ConversationMessage?> readGlobalMessageById({
    required int messageId,
  }) async {
    return null;
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
    return timeline;
  }

  @override
  Future<ConversationMessage?> readHandleMessageById({
    required int handleId,
    required int messageId,
  }) async {
    return hydratedMessage.messageId == messageId ? hydratedMessage : null;
  }

  @override
  Future<List<ConversationMessageTimelineEntry>> readMessageContextTimeline({
    required int messageId,
    required int chatId,
    required int beforeCount,
    required int afterCount,
  }) async {
    return const <ConversationMessageTimelineEntry>[];
  }
}
