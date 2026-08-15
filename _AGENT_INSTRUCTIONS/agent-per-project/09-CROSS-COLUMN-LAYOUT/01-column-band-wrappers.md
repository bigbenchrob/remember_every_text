---
tier: project
scope: page-track-matrix-rendering
owner: agent-per-project
last_reviewed: 2026-07-24
source_of_truth: doc
links:
  - ./00-cross-column-layout-contract.md
  - ./05-anatomy-of-track-cell-rendering.md
  - ./07-column-specific-shared-track-boundaries.md
  - ../../../lib/config/theme/widgets/layout/page_track_layout_matrix.dart
  - ../../../lib/config/theme/widgets/layout/resolved_track_layout_matrix.dart
tests:
  - test/config/theme/widgets/layout/page_track_layout_matrix_test.dart
  - test/config/theme/widgets/layout/resolved_track_layout_matrix_test.dart
---

# Page Track Matrix And Cell Renderer

This filename is retained to avoid breaking historical links. The old
`TrackCellColumnBand` wrapper architecture has been retired.

The active Search-page mechanics are:

```text
PageTrackLayoutMatrix<TrackOccupant>
    -> ResolvedTrackLayoutMatrix
    -> ResolvedTrackLayoutMatrixScope
    -> TrackCellView(CellId)
```

## PageTrackLayoutMatrix

The matrix is the page's composition authority. It declares every coordinate
exactly once as either occupied or empty. A `CellId` combines an ordinal
`TrackId` with an ordinal `TrackColumnId`.

The matrix owns placement only. It does not calculate geometry and does not
interpret feature meaning.

## ResolvedTrackLayoutMatrix

The resolver asks each occupied cell's `TrackOccupant` for an
`OccupantDimensionalClaim`. For every cell it computes:

```text
effective natural height =
    max(minimumReservedHeight, live naturalHeight or zero)
```

It resolves each Track to the maximum effective height of its cells and records
the resulting geometry for every coordinate.

Empty cells contribute no claim. They may still contribute an explicit
page-owned minimum reservation, and every cell receives the same resolved
Track height as its peers.

## TrackCellView

`TrackCellView` receives one complete `CellId`. It reads the corresponding
resolved cell, gives the occupant its resolved allocation, and places the
resulting feature presentation using the alignment recorded by the page.

It is intentionally unintelligent. It does not infer placement, calculate
geometry, inspect siblings, or apply feature semantics.

## Column Rendering Lifetime

The resolved matrix may contain more ordinal Tracks than a particular column
renders before resuming native flow. Page composition declares that column's
final shared Track explicitly.

The column renderer emits `TrackCellView` instances only through that declared
boundary. It does not:

- render empty trailing cells through the page's final Track;
- infer departure from the first empty cell;
- inspect feature meaning; or
- change the boundary when transient occupancy changes.

This keeps matrix resolution page-wide while allowing each column to have a
truthful shared lifetime. The full contract is documented in
[`07-column-specific-shared-track-boundaries.md`](07-column-specific-shared-track-boundaries.md).

## Diagnostics

Developer diagnostics belong to the resolved-cell renderer. Diagnostic colors
identify ordinal Tracks only; they never imply title, metadata, controls, or
other semantic roles.

## Retired Compatibility Path

The following row-only compatibility types no longer exist:

- `TrackRequirement`
- `ResolvedTrackPlan`
- `ResolvedTrackPlanScope`
- `TrackCellColumnBand`
- `TrackOccupantView`
- `VerticalColumnBand`

Do not recreate them. New Search-page Track-region content must appear exactly
once in the page matrix and render by complete `CellId`.
