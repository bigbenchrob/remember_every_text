import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../config/theme/widgets/layout/page_track_layout_matrix.dart';
import '../../../../config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import '../../../../features/messages/presentation/layout/unfamiliar_sources_message_track_occupants.dart';
import '../../../../features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/top_chat_menu_widget.dart';
import '../../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../domain/sidebar_mode.dart';

const _unfamiliarSourcesPageTrackIds = [
  TrackId.trackA,
  TrackId.trackB,
  TrackId.trackC,
  TrackId.trackD,
  TrackId.trackE,
  TrackId.trackF,
  TrackId.trackG,
  TrackId.trackH,
  TrackId.trackI,
];

/// One resolved unfamiliar-sources page composition.
///
/// Navigation owns this matrix and its placement. `MacosAppShell` prepares the
/// page inputs and invokes composition. Messages supplies the complete
/// center-panel handle-lens occupants; Handles supplies the source facts and
/// review actions consumed by that presentation.
final class UnfamiliarSourcesPageTrackComposition {
  const UnfamiliarSourcesPageTrackComposition({
    required this.matrix,
    required this.resolvedMatrix,
  });

  final PageTrackLayoutMatrix<TrackOccupant> matrix;
  final ResolvedTrackLayoutMatrix resolvedMatrix;
}

UnfamiliarSourcesPageTrackComposition composeUnfamiliarSourcesPageTrackLayout({
  required PresentationConstraints presentationConstraints,
  required ThemeTypography typography,
  required UnfamiliarSourcesMessageTrackOccupants? messageOccupants,
}) {
  final matrix = buildUnfamiliarSourcesPageTrackLayoutMatrix(
    sidebarTopMenu: TopMenuTrackOccupant(
      currentChoice: TopChatMenuChoice.strayHandles,
      cassetteIndex: 0,
      sidebarMode: SidebarMode.messages,
      selectedValueStyle: typography.controlValue,
    ),
    messageOccupants: messageOccupants,
    subjectToMetricsSpacing: const FixedHeightTrackOccupant(height: 6),
    metricsToSearchSpacing: const FixedHeightTrackOccupant(height: 8),
    searchToActionsSpacing: const FixedHeightTrackOccupant(height: 8),
    centerHeaderToEvidenceSpacing: const FixedHeightTrackOccupant(height: 16),
  );
  return UnfamiliarSourcesPageTrackComposition(
    matrix: matrix,
    resolvedMatrix: ResolvedTrackLayoutMatrix.resolve(
      matrix: matrix,
      constraints: presentationConstraints,
    ),
  );
}

