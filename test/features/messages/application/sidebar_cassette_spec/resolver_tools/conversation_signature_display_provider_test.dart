import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_signatures/conversation_signature.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_signatures/conversation_signature_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_signatures/conversation_signature_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_repository.dart';
import 'package:remember_this_text/features/chats/application/conversation_browser/contact_handle_label_provider.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/conversation_signature_display_provider.dart';

void main() {
  test('resolves participant labels before sidebar rendering', () async {
    final container = ProviderContainer(
      overrides: [
        conversationSignaturesProvider(limit: 500).overrideWith((ref) async {
          return const [
            ConversationSignature(
              conversationId: 42,
              title: '+16049995969 and +17789908506',
              participantLabels: ['+16049995969', '+17789908506'],
              participantCount: 2,
              isGroup: true,
              messageCount: 12,
              attachmentCount: 1,
              firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
              lastMessageText: 'hello',
              activityMonths: [
                ConversationSignatureMonth(
                  year: 2026,
                  month: 5,
                  messageCount: 12,
                ),
              ],
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

    final signatures = await container.read(
      conversationSignatureDisplayProvider().future,
    );

    expect(signatures, hasLength(1));
    expect(signatures.single.title, 'Cathie Campbell and +17789908506');
    expect(signatures.single.participantLabels, [
      'Cathie Campbell',
      '+17789908506',
    ]);
    expect(signatures.single.activityMonths.single.messageCount, 12);
  });

  test('applies sidebar search filter and sort semantics', () async {
    final container = ProviderContainer(
      overrides: [
        conversationSignaturesProvider(limit: 500).overrideWith((ref) async {
          return const [
            ConversationSignature(
              conversationId: 1,
              title: '+15551',
              participantLabels: ['+15551'],
              participantCount: 1,
              isGroup: false,
              messageCount: 20,
              attachmentCount: 0,
              firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
              lastMessageText: 'hello',
              activityMonths: [
                ConversationSignatureMonth(
                  year: 2026,
                  month: 5,
                  messageCount: 20,
                ),
              ],
            ),
            ConversationSignature(
              conversationId: 2,
              title: '+15552 and +15553',
              participantLabels: ['+15552', '+15553'],
              participantCount: 2,
              isGroup: true,
              messageCount: 1500,
              attachmentCount: 0,
              firstMessageAtUtc: '2024-01-01T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-19T10:00:00.000Z',
              lastMessageText: 'settlement terms',
              activityMonths: [
                ConversationSignatureMonth(
                  year: 2026,
                  month: 2,
                  messageCount: 12,
                ),
                ConversationSignatureMonth(
                  year: 2026,
                  month: 3,
                  messageCount: 18,
                ),
              ],
            ),
            ConversationSignature(
              conversationId: 3,
              title: '+15554 and +15555',
              participantLabels: ['+15554', '+15555'],
              participantCount: 2,
              isGroup: true,
              messageCount: 800,
              attachmentCount: 0,
              firstMessageAtUtc: '2025-01-01T10:00:00.000Z',
              lastMessageAtUtc: '2025-01-02T10:00:00.000Z',
              lastMessageText: 'quiet',
              activityMonths: [
                ConversationSignatureMonth(
                  year: 2025,
                  month: 1,
                  messageCount: 20,
                ),
              ],
            ),
          ];
        }),
        contactHandleLabelsProvider.overrideWith((ref) async {
          return const <String, ContactHandleLabel>{};
        }),
      ],
    );
    addTearDown(container.dispose);

    final searchMatches = await container.read(
      conversationSignatureDisplayProvider(searchQuery: 'settlement').future,
    );
    expect(searchMatches.map((signature) => signature.conversationId), [2]);

    final groupMatches = await container.read(
      conversationSignatureDisplayProvider(
        filter: ConversationSignatureFilter.groups,
        sort: ConversationSignatureSort.mostActiveRecently,
      ).future,
    );
    expect(groupMatches.map((signature) => signature.conversationId), [2, 3]);

    final highActivityMatches = await container.read(
      conversationSignatureDisplayProvider(
        filter: ConversationSignatureFilter.highActivity,
      ).future,
    );
    expect(highActivityMatches.map((signature) => signature.conversationId), [
      2,
    ]);

    final nonFavouriteMatches = await container.read(
      conversationSignatureDisplayProvider(
        excludedFavouriteConversationIds: const [2],
      ).future,
    );
    expect(nonFavouriteMatches.map((signature) => signature.conversationId), [
      1,
      3,
    ]);
  });

  test(
    'reads display models for explicit conversation ids in caller order',
    () async {
      const repository = _FakeConversationRepository(
        overviewsById: {
          1: ConversationOverview(
            conversationId: 1,
            participantHandles: ['+15551'],
            participantCount: 1,
            isGroup: false,
            messageCount: 20,
            attachmentCount: 0,
            firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
            lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
            lastMessageText: 'first',
          ),
          2: ConversationOverview(
            conversationId: 2,
            participantHandles: ['+15552', '+15553'],
            participantCount: 2,
            isGroup: true,
            messageCount: 30,
            attachmentCount: 1,
            firstMessageAtUtc: '2026-04-01T10:00:00.000Z',
            lastMessageAtUtc: '2026-05-21T10:00:00.000Z',
            lastMessageText: 'second',
          ),
        },
        activityTracesById: {
          1: ConversationActivityTrace(
            conversationId: 1,
            months: [
              ConversationActivityMonth(year: 2026, month: 5, messageCount: 20),
            ],
          ),
          2: ConversationActivityTrace(
            conversationId: 2,
            months: [
              ConversationActivityMonth(year: 2026, month: 4, messageCount: 10),
              ConversationActivityMonth(year: 2026, month: 5, messageCount: 20),
            ],
          ),
        },
      );
      final container = ProviderContainer(
        overrides: [
          conversationSignatureReaderProvider.overrideWith((ref) async {
            return const ConversationSignatureReader(
              reader: ConversationReader(repository: repository),
            );
          }),
          contactHandleLabelsProvider.overrideWith((ref) async {
            return const <String, ContactHandleLabel>{};
          }),
        ],
      );
      addTearDown(container.dispose);

      final signatures = await container.read(
        conversationSignatureDisplayByIdsProvider(
          request: ConversationSignatureDisplayByIdsRequest(
            conversationIds: const [2, 1],
          ),
        ).future,
      );

      expect(signatures.map((signature) => signature.conversationId), [2, 1]);
      expect(
        signatures.first.activityMonths.map((month) => month.messageCount),
        [10, 20],
      );
      expect(signatures.first.title, '+15552 and +15553');
    },
  );
}

class _FakeConversationRepository implements ConversationRepository {
  const _FakeConversationRepository({
    required this.overviewsById,
    required this.activityTracesById,
  });

  final Map<int, ConversationOverview> overviewsById;
  final Map<int, ConversationActivityTrace> activityTracesById;

  @override
  Future<List<ConversationOverview>> readOverviews({int limit = 100}) async {
    return overviewsById.values.take(limit).toList();
  }

  @override
  Future<List<ConversationOverview>> readOverviewsByIds({
    required List<int> conversationIds,
  }) async {
    return [
      for (final conversationId in conversationIds)
        if (overviewsById[conversationId] != null)
          overviewsById[conversationId]!,
    ];
  }

  @override
  Future<Map<int, ConversationActivityTrace>> readActivityTraces({
    required List<int> conversationIds,
  }) async {
    return {
      for (final conversationId in conversationIds)
        if (activityTracesById[conversationId] != null)
          conversationId: activityTracesById[conversationId]!,
    };
  }

  @override
  Future<List<ConversationMessage>> readMessages({
    required int conversationId,
    int limit = 100,
  }) async {
    return const <ConversationMessage>[];
  }

  @override
  Future<Map<int, ConversationMessageTextMatch>>
  readConversationMessageTextMatches({
    required String query,
    int limit = 500,
    int snippetsPerConversation = 3,
  }) async {
    return const <int, ConversationMessageTextMatch>{};
  }
}
