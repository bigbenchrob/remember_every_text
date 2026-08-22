import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/config/theme/widgets/layout/page_track_layout_matrix.dart';
import 'package:remember_this_text/config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import 'package:remember_this_text/essentials/navigation/presentation/layout/message_history_coverage_page_track_plan.dart';

void main() {
  group('Message History Coverage page Track matrix', () {
    test('declares only the shared A1/A2 relationship', () {
      final matrix = buildMessageHistoryCoveragePageTrackLayoutMatrix(
        sidebarSettingsMenu: const FixedHeightTrackOccupant(height: 40),
        centerTitle: const FixedHeightTrackOccupant(height: 20),
      );

      expect(matrix.trackIds, const [TrackId.trackA]);
      expect(matrix.cells, hasLength(3));
      expect(
        {
          for (final cell in matrix.cells)
            if (cell.isOccupied) cell.cellId.diagnosticLabel: cell.debugLabel,
        },
        const {'A1': 'Settings menu', 'A2': 'Message History Coverage title'},
      );
      expect(
        matrix
            .cellAt(
              const CellId(
                trackId: TrackId.trackA,
                columnId: TrackColumnId.column3,
              ),
            )
            .isOccupied,
        isFalse,
      );
    });

    testWidgets('resolves A from its tallest natural occupant', (tester) async {
      final matrix = buildMessageHistoryCoveragePageTrackLayoutMatrix(
        sidebarSettingsMenu: const FixedHeightTrackOccupant(height: 40),
        centerTitle: const FixedHeightTrackOccupant(height: 20),
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
                  availableWidth: 900,
                ),
              );
              expect(resolved.heightFor(TrackId.trackA), 40);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });
}
