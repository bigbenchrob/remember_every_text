import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_repository.dart';
import 'package:remember_this_text/features/contacts/feature_level_providers.dart';
import 'package:remember_this_text/features/handles/feature_level_providers.dart';
import 'package:remember_this_text/features/messages/presentation/view/handle_messages_evidence_view.dart';

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
        text: 'handle message',
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
          handleDisplayNameProvider(handleId: 12).overrideWith((ref) async {
            return 'Claire';
          }),
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(identitiesByHandleKey: {});
          }),
        ],
        child: const MacosApp(home: HandleMessagesEvidenceView(handleId: 12)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Messages for Claire'), findsOneWidget);
    expect(find.text('handle message'), findsOneWidget);
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
    bool matchAnyTerm = false,
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
  Future<List<int>> readHandleMessageIdsMatchingText({
    required int handleId,
    required String query,
    bool matchAnyTerm = false,
  }) async {
    return const <int>[];
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
