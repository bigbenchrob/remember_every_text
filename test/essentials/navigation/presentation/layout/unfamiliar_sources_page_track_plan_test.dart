import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/config/theme/widgets/layout/page_track_layout_matrix.dart';
import 'package:remember_this_text/config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import 'package:remember_this_text/essentials/navigation/presentation/layout/unfamiliar_sources_page_track_plan.dart';
import 'package:remember_this_text/features/messages/presentation/layout/unfamiliar_sources_message_track_occupants.dart';

void main() {
  group('Unfamiliar sources page Track matrix', () {
    test('declares the menu, four center occupants, and content seam', () {
      final matrix = buildUnfamiliarSourcesPageTrackLayoutMatrix(
        sidebarTopMenu: const FixedHeightTrackOccupant(height: 40),
        messageOccupants: _messageOccupants(),
        subjectToMetricsSpacing: const FixedHeightTrackOccupant(height: 6),
        metricsToSearchSpacing: const FixedHeightTrackOccupant(height: 8),
        searchToActionsSpacing: const FixedHeightTrackOccupant(height: 8),
        centerHeaderToEvidenceSpacing: const FixedHeightTrackOccupant(
          height: 16,
        ),
      );

      expect(matrix.cells, hasLength(27));
      expect(_occupiedLabels(matrix), const {
        'A1': 'Unfamiliar sources top menu',
        'A2': 'Unknown Sources center-panel identity',
        'B2': 'Unknown Sources selected subject',
        'C2': 'Source subject-to-metrics spacing',
        'D2': 'Source evidence metrics',
        'E2': 'Source metrics-to-search spacing',
        'F2': 'Source evidence search controls',
        'G2': 'Source search-to-actions spacing',
        'H2': 'Source triage actions',
        'I2': 'Center header-to-evidence spacing',
      });
      expect(
        matrix
            .cellAt(
              const CellId(
                trackId: TrackId.trackA,
                columnId: TrackColumnId.column2,
              ),
            )
            .alignment,
        TrackCellAlignment.center,
      );
    });

    testWidgets('resolves each row from its natural occupant requirement', (
      tester,
    ) async {
      final matrix = buildUnfamiliarSourcesPageTrackLayoutMatrix(
        sidebarTopMenu: const FixedHeightTrackOccupant(height: 40),
        messageOccupants: _messageOccupants(),
        subjectToMetricsSpacing: const FixedHeightTrackOccupant(height: 6),
        metricsToSearchSpacing: const FixedHeightTrackOccupant(height: 8),
        searchToActionsSpacing: const FixedHeightTrackOccupant(height: 8),
        centerHeaderToEvidenceSpacing: const FixedHeightTrackOccupant(
          height: 16,
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
                  availableWidth: 640,
                ),
              );
              expect(resolved.heightFor(TrackId.trackA), 40);
              expect(resolved.heightFor(TrackId.trackB), 14);
              expect(resolved.heightFor(TrackId.trackC), 6);
              expect(resolved.heightFor(TrackId.trackD), 15);
              expect(resolved.heightFor(TrackId.trackE), 8);
              expect(resolved.heightFor(TrackId.trackF), 30);
              expect(resolved.heightFor(TrackId.trackG), 8);
              expect(resolved.heightFor(TrackId.trackH), 26);
              expect(resolved.heightFor(TrackId.trackI), 16);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    test('uses truthful idle occupants without source-only spacing', () {
      final matrix = buildUnfamiliarSourcesPageTrackLayoutMatrix(
        sidebarTopMenu: const FixedHeightTrackOccupant(height: 40),
        messageOccupants: _idleMessageOccupants(),
        subjectToMetricsSpacing: const FixedHeightTrackOccupant(height: 6),
        metricsToSearchSpacing: const FixedHeightTrackOccupant(height: 8),
        searchToActionsSpacing: const FixedHeightTrackOccupant(height: 8),
        centerHeaderToEvidenceSpacing: const FixedHeightTrackOccupant(
          height: 16,
        ),
      );

      expect(_occupiedLabels(matrix), const {
        'A1': 'Unfamiliar sources top menu',
        'A2': 'Unknown Sources center-panel identity',
        'I2': 'Center header-to-evidence spacing',
      });
      for (final trackId in TrackId.values.skip(1)) {
        final sidebarCell = matrix.cellAt(
          CellId(trackId: trackId, columnId: TrackColumnId.column1),
        );
        expect(sidebarCell.isOccupied, isFalse);
        expect(sidebarCell.minimumReservedHeight, 0);
      }
    });
  });
}

UnfamiliarSourcesMessageTrackOccupants _idleMessageOccupants() {
  return const UnfamiliarSourcesMessageTrackOccupants(
    panelIdentity: FixedHeightTrackOccupant(height: 20),
  );
}

UnfamiliarSourcesMessageTrackOccupants _messageOccupants() {
  return const UnfamiliarSourcesMessageTrackOccupants(
    panelIdentity: FixedHeightTrackOccupant(height: 20),
    subject: FixedHeightTrackOccupant(height: 14),
    metrics: FixedHeightTrackOccupant(height: 15),
    searchControls: FixedHeightTrackOccupant(height: 30),
    actions: FixedHeightTrackOccupant(height: 26),
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
