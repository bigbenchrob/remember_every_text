import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_repository.dart';
import 'package:remember_this_text/essentials/search/application/graph_message_search.dart';
import 'package:remember_this_text/essentials/search/application/graph_search_repository_provider.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/message_evidence_spine_provider.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_row_data.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_scope.dart';
import 'package:remember_this_text/features/messages/presentation/view/global_messages_evidence_view.dart';

void main() {
  testWidgets('renders global timeline through evidence spine', (tester) async {
    const message = ConversationMessage(
      messageId: 1,
      dateUtc: '2026-04-20T10:00:00.000Z',
      isFromMe: true,
      text: 'global message',
      associatedMessageId: null,
      attachmentCount: 0,
    );
    const repository = _FakeMessageGraphRepository(
      timeline: [
        ConversationMessageTimelineEntry(
          messageId: 1,
          dateUtc: '2026-04-20T10:00:00.000Z',
          monthKey: '2026-04',
        ),
      ],
      messagesById: {1: message},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messageGraphReaderProvider.overrideWith((ref) async {
            return const MessageGraphReader(repository: repository);
          }),
          messageEvidenceRowProvider(
            scope: const GlobalMessagesEvidenceScope(),
            messageId: message.messageId,
          ).overrideWith((ref) async => _rowData(message)),
        ],
        child: const MacosApp(home: GlobalMessagesEvidenceView()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('All messages'), findsOneWidget);
    expect(find.text('global message'), findsOneWidget);
  });

  testWidgets('filters global timeline through evidence spine text matches', (
    tester,
  ) async {
    const matchingMessage = ConversationMessage(
      messageId: 1,
      dateUtc: '2026-04-20T10:00:00.000Z',
      isFromMe: true,
      text: 'needle global message',
      associatedMessageId: null,
      attachmentCount: 0,
    );
    const nonMatchingMessage = ConversationMessage(
      messageId: 2,
      dateUtc: '2026-04-21T10:00:00.000Z',
      isFromMe: true,
      text: 'other global message',
      associatedMessageId: null,
      attachmentCount: 0,
    );
    const repository = _FakeMessageGraphRepository(
      timeline: [
        ConversationMessageTimelineEntry(
          messageId: 1,
          dateUtc: '2026-04-20T10:00:00.000Z',
          monthKey: '2026-04',
        ),
        ConversationMessageTimelineEntry(
          messageId: 2,
          dateUtc: '2026-04-21T10:00:00.000Z',
          monthKey: '2026-04',
        ),
      ],
      messagesById: {1: matchingMessage, 2: nonMatchingMessage},
      globalMatchesByQuery: {
        'needle': [1],
      },
    );
    const allMessagesScope = GlobalMessagesEvidenceScope();
    const searchScope = MessageSearchEvidenceScope(query: 'needle');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messageGraphReaderProvider.overrideWith((ref) async {
            return const MessageGraphReader(repository: repository);
          }),
          graphSearchRepositoryProvider.overrideWith((ref) async {
            return const _FakeGraphSearchRepository(
              globalMatchesByQuery: {
                'needle': [1],
              },
            );
          }),
          messageEvidenceRowProvider(
            scope: allMessagesScope,
            messageId: matchingMessage.messageId,
          ).overrideWith((ref) async => _rowData(matchingMessage)),
          messageEvidenceRowProvider(
            scope: allMessagesScope,
            messageId: nonMatchingMessage.messageId,
          ).overrideWith((ref) async => _rowData(nonMatchingMessage)),
          messageEvidenceRowProvider(
            scope: searchScope,
            messageId: matchingMessage.messageId,
          ).overrideWith((ref) async => _rowData(matchingMessage)),
        ],
        child: const MacosApp(home: GlobalMessagesEvidenceView()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('needle global message'), findsOneWidget);
    expect(find.text('other global message'), findsOneWidget);

    await tester.enterText(find.byType(MacosTextField), 'needle');
    await tester.pumpAndSettle();

    expect(find.text('needle global message'), findsOneWidget);
    expect(find.text('other global message'), findsNothing);
    expect(find.text('1 of 2 messages match "needle"'), findsOneWidget);
  });
}

MessageEvidenceRowData _rowData(ConversationMessage message) {
  return MessageEvidenceRowData(
    messageId: message.messageId,
    dateUtc: message.dateUtc,
    isFromMe: message.isFromMe,
    text: message.text,
    associatedMessageId: message.associatedMessageId,
    attachmentCount: message.attachmentCount,
  );
}

class _FakeGraphSearchRepository implements GraphSearchRepository {
  const _FakeGraphSearchRepository({
    this.globalMatchesByQuery = const <String, List<int>>{},
  });

  final Map<String, List<int>> globalMatchesByQuery;

  @override
  Future<List<int>> searchMessageIds({
    required GraphMessageSearchScope scope,
    required String query,
    required bool matchAnyTerm,
    required bool filterSaved,
    bool lastTokenComplete = false,
    int limit = graphSearchResultLimit,
  }) async {
    if (scope.type != GraphMessageSearchScopeType.global) {
      return const <int>[];
    }
    return globalMatchesByQuery[query] ?? const <int>[];
  }
}

class _FakeMessageGraphRepository implements MessageGraphRepository {
  const _FakeMessageGraphRepository({
    required this.timeline,
    required this.messagesById,
    this.globalMatchesByQuery = const <String, List<int>>{},
  });

  final List<ConversationMessageTimelineEntry> timeline;
  final Map<int, ConversationMessage> messagesById;
  final Map<String, List<int>> globalMatchesByQuery;

  @override
  Future<List<ConversationMessageTimelineEntry>>
  readGlobalMessageTimeline() async {
    return timeline;
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
    bool matchAnyTerm = false,
  }) async {
    return globalMatchesByQuery[query] ?? const <int>[];
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
