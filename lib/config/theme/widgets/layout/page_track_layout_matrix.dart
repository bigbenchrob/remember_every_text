import 'package:flutter/foundation.dart' show immutable;

import 'cross_column_track_plan.dart';

/// Ordinal columns in a page Track region.
///
/// Column identifiers carry no sidebar, panel, or feature meaning.
enum TrackColumnId { column1, column2, column3 }

/// Complete coordinate for one page Track cell.
@immutable
class CellId {
  const CellId({required this.trackId, required this.columnId});

  final TrackId trackId;
  final TrackColumnId columnId;

  String get diagnosticLabel {
    return '${_trackLabel(trackId)}${_columnLabel(columnId)}';
  }

  @override
  bool operator ==(Object other) {
    return other is CellId &&
        other.trackId == trackId &&
        other.columnId == columnId;
  }

  @override
  int get hashCode {
    return Object.hash(trackId, columnId);
  }

  @override
  String toString() {
    return diagnosticLabel;
  }
}

/// Vertical placement of an occupant within an already-resolved cell.
enum TrackCellAlignment { top, center, bottom }

/// One explicit occupied or empty cell in a page Track matrix.
class MatrixCell<T extends Object> {
  const MatrixCell._({
    required this.cellId,
    required this.occupant,
    required this.alignment,
    required this.minimumReservedHeight,
    required this.debugLabel,
  }) : assert(
         minimumReservedHeight >= 0 && minimumReservedHeight < double.infinity,
       );

  const MatrixCell.empty({
    required CellId cellId,
    TrackCellAlignment alignment = TrackCellAlignment.top,
    double minimumReservedHeight = 0,
    String? debugLabel,
  }) : this._(
         cellId: cellId,
         occupant: null,
         alignment: alignment,
         minimumReservedHeight: minimumReservedHeight,
         debugLabel: debugLabel,
       );

  const MatrixCell.occupied({
    required CellId cellId,
    required T occupant,
    TrackCellAlignment alignment = TrackCellAlignment.top,
    double minimumReservedHeight = 0,
    String? debugLabel,
  }) : this._(
         cellId: cellId,
         occupant: occupant,
         alignment: alignment,
         minimumReservedHeight: minimumReservedHeight,
         debugLabel: debugLabel,
       );

  final CellId cellId;
  final T? occupant;
  final TrackCellAlignment alignment;
  final double minimumReservedHeight;
  final String? debugLabel;

  bool get isOccupied {
    return occupant != null;
  }
}

/// Complete two-dimensional Track composition for one page.
///
/// The matrix validates that every declared Track-and-column coordinate is
/// represented exactly once. It records placement only; it does not calculate
/// geometry or interpret occupant meaning.
class PageTrackLayoutMatrix<T extends Object> {
  PageTrackLayoutMatrix({
    required Iterable<TrackId> trackIds,
    required Iterable<TrackColumnId> columnIds,
    required Iterable<MatrixCell<T>> cells,
  }) : _trackIds = List<TrackId>.unmodifiable(trackIds),
       _columnIds = List<TrackColumnId>.unmodifiable(columnIds) {
    _validateAxis(_trackIds, 'trackIds');
    _validateAxis(_columnIds, 'columnIds');

    final suppliedCells = <CellId, MatrixCell<T>>{};
    for (final cell in cells) {
      if (!cell.minimumReservedHeight.isFinite ||
          cell.minimumReservedHeight < 0) {
        throw ArgumentError.value(
          cell.minimumReservedHeight,
          'cells',
          'A cell reservation must be finite and non-negative.',
        );
      }
      if (!_trackIds.contains(cell.cellId.trackId) ||
          !_columnIds.contains(cell.cellId.columnId)) {
        throw ArgumentError.value(
          cell.cellId,
          'cells',
          'Cell is outside the declared matrix axes.',
        );
      }
      if (suppliedCells.containsKey(cell.cellId)) {
        throw ArgumentError.value(
          cell.cellId,
          'cells',
          'Cell coordinate is declared more than once.',
        );
      }
      suppliedCells[cell.cellId] = cell;
    }

    final orderedCells = <CellId, MatrixCell<T>>{};
    for (final trackId in _trackIds) {
      for (final columnId in _columnIds) {
        final cellId = CellId(trackId: trackId, columnId: columnId);
        final cell = suppliedCells[cellId];
        if (cell == null) {
          throw ArgumentError.value(
            cellId,
            'cells',
            'Every declared matrix coordinate must have an explicit cell.',
          );
        }
        orderedCells[cellId] = cell;
      }
    }
    _cells = Map<CellId, MatrixCell<T>>.unmodifiable(orderedCells);
  }

  final List<TrackId> _trackIds;
  final List<TrackColumnId> _columnIds;
  late final Map<CellId, MatrixCell<T>> _cells;

  List<TrackId> get trackIds {
    return _trackIds;
  }

  List<TrackColumnId> get columnIds {
    return _columnIds;
  }

  Iterable<MatrixCell<T>> get cells {
    return _cells.values;
  }

  MatrixCell<T> cellAt(CellId cellId) {
    final cell = _cells[cellId];
    if (cell == null) {
      throw ArgumentError.value(
        cellId,
        'cellId',
        'Cell is outside this matrix.',
      );
    }
    return cell;
  }
}

void _validateAxis<T extends Object>(List<T> values, String argumentName) {
  if (values.isEmpty) {
    throw ArgumentError.value(
      values,
      argumentName,
      'A matrix axis cannot be empty.',
    );
  }
  if (values.toSet().length != values.length) {
    throw ArgumentError.value(
      values,
      argumentName,
      'A matrix axis cannot contain duplicate identifiers.',
    );
  }
}

String _trackLabel(TrackId trackId) {
  return switch (trackId) {
    TrackId.trackA => 'A',
    TrackId.trackB => 'B',
    TrackId.trackC => 'C',
    TrackId.trackD => 'D',
    TrackId.trackE => 'E',
    TrackId.trackF => 'F',
    TrackId.trackG => 'G',
    TrackId.trackH => 'H',
    TrackId.trackI => 'I',
  };
}

String _columnLabel(TrackColumnId columnId) {
  return switch (columnId) {
    TrackColumnId.column1 => '1',
    TrackColumnId.column2 => '2',
    TrackColumnId.column3 => '3',
  };
}
