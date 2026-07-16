---
tier: project
scope: cross-column-layout-contract
owner: agent-per-project
last_reviewed: 2026-07-16
source_of_truth: doc
links:
  - ./README.md
  - ./01-column-band-wrappers.md
  - ./02-sidebar-cassette-content-start-seam.md
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

The important invariant is that every participating column receives the same
resolved height for each track. The page establishes common y-positions across
peer columns; it does not assign business meaning to those coordinates.

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

If a cell is empty, it contributes no requirement. If any cell contains a
`FixedHeightTrackOccupant`, that occupant contributes an ordinary requirement
to the track. Designers may describe the visual effect as a spacer or shim, but
the layout engine records only geometry and occupancy.

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

- the resolved heights of ordinal tracks
- the content-start y-position that follows the page's chosen track sequence
- optional developer diagnostics showing band boundaries

Components own:

- wording
- typography
- internal vertical placement inside their assigned track cell
- compact/truncated/adaptive presentation when content approaches overflow

Components do not own:

- panel-level top padding outside track-cell wrappers
- ad hoc spacer stacks that move primary content down outside the track model
- repair logic that tries to align with peer panels after layout

## What To Do When Alignment Looks Wrong

Fix one of:

- track-cell wrapper defaults
- page-owned cell alignment inside a resolved track
- sidebar content-start seam semantics
- component compact-mode behavior

Do not add one-off top padding outside the track cells.

Do not make a feature widget know about sibling columns.

Do not solve alignment with post-frame measurement or imperative repair unless
there is a separate design decision approving that risk.

## Current Implementation

The active wrapper is `TrackCellColumnBand`. It consumes a `TrackId` and a
resolved track plan, then renders one cell of that track. Older fixed wrappers
with semantic names have been retired from the active Search-page path.

Occupied tracks should be content-tight: their height comes from the maximum
natural requirement declared by their occupants. Any intentional separation
should be represented by an explicit fixed-height occupant in an ordinary track
cell, not by hidden padding in an occupied track.
