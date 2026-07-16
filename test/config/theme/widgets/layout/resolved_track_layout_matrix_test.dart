import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/config/theme/widgets/layout/page_track_layout_matrix.dart';
import 'package:remember_this_text/config/theme/widgets/layout/resolved_track_layout_matrix.dart';

void main() {
  group('ResolvedTrackLayoutMatrix', () {
    testWidgets('resolves each Track from occupied cell claims', (
      tester,
    ) async {
      final matrix = _matrix(
        a1: const FixedHeightTrackOccupant(height: 30),
        a2: const FixedHeightTrackOccupant(height: 20),
        b2: const FixedHeightTrackOccupant(height: 14),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              final resolved = ResolvedTrackLayoutMatrix.resolve(
                matrix: matrix,
                constraints: PresentationConstraints.fromBuildContext(
                  context,
                  availableWidth: 320,
                ),
              );

              expect(resolved.heightFor(TrackId.trackA), 30);
              expect(resolved.heightFor(TrackId.trackB), 14);
              expect(resolved.cellAt(_a2).claim?.naturalHeight, 20);
              expect(resolved.cellAt(_b1).isOccupied, isFalse);
              expect(resolved.cellAt(_b1).height, 14);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('TrackCellView renders occupancy and page-owned alignment', (
      tester,
    ) async {
      final matrix = _matrix(
        a1: const FixedHeightTrackOccupant(height: 30),
        a2: const TextTrackOccupant(
          text: 'All messages',
          style: TextStyle(fontSize: 10, height: 1),
        ),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              final resolved = ResolvedTrackLayoutMatrix.resolve(
                matrix: matrix,
                constraints: PresentationConstraints.fromBuildContext(
                  context,
                  availableWidth: 320,
                ),
              );
              return ResolvedTrackLayoutMatrixScope(
                matrix: resolved,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [TrackCellView(cellId: _a2)],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('All messages'), findsOneWidget);
      expect(tester.getSize(find.byType(TrackCellView)).height, 30);
      expect(tester.getTopLeft(find.text('All messages')).dy, 20);
    });

    testWidgets('TrackCellView renders an empty cell with shared geometry', (
      tester,
    ) async {
      final matrix = _matrix(
        a1: const FixedHeightTrackOccupant(height: 30),
        a2: const FixedHeightTrackOccupant(height: 20),
        b2: const FixedHeightTrackOccupant(height: 14),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              final resolved = ResolvedTrackLayoutMatrix.resolve(
                matrix: matrix,
                constraints: PresentationConstraints.fromBuildContext(
                  context,
                  availableWidth: 320,
                ),
              );
              return ResolvedTrackLayoutMatrixScope(
                matrix: resolved,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [TrackCellView(cellId: _b1)],
                ),
              );
            },
          ),
        ),
      );

      expect(tester.getSize(find.byType(TrackCellView)).height, 14);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('uses reservation when an occupant is absent', (tester) async {
      final matrix = _matrix(
        a1: const FixedHeightTrackOccupant(height: 30),
        a2: const FixedHeightTrackOccupant(height: 20),
        b1MinimumReservedHeight: 24,
      );

      await _withResolvedMatrix(tester, matrix, (resolved) {
        expect(resolved.heightFor(TrackId.trackB), 24);
        expect(resolved.cellAt(_b1).claim, isNull);
        expect(resolved.cellAt(_b1).height, 24);
        expect(resolved.cellAt(_b2).height, 24);
      });
    });

    testWidgets('uses the larger of reservation and live claim', (
      tester,
    ) async {
      for (final testCase in <({double claim, double expected})>[
        (claim: 12, expected: 24),
        (claim: 24, expected: 24),
        (claim: 36, expected: 36),
      ]) {
        final matrix = _matrix(
          a1: const FixedHeightTrackOccupant(height: 30),
          a2: const FixedHeightTrackOccupant(height: 20),
          b1MinimumReservedHeight: 24,
          b2: FixedHeightTrackOccupant(height: testCase.claim),
        );

        await _withResolvedMatrix(tester, matrix, (resolved) {
          expect(resolved.heightFor(TrackId.trackB), testCase.expected);
          expect(resolved.cellAt(_b2).claim?.naturalHeight, testCase.claim);
          expect(resolved.cellAt(_b2).alignment, TrackCellAlignment.top);
        });
      }
    });

    testWidgets('returns to reservation after live content is removed', (
      tester,
    ) async {
      final withContent = _matrix(
        a1: const FixedHeightTrackOccupant(height: 30),
        a2: const FixedHeightTrackOccupant(height: 20),
        b1MinimumReservedHeight: 24,
        b2: const FixedHeightTrackOccupant(height: 40),
      );
      final withoutContent = _matrix(
        a1: const FixedHeightTrackOccupant(height: 30),
        a2: const FixedHeightTrackOccupant(height: 20),
        b1MinimumReservedHeight: 24,
      );

      await _withResolvedMatrix(tester, withContent, (resolved) {
        expect(resolved.heightFor(TrackId.trackB), 40);
      });
      await _withResolvedMatrix(tester, withoutContent, (resolved) {
        expect(resolved.heightFor(TrackId.trackB), 24);
      });
    });
  });
}

const _a1 = CellId(trackId: TrackId.trackA, columnId: TrackColumnId.column1);
const _a2 = CellId(trackId: TrackId.trackA, columnId: TrackColumnId.column2);
const _b1 = CellId(trackId: TrackId.trackB, columnId: TrackColumnId.column1);
const _b2 = CellId(trackId: TrackId.trackB, columnId: TrackColumnId.column2);

PageTrackLayoutMatrix<TrackOccupant> _matrix({
  required TrackOccupant a1,
  required TrackOccupant a2,
  TrackOccupant? b2,
  double b1MinimumReservedHeight = 0,
}) {
  return PageTrackLayoutMatrix<TrackOccupant>(
    trackIds: const [TrackId.trackA, TrackId.trackB],
    columnIds: const [TrackColumnId.column1, TrackColumnId.column2],
    cells: [
      MatrixCell<TrackOccupant>.occupied(cellId: _a1, occupant: a1),
      MatrixCell<TrackOccupant>.occupied(
        cellId: _a2,
        occupant: a2,
        alignment: TrackCellAlignment.bottom,
      ),
      MatrixCell<TrackOccupant>.empty(
        cellId: _b1,
        minimumReservedHeight: b1MinimumReservedHeight,
      ),
      if (b2 == null)
        const MatrixCell<TrackOccupant>.empty(cellId: _b2)
      else
        MatrixCell<TrackOccupant>.occupied(cellId: _b2, occupant: b2),
    ],
  );
}

Future<void> _withResolvedMatrix(
  WidgetTester tester,
  PageTrackLayoutMatrix<TrackOccupant> matrix,
  void Function(ResolvedTrackLayoutMatrix resolved) verify,
) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Builder(
        builder: (context) {
          final resolved = ResolvedTrackLayoutMatrix.resolve(
            matrix: matrix,
            constraints: PresentationConstraints.fromBuildContext(
              context,
              availableWidth: 320,
            ),
          );
          verify(resolved);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
}
