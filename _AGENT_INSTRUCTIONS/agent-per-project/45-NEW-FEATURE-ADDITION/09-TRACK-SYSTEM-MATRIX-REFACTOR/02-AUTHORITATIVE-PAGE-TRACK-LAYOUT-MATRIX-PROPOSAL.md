---
tier: project
scope: page-track-layout-matrix-architecture
owner: agent-per-project
last_reviewed: 2026-07-26
source_of_truth: doc
links:
  - ./README.md
  - ./01-CURRENT-TRACK-SYSTEM-ANATOMY.md
  - ./03-PAGE-TRACK-LAYOUT-MATRIX-MIGRATION-PLAN.md
  - ./01-SEED-DOCUMENTS/02%20%E2%80%94%20AUTHORITATIVE%20TRACK-CELL%20MATRIX%20PROPOSAL.md
  - ../../09-CROSS-COLUMN-LAYOUT/07-column-specific-shared-track-boundaries.md
tests: []
---

# PageTrackLayoutMatrix Architecture

## Purpose

This document defines the replacement architecture for the Search-page Track
system.

### Governing Axiom

> **The `PageTrackLayoutMatrix` is the missing composition authority.**

The matrix becomes the one authoritative description of the page's Track
region. Placement, alignment, and geometry inputs originate there. Everything
else derives from it.

This document defines architecture only. It does not authorize implementation
or broaden the refactor beyond the Search page.

## One Authoritative Page Composition

Every Track-enabled page owns exactly one `PageTrackLayoutMatrix`.

Every visible Track-region element must appear exactly once in that matrix.
Track-region content must not bypass the matrix through direct placement in a
participating widget tree.

For the Search page, the matrix completely records:

- every ordinal Track;
- every ordinal column;
- every cell coordinate;
- every occupied and empty cell;
- the occupant placed in each occupied cell;
- the vertical alignment of each cell;
- optional human-readable diagnostic labels.

No widget tree, occupant, wrapper, or secondary alignment map may independently
redefine that composition.

The matrix is the sole source of:

- Track-cell placement;
- occupant placement;
- cell alignment;
- the inputs from which Track geometry is resolved.

Page composition also declares the final shared Track for each participating
column. The final page Track and a column's final shared Track are distinct.
This affects rendering lifetime only. It does not change matrix ownership,
geometry resolution, or page composition authority.

The matrix may continue through later Tracks for one column after another
column has resumed its native flow, meaning its established column-owned
rendering mechanism.

The resolver calculates geometry from the matrix and stores the result in one
immutable resolved matrix.

## Two-Dimensional Model

The matrix is a true two-dimensional composition:

```text
                Column 1        Column 2        Column 3

Track A         A1              A2              A3
Track B         B1              B2              B3
Track C         C1              C2              C3
Track D         D1              D2              D3
Track E         E1              E2              E3
```

`TrackId` identifies a row. `TrackColumnId` identifies a column. `CellId`
combines them into a complete coordinate such as A1 or C3.

A renderer always identifies itself by complete `CellId`, never only by
`TrackId`.

## Semantic Neutrality

Tracks and columns are ordinal geometry only.

The generic system does not know that:

- Column 1 is currently a sidebar;
- A2 currently contains an `All messages` title;
- B3 currently contains a Conversation Card;
- E2 currently creates visible separation.

Those descriptions belong to the Search-page composition and its diagnostics,
not to Track or column types.

The Search-page composer necessarily selects feature-owned occupants. The
generic matrix stores those occupants opaquely and never branches on feature
meaning or diagnostic labels.

## Responsibility Chain

```text
Feature presentation
    owns the widget definition

TrackOccupant
    owns dimensional calculation
    and delegates construction of the approved feature presentation

Page composition
    owns cell placement through PageTrackLayoutMatrix

MatrixCell
    owns occupant placement and alignment

Resolver
    owns geometry

TrackCellView
    consumes the resolved cell
```

The generic Track system must never become a warehouse for Search, Messages,
Conversations, or Sidebar presentation construction.

### Feature Presentation

Feature presentation owns wording, typography, visual structure, interaction,
and the presentation widget itself.

### TrackOccupant

A `TrackOccupant` adapts an approved feature presentation to the Track system.
It owns:

- prepared presentation data;
- dimensional calculation;
- delegation to the approved feature-owned presentation constructor.

It does not know:

- Track;
- column;
- `CellId`;
- page;
- alignment;
- sibling occupants.

### PageTrackLayoutMatrix

