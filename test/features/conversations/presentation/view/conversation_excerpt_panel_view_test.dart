import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_signatures/conversation_signature.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_repository.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/conversations/feature_level_providers.dart';
import 'package:remember_this_text/features/conversations/presentation/view/conversation_excerpt_panel_view.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/message_evidence_spine_provider.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_row_data.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_scope.dart';

void main() {
  test('reads temporal orientation from the exact anchor message', () async {
    final conversationId = _liveChatGraphId(12);
    final anchorGraphId = _liveChatGraphId(500);
    final anchorMessage = _message(
      id: anchorGraphId,
      text: 'Anchor message',
      conversationId: conversationId,
    );
    final repository = _FakeMessageGraphRepository(
      contextTimeline: const [],
      messagesById: {anchorGraphId: anchorMessage},
    );
    final container = ProviderContainer(
      overrides: [
        messageGraphReaderProvider.overrideWith((ref) async {
          return MessageGraphReader(repository: repository);
        }),
      ],
    );
    addTearDown(container.dispose);

    final anchorDate = await container.read(
      conversationExcerptAnchorDateProvider(
        conversationId: conversationId,
        anchorMessageId: anchorGraphId,
      ).future,
    );

    expect(anchorDate, DateTime.utc(2026, 4, 11, 12));
  });

  testWidgets('renders conversation excerpt through message evidence spine', (
    tester,
  ) async {
    final conversationId = _liveChatGraphId(12);
    final anchorGraphId = _liveChatGraphId(500);
    final evidenceScope = ConversationExcerptEvidenceScope(
      conversationId: conversationId,
      anchorMessageId: anchorGraphId,
      beforeCount: 10,
      afterCount: 10,
    );
    final beforeMessage = _message(
      id: _liveChatGraphId(498),
      text: 'Before context',
    );
    final anchorMessage = _message(id: anchorGraphId, text: 'Anchor message');
    final afterMessage = _message(
      id: _liveChatGraphId(502),
      text: 'After context',
    );
    final repository = _FakeMessageGraphRepository(
      contextTimeline: [
        ConversationMessageTimelineEntry(
          messageId: beforeMessage.messageId,
          dateUtc: '2026-04-11T11:58:00.000Z',
          monthKey: '2026-04',
        ),
        ConversationMessageTimelineEntry(
          messageId: anchorGraphId,
          dateUtc: '2026-04-11T12:00:00.000Z',
          monthKey: '2026-04',
        ),
        ConversationMessageTimelineEntry(
          messageId: afterMessage.messageId,
          dateUtc: '2026-04-11T12:02:00.000Z',
          monthKey: '2026-04',
        ),
      ],
      messagesById: {
        beforeMessage.messageId: beforeMessage,
        anchorMessage.messageId: anchorMessage,
        afterMessage.messageId: afterMessage,
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messageGraphReaderProvider.overrideWith((ref) async {
            return MessageGraphReader(repository: repository);
          }),
          conversationSignatureDisplayByIdsProvider(
            request: ConversationSignatureDisplayByIdsRequest(
              conversationIds: [conversationId],
            ),
          ).overrideWith((ref) async {
            return [
              ConversationSignatureDisplayModel(
                conversationId: conversationId,
                title: 'Alex and Casey',
                participantLabels: const ['Alex', 'Casey'],
                participantCount: 2,
                isGroup: true,
                messageCount: 3,
                attachmentCount: 0,
                firstMessageAtUtc: '2026-04-11T11:58:00.000Z',
                lastMessageAtUtc: '2026-04-11T12:02:00.000Z',
                lastMessageText: 'After context',
                activityMonths: const [
                  ConversationSignatureMonth(
                    year: 2026,
                    month: 4,
                    messageCount: 3,
                  ),
                ],
              ),
            ];
          }),
          messageEvidenceRowProvider(
            scope: evidenceScope,
            messageId: beforeMessage.messageId,
          ).overrideWith((ref) async => _rowData(beforeMessage)),
          messageEvidenceRowProvider(
            scope: evidenceScope,
            messageId: anchorMessage.messageId,
          ).overrideWith((ref) async => _rowData(anchorMessage)),
          messageEvidenceRowProvider(
            scope: evidenceScope,
            messageId: afterMessage.messageId,
          ).overrideWith((ref) async => _rowData(afterMessage)),
        ],
        child: MacosApp(
          home: MacosWindow(
            child: SizedBox(
              width: 420,
              height: 620,
              child: ConversationExcerptPanelView(
                conversationId: conversationId,
                anchorMessageId: anchorGraphId,
                beforeCount: 10,
                afterCount: 10,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Conversation excerpt'), findsOneWidget);
    expect(find.text('Alex and Casey +2'), findsOneWidget);
    expect(find.text('April 2026'), findsOneWidget);
    expect(
      find.text('21-message excerpt centered on the chosen message'),
      findsNothing,
    );
    expect(find.text('Message context'), findsNothing);
    expect(find.text('Anchor message'), findsOneWidget);
    expect(find.text('Before context'), findsOneWidget);
    expect(find.text('After context'), findsOneWidget);
    expect(repository.contextRequest, (conversationId, anchorGraphId, 10, 10));
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
    senderDisplayHandle: message.senderDisplayHandle,
  );
}

ConversationMessage _message({
  required int id,
  required String text,
  int? conversationId,
}) {
  return ConversationMessage(
    messageId: id,
    conversationId: conversationId,
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
    bool matchAnyTerm = false,
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
  Future<List<int>> readHandleMessageIdsMatchingText({
    required int handleId,
    required String query,
    bool matchAnyTerm = false,
  }) async {
    return const <int>[];
  }

  @override
  Future<List<ConversationMessageTimelineEntry>>
  readConversationExcerptTimeline({
    required int conversationId,
    required int anchorMessageId,
    required int beforeCount,
    required int afterCount,
  }) async {
    contextRequest = (conversationId, anchorMessageId, beforeCount, afterCount);
    return contextTimeline;
  }
}
