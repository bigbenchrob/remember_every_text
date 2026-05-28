import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/features/contacts/domain/participant_origin.dart';
import 'package:remember_this_text/features/contacts/infrastructure/repositories/contact_profile_provider.dart';
import 'package:remember_this_text/features/messages/domain/value_objects/message_timeline_scope.dart';
import 'package:remember_this_text/features/messages/presentation/view/contact_graph_messages_view.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/timeline/ordinal/current_visible_month_provider.dart';

void main() {
  testWidgets('opens graph contact timeline at latest message', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._contactGraphOverrides(
            messages: const [
              ConversationMessage(
                messageId: 2,
                dateUtc: '2026-05-20T10:00:00.000Z',
                isFromMe: true,
                text: 'newest graph message',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
              ConversationMessage(
                messageId: 1,
                dateUtc: '2026-05-19T10:00:00.000Z',
                isFromMe: false,
                text: 'older graph message',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
            ],
          ),
        ],
        child: const MacosApp(home: ContactGraphMessagesView(contactId: 24)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('newest graph message'), findsOneWidget);
  });

  testWidgets('publishes selected contact month for heatmap feedback', (
    tester,
  ) async {
    final visibleMonthWrites = <String?>[];
    final monthAnchor = DateTime(2026, 4);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._contactGraphOverrides(
            messages: const [
              ConversationMessage(
                messageId: 1,
                dateUtc: '2026-04-20T10:00:00.000Z',
                isFromMe: true,
                text: 'april graph message',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
            ],
            monthAnchor: monthAnchor,
          ),
          currentVisibleMonthForScopeProvider(
            scope: const MessageTimelineScope.contact(contactId: 24),
          ).overrideWith(() => _VisibleMonthSpy(visibleMonthWrites)),
        ],
        child: MacosApp(
          home: ContactGraphMessagesView(
            contactId: 24,
            monthAnchor: monthAnchor,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(visibleMonthWrites, contains('2026-04'));
  });

  testWidgets('opens filtered graph contact timeline through shared view', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._contactGraphOverrides(
            messages: const [
              ConversationMessage(
                messageId: 3,
                dateUtc: '2026-05-20T10:00:00.000Z',
                isFromMe: true,
                text: 'selected handle graph message',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
            ],
            filterHandleId: 12,
          ),
        ],
        child: const MacosApp(
          home: ContactGraphMessagesView(contactId: 24, filterHandleId: 12),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('selected handle graph message'), findsOneWidget);
  });

  testWidgets(
    'publishes filtered selected contact month for heatmap feedback',
    (tester) async {
      final visibleMonthWrites = <String?>[];
      final monthAnchor = DateTime(2026, 4);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ..._contactGraphOverrides(
              messages: const [
                ConversationMessage(
                  messageId: 3,
                  dateUtc: '2026-04-20T10:00:00.000Z',
                  isFromMe: true,
                  text: 'filtered april graph message',
                  associatedMessageId: null,
                  attachmentCount: 0,
                ),
              ],
              monthAnchor: monthAnchor,
              filterHandleId: 12,
            ),
            currentVisibleMonthForScopeProvider(
              scope: const MessageTimelineScope.contact(
                contactId: 24,
                filterHandleId: 12,
              ),
            ).overrideWith(() => _VisibleMonthSpy(visibleMonthWrites)),
          ],
          child: MacosApp(
            home: ContactGraphMessagesView(
              contactId: 24,
              monthAnchor: monthAnchor,
              filterHandleId: 12,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(visibleMonthWrites, contains('2026-04'));
    },
  );

  testWidgets(
    'contact search overlays matching count without removing nonmatching rows',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ..._contactGraphOverrides(
              messages: const [
                ConversationMessage(
                  messageId: 1,
                  dateUtc: '2026-04-20T10:00:00.000Z',
                  isFromMe: true,
                  text: 'settlement message',
                  associatedMessageId: null,
                  attachmentCount: 0,
                ),
                ConversationMessage(
                  messageId: 2,
                  dateUtc: '2026-05-20T10:00:00.000Z',
                  isFromMe: false,
                  text: 'other message',
                  associatedMessageId: null,
                  attachmentCount: 0,
                ),
              ],
              matchingIdsByQuery: const {
                'settlement': [1],
              },
            ),
          ],
          child: const MacosApp(home: ContactGraphMessagesView(contactId: 24)),
        ),
      );

      await tester.pumpAndSettle();
      await tester.enterText(find.byType(MacosTextField), 'settlement');
      await tester.pumpAndSettle();

      expect(find.text('settlement message'), findsOneWidget);
      expect(find.text('other message'), findsOneWidget);
      expect(find.text('1 of 2 messages match "settlement"'), findsOneWidget);
    },
  );
}

