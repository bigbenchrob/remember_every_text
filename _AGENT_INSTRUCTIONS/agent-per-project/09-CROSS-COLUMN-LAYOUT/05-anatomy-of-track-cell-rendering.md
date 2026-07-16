---
tier: project
scope: track-cell-rendering-anatomy
owner: agent-per-project
last_reviewed: 2026-07-16
source_of_truth: doc
links:
  - ./00-cross-column-layout-contract.md
  - ./01-column-band-wrappers.md
  - ./03-search-page-current-implementation.md
  - ../../../lib/config/theme/widgets/layout/cross_column_track_plan.dart
  - ../../../lib/config/theme/widgets/layout/page_track_layout_matrix.dart
  - ../../../lib/config/theme/widgets/layout/resolved_track_layout_matrix.dart
  - ../../../lib/essentials/navigation/presentation/layout/search_page_track_plan.dart
tests:
  - test/config/theme/widgets/layout/page_track_layout_matrix_test.dart
  - test/config/theme/widgets/layout/resolved_track_layout_matrix_test.dart
---

# Anatomy Of Track Cell Rendering

This document explains the current Search-page rendering chain mechanically.

## Rendering Chain

```text
Messages and Conversations prepare presentation inputs
    -> Search page constructs placement-independent TrackOccupants
    -> PageTrackLayoutMatrix places each occupant at one CellId
       and records any page-owned minimum reservation
    -> each occupant declares an OccupantDimensionalClaim
    -> ResolvedTrackLayoutMatrix resolves max effective height per ordinal Track
    -> ResolvedTrackLayoutMatrixScope distributes one immutable result
    -> TrackCellView renders one resolved CellId
    -> feature-owned presentation appears inside the resolved allocation
```

## 1. Features Prepare Presentation

Messages owns evidence labels and controls. Conversations owns the Conversation
title, signature card, and excerpt label. The page receives prepared occupants;
it does not initiate feature reads or construct feature UI.

## 2. The Page Declares The Matrix

`buildSearchPageTrackLayoutMatrix(...)` records every Search-page coordinate
exactly once. Occupied cells contain a `TrackOccupant`; empty cells contain no
occupant. A cell may also carry a `minimumReservedHeight` when the page's
intended resting composition must survive an optional occupant's absence. Cell
alignment and reservations are page-composition decisions.

This is the only place that answers questions such as:

```text
Which occupant is in C2?
Is D3 occupied?
How is A1 aligned?
```

## 3. Occupants Declare Dimensional Truth

Each `TrackOccupant` calculates an `OccupantDimensionalClaim` from the same
presentation contract and constraints used to construct its approved feature
presentation.

The occupant does not know its `CellId`, Track, column, page, or alignment.

## 4. The Resolver Produces One Matrix

`ResolvedTrackLayoutMatrix.resolve(...)` visits every matrix cell once. An
occupied cell may contribute a live `naturalHeight`; an empty cell contributes
no claim. The resolver computes each cell's effective height as:

```text
max(minimumReservedHeight, live naturalHeight or zero)
```

For each ordinal Track it chooses the maximum effective height. It then records
a `ResolvedTrackCell` for every occupied and empty coordinate. The live claim
remains unchanged, so reservation geometry never masquerades as occupant
dimensional truth.

The resolver knows only geometry and occupancy. Diagnostic labels are inert.

## 5. The Scope Distributes The Result

`MacosAppShell` constructs the Search composition before `MacosWindow` renders
and places one `ResolvedTrackLayoutMatrixScope` above the window. Sidebar,
center, and end panel therefore consume the same immutable geometry.

## 6. TrackCellView Renders A Cell

Each participating column emits `TrackCellView(cellId: ...)` in ordinal Track
order. The renderer:

1. reads its resolved cell;
2. returns an empty box for an empty cell;
3. asks an occupant to construct the approved presentation for an occupied
   cell;
4. places that presentation using the cell alignment stored by the page.

It does not find peers or resolve heights.

## Inspector Notes

Flutter Inspector may show framework element types such as
`SingleChildRenderObjectElement`. Those are Flutter's rendered element tree,
not MessageLens `TrackOccupant` objects. Occupants are declarative Dart objects
consumed before the resulting presentation enters the widget tree.

## Correct Mental Model

```text
Features prepare presentation.
Occupants declare dimensional truth.
The page matrix declares placement.
The resolver derives shared geometry.
Cells render the immutable result.
```

The retired row-only plan and band wrappers are historical architecture, not a
fallback to use for new work.
