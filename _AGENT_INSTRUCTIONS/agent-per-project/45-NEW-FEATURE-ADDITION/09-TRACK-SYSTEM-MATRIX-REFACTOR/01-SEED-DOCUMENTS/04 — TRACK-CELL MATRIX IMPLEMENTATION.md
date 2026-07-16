# 04 — PageTrackLayoutMatrix Implementation

## Purpose

Implement the approved PageTrackLayoutMatrix architecture for the Search page.

Use:

```text
01-CURRENT-TRACK-SYSTEM-ANATOMY.md
02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md
03-PAGE-TRACK-LAYOUT-MATRIX-MIGRATION-PLAN.md
```

as the governing documents.

Proceed sequentially through the migration phases.

This is a substantial refactor, but it is intentionally limited to the Search-page Track system.

Work autonomously through implementation, focused tests, analyzer, manual verification, cleanup, and documentation.

Pause only for:

- a genuine contradiction with the approved architecture;
- an unresolved feature-ownership conflict;
- a risk of data loss;
- a migration step that cannot preserve a runnable application.

Do not pause for routine implementation choices.

---

# Objective

Replace the current Search-page Track implementation:

```text
unordered bag of Track requirement contributors
    +
distributed widget-tree placement
    +
late additional occupants
```

with:

```text
one authoritative PageTrackLayoutMatrix
    -> complete CellIds
    -> placement-independent TrackOccupants
    -> OccupantDimensionalClaims
    -> one ResolvedTrackLayoutMatrix
    -> CellId-based renderers
```

At completion:

- the Search-page matrix is visible and editable in one place;
- every occupant is assigned to an explicit cell;
- occupants do not own Track or column placement;
- cell alignment is declared in the matrix;
- Track heights are resolved from the complete matrix;
- right-panel lifecycle does not influence geometry;
- obsolete bag-based mechanisms are removed.

---

# Governing Vocabulary

Use the approved vocabulary consistently:

```text
PageTrackLayoutMatrix
ResolvedTrackLayoutMatrix

TrackId
TrackColumnId
CellId

MatrixCell
TrackOccupant
OccupantDimensionalClaim
TrackCellView
TrackCellAlignment
```

Use actual repository-conforming names if the proposal or migration plan settled slightly different final names.

Do not introduce semantic Track names.

Tracks remain:

```text
Track A
Track B
Track C
...
```

Cells remain:

```text
A1
A2
A3
B1
B2
B3
...
```

---

# Architectural Invariants

Preserve these rules throughout implementation.

## One authoritative matrix

The Search page owns exactly one authoritative `PageTrackLayoutMatrix`.

No other file may independently redefine:

- occupant cell placement;
- Track membership;
- cell alignment;
- page-level Track geometry.

---

## Complete coordinates

A renderer identifies itself by complete `CellId`.

A `TrackId` alone is not a cell coordinate.

---

## Placement-independent occupants

A `TrackOccupant` knows:

- presentation data;
- presentation construction;
- dimensional claim calculation.

It does not know:

- Track;
- column;
- CellId;
- page;
- sidebar or panel role;
- alignment.

---

## Occupant dimensional truth

An occupant declares:

```dart
OccupantDimensionalClaim(
  naturalHeight: ...,
  preferredWidth: ...,
  minimumWidth: ...,
)
```

Include only dimensions justified by current real occupants.

Do not add speculative fields.

---

## Matrix-owned alignment

Vertical alignment belongs to the matrix cell:

```text
top
center
bottom
```

Do not simulate matrix alignment using ad hoc padding.

---

## Lifecycle-independent geometry

The complete intended matrix is derived from page state before participating panels render.

The end-panel widget mounting later must not change Track geometry.

---

# Implementation Method

Execute the phases in `03-PAGE-TRACK-LAYOUT-MATRIX-MIGRATION-PLAN.md` in order.

After every phase:

1. keep the application compiling;
2. run focused tests;
3. run `flutter analyze`;
4. inspect the Search page manually;
5. remove the superseded old mechanism;
6. update the checklist and implementation record.

Do not accumulate a second permanent architecture beside the first.

Temporary compatibility may exist only across the smallest practical number of phases.

---

# Phase 1 — Complete Cell Identity

Implement:

```text
TrackColumnId
CellId
```

Requirements:

- `CellId` combines Track and column;
- A1, A2, and A3 are distinct;
- debug formatting is concise and stable;
- invalid coordinates cannot be constructed accidentally;
- generic infrastructure remains ordinal and semantic-free.

Add focused tests.

No visual change is expected.

Document the final API.

---

# Phase 2 — Introduce The Search-Page Matrix

Create the authoritative Search-page `PageTrackLayoutMatrix`.

The matrix must visibly declare the complete current Track region.

Use the approved current arrangement from the running application and design discussion.

Every cell should be represented as either:

- occupied by one `TrackOccupant`;
- explicitly empty.

Each occupied cell should include:

- `CellId`;
- occupant;
- optional human-readable label;
- `TrackCellAlignment`.

