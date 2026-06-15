import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import 'package:remember_this_text/features/contacts/feature_level_providers.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/contact_evidence_header_context_provider.dart';

void main() {
  test('resolves contact header context through display identity', () async {
    final container = ProviderContainer(
      overrides: [
        displayIdentityResolverProvider.overrideWith((ref) async {
          return const DisplayIdentityResolver(
            identitiesByHandleKey: {},
            identitiesByContactId: {
              24: ParticipantDisplayIdentity(
                primaryLabel: 'Claire',
                source: DisplayIdentitySource.userOverride,
                isKnownContact: true,
                contactId: 24,
              ),
            },
          );
        }),
        contactPageGraphSnapshotProvider(contactId: 24).overrideWith((
          ref,
        ) async {
          return const ContactGraphSnapshot(
            contactId: 24,
            conversations: [],
            messageActivity: ContactMessageActivity(
              firstMessageAtUtc: '2026-04-10T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
              monthCounts: [
                ContactMessageMonthCount(year: 2026, month: 4, messageCount: 2),
                ContactMessageMonthCount(year: 2026, month: 5, messageCount: 3),
              ],
            ),
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    final context = await container.read(
      contactEvidenceHeaderContextProvider(contactId: 24).future,
    );

    expect(context.contactName, 'Claire');
    expect(context.totalMessageCount, 5);
    expect(context.firstMessageAtUtc, '2026-04-10T10:00:00.000Z');
    expect(context.lastMessageAtUtc, '2026-05-20T10:00:00.000Z');
  });
}
