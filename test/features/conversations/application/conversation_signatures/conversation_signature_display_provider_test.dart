import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_signatures/conversation_signature.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_signatures/conversation_signature_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_signatures/conversation_signature_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_repository.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity_resolver_provider.dart';
import 'package:remember_this_text/features/conversations/application/conversation_signatures/conversation_signature_display_provider.dart';
import 'package:remember_this_text/features/conversations/application/conversation_tags/conversation_tag_repository.dart';
import 'package:remember_this_text/features/conversations/application/conversation_tags/conversation_tag_repository_provider.dart';
import 'package:remember_this_text/features/conversations/domain/conversation_tags/conversation_tag_display.dart';

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
        displayIdentityResolverProvider.overrideWith((ref) async {
          return const DisplayIdentityResolver(
            identitiesByHandleKey: {
              '16049995969': ParticipantDisplayIdentity(
                primaryLabel: 'Cathie',
                source: DisplayIdentitySource.userOverride,
                isKnownContact: true,
              ),
            },
          );
        }),
        conversationTagRepositoryProvider.overrideWith((ref) async {
          return const _FakeConversationTagRepository();
        }),
      ],
    );
    addTearDown(container.dispose);

    final signatures = await container.read(
      conversationSignatureDisplayProvider().future,
    );

    expect(signatures, hasLength(1));
    expect(signatures.single.title, 'Cathie and +17789908506');
    expect(signatures.single.chatHookLabel, isNull);
    expect(signatures.single.participantLabels, ['Cathie', '+17789908506']);
    expect(signatures.single.activityMonths.single.messageCount, 12);
  });

  test('adds secondary chat hook for resolved one-to-one contacts', () async {
    final container = ProviderContainer(
      overrides: [
        conversationSignaturesProvider(limit: 500).overrideWith((ref) async {
          return const [
            ConversationSignature(
              conversationId: 42,
              title: '+16045550101',
              participantLabels: ['+16045550101'],
              participantCount: 1,
              isGroup: false,
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
        displayIdentityResolverProvider.overrideWith((ref) async {
          return const DisplayIdentityResolver(
            identitiesByHandleKey: {
              '6045550101': ParticipantDisplayIdentity(
                primaryLabel: 'Claire',
                source: DisplayIdentitySource.userOverride,
                isKnownContact: true,
              ),
            },
          );
        }),
        conversationTagRepositoryProvider.overrideWith((ref) async {
          return const _FakeConversationTagRepository();
        }),
      ],
    );
    addTearDown(container.dispose);

    final signatures = await container.read(
      conversationSignatureDisplayProvider().future,
    );

    expect(signatures.single.title, 'Claire');
    expect(signatures.single.chatHookLabel, '(604) 555-0101');
    expect(conversationSignatureIdsWithDuplicateChatHooks(signatures), isEmpty);
  });

  test(
    'self-only signature is titled self without exposing its chat hook',
    () async {
      final container = ProviderContainer(
        overrides: [
          conversationSignaturesProvider(limit: 500).overrideWith((ref) async {
            return const [
              ConversationSignature(
                conversationId: 42,
                title: '+16046858506',
                participantLabels: ['+16046858506'],
                participantCount: 1,
                isGroup: false,
                isSelfConversation: true,
                messageCount: 12,
                attachmentCount: 1,
                firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
                lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
                lastMessageText: 'remember this',
                activityMonths: [],
              ),
            ];
          }),
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(
              identitiesByHandleKey: {
                '16046858506': ParticipantDisplayIdentity(
                  primaryLabel: selfParticipantDisplayLabel,
                  source: DisplayIdentitySource.localAccount,
                  isKnownContact: true,
                ),
              },
            );
          }),
          conversationTagRepositoryProvider.overrideWith((ref) async {
            return const _FakeConversationTagRepository();
          }),
        ],
      );
      addTearDown(container.dispose);

      final signatures = await container.read(
        conversationSignatureDisplayProvider().future,
      );

      expect(signatures.single.title, 'self');
      expect(signatures.single.participantLabels, ['Me']);
      expect(signatures.single.chatHookLabel, isNull);
      expect(signatures.single.isSelfConversation, isTrue);
    },
  );

  test('marks only duplicate one-to-one display identities for chat hooks', () {
    const signatures = [
      ConversationSignatureDisplayModel(
        conversationId: 1,
        title: 'Rusung',
        chatHookLabel: 'rusung@icloud.com',
        participantLabels: ['Rusung'],
        participantCount: 1,
        isGroup: false,
        messageCount: 10,
        attachmentCount: 0,
        firstMessageAtUtc: null,
        lastMessageAtUtc: null,
        lastMessageText: null,
        activityMonths: [],
      ),
      ConversationSignatureDisplayModel(
        conversationId: 2,
        title: 'Rusung',
        chatHookLabel: '+1 503-776-0150',
        participantLabels: ['Rusung'],
        participantCount: 1,
        isGroup: false,
        messageCount: 10,
        attachmentCount: 0,
        firstMessageAtUtc: null,
        lastMessageAtUtc: null,
        lastMessageText: null,
        activityMonths: [],
      ),
      ConversationSignatureDisplayModel(
        conversationId: 3,
        title: 'Claire',
        chatHookLabel: 'claire@example.com',
        participantLabels: ['Claire'],
        participantCount: 1,
        isGroup: false,
        messageCount: 10,
        attachmentCount: 0,
        firstMessageAtUtc: null,
        lastMessageAtUtc: null,
        lastMessageText: null,
        activityMonths: [],
      ),
      ConversationSignatureDisplayModel(
        conversationId: 4,
        title: 'Rusung and Claire',
        chatHookLabel: 'ignored@example.com',
        participantLabels: ['Rusung', 'Claire'],
        participantCount: 2,
        isGroup: true,
        messageCount: 10,
        attachmentCount: 0,
        firstMessageAtUtc: null,
        lastMessageAtUtc: null,
        lastMessageText: null,
        activityMonths: [],
      ),
    ];

    expect(conversationSignatureIdsWithDuplicateChatHooks(signatures), {1, 2});
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
        displayIdentityResolverProvider.overrideWith((ref) async {
          return const DisplayIdentityResolver(identitiesByHandleKey: {});
        }),
        conversationTagRepositoryProvider.overrideWith((ref) async {
          return const _FakeConversationTagRepository();
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
        sort: ConversationSignatureSort.mostRecentlyUpdated,
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
    'filters conversations by selected tag tokens using AND semantics',
    () async {
      final container = ProviderContainer(
        overrides: [
          conversationSignaturesProvider(limit: 500).overrideWith((ref) async {
            return const [
              ConversationSignature(
                conversationId: 1,
                title: 'family',
                participantLabels: ['+15551'],
                participantCount: 1,
                isGroup: false,
                messageCount: 20,
                attachmentCount: 0,
                firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
                lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
                lastMessageText: 'hello',
                activityMonths: [],
              ),
              ConversationSignature(
                conversationId: 2,
                title: 'family estate',
                participantLabels: ['+15552'],
                participantCount: 1,
                isGroup: false,
                messageCount: 30,
                attachmentCount: 0,
                firstMessageAtUtc: '2026-04-01T10:00:00.000Z',
                lastMessageAtUtc: '2026-05-21T10:00:00.000Z',
                lastMessageText: 'paperwork',
                activityMonths: [],
              ),
              ConversationSignature(
                conversationId: 3,
                title: 'estate only',
                participantLabels: ['+15553'],
                participantCount: 1,
                isGroup: false,
                messageCount: 40,
                attachmentCount: 0,
                firstMessageAtUtc: '2026-03-01T10:00:00.000Z',
                lastMessageAtUtc: '2026-05-22T10:00:00.000Z',
                lastMessageText: 'terms',
                activityMonths: [],
              ),
            ];
          }),
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(identitiesByHandleKey: {});
          }),
          conversationTagRepositoryProvider.overrideWith((ref) async {
            return const _FakeConversationTagRepository(
              tagsByConversationId: {
                1: [
                  ConversationTagDisplay(
                    id: 10,
                    displayName: 'Family',
                    normalizedName: 'family',
                  ),
                ],
                2: [
                  ConversationTagDisplay(
                    id: 10,
                    displayName: 'Family',
                    normalizedName: 'family',
                  ),
                  ConversationTagDisplay(
                    id: 11,
                    displayName: 'Estate',
                    normalizedName: 'estate',
                  ),
                ],
                3: [
                  ConversationTagDisplay(
                    id: 11,
                    displayName: 'Estate',
                    normalizedName: 'estate',
                  ),
                ],
              },
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      final familyMatches = await container.read(
        conversationSignatureDisplayProvider(
          selectedTags: ConversationSignatureSelectedTagsRequest(
            tagIds: const [10],
          ),
        ).future,
      );
      expect(familyMatches.map((signature) => signature.conversationId), [
        2,
        1,
      ]);

      final familyEstateMatches = await container.read(
        conversationSignatureDisplayProvider(
          selectedTags: ConversationSignatureSelectedTagsRequest(
            tagIds: const [10, 11],
          ),
        ).future,
      );
      expect(familyEstateMatches.map((signature) => signature.conversationId), [
        2,
      ]);
    },
  );

  test(
    'suppresses tagged conversations from default browse but not explicit tag retrieval',
    () async {
      final container = ProviderContainer(
        overrides: [
          conversationSignaturesProvider(limit: 500).overrideWith((ref) async {
            return const [
              ConversationSignature(
                conversationId: 1,
                title: 'family',
                participantLabels: ['+15551'],
                participantCount: 1,
                isGroup: false,
                messageCount: 20,
                attachmentCount: 0,
                firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
                lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
                lastMessageText: 'hello',
                activityMonths: [],
              ),
              ConversationSignature(
                conversationId: 2,
                title: '2fa',
                participantLabels: ['+15552'],
                participantCount: 1,
                isGroup: false,
                messageCount: 30,
                attachmentCount: 0,
                firstMessageAtUtc: '2026-04-01T10:00:00.000Z',
                lastMessageAtUtc: '2026-05-21T10:00:00.000Z',
                lastMessageText: 'code',
                activityMonths: [],
              ),
            ];
          }),
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(identitiesByHandleKey: {});
          }),
          conversationTagRepositoryProvider.overrideWith((ref) async {
            return const _FakeConversationTagRepository(
              tagsByConversationId: {
                2: [
                  ConversationTagDisplay(
                    id: 20,
                    displayName: '2FA',
                    normalizedName: '2fa',
                    visibilityPolicy:
                        ConversationTagVisibilityPolicy.suppressFromBrowse,
                  ),
                ],
              },
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      final defaultBrowse = await container.read(
        conversationSignatureDisplayProvider().future,
      );
      expect(defaultBrowse.map((signature) => signature.conversationId), [1]);

      final explicitRetrieval = await container.read(
        conversationSignatureDisplayProvider(
          selectedTags: ConversationSignatureSelectedTagsRequest(
            tagIds: const [20],
          ),
        ).future,
      );
      expect(explicitRetrieval.map((signature) => signature.conversationId), [
        2,
      ]);
    },
  );

  test('applies revised conversation sort semantics', () async {
    final container = ProviderContainer(
      overrides: [
        conversationSignaturesProvider(limit: 500).overrideWith((ref) async {
          return const [
            ConversationSignature(
              conversationId: 1,
              title: 'recent short',
              participantLabels: ['+15551'],
              participantCount: 1,
              isGroup: false,
              messageCount: 20,
              attachmentCount: 0,
              firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
              lastMessageText: 'recent',
              activityMonths: [],
            ),
            ConversationSignature(
              conversationId: 2,
              title: 'long large',
              participantLabels: ['+15552'],
              participantCount: 1,
              isGroup: false,
              messageCount: 1500,
              attachmentCount: 0,
              firstMessageAtUtc: '2024-01-01T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-19T10:00:00.000Z',
              lastMessageText: 'long',
              activityMonths: [],
            ),
            ConversationSignature(
              conversationId: 3,
              title: 'old dormant',
              participantLabels: ['+15553'],
              participantCount: 1,
              isGroup: false,
              messageCount: 800,
              attachmentCount: 0,
              firstMessageAtUtc: '2025-01-01T10:00:00.000Z',
              lastMessageAtUtc: '2025-01-02T10:00:00.000Z',
              lastMessageText: 'old',
              activityMonths: [],
            ),
          ];
        }),
        displayIdentityResolverProvider.overrideWith((ref) async {
          return const DisplayIdentityResolver(identitiesByHandleKey: {});
        }),
        conversationTagRepositoryProvider.overrideWith((ref) async {
          return const _FakeConversationTagRepository();
        }),
      ],
    );
    addTearDown(container.dispose);

    Future<List<int>> orderFor(ConversationSignatureSort sort) async {
      final signatures = await container.read(
        conversationSignatureDisplayProvider(sort: sort).future,
      );
      return signatures.map((signature) => signature.conversationId).toList();
    }

    expect(await orderFor(ConversationSignatureSort.mostRecentlyUpdated), [
      1,
      2,
      3,
    ]);
    expect(await orderFor(ConversationSignatureSort.mostTotalMessages), [
      2,
      3,
      1,
    ]);
    expect(await orderFor(ConversationSignatureSort.byDateOfCreation), [
      2,
      3,
      1,
    ]);
    expect(await orderFor(ConversationSignatureSort.startedMostRecently), [
      1,
      3,
      2,
    ]);
    expect(await orderFor(ConversationSignatureSort.longestRunning), [2, 1, 3]);
    expect(await orderFor(ConversationSignatureSort.dormant), [3, 2, 1]);
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
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(identitiesByHandleKey: {});
          }),
          conversationTagRepositoryProvider.overrideWith((ref) async {
            return const _FakeConversationTagRepository(
              tagsByConversationId: {
                2: [
                  ConversationTagDisplay(
                    id: 9,
                    displayName: 'Family',
                    normalizedName: 'family',
                  ),
                ],
              },
            );
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
      expect(signatures.first.tags.map((tag) => tag.displayName), ['Family']);
    },
  );
}

class _FakeConversationTagRepository implements ConversationTagRepository {
  const _FakeConversationTagRepository({
    this.tagsByConversationId = const <int, List<ConversationTagDisplay>>{},
  });

  final Map<int, List<ConversationTagDisplay>> tagsByConversationId;

  @override
  Future<List<ConversationTagDisplay>> readAllTags() async {
    return const <ConversationTagDisplay>[];
  }

  @override
  Future<Map<int, List<ConversationTagDisplay>>> readTagsByConversationIds(
    Iterable<int> conversationIds,
  ) async {
    return {
      for (final conversationId in conversationIds)
        conversationId:
            tagsByConversationId[conversationId] ??
            const <ConversationTagDisplay>[],
    };
  }

  @override
  Future<ConversationTagDisplay> createTag(String rawName) {
    throw UnimplementedError();
  }

  @override
  Future<ConversationTagDisplay> createAndAssignTag({
    required int conversationId,
    required String rawName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> assignTag({required int conversationId, required int tagId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeTag({required int conversationId, required int tagId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> setTagVisibilityPolicy({
    required int tagId,
    required ConversationTagVisibilityPolicy visibilityPolicy,
  }) {
    throw UnimplementedError();
  }
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
  Future<List<ConversationMessageTimelineEntry>> readMessageTimeline({
    required int conversationId,
  }) async {
    return const <ConversationMessageTimelineEntry>[];
  }

  @override
  Future<ConversationMessage?> readMessageById({
    required int conversationId,
    required int messageId,
  }) async {
    return null;
  }

  @override
  Future<List<int>> readMessageIdsMatchingText({
    required int conversationId,
    required String query,
    bool matchAnyTerm = false,
  }) async {
    return const <int>[];
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
