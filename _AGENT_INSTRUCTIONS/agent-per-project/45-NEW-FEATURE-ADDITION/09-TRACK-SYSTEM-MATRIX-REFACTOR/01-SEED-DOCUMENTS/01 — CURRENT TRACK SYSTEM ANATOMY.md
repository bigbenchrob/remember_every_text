# 01 — Why The Current Track Plan Must Become A Page Track Layout Matrix

## Purpose

Record, succinctly, why the current Search-page Track implementation is no longer suitable and define the high-level migration direction.

This is not a forensic audit.

Do not trace every occupant, renderer, provider, or wrapper in detail.

Do not produce a large inventory of current files.

Do not spend significant time documenting an architecture that is already known to be transitional and incorrect.

The purpose of this document is to give enough context for the replacement architecture and establish a practical sequential migration path.

No application source changes in this task.

---

# Current Problem

The current Search-page Track implementation was assembled incrementally while the layout requirements were still evolving.

It has successfully proved one useful mechanism:

```text
collect occupant height requirements
    -> group them by Track
    -> choose the largest requirement
    -> give every column the same Track height
```

However, the current page plan is not a complete page composition.

It is an unordered bag of `TrackOccupant` requirement contributors.

The code does not authoritatively record:

```text
A1 = Search top menu
A2 = All messages title
A3 = Conversation title

B2 = Search result metadata

C2 = Search controls
C3 = Conversation Card

D2 = Search explanation
D3 = Conversation excerpt explanation
```

Instead:

- some occupants expose a `TrackId`;
- some occupants hide their `TrackId`;
- no occupant records a complete Track-and-column coordinate;
- actual widget placement is scattered through separate sidebar, center-panel, and end-panel widget trees;
- vertical alignment is supplied separately from the requirement plan;
- conditional right-panel occupants are added later through mechanisms such as `additionalOccupants`.

The result is that the system can answer:

```text
How tall should Track C be?
```

but it cannot authoritatively answer:

```text
What occupies C2?
What occupies C3?
How is C2 aligned?
Where is C3 rendered?
```

Those answers must be reconstructed from several files.

---

# Why The Bag Of Occupants Is Insufficient

A `TrackId` identifies only a row.

It does not identify a cell.

```text
Track C
```

is not the same as:

```text
C1
C2
C3
```

The current requirement bag therefore lacks the information needed to describe the page’s two-dimensional layout.

It also lets placement knowledge become distributed:

```text
occupant class
    may know Track

widget tree
    knows column

renderer
    knows height source

separate placement code
    knows alignment
```

No single source owns the complete composition.

This makes layout changes unnecessarily difficult.

A designer should be able to say:

```text
Move “Search result metadata” from D2 to C2.
Center the Search controls in C2.
Move the Conversation Card from C3 to D3.
```

and make those changes in one authoritative matrix.

The current system instead requires finding and coordinating several independent code paths.

---

# End-Panel Lifecycle Failure

The current architecture also allows page geometry to depend on which panel widgets have already been mounted.

When the Search page first opens:

- the center column may already be rendering;
- the end panel may not yet exist;
- right-panel occupants such as the Conversation Card may not yet have joined the requirement bag;
- Track C and later Tracks may therefore resolve without all intended participants.

This produces the observed initial state:

- compressed or jammed center-column Tracks;
- missing or displaced Search metadata;
- Search-control overflow;
- `In Conversation` appearing selected without the visible end panel;
- correct geometry appearing only after a window resize or later rebuild.

The resize is not the real solution.

It merely causes the page to be recomposed after the missing right-panel information has become available.

The required invariant is:

> The complete Search-page Track geometry must be resolved from intended page state before any participating panel renders.

The physical existence of the end-panel widget must not determine page geometry.

---

# Target Direction

Replace the current requirement bag with one authoritative:

```text
PageTrackLayoutMatrix
```

The matrix is a two-dimensional page composition.

It contains:

```text
Tracks
    x
Columns
```

and therefore explicit cells:

```text
A1 A2 A3
B1 B2 B3
C1 C2 C3
D1 D2 D3
```

