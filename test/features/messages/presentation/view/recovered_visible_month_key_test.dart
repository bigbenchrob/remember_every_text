import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/messages/domain/entities/attachment_info.dart';
import 'package:remember_this_text/features/messages/infrastructure/repositories/recovered_unlinked_messages_provider.dart';
import 'package:remember_this_text/features/messages/presentation/view/recovered_visible_month_key.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
  test('uses first visible recovered message with a non-null month', () {
    final messages = [
      _message(id: 1, sentAt: null),
      _message(id: 2, sentAt: DateTime(2024, 2, 10)),
      _message(id: 3, sentAt: DateTime(2024, 3, 5)),
    ];

    final monthKey = recoveredVisibleMonthKeyForVisiblePositions(
      positions: const [
        ItemPosition(index: 0, itemLeadingEdge: 0, itemTrailingEdge: 0.4),
        ItemPosition(index: 1, itemLeadingEdge: 0.4, itemTrailingEdge: 0.8),
      ],
      messages: messages,
    );

    expect(monthKey, '2024-02');
  });

  test('returns null when no visible recovered message has a month', () {
    final messages = [
      _message(id: 1, sentAt: null),
      _message(id: 2, sentAt: null),
    ];

    final monthKey = recoveredVisibleMonthKeyForVisiblePositions(
      positions: const [
        ItemPosition(index: 0, itemLeadingEdge: 0, itemTrailingEdge: 0.4),
        ItemPosition(index: 1, itemLeadingEdge: 0.4, itemTrailingEdge: 0.8),
      ],
      messages: messages,
    );

    expect(monthKey, isNull);
  });
}

RecoveredUnlinkedMessageItem _message({
  required int id,
  required DateTime? sentAt,
}) {
  return RecoveredUnlinkedMessageItem(
    id: id,
    guid: 'msg-$id',
    senderHandleId: null,
    semanticKind: 'plain-text',
    isSparseArtifact: false,
    isFromMe: false,
    isInferred: false,
    senderLabel: 'Sender',
    service: 'iMessage',
    text: 'text',
    sentAt: sentAt,
    itemType: 'message',
    hasAttachments: false,
    attachmentCount: 0,
    attachments: const <AttachmentInfo>[],
  );
}
