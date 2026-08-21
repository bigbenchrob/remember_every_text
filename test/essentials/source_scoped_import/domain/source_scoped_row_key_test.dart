import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  test('packs and unpacks source id and source rowid exactly', () {
    final packed = SourceScopedRowKey.pack(sourceId: 7, sourceRowId: 42);

    expect(SourceScopedRowKey.unpackSourceId(packed), 7);
    expect(SourceScopedRowKey.unpackSourceRowId(packed), 42);
  });

  test('round trips realistic and boundary rowids for every source kind', () {
    const sourceIds = <int>[1, 2, 3, SourceScopedRowKey.maxSourceId];
    const sourceRowIds = <int>[
      1,
      153403,
      8796093022207,
      SourceScopedRowKey.maxSourceRowId,
    ];

    for (final sourceId in sourceIds) {
      for (final sourceRowId in sourceRowIds) {
        final packed = SourceScopedRowKey.pack(
          sourceId: sourceId,
          sourceRowId: sourceRowId,
        );

        expect(SourceScopedRowKey.unpackSourceId(packed), sourceId);
        expect(SourceScopedRowKey.unpackSourceRowId(packed), sourceRowId);
      }
    }
  });

  test('maximum packed key remains a positive signed SQLite integer', () {
    final packed = SourceScopedRowKey.pack(
      sourceId: SourceScopedRowKey.maxSourceId,
      sourceRowId: SourceScopedRowKey.maxSourceRowId,
    );

    expect(packed, 0x7FFFFFFFFFFFFFFF);
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