/// Declares every unfamiliar-sources page Track coordinate exactly once.
PageTrackLayoutMatrix<TrackOccupant>
buildUnfamiliarSourcesPageTrackLayoutMatrix({
  required TrackOccupant sidebarTopMenu,
  required UnfamiliarSourcesMessageTrackOccupants? messageOccupants,
  required TrackOccupant subjectToMetricsSpacing,
  required TrackOccupant metricsToSearchSpacing,
  required TrackOccupant searchToActionsSpacing,
  required TrackOccupant centerHeaderToEvidenceSpacing,
}) {
  return PageTrackLayoutMatrix<TrackOccupant>(
    trackIds: _unfamiliarSourcesPageTrackIds,
    columnIds: TrackColumnId.values,
    cells: [
      _occupied(
        trackId: TrackId.trackA,
        columnId: TrackColumnId.column1,
        occupant: sidebarTopMenu,
        alignment: TrackCellAlignment.center,
        debugLabel: 'Unfamiliar sources top menu',
      ),
      _optional(
        trackId: TrackId.trackA,
        columnId: TrackColumnId.column2,
        occupant: messageOccupants?.panelIdentity,
        alignment: TrackCellAlignment.center,
        debugLabel: 'Unknown Sources center-panel identity',
      ),
      _empty(trackId: TrackId.trackA, columnId: TrackColumnId.column3),
      _empty(trackId: TrackId.trackB, columnId: TrackColumnId.column1),
      _optional(
        trackId: TrackId.trackB,
        columnId: TrackColumnId.column2,
        occupant: messageOccupants?.subject,
        debugLabel: 'Unknown Sources selected subject',
      ),
      _empty(trackId: TrackId.trackB, columnId: TrackColumnId.column3),
      _empty(trackId: TrackId.trackC, columnId: TrackColumnId.column1),
      _optional(
        trackId: TrackId.trackC,
        columnId: TrackColumnId.column2,
        occupant:
            messageOccupants?.subject == null ||
                messageOccupants?.metrics == null
            ? null
            : subjectToMetricsSpacing,
        debugLabel: 'Source subject-to-metrics spacing',
      ),
      _empty(trackId: TrackId.trackC, columnId: TrackColumnId.column3),
      _empty(trackId: TrackId.trackD, columnId: TrackColumnId.column1),
      _optional(
        trackId: TrackId.trackD,
        columnId: TrackColumnId.column2,
        occupant: messageOccupants?.metrics,
        debugLabel: 'Source evidence metrics',
      ),
      _empty(trackId: TrackId.trackD, columnId: TrackColumnId.column3),
      _empty(trackId: TrackId.trackE, columnId: TrackColumnId.column1),
      _optional(
        trackId: TrackId.trackE,
        columnId: TrackColumnId.column2,
        occupant:
            messageOccupants?.metrics == null ||
                messageOccupants?.searchControls == null
            ? null
            : metricsToSearchSpacing,
        debugLabel: 'Source metrics-to-search spacing',
      ),
      _empty(trackId: TrackId.trackE, columnId: TrackColumnId.column3),
      _empty(trackId: TrackId.trackF, columnId: TrackColumnId.column1),
      _optional(
        trackId: TrackId.trackF,
        columnId: TrackColumnId.column2,
        occupant: messageOccupants?.searchControls,
        alignment: TrackCellAlignment.center,
        debugLabel: 'Source evidence search controls',
      ),
      _empty(trackId: TrackId.trackF, columnId: TrackColumnId.column3),
      _empty(trackId: TrackId.trackG, columnId: TrackColumnId.column1),
      _optional(
        trackId: TrackId.trackG,
        columnId: TrackColumnId.column2,
        occupant:
            messageOccupants?.searchControls == null ||
                messageOccupants?.actions == null
            ? null
            : searchToActionsSpacing,
        debugLabel: 'Source search-to-actions spacing',
      ),
      _empty(trackId: TrackId.trackG, columnId: TrackColumnId.column3),
      _empty(trackId: TrackId.trackH, columnId: TrackColumnId.column1),
      _optional(
        trackId: TrackId.trackH,
        columnId: TrackColumnId.column2,
        occupant: messageOccupants?.actions,
        debugLabel: 'Source triage actions',
      ),
      _empty(trackId: TrackId.trackH, columnId: TrackColumnId.column3),
      _empty(trackId: TrackId.trackI, columnId: TrackColumnId.column1),
      _occupied(
        trackId: TrackId.trackI,
        columnId: TrackColumnId.column2,
        occupant: centerHeaderToEvidenceSpacing,
        debugLabel: 'Center header-to-evidence spacing',
      ),
      _empty(trackId: TrackId.trackI, columnId: TrackColumnId.column3),
    ],
  );
}

MatrixCell<TrackOccupant> _occupied({
  required TrackId trackId,
  required TrackColumnId columnId,
  required TrackOccupant occupant,
  TrackCellAlignment alignment = TrackCellAlignment.top,
  String? debugLabel,
}) {
  return MatrixCell<TrackOccupant>.occupied(
    cellId: CellId(trackId: trackId, columnId: columnId),
    occupant: occupant,
    alignment: alignment,
    debugLabel: debugLabel,
  );
}

MatrixCell<TrackOccupant> _optional({
  required TrackId trackId,
  required TrackColumnId columnId,
  required TrackOccupant? occupant,
  TrackCellAlignment alignment = TrackCellAlignment.top,
  String? debugLabel,
}) {
  if (occupant == null) {
    return _empty(trackId: trackId, columnId: columnId, debugLabel: debugLabel);
  }
  return _occupied(
    trackId: trackId,
    columnId: columnId,
    occupant: occupant,
    alignment: alignment,
    debugLabel: debugLabel,
  );
}

MatrixCell<TrackOccupant> _empty({
  required TrackId trackId,
  required TrackColumnId columnId,
  String? debugLabel,
}) {
  return MatrixCell<TrackOccupant>.empty(
    cellId: CellId(trackId: trackId, columnId: columnId),
    debugLabel: debugLabel,
  );
}
