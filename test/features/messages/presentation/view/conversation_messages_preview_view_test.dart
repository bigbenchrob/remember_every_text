import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import 'package:remember_this_text/features/contacts/feature_level_providers.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/message_evidence_spine_provider.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_row_data.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_scope.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_search_mode.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_skeleton.dart';
import 'package:remember_this_text/features/messages/presentation/view/conversation_messages_preview_view.dart';

void main() {
  testWidgets('renders graph conversation through evidence spine', (
    tester,
  ) async {
    const scope = ConversationEvidenceScope(conversationId: 42);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [
              ConversationOverview(
                conversationId: 42,
                participantHandles: ['1 (778) 990-8506', '+15552'],
                participantCount: 2,
                isGroup: true,
                messageCount: 3,
                attachmentCount: 0,
                firstMessageAtUtc: '2026-05-18T10:00:00.000Z',
                lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
                lastMessageText: 'newest',
              ),
            ];
          }),
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(
              identitiesByHandleKey: {
                '17789908506': ParticipantDisplayIdentity(
                  primaryLabel: 'Claire',
                  source: DisplayIdentitySource.userOverride,
                  isKnownContact: true,
                  contactId: 17,
                ),
              },
            );
          }),
          messageEvidenceTimelineSkeletonProvider(scope: scope).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceTimelineSkeleton(
              entries: [
                MessageEvidenceSkeletonEntry(
                  messageId: 1,
                  dateUtc: '2026-05-18T10:00:00.000Z',
                  monthKey: '2026-05',
                ),
                MessageEvidenceSkeletonEntry(
                  messageId: 2,
                  dateUtc: '2026-05-19T10:00:00.000Z',
                  monthKey: '2026-05',
                ),
                MessageEvidenceSkeletonEntry(
                  messageId: 3,
                  dateUtc: '2026-05-20T10:00:00.000Z',
                  monthKey: '2026-05',
                ),
              ],
            );
          }),
          messageEvidenceRowProvider(scope: scope, messageId: 1).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceRowData(
              messageId: 1,
              dateUtc: '2026-05-18T10:00:00.000Z',
              isFromMe: false,
              text: 'oldest',
              associatedMessageId: null,
              attachmentCount: 0,
            );
          }),
          messageEvidenceRowProvider(scope: scope, messageId: 2).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceRowData(
              messageId: 2,
              dateUtc: '2026-05-19T10:00:00.000Z',
              isFromMe: false,
              text: null,
              associatedMessageId: null,
              attachmentCount: 0,
              senderDisplayHandle: '+15552',
              itemKind: 'system',
              isSparseArtifact: true,
              hasAttributedBodySource: true,
            );
          }),
          messageEvidenceRowProvider(scope: scope, messageId: 3).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceRowData(
              messageId: 3,
              dateUtc: '2026-05-20T10:00:00.000Z',
              isFromMe: true,
              text: 'newest',
              associatedMessageId: 1,
              attachmentCount: 0,
              semanticKind: 'reaction',
            );
          }),
        ],
        child: const MacosApp(
          home: ConversationMessagesPreviewView(conversationId: 42),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Conversation with Claire and +15552'), findsOneWidget);
    expect(find.textContaining('3 messages'), findsOneWidget);
    expect(find.text('newest'), findsOneWidget);
    expect(find.text('associated 1'), findsOneWidget);
    expect(find.text('reaction'), findsOneWidget);
    expect(find.text('View options'), findsNothing);
    expect(find.text('Latest 500'), findsNothing);
  });

  testWidgets('shows search and anchor context without batch controls', (
    tester,
  ) async {
    const scope = ConversationEvidenceScope(conversationId: 42);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [];
          }),
          messageEvidenceTimelineSkeletonProvider(scope: scope).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceTimelineSkeleton(entries: []);
          }),
        ],
        child: const MacosApp(
          home: ConversationMessagesPreviewView(
            conversationId: 42,
            anchorMessageId: 101,
            searchQuery: 'settlement',
          ),
        ),
      ),
    );

    await tester.pump();

    await tester.pump();

    expect(
      find.textContaining('Message text contains "settlement"'),
      findsOneWidget,
    );
    expect(find.textContaining('Anchored at message 101'), findsOneWidget);
    expect(find.text('View options'), findsNothing);
    expect(find.text('Latest 500'), findsNothing);
  });

  testWidgets('passes anchor and search highlight into the evidence timeline', (
    tester,
  ) async {
    const scope = ConversationEvidenceScope(conversationId: 42);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [];
          }),
          messageEvidenceTimelineSkeletonProvider(scope: scope).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceTimelineSkeleton(
              entries: [
                MessageEvidenceSkeletonEntry(
                  messageId: 100,
                  dateUtc: '2026-05-18T10:00:00.000Z',
                  monthKey: '2026-05',
                ),
                MessageEvidenceSkeletonEntry(
                  messageId: 101,
                  dateUtc: '2026-05-20T10:00:00.000Z',
                  monthKey: '2026-05',
                ),
              ],
            );
          }),
          messageEvidenceTextMatchIdsProvider(
            scope: scope,
            query: 'settlement',
            mode: MessageEvidenceSearchMode.allTerms,
          ).overrideWith((ref) async {
            return [101];
          }),
          messageEvidenceRowProvider(scope: scope, messageId: 101).overrideWith(
            (ref) async {
              return const MessageEvidenceRowData(
                messageId: 101,
                dateUtc: '2026-05-20T10:00:00.000Z',
                isFromMe: true,
                text: 'settlement authority',
                associatedMessageId: null,
                attachmentCount: 0,
              );
            },
          ),
        ],
        child: const MacosApp(
          home: ConversationMessagesPreviewView(
            conversationId: 42,
            anchorMessageId: 101,
            searchQuery: 'settlement',
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('settlement authority'), findsOneWidget);
  });

  testWidgets('conversation search displays only matching scope rows', (
    tester,
  ) async {
    const scope = ConversationEvidenceScope(conversationId: 42);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [
              ConversationOverview(
                conversationId: 42,
                participantHandles: ['+15551'],
                participantCount: 1,
                isGroup: false,
                messageCount: 2,
                attachmentCount: 0,
                firstMessageAtUtc: '2026-05-18T10:00:00.000Z',
                lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
                lastMessageText: 'other',
              ),
            ];
          }),
          messageEvidenceTimelineSkeletonProvider(scope: scope).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceTimelineSkeleton(
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
            );
          }),
          messageEvidenceTextMatchIdsProvider(
            scope: scope,
            query: 'settlement',
            mode: MessageEvidenceSearchMode.allTerms,
          ).overrideWith((ref) async {
            return [1];
          }),
          messageEvidenceRowProvider(scope: scope, messageId: 1).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceRowData(
              messageId: 1,
              dateUtc: '2026-05-18T10:00:00.000Z',
              isFromMe: false,
              text: 'settlement authority',
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
              isFromMe: false,
              text: 'other message',
              associatedMessageId: null,
              attachmentCount: 0,
            );
          }),
        ],
        child: const MacosApp(
          home: ConversationMessagesPreviewView(
            conversationId: 42,
            searchQuery: 'settlement',
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('settlement authority'), findsOneWidget);
    expect(find.text('other message'), findsNothing);
    expect(find.text('1 of 2 messages match "settlement"'), findsOneWidget);
  });
}
