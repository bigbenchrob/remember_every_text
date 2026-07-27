import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../config/theme/widgets/layout/page_track_layout_matrix.dart';
import '../../../../config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import '../../../../features/messages/presentation/layout/recovered_messages_page_track_occupants.dart';
import '../../../../features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/top_chat_menu_widget.dart';
import '../../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../domain/sidebar_mode.dart';

const _recoveredMessagesPageTrackIds = [TrackId.trackA];

/// One resolved recovered-message page composition.
///
/// Only Track A is shared: the sidebar menu and center-panel title are peers.
/// Both columns resume their native feature-owned flow below that boundary.
final class RecoveredMessagesPageTrackComposition {
  const RecoveredMessagesPageTrackComposition({
    required this.matrix,
    required this.resolvedMatrix,
  });

  final PageTrackLayoutMatrix<TrackOccupant> matrix;
  final ResolvedTrackLayoutMatrix resolvedMatrix;
}

RecoveredMessagesPageTrackComposition composeRecoveredMessagesPageTrackLayout({
  required PresentationConstraints presentationConstraints,
  required ThemeTypography typography,
  required TopChatMenuChoice topMenuChoice,
  required RecoveredMessagesPageTrackOccupants messageOccupants,
}) {
  final matrix = buildRecoveredMessagesPageTrackLayoutMatrix(
    sidebarTopMenu: TopMenuTrackOccupant(
      currentChoice: topMenuChoice,
      cassetteIndex: 0,
      sidebarMode: SidebarMode.messages,
      selectedValueStyle: typography.controlValue,
    ),
    centerTitle: messageOccupants.title,
  );
  return RecoveredMessagesPageTrackComposition(
    matrix: matrix,
    resolvedMatrix: ResolvedTrackLayoutMatrix.resolve(
      matrix: matrix,
      constraints: presentationConstraints,
    ),
  );
}

/// Declares the complete shared Track region for a recovered-message page.
PageTrackLayoutMatrix<TrackOccupant>
buildRecoveredMessagesPageTrackLayoutMatrix({
  required TrackOccupant sidebarTopMenu,
  required TrackOccupant centerTitle,
}) {
  return PageTrackLayoutMatrix<TrackOccupant>(
    trackIds: _recoveredMessagesPageTrackIds,
    columnIds: TrackColumnId.values,
    cells: [
      MatrixCell<TrackOccupant>.occupied(
        cellId: const CellId(
          trackId: TrackId.trackA,
          columnId: TrackColumnId.column1,
        ),
        occupant: sidebarTopMenu,
        alignment: TrackCellAlignment.center,
        debugLabel: 'Recovered messages top menu',
      ),
      MatrixCell<TrackOccupant>.occupied(
        cellId: const CellId(
          trackId: TrackId.trackA,
          columnId: TrackColumnId.column2,
        ),
        occupant: centerTitle,
        alignment: TrackCellAlignment.center,
        debugLabel: 'Recovered messages title',
      ),
      const MatrixCell<TrackOccupant>.empty(
        cellId: CellId(
          trackId: TrackId.trackA,
          columnId: TrackColumnId.column3,
        ),
      ),
    ],
  );
}