Each occupied cell should declare:

- complete `CellId`;
- occupant;
- optional human-readable label;
- vertical alignment.

Each occupant should declare only its own presentation geometry and construction contract.

The emerging dimensional vocabulary is:

```dart
OccupantDimensionalClaim(
  naturalHeight: ...,
  preferredWidth: ...,
  minimumWidth: ...,
)
```

The occupant does not know:

- which Track it occupies;
- which column it occupies;
- which page contains it;
- whether it appears in a sidebar or panel.

The matrix places it.

---

# Core Responsibility Split

## Occupant

Knows:

- its prepared presentation data;
- how to calculate its `OccupantDimensionalClaim`;
- how to construct or supply its approved presentation.

Does not know:

- Track;
- column;
- cell;
- page;
- vertical placement.

## Matrix Cell

Knows:

- complete `CellId`;
- occupant, if any;
- human-readable label;
- vertical alignment.

## PageTrackLayoutMatrix

Knows:

- the complete page composition;
- every Track;
- every column;
- every occupied and empty cell.

## ResolvedTrackLayoutMatrix

Knows:

- the final resolved height of each Track;
- the final allocation and alignment for every cell.

## Cell Renderer

Knows:

```text
Who am I?
    C2

How high am I?
    resolved Track C height

How should I position my child?
    C2 alignment
```

It does not calculate or alter the plan.

---

# Migration Principle

Do not replace the system in one flag-day rewrite.

Migrate it sequentially.

At each phase:

- add one new authoritative capability;
- move the Search page onto it;
- remove the corresponding old capability;
- keep the application working;
- preserve current visual behavior unless a defect is explicitly being corrected.

The migration should resemble the earlier move to graph-based evidence in discipline, but not in duration or breadth.

This is a focused Search-page layout refactor for one current user.

Do not turn it into a generalized multi-page layout framework.

---

# Sequential Migration

## Phase 1 — Introduce Complete Cell Identity

Add:

```text
TrackColumnId
CellId
```

A `CellId` represents:

```text
Track + column
```

Examples:

```text
A1
A2
A3
C2
C3
```

Do not change rendering yet.

Add focused tests proving that cells are complete, unique coordinates.

Remove no old code in this phase.

---

## Phase 2 — Introduce PageTrackLayoutMatrix

Create the Search-page matrix in one authoritative file.

The matrix should visibly declare the current composition.

Conceptually:

```text
Track A
  A1 Search top menu
  A2 All messages title
  A3 Conversation title

Track B
  B1 empty
  B2 Search result metadata
  B3 empty

Track C
  C1 empty
  C2 Search controls
  C3 Conversation Card

Track D
  D1 empty
  D2 Search explanation
  D3 Conversation excerpt explanation
```

Use the actual approved current arrangement when implementing.

At this phase the matrix may temporarily coexist with the current occupant bag.

The purpose is to establish one visible source of truth for placement.

---

## Phase 3 — Move Track Assignment Out Of Occupants

Remove hidden and explicit `TrackId` ownership from occupant classes.

Occupants become placement-agnostic.

For example:

```text
MessageEvidenceSearchControlsTrackOccupant
```

must no longer inherently mean Track C.

The Search-page matrix assigns it to C2.

Likewise:

- Top Menu does not inherently mean A1;
- Conversation Card does not inherently mean C3;
- supporting text does not inherently mean Track D;
- fixed-height spacing does not inherently mean Track E.

When an occupant has been migrated, remove its old Track-assignment path immediately.

Do not maintain two permanent placement systems.

---

## Phase 4 — Introduce OccupantDimensionalClaim

Replace the Track-specific requirement concept with occupant-owned dimensional truth.

First implementation may contain only fields already required by real occupants:

```dart
OccupantDimensionalClaim(
  naturalHeight: ...,
  preferredWidth: ...,
  minimumWidth: ...,
)
```

Do not add speculative dimensions.

The claim travels with the occupant wherever the matrix places it.

The resolver uses the claims of all occupants in one Track to determine that Track’s height.

When this path is working, remove the old `TrackRequirement` path.

