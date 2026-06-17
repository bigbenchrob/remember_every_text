import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/identity/retained_overlay_identity_bridge.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  test(
    'retained contact id is recoverable from live address book graph id',
    () {
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: 17,
      );

      expect(retainedOverlayContactIdForGraphContactId(graphContactId), 17);
    },
  );

  test('non-address-book graph id does not produce a retained contact id', () {
    final graphContactId = SourceScopedRowKey.pack(
      sourceId: 1,
      sourceRowId: 17,
    );

    expect(retainedOverlayContactIdForGraphContactId(graphContactId), isNull);
  });
}
