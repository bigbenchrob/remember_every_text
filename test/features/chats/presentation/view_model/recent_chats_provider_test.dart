import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import 'package:remember_this_text/features/chats/presentation/view_model/recent_chats_provider.dart';
import 'package:remember_this_text/features/contacts/feature_level_providers.dart';

void main() {
  test('recent chats reads from conversation graph', () async {
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
              attachmentCount: 0,
              firstMessageAtUtc: '2026-05-18T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
              lastMessageText: 'hello',
            ),
          ];
        }),
        displayIdentityResolverProvider.overrideWith((ref) async {
          return const DisplayIdentityResolver(identitiesByHandleKey: {});
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
    expect(summaries.single.attachmentCount, 0);
    expect(summaries.single.isGroup, isTrue);
    expect(summaries.single.participants, ['+15551', '+15552']);
    expect(summaries.single.handles, ['+15551', '+15552']);
    expect(summaries.single.lastMessageDate, isNotNull);
    expect(summaries.single.lastMessagePreview, 'hello');
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
                attachmentCount: 0,
                firstMessageAtUtc: '2026-05-18T10:00:00.000Z',
                lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
                lastMessageText: 'hello',
              ),
            ];
          }),
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(
              identitiesByHandleKey: {
                'cathie.campbell@gmail.com': ParticipantDisplayIdentity(
                  primaryLabel: 'Cathie Campbell',
                  source: DisplayIdentitySource.graphContact,
                  isKnownContact: true,
                ),
              },
            );
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
    'graph recent chats use user override identity from display resolver',
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
                attachmentCount: 0,
                firstMessageAtUtc: '2026-05-18T10:00:00.000Z',
                lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
                lastMessageText: 'hello',
              ),
            ];
          }),
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(
              identitiesByHandleKey: {
                'cathie.campbell@gmail.com': ParticipantDisplayIdentity(
                  primaryLabel: 'Cathie',
                  source: DisplayIdentitySource.userOverride,
                  isKnownContact: true,
                ),
                '17789908506': ParticipantDisplayIdentity(
                  primaryLabel: 'Claire',
                  source: DisplayIdentitySource.userOverride,
                  isKnownContact: true,
                ),
              },
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      final summaries = await container.read(
        recentChatsProvider(limit: 10).future,
      );

      expect(summaries.single.title, 'Cathie and Claire');
      expect(summaries.single.participants, ['Cathie', 'Claire']);
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
                attachmentCount: 0,
                firstMessageAtUtc: '2026-05-18T10:00:00.000Z',
                lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
                lastMessageText: 'hello',
              ),
            ];
          }),
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(
              identitiesByHandleKey: {
                '6049995969': ParticipantDisplayIdentity(
                  primaryLabel: 'Cathie Campbell',
                  source: DisplayIdentitySource.graphContact,
                  isKnownContact: true,
                ),
              },
            );
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
