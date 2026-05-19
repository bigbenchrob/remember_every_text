import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update_ss/domain/source_scoped_row_key.dart';

void main() {
  test('packs and unpacks source id and source rowid exactly', () {
    final packed = SourceScopedRowKey.pack(sourceId: 7, sourceRowId: 42);

    expect(SourceScopedRowKey.unpackSourceId(packed), 7);
    expect(SourceScopedRowKey.unpackSourceRowId(packed), 42);
  });

  test('keeps source-local rowids collision-free across sources', () {
    final sourceOne = SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 42);
    final sourceTwo = SourceScopedRowKey.pack(sourceId: 2, sourceRowId: 42);
    final sourceOneOtherRow = SourceScopedRowKey.pack(
      sourceId: 1,
      sourceRowId: 43,
    );

    expect(sourceOne, isNot(sourceTwo));
    expect(sourceOne, isNot(sourceOneOtherRow));
  });

  test('rejects values outside documented bounds', () {
    expect(
      () => SourceScopedRowKey.pack(sourceId: 0, sourceRowId: 1),
      throwsRangeError,
    );
    expect(
      () => SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 0),
      throwsRangeError,
    );
    expect(
      () => SourceScopedRowKey.pack(
        sourceId: SourceScopedRowKey.maxSourceId + 1,
        sourceRowId: 1,
      ),
      throwsRangeError,
    );
    expect(
      () => SourceScopedRowKey.pack(
        sourceId: 1,
        sourceRowId: SourceScopedRowKey.maxSourceRowId + 1,
      ),
      throwsRangeError,
    );
  });
}
