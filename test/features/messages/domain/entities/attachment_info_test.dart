import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/features/messages/domain/entities/attachment_info.dart';

void main() {
  test('hasArchiveCompatibilityKey is false without a typed key', () {
    const attachment = AttachmentInfo(
      id: 1,
      localPath: null,
      mimeType: 'image/jpeg',
      transferName: 'image.jpg',
    );

    expect(attachment.hasArchiveCompatibilityKey, isFalse);
  });

  test('hasArchiveCompatibilityKey is true with a typed key', () {
    const attachment = AttachmentInfo(
      id: 1,
      localPath: null,
      mimeType: 'image/jpeg',
      transferName: 'image.jpg',
      archiveCompatibilityKey: ArchiveCompatibilityKey(
        messageGuid: 'message-guid',
        importAttachmentId: 42,
      ),
    );

    expect(attachment.hasArchiveCompatibilityKey, isTrue);
  });
}
