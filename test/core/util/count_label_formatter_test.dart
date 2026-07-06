import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/core/util/count_label_formatter.dart';

void main() {
  group('CountLabelFormatter', () {
    test('formats singular message count', () {
      expect(CountLabelFormatter.messages(1), '1 message');
    });

    test('formats plural message count', () {
      expect(CountLabelFormatter.messages(2), '2 messages');
    });

    test('formats large message count with separators', () {
      expect(CountLabelFormatter.messages(56810), '56,810 messages');
    });

    test('formats recovered singular message count', () {
      expect(CountLabelFormatter.recoveredMessages(1), '1 recovered message');
    });

    test('formats app vocabulary nouns', () {
      expect(CountLabelFormatter.users(1), '1 user');
      expect(CountLabelFormatter.users(2), '2 users');
      expect(CountLabelFormatter.handles(1), '1 handle');
      expect(CountLabelFormatter.contacts(2), '2 contacts');
      expect(CountLabelFormatter.conversations(1), '1 conversation');
      expect(CountLabelFormatter.attachments(2), '2 attachments');
      expect(CountLabelFormatter.chats(1), '1 chat');
      expect(CountLabelFormatter.rows(2), '2 rows');
      expect(CountLabelFormatter.files(1), '1 file');
      expect(CountLabelFormatter.sources(2), '2 sources');
    });

    test('formats irregular nouns with explicit forms', () {
      expect(
        CountLabelFormatter.formatNoun(
          count: 2,
          singular: 'mouse',
          plural: 'mice',
        ),
        '2 mice',
      );
    });
  });
}
