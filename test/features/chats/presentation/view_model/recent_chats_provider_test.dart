import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import 'package:remember_this_text/features/chats/application/chat_read_model_source_provider.dart';
import 'package:remember_this_text/features/chats/application/conversation_browser/contact_handle_label_provider.dart';
import 'package:remember_this_text/features/chats/presentation/view_model/recent_chats_provider.dart';

void main() {
  test('chat read model source defaults to conversation graph', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(chatReadModelSourceProvider),
      ChatReadModelSourceMode.conversationGraph,
    );
  });

  test('chat read model source can still switch to legacy', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(chatReadModelSourceProvider.notifier)
        .setMode(ChatReadModelSourceMode.legacy);

    expect(
      container.read(chatReadModelSourceProvider),
      ChatReadModelSourceMode.legacy,
    );
  });

  test('recent chats reads from conversation graph by default', () async {
    final container = ProviderContainer(
      overrides: [
        conversationOverviewsProvider(limit: 10).overrideWith((ref) async {
          return const [
            ConversationOverview(
              conversationId: 42,
              participantHandles: ['+15551', '+15552'],
              participantCount: 2,
              isGroup: true,
              messageCount: 7,
              lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
              lastMessageText: 'hello',
            ),
          ];
        }),
        contactHandleLabelsProvider.overrideWith((ref) async {
          return const <String, ContactHandleLabel>{};
        }),
      ],
    );
    addTearDown(container.dispose);

    final summaries = await container.read(
      recentChatsProvider(limit: 10).future,
    );

    expect(summaries, hasLength(1));
    expect(summaries.single.chatId, 42);
    expect(summaries.single.title, '+15551 and +15552');
    expect(summaries.single.messageCount, 7);
    expect(summaries.single.isGroup, isTrue);
    expect(summaries.single.participants, ['+15551', '+15552']);
    expect(summaries.single.handles, ['+15551', '+15552']);
    expect(summaries.single.lastMessageDate, isNotNull);
    expect(summaries.single.lastMessagePreview, 'hello');
    expect(summaries.single.timelineData, isNull);
    expect(summaries.single.calendarHeatmapTimelineData, isNull);
  });

  test(
    'graph recent chats prefer contact labels while preserving raw handles',
    () async {
      final container = ProviderContainer(
        overrides: [
          conversationOverviewsProvider(limit: 10).overrideWith((ref) async {
            return const [
              ConversationOverview(
                conversationId: 42,
                participantHandles: [
                  'cathie.campbell@gmail.com',
                  '+17789908506',
                ],
                participantCount: 2,
                isGroup: true,
                messageCount: 7,
                lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
                lastMessageText: 'hello',
              ),
            ];
          }),
          contactHandleLabelsProvider.overrideWith((ref) async {
            return <String, ContactHandleLabel>{
              contactHandleLabelKeyForTesting(
                'cathie.campbell@gmail.com',
              ): const ContactHandleLabel(
                handle: 'cathie.campbell@gmail.com',
                displayName: 'Cathie Campbell',
              ),
            };
          }),
        ],
      );
      addTearDown(container.dispose);

      final summaries = await container.read(
        recentChatsProvider(limit: 10).future,
      );

      expect(summaries.single.title, 'Cathie Campbell and +17789908506');
      expect(summaries.single.participants, [
        'Cathie Campbell',
        '+17789908506',
      ]);
      expect(summaries.single.handles, [
        'cathie.campbell@gmail.com',
        '+17789908506',
      ]);
    },
  );

  test(
    'graph recent chats resolve phone labels across plus-one formatting',
    () async {
      final container = ProviderContainer(
        overrides: [
          conversationOverviewsProvider(limit: 10).overrideWith((ref) async {
            return const [
              ConversationOverview(
                conversationId: 42,
                participantHandles: ['+16049995969'],
                participantCount: 1,
                isGroup: false,
                messageCount: 7,
                lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
                lastMessageText: 'hello',
              ),
            ];
          }),
          contactHandleLabelsProvider.overrideWith((ref) async {
            return <String, ContactHandleLabel>{
              contactHandleLabelKeyForTesting(
                '6049995969',
              ): const ContactHandleLabel(
                handle: '6049995969',
                displayName: 'Cathie Campbell',
              ),
            };
          }),
        ],
      );
      addTearDown(container.dispose);

      final summaries = await container.read(
        recentChatsProvider(limit: 10).future,
      );

      expect(summaries.single.participants, ['Cathie Campbell']);
      expect(summaries.single.handles, ['+16049995969']);
    },
  );
}
