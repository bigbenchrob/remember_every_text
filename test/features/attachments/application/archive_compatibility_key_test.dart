import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/attachments/application/archive_compatibility_key.dart';

void main() {
  test('storageKeySegment preserves current archive compatibility shape', () {
    const key = ArchiveCompatibilityKey(
      messageGuid: 'message-guid',
      importAttachmentId: 42,
    );

    expect(key.storageKeySegment, 'message-guid::42');
  });
}
