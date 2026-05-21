import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/chats/application/conversation_browser/contact_handle_label_provider.dart';

void main() {
  test('builds equivalent phone keys for local and plus-one forms', () {
    expect(
      contactHandleLabelKeysForTesting('6049995969'),
      contains('16049995969'),
    );
    expect(
      contactHandleLabelKeysForTesting('+16049995969'),
      contains('6049995969'),
    );
  });
}
