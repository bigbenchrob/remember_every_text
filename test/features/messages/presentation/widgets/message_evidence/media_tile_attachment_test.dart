import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_evidence/media_tile_attachment.dart';

void main() {
  test('hasArchiveCompatibilityKey rejects empty message guid', () {
    const attachment = MediaTileAttachment(
      id: 1,
      localPath: null,
      mimeType: 'image/jpeg',
      transferName: 'image.jpg',
      messageGuid: '',
      importAttachmentId: 42,
    );

    expect(attachment.hasArchiveCompatibilityKey, isFalse);
    expect(attachment.archiveCompatibilityKey, isNull);
  });

  test('archiveCompatibilityKey exposes typed key when complete', () {
    const attachment = MediaTileAttachment(
      id: 1,
      localPath: null,
      mimeType: 'image/jpeg',
      transferName: 'image.jpg',
      messageGuid: 'message-guid',
      importAttachmentId: 42,
    );

    final archiveKey = attachment.archiveCompatibilityKey;

    expect(archiveKey, isNotNull);
    expect(archiveKey!.messageGuid, 'message-guid');
    expect(archiveKey.importAttachmentId, 42);
  });
}
