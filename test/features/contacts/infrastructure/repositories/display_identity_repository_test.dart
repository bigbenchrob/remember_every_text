import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/contacts/infrastructure/repositories/display_identity_repository.dart';

void main() {
  test('legacy contact id is recoverable from live address book graph id', () {
    final graphContactId = SourceScopedRowKey.pack(
      sourceId: liveAddressBookSourceId,
      sourceRowId: 17,
    );

    expect(legacyContactIdForGraphContactId(graphContactId), 17);
  });

  test('non-address-book graph id does not produce a legacy contact id', () {
    final graphContactId = SourceScopedRowKey.pack(
      sourceId: 1,
      sourceRowId: 17,
    );

    expect(legacyContactIdForGraphContactId(graphContactId), isNull);
  });
}
