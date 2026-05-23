import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/working_projection_readiness_provider.dart';
import 'package:remember_this_text/features/chats/application/chat_read_model_source_provider.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/contact_timeline_provider.dart';

void main() {
  test('contact timeline can be derived from graph contact activity', () async {
    final container = ProviderContainer(
      overrides: [
        workingProjectionReadinessProvider.overrideWith((ref) async {
          return const WorkingProjectionReadiness(
            isReady: false,
            reason: 'legacy not ready',
          );
        }),
        chatReadModelSourceProvider.overrideWith(() => _GraphReadModelSource()),
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
}

class _GraphReadModelSource extends ChatReadModelSource {
  @override
  ChatReadModelSourceMode build() {
    return ChatReadModelSourceMode.conversationGraph;
  }
}
