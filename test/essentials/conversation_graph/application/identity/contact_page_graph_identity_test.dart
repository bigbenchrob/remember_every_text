import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/identity/contact_page_graph_identity.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  group('graphContactIdForContactPage', () {
    test('packs live AddressBook source rowids into graph contact ids', () {
      expect(
        graphContactIdForContactPage(24),
        SourceScopedRowKey.pack(
          sourceId: liveAddressBookSourceId,
          sourceRowId: 24,
        ),
      );
    });

    test('preserves virtual contact ids', () {
      expect(graphContactIdForContactPage(1000000000), 1000000000);
    });
  });
}