---

## Phase 5 — Resolve The Matrix

Make the complete matrix the input to Track-height resolution.

For each Track:

```text
read occupied cells
    -> ask each occupant for its dimensional claim
    -> take maximum naturalHeight
    -> assign that height to every cell in the Track
```

Produce one immutable:

```text
ResolvedTrackLayoutMatrix
```

The resolved matrix must contain enough information for every cell renderer to look up:

- resolved height;
- alignment;
- occupant identity or build contract;
- debug label.

When this works, remove the unordered occupant bag.

Remove `additionalOccupants` as a geometry mechanism.

---

## Phase 6 — Migrate Renderers To CellId

Change Track-region renderers from row-only identity:

```dart
trackId: TrackId.trackC
```

to complete cell identity:

```dart
cellId: CellId.c2
```

Each renderer should obtain its allocation from the resolved matrix.

It must no longer choose its own:

- height;
- vertical alignment;
- Track assignment.

The existing widget code may remain distributed through feature-owned widget trees.

The important change is that each render location identifies itself by complete cell coordinate and reads geometry from the master matrix.

When a renderer has migrated, remove its old row-only lookup path.

---

## Phase 7 — Derive The Whole Matrix From Page State

Ensure the Search-page matrix is constructed from intended page state before participating panels mount.

If Search state says that a Conversation excerpt is selected, the matrix must already include the appropriate Column 3 cells and occupants.

The matrix must not wait for the physical end-panel widget to contribute them later.

This phase should correct the initial-load defect:

- center Tracks resolve correctly on first render;
- metadata is visible;
- Search controls do not overflow;
- `In Conversation` opens the end panel without resize;
- right-panel appearance does not alter previously resolved geometry.

Remove any remaining lifecycle-dependent geometry path.

---

## Phase 8 — Delete Compatibility Code

After the matrix is authoritative:

- remove the old occupant bag;
- remove `additionalOccupants`;
- remove hidden occupant Track IDs;
- remove duplicate alignment maps;
- remove row-only renderer APIs;
- remove obsolete compatibility fallbacks;
- remove semantic Track naming from current source and canonical docs.

Do not retain dead compatibility merely because it once helped the migration.

---

# Scope Constraints

This migration applies only to the Search page.

Do not implement:

- Contacts-page matrix;
- Conversations Browse matrix;
- generic arbitrary-column page framework;
- sidebar cassette auto-placement;
- horizontal alignment system;
- CSS Grid-style spanning;
- post-resolution cell merging;
- custom RenderObjects;
- post-frame measurement;
- wrapper retirement outside what is directly required;
- unrelated Search or Conversation redesign.

The goal is a clean, usable Search-page implementation—not a universal layout engine.

---

# Documentation Sequence

This document establishes the problem and migration direction.

The following numbered documents should then be used as follows:

```text
01 — concise problem and migration direction
02 — exact proposed matrix architecture and naming
03 — executable file-by-file migration plan
04 — implementation record and completion report
```

Document 02 should design only what is necessary to execute the phases above.

Document 03 should convert the approved design into small implementation slices.

Do not repeat a large anatomy of the current system in later documents.

---

# Deliverable

Complete:

```text
01-CURRENT-TRACK-SYSTEM-ANATOMY.md
```

Despite the existing filename, keep the document concise.

It should contain:

- brief current-state summary;
- why the occupant bag is insufficient;
- why the end-panel lifecycle causes broken initial geometry;
- target `PageTrackLayoutMatrix` direction;
- responsibility split;
- sequential migration phases;
- scope constraints.

Do not exceed what is necessary to orient Document 02 and Document 03.

Update the package README to link the document if needed.

Append a documentation-only entry to:

```text
DOCUMENTATION_PASS_LOG.md
```

No application source changes.

---

# Final Report

Report only:

- document completed;
- concise statement of the current defect;
- target architecture summarized;
- migration phases recorded;
- documentation files updated;
- unresolved decisions to carry into Document 02.

Do not produce a detailed source inventory.

Do not begin implementation.

Do not expand the task beyond the Search-page Track system.
