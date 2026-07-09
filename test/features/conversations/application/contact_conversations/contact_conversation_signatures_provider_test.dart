import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity_resolver_provider.dart';
import 'package:remember_this_text/features/conversations/application/contact_conversations/contact_conversation_signatures_provider.dart';
import 'package:remember_this_text/features/conversations/feature_level_providers.dart';

void main() {
  test(
    'resolves contact conversations into display signature models',
    () async {
      final request = ConversationSignatureDisplayByIdsRequest(
        conversationIds: const [42],
      );
      final container = ProviderContainer(
        overrides: [
          contactPageGraphSnapshotProvider(contactId: 24).overrideWith((
            ref,
          ) async {
            return const ContactGraphSnapshot(
              contactId: 24,
              conversations: [
                ConversationOverview(
                  conversationId: 42,
                  participantHandles: ['+15551'],
                  participantCount: 1,
                  isGroup: false,
                  messageCount: 5,
                  attachmentCount: 0,
                  firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
                  lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
                  lastMessageText: 'hello',
                ),
              ],
              messageActivity: null,
            );
          }),
          conversationSignatureDisplayByIdsProvider(
            request: request,
          ).overrideWith((ref) async {
            return const [
              ConversationSignatureDisplayModel(
                conversationId: 42,
                title: 'Claire',
                participantLabels: ['Claire'],
                participantCount: 1,
                isGroup: false,
                messageCount: 5,
                attachmentCount: 0,
                firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
                lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
                lastMessageText: 'hello',
                activityMonths: [],
              ),
            ];
          }),
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(identitiesByHandleKey: {});
          }),
        ],
      );
      addTearDown(container.dispose);

      final signatures = await container.read(
        contactConversationSignaturesProvider(contactId: 24).future,
      );

      expect(signatures, hasLength(1));
      expect(signatures.single.conversationId, 42);
      expect(signatures.single.title, 'Claire');
    },
  );
}
