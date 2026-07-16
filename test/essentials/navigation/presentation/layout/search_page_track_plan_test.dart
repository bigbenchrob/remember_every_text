import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/config/theme/widgets/layout/page_track_layout_matrix.dart';
import 'package:remember_this_text/config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import 'package:remember_this_text/essentials/navigation/presentation/layout/search_page_track_plan.dart';

void main() {
  group('Search page Track matrix', () {
    test('declares every current coordinate exactly once', () {
      final matrix = buildSearchPageTrackLayoutMatrix(
        occupants: _occupants(),
        minimumReservations: _minimumReservations(),
      );

      expect(matrix.cells, hasLength(15));
      expect(matrix.cells.map((cell) => cell.cellId.diagnosticLabel), const [
        'A1',
        'A2',
        'A3',
        'B1',
        'B2',
        'B3',
        'C1',
        'C2',
        'C3',
        'D1',
        'D2',
        'D3',
        'E1',
        'E2',
        'E3',
      ]);
      expect(_occupiedLabels(matrix), const {
        'A1': 'Search top menu',
        'A2': 'All messages title',
        'A3': 'Conversation title',
        'B2': 'Message result metadata',
        'C2': 'Message search controls',
        'D2': 'Message search supporting context',
        'E1': 'Fixed spacing',
      });
      expect(
        matrix
            .cellAt(
              const CellId(
                trackId: TrackId.trackC,
                columnId: TrackColumnId.column2,
              ),
            )
            .alignment,
        TrackCellAlignment.center,
      );
    });

    test('records optional Conversation cells without an occupant bag', () {
      final matrix = buildSearchPageTrackLayoutMatrix(
        occupants: _occupants(
          rightConversationCard: const FixedHeightTrackOccupant(height: 88),
          rightExcerptLabel: const FixedHeightTrackOccupant(height: 30),
        ),
        minimumReservations: _minimumReservations(),
      );

      expect(
        _occupiedLabels(matrix),
        containsPair('B3', 'Conversation signature card'),
      );
      expect(
        _occupiedLabels(matrix),
        containsPair('D3', 'Conversation excerpt label'),
      );
      expect(matrix.cells.where((cell) => cell.isOccupied), hasLength(9));
    });

    testWidgets('resolves Track heights from claims and reservations', (
      tester,
    ) async {
      final matrix = buildSearchPageTrackLayoutMatrix(
        occupants: _occupants(
          rightConversationCard: const FixedHeightTrackOccupant(height: 88),
          rightExcerptLabel: const FixedHeightTrackOccupant(height: 30),
        ),
        minimumReservations: _minimumReservations(),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              final presentationConstraints =
                  PresentationConstraints.fromBuildContext(
                    context,
                    availableWidth: double.infinity,
                  );
              final resolvedMatrix = ResolvedTrackLayoutMatrix.resolve(
                matrix: matrix,
                constraints: presentationConstraints,
              );
              expect(resolvedMatrix.heightFor(TrackId.trackA), 30);
              expect(resolvedMatrix.heightFor(TrackId.trackB), 88);
              expect(resolvedMatrix.heightFor(TrackId.trackC), 30);
              expect(resolvedMatrix.heightFor(TrackId.trackD), 30);
              expect(resolvedMatrix.heightFor(TrackId.trackE), 16);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    test('matrix placement does not mutate the occupant', () {
      const occupant = FixedHeightTrackOccupant(height: 88);
      final original = buildSearchPageTrackLayoutMatrix(
        occupants: _occupants(rightConversationCard: occupant),
        minimumReservations: _minimumReservations(),
      );

      expect(
        original
            .cellAt(
              const CellId(
                trackId: TrackId.trackB,
                columnId: TrackColumnId.column3,
              ),
            )
            .occupant,
        same(occupant),
      );
      expect(occupant, isA<TrackOccupant>());
    });

    testWidgets('preserves resting geometry without right-panel occupants', (
      tester,
    ) async {
      final matrix = buildSearchPageTrackLayoutMatrix(
        occupants: _occupants(),
        minimumReservations: _minimumReservations(),
      );

      await _withResolvedMatrix(tester, matrix, (resolved) {
        expect(resolved.heightFor(TrackId.trackB), 60);
        expect(resolved.heightFor(TrackId.trackC), 30);
        expect(resolved.heightFor(TrackId.trackD), 23);
        expect(
          resolved
              .cellAt(
                const CellId(
                  trackId: TrackId.trackB,
                  columnId: TrackColumnId.column3,
                ),
              )
              .claim,
          isNull,
        );
      });
    });

    testWidgets('expands beyond and returns to Search-page reservations', (
      tester,
    ) async {
      final resting = buildSearchPageTrackLayoutMatrix(
        occupants: _occupants(),
        minimumReservations: _minimumReservations(),
      );
      final minimumCard = buildSearchPageTrackLayoutMatrix(
        occupants: _occupants(
          rightConversationCard: const FixedHeightTrackOccupant(height: 50),
          rightExcerptLabel: const FixedHeightTrackOccupant(height: 12),
        ),
        minimumReservations: _minimumReservations(),
      );
      final tallCard = buildSearchPageTrackLayoutMatrix(
        occupants: _occupants(
          rightConversationCard: const FixedHeightTrackOccupant(height: 96),
          rightExcerptLabel: const FixedHeightTrackOccupant(height: 34),
        ),
        minimumReservations: _minimumReservations(),
      );

      await _withResolvedMatrix(tester, resting, (resolved) {
        expect(resolved.heightFor(TrackId.trackB), 60);
        expect(resolved.heightFor(TrackId.trackC), 30);
        expect(resolved.heightFor(TrackId.trackD), 23);
      });
      await _withResolvedMatrix(tester, minimumCard, (resolved) {
        expect(resolved.heightFor(TrackId.trackB), 60);
        expect(resolved.heightFor(TrackId.trackC), 30);
        expect(resolved.heightFor(TrackId.trackD), 23);
      });
      await _withResolvedMatrix(tester, tallCard, (resolved) {
        expect(resolved.heightFor(TrackId.trackB), 96);
        expect(resolved.heightFor(TrackId.trackC), 30);
        expect(resolved.heightFor(TrackId.trackD), 34);
      });
      await _withResolvedMatrix(tester, resting, (resolved) {
        expect(resolved.heightFor(TrackId.trackB), 60);
        expect(resolved.heightFor(TrackId.trackC), 30);
        expect(resolved.heightFor(TrackId.trackD), 23);
      });
    });
  });
}

const SearchPageTrackMinimumReservations _minimumReservationsValue =
    SearchPageTrackMinimumReservations(
      centerSupportingContext: 23,
      rightConversationCard: 60,
      rightExcerptLabel: 15,
    );

SearchPageTrackMinimumReservations _minimumReservations() {
  return _minimumReservationsValue;
}

SearchPageTrackOccupants _occupants({
  TrackOccupant? rightConversationCard,
  TrackOccupant? rightExcerptLabel,
}) {
  return SearchPageTrackOccupants(
    sidebarTopMenu: const FixedHeightTrackOccupant(height: 30),
    centerTitle: const FixedHeightTrackOccupant(height: 20),
    rightTitle: const FixedHeightTrackOccupant(height: 20),
    centerMetadata: const FixedHeightTrackOccupant(height: 14),
    centerSearchControls: const FixedHeightTrackOccupant(height: 30),
    centerSupportingContext: const FixedHeightTrackOccupant(height: 23),
    bottomSpacing: const FixedHeightTrackOccupant(height: 16),
    rightConversationCard: rightConversationCard,
    rightExcerptLabel: rightExcerptLabel,
  );
}

Map<String, String> _occupiedLabels(
  PageTrackLayoutMatrix<TrackOccupant> matrix,
) {
  return {
    for (final cell in matrix.cells)
      if (cell.isOccupied) cell.cellId.diagnosticLabel: cell.debugLabel!,
  };
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
              availableWidth: 640,
            ),
          );
          verify(resolved);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
}
