import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/features/contacts/domain/participant_origin.dart';
import 'package:remember_this_text/features/contacts/infrastructure/repositories/contact_profile_provider.dart';
import 'package:remember_this_text/features/messages/domain/value_objects/message_timeline_scope.dart';
import 'package:remember_this_text/features/messages/presentation/view/contact_graph_messages_view.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/timeline/ordinal/current_visible_month_provider.dart';

void main() {
  testWidgets('shows graph contact messages newest first', (tester) async {
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
        child: const CupertinoApp(
          home: ContactGraphMessagesView(contactId: 24),
        ),
      ),
    );

    await tester.pump();

    final newestTopLeft = tester.getTopLeft(find.text('newest graph message'));
    final olderTopLeft = tester.getTopLeft(find.text('older graph message'));
    expect(newestTopLeft.dy, lessThan(olderTopLeft.dy));
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
            messages: const [],
            monthAnchor: monthAnchor,
          ),
          currentVisibleMonthForScopeProvider(
            scope: const MessageTimelineScope.contact(contactId: 24),
          ).overrideWith(() => _VisibleMonthSpy(visibleMonthWrites)),
        ],
        child: CupertinoApp(
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
}

List<Override> _contactGraphOverrides({
  required List<ConversationMessage> messages,
  DateTime? monthAnchor,
}) {
  return [
    contactPageGraphMessagesProvider(
      contactId: 24,
      limit: monthAnchor == null ? 500 : 100000,
      monthAnchor: monthAnchor,
    ).overrideWith((ref) async {
      return messages;
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
