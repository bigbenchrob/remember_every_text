import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/features/messages/domain/entities/attachment_info.dart';
import 'package:remember_this_text/features/messages/domain/value_objects/message_timeline_scope.dart';
import 'package:remember_this_text/features/messages/infrastructure/repositories/recovered_unlinked_messages_provider.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/timeline/hydration/message_by_ordinal_provider.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/timeline/hydration/message_grouping_metadata_by_ordinal_provider.dart';

void main() {
  group('recovered timeline hydration providers', () {
    test('messageByTimelineOrdinal hydrates recovered messages', () async {
      const scope = MessageTimelineScope.recovered(
        contactId: 9,
        onlyNoHandleFromMe: true,
      );
      final container = ProviderContainer(
        overrides: [
          recoveredUnlinkedMessagesProvider(contactId: 9).overrideWith(
            (ref) => Stream<List<RecoveredUnlinkedMessageItem>>.value([
              RecoveredUnlinkedMessageItem(
                id: 10,
                guid: 'filtered-out',
                senderHandleId: 100,
                contactName: 'Ignored',
                rawItemType: null,
                rawAssociatedMessageType: null,
                semanticKind: 'plain-text',
                isSparseArtifact: false,
                isFromMe: true,
                isInferred: false,
                senderLabel: 'You',
                service: 'iMessage',
                text: 'skip me',
                sentAt: DateTime(2024, 1, 10),
                itemType: 'text',
                hasAttachments: false,
                attachmentCount: 0,
                attachments: const <AttachmentInfo>[],
              ),
              RecoveredUnlinkedMessageItem(
                id: 20,
                guid: 'retained',
                senderHandleId: null,
                contactName: null,
                rawItemType: null,
                rawAssociatedMessageType: null,
                semanticKind: 'attachment-only',
                isSparseArtifact: false,
                isFromMe: true,
                isInferred: false,
                senderLabel: 'You',
                service: 'iMessage',
                text: 'kept',
                sentAt: DateTime(2024, 2, 20),
                itemType: 'text',
                hasAttachments: true,
                attachmentCount: 1,
                attachments: const <AttachmentInfo>[
                  AttachmentInfo(
                    id: 501,
                    localPath: '~/Library/Messages/sample.heic',
                    mimeType: 'image/heic',
                    transferName: 'sample.heic',
                  ),
                ],
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        messageByTimelineOrdinalProvider(scope: scope, ordinal: 0),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      final item = await container.read(
        messageByTimelineOrdinalProvider(scope: scope, ordinal: 0).future,
      );

      expect(item, isNotNull);
      expect(item!.id, 20);
      expect(item.chatId, -20);
      expect(item.senderName, 'You');
      expect(item.attachments.single.transferName, 'sample.heic');
    });

    test(
      'messageGroupingMetadataByTimelineOrdinal synthesizes recovered metadata',
      () async {
        const scope = MessageTimelineScope.recovered(contactId: 9);
        final container = ProviderContainer(
          overrides: [
            recoveredUnlinkedMessagesProvider(contactId: 9).overrideWith(
              (ref) => Stream<List<RecoveredUnlinkedMessageItem>>.value([
                RecoveredUnlinkedMessageItem(
                  id: 30,
                  guid: 'recovered-30',
                  senderHandleId: 100,
                  contactName: 'Pat Example',
                  rawItemType: null,
                  rawAssociatedMessageType: null,
                  semanticKind: 'plain-text',
                  isSparseArtifact: false,
                  isFromMe: false,
                  isInferred: true,
                  senderLabel: '+1 555 1212',
                  service: 'SMS',
                  text: 'Recovered text',
                  sentAt: DateTime(2024, 3, 12),
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
          messageGroupingMetadataByTimelineOrdinalProvider(
            scope: scope,
            ordinal: 0,
          ),
          (_, __) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);

        final metadata = await container.read(
          messageGroupingMetadataByTimelineOrdinalProvider(
            scope: scope,
            ordinal: 0,
          ).future,
        );

        expect(metadata, isNotNull);
        expect(metadata!.chatId, -30);
        expect(metadata.senderName, 'Pat Example');
        expect(metadata.text, 'Recovered text');
      },
    );
  });
}
