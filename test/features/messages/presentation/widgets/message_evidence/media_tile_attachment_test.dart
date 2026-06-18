import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/retained_archive/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_evidence/media_tile_attachment.dart';

void main() {
  test('hasArchiveCompatibilityKey is false when no key is provided', () {
    const attachment = MediaTileAttachment(
      id: 1,
      localPath: null,
      mimeType: 'image/jpeg',
      transferName: 'image.jpg',
    );

    expect(attachment.hasArchiveCompatibilityKey, isFalse);
    expect(attachment.archiveCompatibilityKey, isNull);
  });

  test('archiveCompatibilityKey passes through typed key', () {
    const key = ArchiveCompatibilityKey(
      messageGuid: 'message-guid',
      importAttachmentId: 42,
    );
    const attachment = MediaTileAttachment(
      id: 1,
      localPath: null,
      mimeType: 'image/jpeg',
      transferName: 'image.jpg',
      archiveCompatibilityKey: key,
    );

    final archiveKey = attachment.archiveCompatibilityKey;

    expect(archiveKey, same(key));
  });
}
