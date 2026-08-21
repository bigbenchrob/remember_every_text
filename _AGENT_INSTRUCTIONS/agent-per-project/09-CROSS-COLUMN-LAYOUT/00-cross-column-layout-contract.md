---
tier: project
scope: cross-column-layout-contract
owner: agent-per-project
last_reviewed: 2026-08-21
source_of_truth: doc
links:
  - ./README.md
  - ./01-column-band-wrappers.md
  - ./02-sidebar-cassette-content-start-seam.md
  - ./07-column-specific-shared-track-boundaries.md
tests: []
---

# Cross-Column Layout Contract

MessageLens pages often present several peer workspaces at once:

```text
left sidebar / navigation lens
center evidence or record lens
right contextual lens
```

The user should perceive these as coordinated views onto the same underlying
graph, not as independently stacked columns.

## Contract

Participating columns share an ordinal set of horizontal tracks:

```text
Track A
Track B
Track C
...
```

Tracks are geometric coordinates only. They do not mean title, context,
controls, shim, metadata, or content. Those words may describe the current
occupants in a particular page composition, but they are not properties of the
track system.

## Governing Principles

> The page establishes common y-positions across peer columns; it does not
> assign business meaning to those coordinates.

> The Matrix coordinates shared geometry. It does not require unrelated
> columns to share a common vertical lifetime.

> A page column's shared Track boundary is structural and stable.
> Presentation variants choose occupants, including empty presentation; they
> do not choose whether the column participates in the Track system.

The important invariant is that every participating column receives the same
resolved height for each Track inside its declared shared lifetime.

Participation is column-specific. A column receives shared geometry only
through the final shared Track explicitly declared for that column. The page
may continue through later Tracks for other columns after an earlier column has
resumed its independent native flow: the rendering mechanism already owned by
that column.

The final Track on the page and a column's final shared Track are not the same
concept. See
[`07-column-specific-shared-track-boundaries.md`](07-column-specific-shared-track-boundaries.md).

That boundary exists to express truthful composition, not as a performance
optimization.

## Track Occupancy

Each page composition decides which cells are occupied:

```text
A1, A2, A3
B1, B2, B3
C1, C2, C3
```

For example, the current Search page uses A1 for the sidebar selector, A2 for
the center panel label, and A3 for the right panel label. That does not make
Track A a "title track." It only records the current occupancy.

If a cell is empty, it contains no occupant and contributes no dimensional
claim. A page may still give that cell an explicit `minimumReservedHeight` when
its intended resting composition must remain stable before optional content is
available. Resolution uses the greater of the reservation and any live
occupant's truthful natural height.

The reservation is page-owned geometry. It is not an invisible occupant,
padding, frozen resolved geometry, or semantic Track behavior. Its value must
come from the same feature-owned presentation contract as the content that may
later occupy the cell.

If any cell contains a `FixedHeightTrackOccupant`, that occupant contributes an
ordinary live requirement to the track. Designers may describe the visual
effect as a spacer or shim, but the layout engine records only geometry and
occupancy.

## Content Start

Primary content begins after the page's pre-content track sequence.

Examples:

- Left: heatmap/navigation or the cassette selected as sidebar content start
- Center: message results
- Right: conversation excerpt messages

The content-start alignment is the main perceptual win. It lets the user scan
across the page and understand that the panels are peers.

## Ownership

The page owns:

- the complete page matrix and cell occupancy
- each participating column's explicit final shared Track
- explicit minimum reservations that define intended resting composition
- the content-start y-position that follows the page's chosen track sequence
- cell alignment within resolved Track allocations

The resolver owns:

- collecting occupant claims from the complete matrix
- resolving each cell's effective height as the greater of its page-owned
  reservation and its live natural height, or zero when both are absent
- resolving the maximum effective height for each ordinal Track
- producing one immutable resolved matrix

Track occupants own:

- dimensional claims derived from approved presentation contracts
- construction of approved feature presentation

Feature components own:

- wording
- typography
- internal vertical placement inside their assigned track cell
- compact/truncated/adaptive presentation when content approaches overflow

Components do not own:

- panel-level top padding outside resolved matrix cells
- ad hoc spacer stacks that move primary content down outside the track model
- repair logic that tries to align with peer panels after layout

The renderer does not infer shared participation from occupancy. An empty cell
inside a declared shared lifetime still receives the Track's resolved geometry.
A cell after that column's boundary is not emitted merely because another
column continues through later page Tracks.

## What To Do When Alignment Looks Wrong

Fix one of:

- matrix occupancy
- page-owned cell alignment inside a resolved Track
- occupant dimensional truth
- sidebar content-start seam semantics
- component compact-mode behavior

Do not add one-off top padding outside the track cells.

Do not make a feature widget know about sibling columns.

Do not solve alignment with post-frame measurement or imperative repair unless
there is a separate design decision approving that risk.

## Current Implementation

The active system is `PageTrackLayoutMatrix` ->
`ResolvedTrackLayoutMatrix` -> `TrackCellView(CellId)`. The old row-only
`ResolvedTrackPlan`, scope, and `TrackCellColumnBand` wrapper have been retired.

Every visible Search-page Track-region element appears exactly once in the
matrix. Renderers consume complete cells and must not bypass the matrix with a
parallel row-only path.

Occupied tracks should be content-tight: their height comes from the maximum
natural requirement declared by their occupants. Any intentional separation
should be represented by an explicit fixed-height occupant in an ordinary track
cell, not by hidden padding in an occupied track.

This composition authority is an application of the
[Mechanical Impossibility Principle](../00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md#the-mechanical-impossibility-principle):
placement follows from one matrix, so a Track-region element cannot render in a
cell the page did not assign to it.
