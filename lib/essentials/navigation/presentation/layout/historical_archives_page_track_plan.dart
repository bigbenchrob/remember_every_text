import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../config/theme/widgets/layout/page_track_layout_matrix.dart';
import '../../../../config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import '../../../../features/settings/presentation/layout/historical_archives_track_occupants.dart';

const historicalArchivesSidebarSharedTrackIds = [
  TrackId.trackA,
  TrackId.trackB,
  TrackId.trackC,
  TrackId.trackD,
  TrackId.trackE,
];

const historicalArchivesPageTrackIds = [
  ...historicalArchivesSidebarSharedTrackIds,
  TrackId.trackF,
  TrackId.trackG,
  TrackId.trackH,
  TrackId.trackI,
];

const historicalArchivesCenterSharedTrackIds = historicalArchivesPageTrackIds;

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
  final centerOccupants = buildHistoricalArchivesCenterTrackOccupants(
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
    centerPageTitle: centerOccupants.pageTitle,
    titleToNarratorSpacing: const FixedHeightTrackOccupant(
      height: historicalArchivesTitleToNarratorGap,
    ),
    centerNarrator: centerOccupants.narrator,
    narratorToInstrumentationSpacing: const FixedHeightTrackOccupant(
      height: historicalArchivesNarratorToInstrumentationGap,
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
  required TrackOccupant centerPageTitle,
  required TrackOccupant titleToNarratorSpacing,
  required TrackOccupant centerNarrator,
  required TrackOccupant narratorToInstrumentationSpacing,
}) {
  final occupants = <CellId, ({TrackOccupant occupant, String label})>{
    const CellId(trackId: TrackId.trackA, columnId: TrackColumnId.column1): (
      occupant: umbrella,
      label: 'Historical Archives context',
    ),
    const CellId(trackId: TrackId.trackB, columnId: TrackColumnId.column1): (
      occupant: sourceTypeControl,
      label: 'Historical archive source-type control',
    ),
    const CellId(trackId: TrackId.trackC, columnId: TrackColumnId.column1): (
      occupant: sourceToKnownFoldersSpacing,
      label: 'Source-type to known-folders section spacing',
    ),
    const CellId(trackId: TrackId.trackD, columnId: TrackColumnId.column1): (
      occupant: knownFoldersHeading,
      label: 'Known archive folders heading',
    ),
    const CellId(trackId: TrackId.trackE, columnId: TrackColumnId.column1): (
      occupant: knownFoldersHeadingToListSpacing,
      label: 'Known-folders heading-to-list spacing',
    ),
    const CellId(trackId: TrackId.trackF, columnId: TrackColumnId.column2): (
      occupant: centerPageTitle,
      label: 'Historical Archives page title',
    ),
    const CellId(trackId: TrackId.trackG, columnId: TrackColumnId.column2): (
      occupant: titleToNarratorSpacing,
      label: 'Page title to Narrator transition',
    ),
    const CellId(trackId: TrackId.trackH, columnId: TrackColumnId.column2): (
      occupant: centerNarrator,
      label: 'Historical Archives Narrator',
    ),
    const CellId(trackId: TrackId.trackI, columnId: TrackColumnId.column2): (
      occupant: narratorToInstrumentationSpacing,
      label: 'Narrator to Directed Instrumentation transition',
    ),
  };

  return PageTrackLayoutMatrix<TrackOccupant>(
    trackIds: historicalArchivesPageTrackIds,
    columnIds: TrackColumnId.values,
    cells: [
      for (final trackId in historicalArchivesPageTrackIds)
        for (final columnId in TrackColumnId.values)
          if (occupants[CellId(trackId: trackId, columnId: columnId)]
              case final occupant?)
            MatrixCell<TrackOccupant>.occupied(
              cellId: CellId(trackId: trackId, columnId: columnId),
              occupant: occupant.occupant,
              debugLabel: occupant.label,
            )
          else
            MatrixCell<TrackOccupant>.empty(
              cellId: CellId(trackId: trackId, columnId: columnId),
            ),
    ],
  );
}