The page owns the matrix and therefore owns the placement of cells in the page
composition. Each matrix cell records the placement and vertical alignment of
its occupant within that coordinate. The matrix does not calculate
presentation metrics, define feature widgets, or render content.

### Resolver

The resolver reads the complete matrix, obtains dimensional claims, resolves
shared Track heights, and produces one immutable
`ResolvedTrackLayoutMatrix`.

### TrackCellView

A `TrackCellView` identifies itself by `CellId` and consumes the corresponding
resolved cell. It does not calculate requirements, choose placement, or alter
geometry.

`TrackCellView` is intentionally simple. It renders the resolved cell presented
to it. It does not infer placement, geometry, alignment, or composition.

## Core Types

### PageTrackLayoutMatrix

The master page composition and sole placement authority.

### TrackId

An ordinal row identifier such as Track A or Track C. It carries no semantic
role.

### TrackColumnId

An ordinal column identifier such as Column 1 or Column 3. It carries no panel
or feature meaning.

### CellId

A complete Track-and-column coordinate such as A1, C2, or D3.

### MatrixCell

One matrix position containing:

- `CellId`;
- zero or one occupant;
- vertical alignment;
- `minimumReservedHeight`, defaulting to zero;
- optional diagnostic label.

An empty cell has no occupant and contributes no dimensional claim. It may
still preserve page-owned resting geometry through a non-zero
`minimumReservedHeight`.

The reservation is explicit page composition. It is not padding, a placeholder
occupant, a semantic Track role, a fixed Track height, or frozen geometry.

### TrackOccupant

A placement-independent presentation participant.

### PresentationConstraints

The genuine environmental constraints needed to calculate dimensional truth.
They may include:

- available width;
- text scaling;
- locale;
- text direction.

Only demonstrated presentation constraints belong in this input.

### OccupantDimensionalClaim

The occupant's truthful dimensional declaration under current presentation
constraints:

```dart
OccupantDimensionalClaim(
  naturalHeight: ...,
  preferredWidth: ...,
  minimumWidth: ...,
)
```

These three fields are justified by current presentation work. The canonical
Conversation Card already demonstrates the need for preferred and minimum
width as well as natural height.

No speculative dimensions should be added.

### ResolvedTrackLayoutMatrix

The immutable result of resolution. It contains resolved Track heights and the
final allocation, alignment, occupant, and diagnostic information needed by
each cell renderer.

## Dimensional Claim Flow

A dimensional claim does not appear independently of presentation:

```text
prepared feature presentation
        +
presentation constraints
        ↓
TrackOccupant
        ↓
OccupantDimensionalClaim
```

The same presentation inputs used to construct the widget must be the sole
source of truth for its dimensional claim. The architecture must not introduce
duplicate height calculations, parallel estimation logic, or
widget-independent sizing formulas. The occupant must not estimate from
character counts, inspect an already-rendered widget, or use post-frame
measurement.

## Geometry Resolution

For each Track, the resolver:

```text
reads every cell
    -> obtains each live occupant's dimensional claim, if present
    -> resolves each cell's effective natural height as
       max(minimumReservedHeight, live naturalHeight or zero)
    -> resolves the maximum effective natural height
    -> assigns that shared height to every cell in the Track
```

Empty cells contribute no claim. A reserved empty cell contributes only its
explicit minimum geometry. Live content larger than a reservation expands the
Track; removing that content returns the Track to the reserved minimum rather
than collapsing it to zero.

Cell alignment and diagnostic labels do not affect Track resolution.

## Cell Alignment

Vertical alignment belongs to the matrix cell because the same occupant may be
placed differently on another page.

The initial alignment vocabulary is deliberately limited to:

```text
top
center
bottom
```

Alignment affects placement inside an already-resolved allocation. It does not
change the occupant claim or Track height, and it must not be simulated with
ad hoc padding.

## Fixed-Height Spacing

Spacing is not a special Track type. It is an ordinary occupant with a fixed
dimensional claim.

For example, E2 may contain:

```text
FixedHeightTrackOccupant(
    naturalHeight: 16,
)
```

Humans may describe the visual effect as a shim. The matrix records only E2
occupancy, and the resolver records only geometry.

## Rendering

Feature-owned rendering may remain physically distributed across the sidebar,
center panel, and right panel.

Every Track-region renderer nevertheless consumes the same resolved matrix and
identifies itself by complete `CellId`:

```text
Who am I?                    C2
What is my allocation?       resolved Track C height
How do I place my occupant?  C2 alignment
What do I present?           C2 occupant
```

The renderer does not reconstruct page composition or accept a competing local
placement decision.

### Column-Specific Shared Lifetimes

Shared participation is a page-owned, column-specific declaration.

