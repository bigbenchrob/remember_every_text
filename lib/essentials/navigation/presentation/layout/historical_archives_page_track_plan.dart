import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../config/theme/widgets/layout/page_track_layout_matrix.dart';
import '../../../../config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import '../../../../features/settings/presentation/layout/historical_archives_track_occupants.dart';

const historicalArchivesSharedTrackIds = [
  TrackId.trackA,
  TrackId.trackB,
  TrackId.trackC,
  TrackId.trackD,
  TrackId.trackE,
];

final class HistoricalArchivesPageTrackComposition {
  const HistoricalArchivesPageTrackComposition({
    required this.matrix,
    required this.resolvedMatrix,
  });

  final PageTrackLayoutMatrix<TrackOccupant> matrix;
  final ResolvedTrackLayoutMatrix resolvedMatrix;
}

HistoricalArchivesPageTrackComposition
composeHistoricalArchivesPageTrackLayout({
  required PresentationConstraints presentationConstraints,
  required ThemeTypography typography,
}) {
  final occupants = buildHistoricalArchivesSidebarTrackOccupants(
    typography: typography,
  );
  final matrix = buildHistoricalArchivesPageTrackLayoutMatrix(
    umbrella: occupants.umbrella,
    sourceTypeControl: occupants.sourceTypeControl,
    sourceToKnownFoldersSpacing: const FixedHeightTrackOccupant(
      height: historicalArchivesSourceToKnownFoldersGap,
    ),
    knownFoldersHeading: occupants.knownFoldersHeading,
    knownFoldersHeadingToListSpacing: const FixedHeightTrackOccupant(
      height: historicalArchivesKnownFoldersHeadingToListGap,
    ),
  );
  return HistoricalArchivesPageTrackComposition(
    matrix: matrix,
    resolvedMatrix: ResolvedTrackLayoutMatrix.resolve(
      matrix: matrix,
      constraints: presentationConstraints,
    ),
  );
}

PageTrackLayoutMatrix<TrackOccupant>
buildHistoricalArchivesPageTrackLayoutMatrix({
  required TrackOccupant umbrella,
  required TrackOccupant sourceTypeControl,
  required TrackOccupant sourceToKnownFoldersSpacing,
  required TrackOccupant knownFoldersHeading,
  required TrackOccupant knownFoldersHeadingToListSpacing,
}) {
  final sidebarOccupants = <TrackId, ({TrackOccupant occupant, String label})>{
    TrackId.trackA: (occupant: umbrella, label: 'Historical Archives context'),
    TrackId.trackB: (
      occupant: sourceTypeControl,
      label: 'Historical archive source-type control',
    ),
    TrackId.trackC: (
      occupant: sourceToKnownFoldersSpacing,
      label: 'Source-type to known-folders section spacing',
    ),
    TrackId.trackD: (
      occupant: knownFoldersHeading,
      label: 'Known archive folders heading',
    ),
    TrackId.trackE: (
      occupant: knownFoldersHeadingToListSpacing,
      label: 'Known-folders heading-to-list spacing',
    ),
  };

  return PageTrackLayoutMatrix<TrackOccupant>(
    trackIds: historicalArchivesSharedTrackIds,
    columnIds: TrackColumnId.values,
    cells: [
      for (final trackId in historicalArchivesSharedTrackIds)
        for (final columnId in TrackColumnId.values)
          if (columnId == TrackColumnId.column1)
            MatrixCell<TrackOccupant>.occupied(
              cellId: CellId(trackId: trackId, columnId: columnId),
              occupant: sidebarOccupants[trackId]!.occupant,
              debugLabel: sidebarOccupants[trackId]!.label,
            )
          else
            MatrixCell<TrackOccupant>.empty(
              cellId: CellId(trackId: trackId, columnId: columnId),
            ),
    ],
  );
}
