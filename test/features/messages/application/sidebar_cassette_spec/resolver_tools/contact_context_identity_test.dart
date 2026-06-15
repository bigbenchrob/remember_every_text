import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/contact_context_identity.dart';

void main() {
  group('isSameContactContext', () {
    test('matches identical contact ids', () {
      expect(isSameContactContext(24, 24), isTrue);
    });

    test('matches AddressBook row id to graph contact ss_id', () {
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: 24,
      );

      expect(isSameContactContext(24, graphContactId), isTrue);
      expect(isSameContactContext(graphContactId, 24), isTrue);
    });

    test('does not match unrelated contacts', () {
      expect(isSameContactContext(24, 25), isFalse);
    });

    test('does not match null selected contact', () {
      expect(isSameContactContext(null, 24), isFalse);
    });
  });
}