For each column, page composition identifies the final ordinal Track through
which that column has a genuine cross-column alignment responsibility. The
renderer emits resolved cells through that boundary and then allows the column
to resume its established native flow.

The boundary is not inferred from:

- the final occupied cell;
- the first empty cell;
- current optional content;
- a run of empty cells; or
- the final Track on the page.

An empty cell inside the declared shared lifetime still receives shared
geometry. A cell after the boundary is not emitted merely because another
column continues through later Tracks.

This preserves the matrix as composition authority without inventing false
pairings between unrelated content. The Matrix coordinates shared geometry; it
does not require unrelated columns to share a common vertical lifetime.

## Page Lifecycle Invariant

The observed initial-layout defect appears to involve incomplete composition at
initial resolution. Possible contributors include late presentation data, late
occupant contribution, multiple plan instances, asynchronous readiness, and
panel lifecycle.

This architecture does not diagnose the exact implementation cause.

It establishes the invariant:

> The complete page geometry must be derived from intended page state before
> participating panels render.

Whether the right panel has mounted must not determine shared Track geometry.
Asynchronous presentation states must still result in a complete intended
matrix rather than a late, hidden geometry contribution.

A `MatrixCell` may therefore declare `minimumReservedHeight` when that
coordinate participates in the intended resting composition even while its
live occupant is absent or smaller. The reservation must derive from the same
feature-owned presentation contract as the eventual occupant. This preserves
stable reactive geometry without freezing the Track against truthful larger
content.

## Migration Strategy

The matrix becomes authoritative through a short, explicit compatibility
period.

### Phase 1 — Matrix Infrastructure

Introduce `TrackColumnId`, `CellId`, and matrix infrastructure without changing
rendering.

### Phase 2 — Search-Page Matrix And Temporary Bridge

Build the Search-page matrix and derive the existing row-height plan from that
matrix through a temporary compatibility bridge.

### Phase 3 — Placement-Independent Occupants

Remove placement from occupants and introduce `OccupantDimensionalClaim` based
on prepared presentation and presentation constraints.

### Phase 4 — Complete Resolution And Cell Rendering

Resolve the complete matrix and migrate renderers from row-only `TrackId`
lookups to complete `CellId` lookups.

### Phase 5 — Transitional Retirement

Remove:

- the unordered occupant bag;
- `additionalOccupants`;
- row-only renderer lookups;
- duplicate alignment declarations;
- the compatibility bridge.

The completed Search page has one composition authority, one resolved matrix,
and one cell-based rendering path.

## Layout Tuning

The principal design benefit is that layout tuning becomes editing one matrix.

Changes such as:

- moving Search metadata from D2 to C2;
- centering Search controls in C2;
- moving the Conversation Card from C3 to D3;

must require changes only to Search-page matrix composition. They must not
require coordinated Track edits inside feature widget trees.

## Architectural Invariants

1. Every Track-enabled page owns exactly one `PageTrackLayoutMatrix`.
2. Every visible Track-region element appears exactly once in that matrix.
3. Tracks and columns are ordinal geometry only.
4. The page owns cell placement; cells own occupant placement and vertical
   alignment within their coordinates.
5. Feature presentation owns widget definitions.
6. Occupants calculate dimensional truth and delegate approved presentation
   construction.
7. Occupants know no Track, column, cell, page, or alignment.
8. The matrix is the sole composition authority.
9. The resolver owns geometry and produces one immutable resolved matrix.
10. `TrackCellView` consumes a resolved cell and does not infer placement,
    geometry, alignment, or composition.
11. Widget trees and rendering order do not define page composition.
12. Empty cells contribute no dimensional claim, but may contribute an
    explicit page-owned `minimumReservedHeight`.
13. Resolution uses the larger of each cell's reservation and its occupant's
    truthful live natural height.
14. Reservations derive from approved feature presentation contracts and do
    not create placeholder occupants, hidden padding, semantic Track roles, or
    frozen geometry.
15. Diagnostic labels never affect layout.
16. The final page Track and a column's final shared Track are distinct.
17. Page composition explicitly declares each column's final shared Track.
18. Shared boundaries are never inferred from current cell occupancy.
19. Different columns may have different shared lifetimes on the same page.
20. After its declared boundary, a column resumes its established native flow.

## Deferred Work

This architecture does not add:

- matrices for other MessageLens pages;
- sidebar cassette auto-placement;
- arbitrary-column page composition;
- horizontal cell alignment;
- cell spanning or merging;
- custom RenderObjects;
- post-frame measurement;
- unrelated Search or Conversation redesign.