List<Override> _contactGraphOverrides({
  required List<ConversationMessage> messages,
  DateTime? monthAnchor,
  int? filterHandleId,
  Map<String, List<int>> matchingIdsByQuery = const <String, List<int>>{},
}) {
  return [
    contactPageGraphMessagesProvider(
      contactId: 24,
      limit: monthAnchor == null ? 500 : 100000,
      monthAnchor: monthAnchor,
    ).overrideWith((ref) async {
      return messages;
    }),
    contactPageGraphMessageTimelineProvider(contactId: 24).overrideWith((
      ref,
    ) async {
      return [
        for (final message in messages)
          ContactGraphMessageTimelineEntry(
            messageId: message.messageId,
            dateUtc: message.dateUtc,
            monthKey: _monthKey(message.dateUtc),
          ),
      ];
    }),
    if (filterHandleId != null)
      contactPageGraphHandleMessageTimelineProvider(
        contactId: 24,
        handleId: filterHandleId,
      ).overrideWith((ref) async {
        return [
          for (final message in messages)
            ContactGraphMessageTimelineEntry(
              messageId: message.messageId,
              dateUtc: message.dateUtc,
              monthKey: _monthKey(message.dateUtc),
            ),
        ];
      }),
    for (final entry in matchingIdsByQuery.entries)
      contactPageGraphMessageIdsMatchingTextProvider(
        contactId: 24,
        query: entry.key,
        handleId: filterHandleId,
      ).overrideWith((ref) async {
        return entry.value;
      }),
    for (final message in messages)
      contactPageGraphMessageByIdProvider(
        contactId: 24,
        messageId: message.messageId,
      ).overrideWith((ref) async {
        return message;
      }),
    if (filterHandleId != null)
      for (final message in messages)
        contactPageGraphHandleMessageByIdProvider(
          contactId: 24,
          handleId: filterHandleId,
          messageId: message.messageId,
        ).overrideWith((ref) async {
          return message;
        }),
    contactPageGraphSnapshotProvider(contactId: 24).overrideWith((ref) async {
      return const ContactGraphSnapshot(
        contactId: 24,
        conversations: <ConversationOverview>[],
        messageActivity: ContactMessageActivity(
          firstMessageAtUtc: '2026-04-10T10:00:00.000Z',
          lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
          monthCounts: <ContactMessageMonthCount>[
            ContactMessageMonthCount(year: 2026, month: 4, messageCount: 1),
            ContactMessageMonthCount(year: 2026, month: 5, messageCount: 1),
          ],
        ),
      );
    }),
    contactProfileProvider(contactId: 24).overrideWith((ref) async {
      return const ContactProfileSummary(
        contactId: 24,
        displayName: 'Claire Merriman Campbell',
        shortName: 'Claire',
        origin: ParticipantOrigin.working,
      );
    }),
  ];
}

String? _monthKey(String? value) {
  final parsed = value == null ? null : DateTime.tryParse(value);
  if (parsed == null) {
    return null;
  }
  return '${parsed.year.toString().padLeft(4, '0')}-'
      '${parsed.month.toString().padLeft(2, '0')}';
}

class _VisibleMonthSpy extends CurrentVisibleMonthForScope {
  _VisibleMonthSpy(this.writes);

  final List<String?> writes;

  @override
  FutureOr<String?> build({required MessageTimelineScope scope}) {
    return null;
  }

  @override
  void setVisibleMonthKey(String? monthKey) {
    writes.add(monthKey);
    super.setVisibleMonthKey(monthKey);
  }
}