The semantic label is for humans and diagnostics only.

The layout engine must not branch on it.

Initially, compatibility with existing rendering may remain.

The matrix must nevertheless become the sole source of placement truth.

---

# Phase 3 — Remove Placement From Occupants

Migrate every Search-page occupant so it no longer owns or hides a `TrackId`.

This includes all applicable current occupants, such as:

- top menu;
- title text;
- metadata;
- Search controls;
- supporting context;
- fixed-height spacing;
- Conversation title;
- Conversation Card;
- excerpt explanation.

The matrix assigns each occupant to a cell.

Delete migrated occupant constructors, subclasses, fields, or constants whose only purpose was hidden Track placement.

Verify:

> Moving an occupant to another cell requires changing only the matrix composition.

Do not preserve duplicate placement APIs.

---

# Phase 4 — Implement OccupantDimensionalClaim

Introduce the approved dimensional-claim type.

Migrate current height calculations into it.

At minimum support current demonstrated needs:

```dart
OccupantDimensionalClaim(
  naturalHeight: ...,
  preferredWidth: ...,
  minimumWidth: ...,
)
```

Where width has no legitimate claim, use the smallest honest representation rather than invented values.

Preserve shared presentation metrics.

Examples:

- text measurement continues using the same typography contract as rendering;
- the top menu continues using its shared presentation metrics;
- the Conversation Card continues using canonical width and calculated natural height;
- fixed-height spacing declares its actual natural height.

Once all Search-page occupants use dimensional claims, remove the superseded Track-oriented requirement abstraction from this path.

---

# Phase 5 — Resolve The Matrix

Make the matrix the sole input to Track-height resolution.

For each Track:

```text
inspect occupied cells
    -> obtain occupant dimensional claims
    -> resolved height = maximum naturalHeight
    -> assign that height to every cell in the Track
```

Produce one immutable:

```text
ResolvedTrackLayoutMatrix
```

It should support direct cell lookup.

A resolved cell should expose only what rendering genuinely needs, such as:

- CellId;
- resolved Track height;
- cell alignment;
- occupant or presentation build contract;
- debug label;
- dimensional claim where useful for diagnostics.

Remove:

- unordered occupant requirement bag;
- geometry-only `additionalOccupants`;
- duplicate max-height resolution;
- hidden late contributors.

---

# Phase 6 — Migrate Renderers To CellId

Update every Search-page Track-region renderer to identify itself with complete `CellId`.

Conceptually:

```dart
TrackCellView(
  cellId: CellId.c2,
)
```

or the approved equivalent.

Each renderer asks the resolved matrix:

```text
Who am I?
What height was assigned to my Track?
How should I position my occupant?
```

The renderer must not independently decide:

- height;
- Track;
- column;
- alignment;
- requirement contribution.

Feature-owned presentation may remain in distributed widget trees if required by ownership.

Where a local child is still passed during migration, ensure the matrix remains authoritative for placement and geometry.

Prefer the approved final endpoint from Document 02.

Remove row-only renderer APIs after migration.

---

# Phase 7 — Resolve From Page State Before Panels Mount

Eliminate lifecycle-dependent geometry.

The Search page must construct its complete matrix from intended page state.

When a selected Search result has Conversation excerpt context, the matrix must already include all applicable Column 3 cells and occupants before the physical end panel mounts.

The end panel later reads the resolved matrix.

It does not contribute late geometry.

Verify the original failure sequence carefully:

- open Search page;
- confirm metadata is visible immediately;
- type into Search box;
- confirm no overflow;
- select a result;
- press `In Conversation`;
- confirm end panel opens without resizing;
- confirm selected message highlight appears correctly;
- confirm Track spacing does not snap into a new shape after panel mounting;
- resize window and confirm no repair-only behavior occurs.

Remove all remaining lifecycle-driven geometry contribution paths.

---

# Phase 8 — Remove Transitional Code

Once the matrix is authoritative, remove obsolete code.

At minimum inspect and remove, where superseded:

- old occupant bag;
- `additionalOccupants`;
- occupant-owned Track IDs;
- explicit Track IDs passed to occupants;
- row-only Track renderer APIs;
- duplicate alignment configuration;
- compatibility height maps;
- semantic Track naming in current source;
- dead wrapper fallback behavior;
- obsolete tests;
- obsolete documentation.

Do not remove wrappers still needed by non-migrated pages unless the migration plan explicitly authorizes it.

Search-page code should finish with one clear path.

---

# Required Search-Page Matrix

The implementation report must include the final matrix as actually shipped.

Use a table such as:

| Track | Column 1 | Column 2 | Column 3 |
| ----- | -------- | -------- | -------- |
| A     | ...      | ...      | ...      |
| B     | ...      | ...      | ...      |
| C     | ...      | ...      | ...      |
| D     | ...      | ...      | ...      |
| E     | ...      | ...      | ...      |

For each occupied cell include:

- CellId;
- semantic/debug label;
- occupant type;
- alignment.

