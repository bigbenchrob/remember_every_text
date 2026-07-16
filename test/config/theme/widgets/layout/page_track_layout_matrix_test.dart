import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/config/theme/widgets/layout/page_track_layout_matrix.dart';

void main() {
  group('CellId', () {
    test('combines ordinal Track and column identity', () {
      const a1 = CellId(
        trackId: TrackId.trackA,
        columnId: TrackColumnId.column1,
      );
      const a2 = CellId(
        trackId: TrackId.trackA,
        columnId: TrackColumnId.column2,
      );
      const c1 = CellId(
        trackId: TrackId.trackC,
        columnId: TrackColumnId.column1,
      );

      expect(a1, isNot(a2));
      expect(a1, isNot(c1));
      expect(a1.diagnosticLabel, 'A1');
      expect(a2.toString(), 'A2');
      expect(c1.toString(), 'C1');
    });

    test('supports value equality and stable hashing', () {
      const first = CellId(
        trackId: TrackId.trackD,
        columnId: TrackColumnId.column3,
      );
      const second = CellId(
        trackId: TrackId.trackD,
        columnId: TrackColumnId.column3,
      );
      final coordinates = <CellId>{first};
      coordinates.add(second);

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(coordinates, hasLength(1));
    });
  });

  group('MatrixCell', () {
    test('makes occupied and empty cells explicit', () {
      const occupied = MatrixCell<String>.occupied(
        cellId: CellId(
          trackId: TrackId.trackA,
          columnId: TrackColumnId.column1,
        ),
        occupant: 'occupant',
        alignment: TrackCellAlignment.center,
        debugLabel: 'Diagnostic only',
      );
      const empty = MatrixCell<String>.empty(
        cellId: CellId(
          trackId: TrackId.trackA,
          columnId: TrackColumnId.column2,
        ),
      );

      expect(occupied.isOccupied, isTrue);
      expect(occupied.occupant, 'occupant');
      expect(occupied.alignment, TrackCellAlignment.center);
      expect(occupied.debugLabel, 'Diagnostic only');
      expect(empty.isOccupied, isFalse);
      expect(empty.occupant, isNull);
      expect(occupied.minimumReservedHeight, 0);
      expect(empty.minimumReservedHeight, 0);
    });

    test('records reservations on empty and occupied cells', () {
      const empty = MatrixCell<String>.empty(
        cellId: CellId(
          trackId: TrackId.trackC,
          columnId: TrackColumnId.column3,
        ),
        minimumReservedHeight: 72,
      );
      const occupied = MatrixCell<String>.occupied(
        cellId: CellId(
          trackId: TrackId.trackD,
          columnId: TrackColumnId.column2,
        ),
        occupant: 'context',
        minimumReservedHeight: 18,
      );

      expect(empty.minimumReservedHeight, 72);
      expect(occupied.minimumReservedHeight, 18);
    });

    test('rejects negative or non-finite reservations', () {
      const cellId = CellId(
        trackId: TrackId.trackC,
        columnId: TrackColumnId.column3,
      );

      expect(
        () =>
            MatrixCell<String>.empty(cellId: cellId, minimumReservedHeight: -1),
        throwsAssertionError,
      );
      expect(
        () => MatrixCell<String>.occupied(
          cellId: cellId,
          occupant: 'content',
          minimumReservedHeight: double.infinity,
        ),
        throwsAssertionError,
      );
    });
  });

  group('PageTrackLayoutMatrix', () {
    test('records one explicit cell for every declared coordinate', () {
      final matrix = PageTrackLayoutMatrix<String>(
        trackIds: const [TrackId.trackA, TrackId.trackB],
        columnIds: const [TrackColumnId.column1, TrackColumnId.column2],
        cells: const [
          MatrixCell<String>.empty(
            cellId: CellId(
              trackId: TrackId.trackB,
              columnId: TrackColumnId.column2,
            ),
          ),
          MatrixCell<String>.occupied(
            cellId: CellId(
              trackId: TrackId.trackA,
              columnId: TrackColumnId.column2,
            ),
            occupant: 'A2',
          ),
          MatrixCell<String>.empty(
            cellId: CellId(
              trackId: TrackId.trackB,
              columnId: TrackColumnId.column1,
            ),
          ),
          MatrixCell<String>.occupied(
            cellId: CellId(
              trackId: TrackId.trackA,
              columnId: TrackColumnId.column1,
            ),
            occupant: 'A1',
          ),
        ],
      );

      expect(matrix.cells, hasLength(4));
      expect(
        matrix
            .cellAt(
              const CellId(
                trackId: TrackId.trackA,
                columnId: TrackColumnId.column2,
              ),
            )
            .occupant,
        'A2',
      );
      expect(matrix.cells.map((cell) => cell.cellId.diagnosticLabel), [
        'A1',
        'A2',
        'B1',
        'B2',
      ]);
    });

    test('rejects a missing matrix coordinate', () {
      expect(
        () => PageTrackLayoutMatrix<String>(
          trackIds: const [TrackId.trackA],
          columnIds: const [TrackColumnId.column1, TrackColumnId.column2],
          cells: const [
            MatrixCell<String>.empty(
              cellId: CellId(
                trackId: TrackId.trackA,
                columnId: TrackColumnId.column1,
              ),
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('rejects duplicate matrix coordinates', () {
      expect(
        () => PageTrackLayoutMatrix<String>(
          trackIds: const [TrackId.trackA],
          columnIds: const [TrackColumnId.column1],
          cells: const [
            MatrixCell<String>.empty(
              cellId: CellId(
                trackId: TrackId.trackA,
                columnId: TrackColumnId.column1,
              ),
            ),
            MatrixCell<String>.occupied(
              cellId: CellId(
                trackId: TrackId.trackA,
                columnId: TrackColumnId.column1,
              ),
              occupant: 'duplicate',
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('rejects cells outside the declared axes', () {
      expect(
        () => PageTrackLayoutMatrix<String>(
          trackIds: const [TrackId.trackA],
          columnIds: const [TrackColumnId.column1],
          cells: const [
            MatrixCell<String>.empty(
              cellId: CellId(
                trackId: TrackId.trackA,
                columnId: TrackColumnId.column2,
              ),
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('rejects duplicate or empty axes', () {
      expect(
        () => PageTrackLayoutMatrix<String>(
          trackIds: const [],
          columnIds: const [TrackColumnId.column1],
          cells: const [],
        ),
        throwsArgumentError,
      );
      expect(
        () => PageTrackLayoutMatrix<String>(
          trackIds: const [TrackId.trackA, TrackId.trackA],
          columnIds: const [TrackColumnId.column1],
          cells: const [],
        ),
        throwsArgumentError,
      );
    });
  });
}
