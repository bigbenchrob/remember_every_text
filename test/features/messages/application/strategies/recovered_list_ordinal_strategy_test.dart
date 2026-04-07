import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/messages/application/strategies/recovered_list_ordinal_strategy.dart';
import 'package:remember_this_text/features/messages/domain/entities/attachment_info.dart';
import 'package:remember_this_text/features/messages/infrastructure/repositories/recovered_unlinked_messages_provider.dart';

void main() {
  group('RecoveredListOrdinalStrategy', () {
    final strategy = RecoveredListOrdinalStrategy([
      RecoveredUnlinkedMessageItem(
        id: 10,
        guid: 'recovered-10',
        senderHandleId: null,
        contactName: null,
        rawItemType: null,
        rawAssociatedMessageType: null,
        semanticKind: 'plain-text',
        isSparseArtifact: false,
        isFromMe: false,
        isInferred: false,
        senderLabel: 'A',
        service: 'iMessage',
        text: 'January',
        sentAt: DateTime(2024, 1, 15),
        itemType: 'text',
        hasAttachments: false,
        attachmentCount: 0,
        attachments: <AttachmentInfo>[],
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
        isInferred: true,
        senderLabel: 'You',
        service: 'iMessage',
        text: 'February',
        sentAt: DateTime(2024, 2, 20),
        itemType: 'text',
        hasAttachments: false,
        attachmentCount: 0,
        attachments: <AttachmentInfo>[],
      ),
      const RecoveredUnlinkedMessageItem(
        id: 30,
        guid: 'recovered-30',
        senderHandleId: null,
        contactName: null,
        rawItemType: null,
        rawAssociatedMessageType: null,
        semanticKind: 'sparse-artifact',
        isSparseArtifact: true,
        isFromMe: false,
        isInferred: false,
        senderLabel: 'Unknown',
        service: 'Unknown',
        text: 'Undated',
        sentAt: null,
        itemType: 'unknown',
        hasAttachments: false,
        attachmentCount: 0,
        attachments: <AttachmentInfo>[],
      ),
    ]);

    test(
      'derives ordinal lookups and month keys from recovered items',
      () async {
        expect(await strategy.getTotalCount(), 3);
        expect(await strategy.getMessageIdByOrdinal(1), 20);
        expect(await strategy.getMonthKeyByOrdinal(0), '2024-01');
        expect(await strategy.getMonthKeyByOrdinal(2), isNull);
        expect(await strategy.getFirstOrdinalForMonth('2024-02'), 1);
        expect(
          await strategy.getFirstOrdinalOnOrAfter(DateTime(2024, 2, 1)),
          1,
        );
        expect(await strategy.getOrdinalForMessage(30), 2);
      },
    );
  });
}
