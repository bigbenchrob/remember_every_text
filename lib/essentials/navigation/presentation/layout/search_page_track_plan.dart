import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../config/theme/widgets/layout/page_track_layout_matrix.dart';
import '../../../../config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import '../../../../features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/top_chat_menu_widget.dart';
import '../../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../domain/sidebar_mode.dart';

const _searchPageTrackIds = [
  TrackId.trackA,
  TrackId.trackB,
  TrackId.trackC,
  TrackId.trackD,
  TrackId.trackE,
  TrackId.trackF,
];

/// Prepared occupants needed to compose the current Search-page Track region.
///
/// These names explain the page composition to humans. Generic Track
/// infrastructure still sees only ordinal cells and occupant requirements.
final class SearchPageTrackOccupants {
  const SearchPageTrackOccupants({
    required this.sidebarTopMenu,
    required this.centerTitle,
    required this.rightTitle,
    required this.centerMetadata,
    required this.centerSearchControls,
    required this.centerInvestigationStatus,
    required this.searchStatusSpacing,
    required this.bottomSpacing,
    this.rightConversationCard,
    this.rightTemporalOrientation,
  });

  final TrackOccupant sidebarTopMenu;
  final TrackOccupant centerTitle;
  final TrackOccupant rightTitle;
  final TrackOccupant centerMetadata;
  final TrackOccupant centerSearchControls;
  final TrackOccupant centerInvestigationStatus;
  final TrackOccupant searchStatusSpacing;
  final TrackOccupant bottomSpacing;
  final TrackOccupant? rightConversationCard;
  final TrackOccupant? rightTemporalOrientation;
}

/// Page-owned resting geometry for optional or temporarily small Search cells.
final class SearchPageTrackMinimumReservations {
  const SearchPageTrackMinimumReservations({
    required this.centerInvestigationStatus,
    required this.rightConversationCard,
  });

  final double centerInvestigationStatus;
  final double rightConversationCard;
}

/// One authoritative Search-page composition and resolved geometry.
final class SearchPageTrackComposition {
  const SearchPageTrackComposition({
    required this.matrix,
    required this.resolvedMatrix,
  });

  final PageTrackLayoutMatrix<TrackOccupant> matrix;
  final ResolvedTrackLayoutMatrix resolvedMatrix;
}

/// Builds and resolves the Search page's complete Track composition.
SearchPageTrackComposition composeSearchPageTrackLayout({
  required PresentationConstraints presentationConstraints,
  required ThemeTypography typography,
  required TrackOccupant centerTitle,
  required TrackOccupant centerMetadata,
  required TrackOccupant centerSearchControls,
  required TrackOccupant centerInvestigationStatus,
  required TrackOccupant rightTitle,
  required double centerInvestigationStatusMinimumReservedHeight,
  required double rightConversationCardMinimumReservedHeight,
  TrackOccupant? rightConversationCard,
  TrackOccupant? rightTemporalOrientation,
}) {
  final occupants = SearchPageTrackOccupants(
    sidebarTopMenu: TopMenuTrackOccupant(
      currentChoice: TopChatMenuChoice.searchAllMessages,
      cassetteIndex: 0,
      sidebarMode: SidebarMode.messages,
      selectedValueStyle: typography.controlValue,
    ),
    centerTitle: centerTitle,
    rightTitle: rightTitle,
    centerMetadata: centerMetadata,
    centerSearchControls: centerSearchControls,
    centerInvestigationStatus: centerInvestigationStatus,
    searchStatusSpacing: const FixedHeightTrackOccupant(height: 2),
    bottomSpacing: const FixedHeightTrackOccupant(height: 16),
    rightConversationCard: rightConversationCard,
    rightTemporalOrientation: rightTemporalOrientation,
  );
  final matrix = buildSearchPageTrackLayoutMatrix(
    occupants: occupants,
    minimumReservations: SearchPageTrackMinimumReservations(
      centerInvestigationStatus: centerInvestigationStatusMinimumReservedHeight,
      rightConversationCard: rightConversationCardMinimumReservedHeight,
    ),
  );

  final resolvedMatrix = ResolvedTrackLayoutMatrix.resolve(
    matrix: matrix,
    constraints: presentationConstraints,
  );

  return SearchPageTrackComposition(
    matrix: matrix,
    resolvedMatrix: resolvedMatrix,
  );
}

