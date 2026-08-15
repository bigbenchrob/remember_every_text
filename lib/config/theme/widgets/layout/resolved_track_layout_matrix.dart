import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'cross_column_track_plan.dart';
import 'page_track_layout_matrix.dart';

/// One immutable, resolved cell in a page Track matrix.
final class ResolvedTrackCell {
  const ResolvedTrackCell({
    required this.cellId,
    required this.height,
    required this.alignment,
    required this.occupant,
    required this.claim,
    required this.availableWidth,
    required this.debugLabel,
  });

  final CellId cellId;
  final double height;
  final TrackCellAlignment alignment;
  final TrackOccupant? occupant;
  final OccupantDimensionalClaim? claim;
  final double availableWidth;
  final String? debugLabel;

  bool get isOccupied {
    return occupant != null;
  }
}

/// Complete resolved geometry and occupancy for one page Track region.
final class ResolvedTrackLayoutMatrix {
  ResolvedTrackLayoutMatrix._({
    required List<TrackId> trackIds,
    required List<TrackColumnId> columnIds,
    required Map<CellId, ResolvedTrackCell> cells,
    required Map<TrackId, double> trackHeights,
  }) : _trackIds = List<TrackId>.unmodifiable(trackIds),
       _columnIds = List<TrackColumnId>.unmodifiable(columnIds),
       _cells = Map<CellId, ResolvedTrackCell>.unmodifiable(cells),
       _trackHeights = Map<TrackId, double>.unmodifiable(trackHeights);

  factory ResolvedTrackLayoutMatrix.resolve({
    required PageTrackLayoutMatrix<TrackOccupant> matrix,
    required PresentationConstraints constraints,
  }) {
    final claims = <CellId, OccupantDimensionalClaim>{};
    final trackHeights = <TrackId, double>{
      for (final trackId in matrix.trackIds) trackId: 0,
    };

    for (final cell in matrix.cells) {
      final occupant = cell.occupant;
      final OccupantDimensionalClaim? claim;
      if (occupant == null) {
        claim = null;
      } else {
        claim = occupant.dimensionalClaim(constraints);
        claims[cell.cellId] = claim;
      }
      final effectiveNaturalHeight = math.max(
        cell.minimumReservedHeight,
        claim?.naturalHeight ?? 0,
      );
      final currentHeight = trackHeights[cell.cellId.trackId] ?? 0;
      if (effectiveNaturalHeight > currentHeight) {
        trackHeights[cell.cellId.trackId] = effectiveNaturalHeight;
      }
    }

    final resolvedCells = <CellId, ResolvedTrackCell>{};
    for (final cell in matrix.cells) {
      resolvedCells[cell.cellId] = ResolvedTrackCell(
        cellId: cell.cellId,
        height: trackHeights[cell.cellId.trackId] ?? 0,
        alignment: cell.alignment,
        occupant: cell.occupant,
        claim: claims[cell.cellId],
        availableWidth: constraints.availableWidth,
        debugLabel: cell.debugLabel,
      );
    }

    return ResolvedTrackLayoutMatrix._(
      trackIds: matrix.trackIds,
      columnIds: matrix.columnIds,
      cells: resolvedCells,
      trackHeights: trackHeights,
    );
  }

  final List<TrackId> _trackIds;
  final List<TrackColumnId> _columnIds;
  final Map<CellId, ResolvedTrackCell> _cells;
  final Map<TrackId, double> _trackHeights;

  List<TrackId> get trackIds {
    return _trackIds;
  }

  List<TrackColumnId> get columnIds {
    return _columnIds;
  }

  Iterable<ResolvedTrackCell> get cells {
    return _cells.values;
  }

  double heightFor(TrackId trackId) {
    final height = _trackHeights[trackId];
    if (height == null) {
      throw ArgumentError.value(
        trackId,
        'trackId',
        'Track is outside this resolved matrix.',
      );
    }
    return height;
  }

  ResolvedTrackCell cellAt(CellId cellId) {
    final cell = _cells[cellId];
    if (cell == null) {
      throw ArgumentError.value(
        cellId,
        'cellId',
        'Cell is outside this resolved matrix.',
      );
    }
    return cell;
  }
}

/// Makes one resolved page matrix available to all participating columns.
class ResolvedTrackLayoutMatrixScope extends InheritedWidget {
  const ResolvedTrackLayoutMatrixScope({
    required this.matrix,
    required super.child,
    super.key,
  });

  final ResolvedTrackLayoutMatrix matrix;

  static ResolvedTrackLayoutMatrix? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ResolvedTrackLayoutMatrixScope>()
        ?.matrix;
  }

  static ResolvedTrackLayoutMatrix of(BuildContext context) {
    final matrix = maybeOf(context);
    assert(matrix != null, 'No ResolvedTrackLayoutMatrixScope was found.');
    return matrix!;
  }

  @override
  bool updateShouldNotify(ResolvedTrackLayoutMatrixScope oldWidget) {
    return matrix != oldWidget.matrix;
  }
}

/// Intentionally simple renderer for one resolved Track cell.
class TrackCellView extends StatelessWidget {
  const TrackCellView({required this.cellId, super.key});

  final CellId cellId;

  @override
  Widget build(BuildContext context) {
    final cell = ResolvedTrackLayoutMatrixScope.of(context).cellAt(cellId);
    final occupant = cell.occupant;
    if (occupant == null) {
      return SizedBox(height: cell.height);
    }

    final presentation = occupant.buildPresentation(
      context,
      ResolvedTrackAllocation(
        trackId: cell.cellId.trackId,
        height: cell.height,
        availableWidth: cell.availableWidth,
      ),
    );
    final alignment = switch (cell.alignment) {
      TrackCellAlignment.top => Alignment.topLeft,
      TrackCellAlignment.center => Alignment.centerLeft,
      TrackCellAlignment.bottom => Alignment.bottomLeft,
    };

    return SizedBox(
      height: cell.height,
      child: Align(alignment: alignment, child: presentation),
    );
  }
}
