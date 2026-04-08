import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/features/messages/application/timeline/ordinal/message_timeline_ordinal_provider.dart';
import 'package:remember_this_text/features/messages/domain/entities/attachment_info.dart';
import 'package:remember_this_text/features/messages/domain/value_objects/message_timeline_scope.dart';
import 'package:remember_this_text/features/messages/infrastructure/repositories/recovered_unlinked_messages_provider.dart';

void main() {
  group('messageTimelineOrdinalProvider', () {
    test(
      'builds recovered scope through scope-based ordinal resolution',
      () async {
        const scope = MessageTimelineScope.recovered(
          contactId: 7,
          onlyNoHandleFromMe: true,
        );
        final container = ProviderContainer(
          overrides: [
            recoveredUnlinkedMessagesProvider(contactId: 7).overrideWith(
              (ref) => Stream<List<RecoveredUnlinkedMessageItem>>.value([
                RecoveredUnlinkedMessageItem(
                  id: 10,
                  guid: 'recovered-10',
                  senderHandleId: 44,
                  contactName: 'A',
                  rawItemType: null,
                  rawAssociatedMessageType: null,
                  semanticKind: 'plain-text',
                  isSparseArtifact: false,
                  isFromMe: true,
                  isInferred: false,
                  senderLabel: 'You',
                  service: 'iMessage',
                  text: 'filtered out',
                  sentAt: DateTime(2024, 1, 10),
                  itemType: 'text',
                  hasAttachments: false,
                  attachmentCount: 0,
                  attachments: const <AttachmentInfo>[],
                ),
                RecoveredUnlinkedMessageItem(
                  id: 20,
                  guid: 'recovered-20',
                  senderHandleId: null,
                  contactName: null,
                  rawItemType: null,
                  rawAssociatedMessageType: null,
                  semanticKind: 'plain-text',
                  isSparseArtifact: false,
                  isFromMe: true,
                  isInferred: false,
                  senderLabel: 'You',
                  service: 'iMessage',
                  text: 'retained',
                  sentAt: DateTime(2024, 2, 20),
                  itemType: 'text',
                  hasAttachments: false,
                  attachmentCount: 0,
                  attachments: const <AttachmentInfo>[],
                ),
              ]),
            ),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(
          messageTimelineOrdinalProvider(scope: scope),
          (_, __) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);

        final state = await container.read(
          messageTimelineOrdinalProvider(scope: scope).future,
        );

        expect(state.totalCount, 1);
        expect(await state.strategy.getMessageIdByOrdinal(0), 20);
        expect(await state.strategy.getFirstOrdinalForMonth('2024-02'), 0);
      },
    );
  });
}