/// Declares every occupied and empty Search-page coordinate exactly once.
///
/// This function is the page's placement authority. Every matrix coordinate is
/// explicit; unordered occupant bags are not accepted.
PageTrackLayoutMatrix<TrackOccupant> buildSearchPageTrackLayoutMatrix({
  required SearchPageTrackOccupants occupants,
  required SearchPageTrackMinimumReservations minimumReservations,
}) {
  return PageTrackLayoutMatrix<TrackOccupant>(
    trackIds: _searchPageTrackIds,
    columnIds: TrackColumnId.values,
    cells: [
      _occupied(
        trackId: TrackId.trackA,
        columnId: TrackColumnId.column1,
        occupant: occupants.sidebarTopMenu,
        alignment: TrackCellAlignment.center,
        debugLabel: 'Search top menu',
      ),
      _occupied(
        trackId: TrackId.trackA,
        columnId: TrackColumnId.column2,
        occupant: occupants.centerTitle,
        alignment: TrackCellAlignment.center,
        debugLabel: 'All messages title',
      ),
      _occupied(
        trackId: TrackId.trackA,
        columnId: TrackColumnId.column3,
        occupant: occupants.rightTitle,
        alignment: TrackCellAlignment.center,
        debugLabel: 'Conversation excerpt title',
      ),
      _empty(trackId: TrackId.trackB, columnId: TrackColumnId.column1),
      _occupied(
        trackId: TrackId.trackB,
        columnId: TrackColumnId.column2,
        occupant: occupants.centerMetadata,
        debugLabel: 'Message result metadata',
      ),
      _optionalOccupied(
        trackId: TrackId.trackB,
        columnId: TrackColumnId.column3,
        occupant: occupants.rightConversationCard,
        minimumReservedHeight: minimumReservations.rightConversationCard,
        debugLabel: 'Conversation signature card',
      ),
      _empty(trackId: TrackId.trackC, columnId: TrackColumnId.column1),
      _occupied(
        trackId: TrackId.trackC,
        columnId: TrackColumnId.column2,
        occupant: occupants.centerSearchControls,
        alignment: TrackCellAlignment.center,
        debugLabel: 'Message search controls',
      ),
      _optionalOccupied(
        trackId: TrackId.trackC,
        columnId: TrackColumnId.column3,
        occupant: occupants.rightTemporalOrientation,
        alignment: TrackCellAlignment.center,
        debugLabel: 'Conversation temporal orientation',
      ),
      _occupied(
        trackId: TrackId.trackD,
        columnId: TrackColumnId.column1,
        occupant: occupants.searchStatusSpacing,
        debugLabel: 'Fixed spacing',
      ),
      _empty(trackId: TrackId.trackD, columnId: TrackColumnId.column2),
      _empty(trackId: TrackId.trackD, columnId: TrackColumnId.column3),
      _empty(trackId: TrackId.trackE, columnId: TrackColumnId.column1),
      _occupied(
        trackId: TrackId.trackE,
        columnId: TrackColumnId.column2,
        occupant: occupants.centerInvestigationStatus,
        minimumReservedHeight: minimumReservations.centerInvestigationStatus,
        debugLabel: 'Search investigation status',
      ),
      _empty(trackId: TrackId.trackE, columnId: TrackColumnId.column3),
      _occupied(
        trackId: TrackId.trackF,
        columnId: TrackColumnId.column1,
        occupant: occupants.bottomSpacing,
        debugLabel: 'Fixed spacing',
      ),
      _empty(trackId: TrackId.trackF, columnId: TrackColumnId.column2),
      _empty(trackId: TrackId.trackF, columnId: TrackColumnId.column3),
    ],
  );
}

MatrixCell<TrackOccupant> _occupied({
  required TrackId trackId,
  required TrackColumnId columnId,
  required TrackOccupant occupant,
  TrackCellAlignment alignment = TrackCellAlignment.top,
  double minimumReservedHeight = 0,
  String? debugLabel,
}) {
  return MatrixCell<TrackOccupant>.occupied(
    cellId: CellId(trackId: trackId, columnId: columnId),
    occupant: occupant,
    alignment: alignment,
    minimumReservedHeight: minimumReservedHeight,
    debugLabel: debugLabel,
  );
}

MatrixCell<TrackOccupant> _optionalOccupied({
  required TrackId trackId,
  required TrackColumnId columnId,
  required TrackOccupant? occupant,
  TrackCellAlignment alignment = TrackCellAlignment.top,
  double minimumReservedHeight = 0,
  String? debugLabel,
}) {
  if (occupant == null) {
    return _empty(
      trackId: trackId,
      columnId: columnId,
      minimumReservedHeight: minimumReservedHeight,
      debugLabel: debugLabel,
    );
  }
  return _occupied(
    trackId: trackId,
    columnId: columnId,
    occupant: occupant,
    alignment: alignment,
    minimumReservedHeight: minimumReservedHeight,
    debugLabel: debugLabel,
  );
}

MatrixCell<TrackOccupant> _empty({
  required TrackId trackId,
  required TrackColumnId columnId,
  double minimumReservedHeight = 0,
  String? debugLabel,
}) {
  return MatrixCell<TrackOccupant>.empty(
    cellId: CellId(trackId: trackId, columnId: columnId),
    minimumReservedHeight: minimumReservedHeight,
    debugLabel: debugLabel,
  );
}
