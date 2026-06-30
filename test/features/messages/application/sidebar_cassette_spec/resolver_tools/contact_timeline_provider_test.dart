import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/contact_timeline_provider.dart';

void main() {
  test('contact timeline can be derived from graph contact activity', () async {
    final container = ProviderContainer(
      overrides: [
        contactPageGraphSnapshotProvider(contactId: 24).overrideWith((
          ref,
        ) async {
          return const ContactGraphSnapshot(
            contactId: 24,
            conversations: <ConversationOverview>[],
            messageActivity: ContactMessageActivity(
              firstMessageAtUtc: '2026-04-10T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-10T10:00:00.000Z',
              monthCounts: <ContactMessageMonthCount>[
                ContactMessageMonthCount(year: 2026, month: 4, messageCount: 2),
                ContactMessageMonthCount(year: 2026, month: 5, messageCount: 3),
              ],
            ),
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    final timeline = await container.read(
      contactTimelineProvider(contactId: 24).future,
    );

    expect(timeline, isNotNull);
    expect(timeline?.totalMessages, 5);
    expect(timeline?.maxMonthCount, 3);
    expect(timeline?.firstMessageDate.month, 4);
    expect(timeline?.lastMessageDate.month, 5);
  });

  test('contact timeline can be scoped to a selected graph handle', () async {
    final container = ProviderContainer(
      overrides: [
        contactPageGraphHandleMessageTimelineProvider(
          contactId: 24,
          handleId: 12,
        ).overrideWith((ref) async {
          return const [
            ContactGraphMessageTimelineEntry(
              messageId: 1,
              dateUtc: '2026-04-10T10:00:00.000Z',
              monthKey: '2026-04',
            ),
            ContactGraphMessageTimelineEntry(
              messageId: 2,
              dateUtc: '2026-04-11T10:00:00.000Z',
              monthKey: '2026-04',
            ),
            ContactGraphMessageTimelineEntry(
              messageId: 3,
              dateUtc: '2026-06-10T10:00:00.000Z',
              monthKey: '2026-06',
            ),
          ];
        }),
      ],
    );
    addTearDown(container.dispose);

    final timeline = await container.read(
      contactTimelineProvider(contactId: 24, filterHandleId: 12).future,
    );

    final months = {
      for (final row in timeline!.yearRows)
        for (final month in row.months)
          '${month.year}-${month.month}': month.messageCount,
    };
    expect(timeline.totalMessages, 3);
    expect(timeline.maxMonthCount, 2);
    expect(months['2026-4'], 2);
    expect(months['2026-5'], 0);
    expect(months['2026-6'], 1);
  });
}
