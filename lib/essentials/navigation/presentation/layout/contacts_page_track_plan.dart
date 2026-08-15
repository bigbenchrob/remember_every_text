import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../config/theme/widgets/layout/page_track_layout_matrix.dart';
import '../../../../config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import '../../../../features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/top_chat_menu_widget.dart';
import '../../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../domain/sidebar_mode.dart';

const _contactsPageTrackIds = [TrackId.trackA];

/// One resolved Contacts page composition.
///
/// Only Track A is shared. Feature-owned sidebar and center content resume
/// their native flows immediately after the persistent page identity row.
final class ContactsPageTrackComposition {
  const ContactsPageTrackComposition({
    required this.matrix,
    required this.resolvedMatrix,
  });

  final PageTrackLayoutMatrix<TrackOccupant> matrix;
  final ResolvedTrackLayoutMatrix resolvedMatrix;
}

ContactsPageTrackComposition composeContactsPageTrackLayout({
  required PresentationConstraints presentationConstraints,
  required ThemeTypography typography,
  required TrackOccupant? centerTitle,
}) {
  final matrix = buildContactsPageTrackLayoutMatrix(
    sidebarTopMenu: TopMenuTrackOccupant(
      currentChoice: TopChatMenuChoice.contacts,
      cassetteIndex: 0,
      sidebarMode: SidebarMode.messages,
      selectedValueStyle: typography.controlValue,
    ),
    centerTitle: centerTitle,
  );
  return ContactsPageTrackComposition(
    matrix: matrix,
    resolvedMatrix: ResolvedTrackLayoutMatrix.resolve(
      matrix: matrix,
      constraints: presentationConstraints,
    ),
  );
}

/// Declares the complete shared Track region for the Contacts page.
PageTrackLayoutMatrix<TrackOccupant> buildContactsPageTrackLayoutMatrix({
  required TrackOccupant sidebarTopMenu,
  required TrackOccupant? centerTitle,
}) {
  return PageTrackLayoutMatrix<TrackOccupant>(
    trackIds: _contactsPageTrackIds,
    columnIds: TrackColumnId.values,
    cells: [
      MatrixCell<TrackOccupant>.occupied(
        cellId: const CellId(
          trackId: TrackId.trackA,
          columnId: TrackColumnId.column1,
        ),
        occupant: sidebarTopMenu,
        alignment: TrackCellAlignment.center,
        debugLabel: 'Contacts top menu',
      ),
      if (centerTitle == null)
        const MatrixCell<TrackOccupant>.empty(
          cellId: CellId(
            trackId: TrackId.trackA,
            columnId: TrackColumnId.column2,
          ),
        )
      else
        MatrixCell<TrackOccupant>.occupied(
          cellId: const CellId(
            trackId: TrackId.trackA,
            columnId: TrackColumnId.column2,
          ),
          occupant: centerTitle,
          alignment: TrackCellAlignment.center,
          debugLabel: 'Contacts center title',
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
