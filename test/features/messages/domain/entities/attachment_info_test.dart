import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/messages/domain/entities/attachment_info.dart';

void main() {
  test('hasArchiveCompatibilityKey rejects empty message guid', () {
    const attachment = AttachmentInfo(
      id: 1,
      localPath: null,
      mimeType: 'image/jpeg',
      transferName: 'image.jpg',
      messageGuid: '',
      importAttachmentId: 42,
    );

    expect(attachment.hasArchiveCompatibilityKey, isFalse);
  });
}
