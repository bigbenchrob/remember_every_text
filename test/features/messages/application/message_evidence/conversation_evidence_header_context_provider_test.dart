import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import 'package:remember_this_text/features/contacts/feature_level_providers.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/conversation_evidence_header_context_provider.dart';

void main() {
  test(
    'resolves conversation header context through display identity',
    () async {
      final container = ProviderContainer(
        overrides: [
          conversationOverviewByIdProvider(conversationId: 42).overrideWith((
            ref,
          ) async {
            return const ConversationOverview(
              conversationId: 42,
              participantHandles: ['1 (778) 990-8506', '+15552'],
              participantCount: 2,
              isGroup: true,
              messageCount: 3,
              attachmentCount: 0,
              firstMessageAtUtc: '2026-05-18T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
              lastMessageText: 'newest',
            );
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
        ],
      );
      addTearDown(container.dispose);

      final context = await container.read(
        conversationEvidenceHeaderContextProvider(conversationId: 42).future,
      );

      expect(context?.title, 'Claire and +15552');
      expect(context?.messageCount, 3);
      expect(context?.firstMessageAtUtc, '2026-05-18T10:00:00.000Z');
      expect(context?.lastMessageAtUtc, '2026-05-20T10:00:00.000Z');
    },
  );
}
