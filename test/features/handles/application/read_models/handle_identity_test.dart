import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/handles/application/read_models/handle_identity.dart';

void main() {
  test(
    'canonicalHandleIdentityKey converts rowid-keyed handle ids to graph ids',
    () {
      final graphHandleId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 42,
      );

      expect(canonicalHandleIdentityKey(42), graphHandleId);
      expect(canonicalHandleIdentityKey(graphHandleId), graphHandleId);
    },
  );

  test('handleIdentityKeyVariants includes rowid-keyed and graph ids', () {
    final graphHandleId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 42,
    );

    expect(
      handleIdentityKeyVariants(42),
      containsAll(<int>[42, graphHandleId]),
    );
    expect(
      handleIdentityKeyVariants(graphHandleId),
      containsAll(<int>[42, graphHandleId]),
    );
  });

  test('overlayValueForHandleIdentity resolves either key form', () {
    final graphHandleId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 42,
    );

    expect(
      overlayValueForHandleIdentity(<int, String>{
        42: 'rowid-keyed',
      }, graphHandleId),
      'rowid-keyed',
    );
    expect(
      overlayValueForHandleIdentity(<int, String>{graphHandleId: 'graph'}, 42),
      'graph',
    );
  });
}