This table must match source exactly.

---

# Testing

Add focused tests throughout the migration.

## Coordinate tests

- complete CellIds are unique;
- Track plus column produces the expected coordinate;
- debug labels such as `C2` are stable;
- duplicate matrix cells are rejected.

## Matrix tests

- Search matrix contains the expected cells;
- occupied cells contain the expected occupant types;
- empty cells contribute no dimensional claim;
- semantic labels do not affect geometry;
- alignment is stored per cell;
- matrix iteration order does not alter resolution.

## Dimensional-claim tests

- fixed-height occupant declares correct `naturalHeight`;
- one-line and wrapped text declare correct height;
- text scaling affects natural height correctly;
- top menu uses shared presentation metrics;
- one-row and multi-row Conversation Cards declare correct height;
- Conversation Card preferred/minimum width matches its canonical presentation contract.

## Resolution tests

- resolved Track height is the maximum `naturalHeight` in that Track;
- every cell in a Track receives the same resolved height;
- cell alignment does not affect resolution;
- empty cells do not alter the result;
- moving an occupant between cells changes only the relevant Track calculation.

## Renderer tests

- C2 renderer reads C2 alignment and Track C height;
- C3 renderer reads C3 alignment and the same Track C height;
- renderers require complete CellId;
- renderers cannot alter the matrix;
- diagnostics display CellId and semantic label correctly.

## Lifecycle regression tests

Where practical, add widget or integration coverage proving:

- final center geometry exists before the end panel mounts;
- right-panel occupancy is derived from page state;
- metadata is not hidden on initial load;
- Search controls do not overflow;
- `In Conversation` does not require resize;
- mounting the end panel does not recalculate geometry unexpectedly.

Run all focused tests and `flutter analyze`.

Report unrelated pre-existing failures separately.

---

# Manual Verification

Perform a manual Search-page pass with Track diagnostics enabled and disabled.

Verify at least:

- initial page load;
- empty Search state;
- active Search query;
- one-line and multi-row Conversation glyphs;
- result selection;
- Conversation excerpt opening;
- narrow and wide application windows;
- panel appearance and disappearance;
- vertical alignment of each occupied cell;
- fixed-height spacing;
- list/content start alignment;
- absence of overflow;
- absence of visible geometry snapping after panel mounting.

Take screenshots or record exact observations in the implementation document where helpful.

---

# Documentation

Complete the existing numbered document:

```text
04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md
```

Use it as the implementation record.

Update it after every phase with:

- phase status;
- files changed;
- final APIs;
- tests;
- analyzer results;
- manual verification;
- removed compatibility code;
- deviations;
- unresolved work.

Also update the Cross-Column Layout Tracks package:

- `README.md`;
- `PROPOSAL.md`;
- `DESIGN_NOTES.md`;
- `CHECKLIST.md`;
- `TESTS.md`;
- TrackOccupant analysis where terminology has changed;
- canonical Cross-Column Layout documentation where the new matrix becomes current;
- `DOCUMENTATION_PASS_LOG.md`.

Clearly distinguish:

- approved architecture;
- implemented Search-page behavior;
- deferred future capabilities.

---

# Deferred Work

Do not implement during this task:

- other page matrices;
- generalized arbitrary-column layout;
- sidebar cassette auto-placement;
- horizontal cell alignment system;
- CSS Grid-style spanning;
- post-resolution merged cells;
- custom RenderObjects;
- post-frame measurement;
- broad wrapper retirement;
- unrelated Search redesign;
- unrelated Conversation Card redesign.

Record post-resolution cell combination as deferred.

It should receive separate design and approval after the matrix migration is stable.

---

# Completion Criteria

The implementation is complete only when:

- one authoritative Search-page `PageTrackLayoutMatrix` exists;
- every Track-region occupant is placed by complete CellId;
- occupants are placement-independent;
- occupants declare `OccupantDimensionalClaim`;
- the matrix alone resolves Track heights;
- one immutable `ResolvedTrackLayoutMatrix` is consumed by all columns;
- cell renderers read height and alignment by CellId;
- right-panel mounting does not influence geometry;
- the original initial-load defect is resolved;
- the obsolete occupant bag and late geometry contributors are removed;
- current documentation reflects the implemented architecture;
- focused tests and analyzer pass.

Do not claim that every MessageLens page now uses the matrix.

This task completes only the Search-page implementation.

---

# Final Report

At completion, report:

- phases completed;
- final Search-page matrix;
- final core type names and APIs;
- final occupant dimensional-claim contract;
- how Track heights are resolved;
- how renderers identify and render cells;
- how the end-panel lifecycle defect was removed;
- files changed, grouped by:
  - generic layout infrastructure;
  - Search-page matrix;
  - feature occupants;
  - renderers;
  - tests;
  - documentation;
- compatibility code removed;
- focused test results;
- analyzer result;
- manual verification;
- deviations from Documents 02 and 03;
- deferred work.

Do not leave the repository with both the old bag-based system and the new matrix acting as authorities.
