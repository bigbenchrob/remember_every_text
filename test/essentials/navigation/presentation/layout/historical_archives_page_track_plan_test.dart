import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/config/theme/widgets/layout/page_track_layout_matrix.dart';
import 'package:remember_this_text/config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import 'package:remember_this_text/essentials/navigation/presentation/layout/historical_archives_page_track_plan.dart';

void main() {
  group('Historical Archives page Track matrix', () {
    test('declares fixed upper geometry through Track E only', () {
      final matrix = _matrix();

      expect(matrix.trackIds, historicalArchivesSharedTrackIds);
      expect(matrix.cells, hasLength(15));
      expect(_occupiedLabels(matrix), const {
        'A1': 'Historical Archives context',
        'B1': 'Historical archive source-type control',
        'C1': 'Source-type to known-folders section spacing',
        'D1': 'Known archive folders heading',
        'E1': 'Known-folders heading-to-list spacing',
      });

      for (final trackId in historicalArchivesSharedTrackIds) {
        expect(
          matrix
              .cellAt(CellId(trackId: trackId, columnId: TrackColumnId.column2))
              .isOccupied,
          isFalse,
        );
      }
    });

    testWidgets(
      'empty center cells consume the sidebar geometry before native flow',
      (tester) async {
        final matrix = _matrix();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                final resolved = ResolvedTrackLayoutMatrix.resolve(
                  matrix: matrix,
                  constraints: PresentationConstraints.fromBuildContext(
                    context,
                    availableWidth: 800,
                  ),
                );
                expect(resolved.heightFor(TrackId.trackA), 24);
                expect(resolved.heightFor(TrackId.trackB), 30);
                expect(resolved.heightFor(TrackId.trackC), 56);
                expect(resolved.heightFor(TrackId.trackD), 18);
                expect(resolved.heightFor(TrackId.trackE), 8);
                for (final trackId in historicalArchivesSharedTrackIds) {
                  expect(
                    resolved
                        .cellAt(
                          CellId(
                            trackId: trackId,
                            columnId: TrackColumnId.column2,
                          ),
                        )
                        .height,
                    resolved.heightFor(trackId),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  });
}

PageTrackLayoutMatrix<TrackOccupant> _matrix() {
  return buildHistoricalArchivesPageTrackLayoutMatrix(
    umbrella: const FixedHeightTrackOccupant(height: 24),
    sourceTypeControl: const FixedHeightTrackOccupant(height: 30),
    sourceToKnownFoldersSpacing: const FixedHeightTrackOccupant(height: 56),
    knownFoldersHeading: const FixedHeightTrackOccupant(height: 18),
    knownFoldersHeadingToListSpacing: const FixedHeightTrackOccupant(height: 8),
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
