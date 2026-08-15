---
tier: project
scope: page-track-layout-matrix-migration
owner: agent-per-project
last_reviewed: 2026-07-16
source_of_truth: doc
links:
  - ./README.md
  - ./01-CURRENT-TRACK-SYSTEM-ANATOMY.md
  - ./02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md
  - ./01-SEED-DOCUMENTS/03%20%E2%80%94%20TRACK-CELL%20MATRIX%20MIGRATION%20PLAN.md
tests:
  - test/config/theme/widgets/layout/cross_column_track_plan_test.dart
---

# PageTrackLayoutMatrix Migration Plan

## Purpose

This document converts the approved `PageTrackLayoutMatrix` architecture into
a practical Search-page migration.

It is an execution plan, not an architecture proposal or implementation
record. Each phase must leave the application runnable and must retire the
superseded authority as soon as its replacement is proven.

The governing architectural axiom is:

> **The `PageTrackLayoutMatrix` is the missing composition authority.**

## Migration Rules

1. The Search page is the only implementation target.
2. Every visible Track-region element appears exactly once in the matrix.
3. During Phase 2, the page becomes the sole cell-placement authority through
   its matrix, and matrix cells become the sole occupant-placement and
   alignment authority.
4. The existing row-height plan may survive only as a derived compatibility
   view of the matrix.
5. Feature presentation remains feature-owned throughout the migration.
6. The application remains usable after every phase.
7. Each phase ends with focused tests, analyzer, and manual Search-page review.
8. No compatibility mechanism survives Phase 5.

## Current Implementation Seams

The migration begins from these current responsibilities:

| Current seam | Transitional responsibility |
| --- | --- |
| `cross_column_track_plan.dart` | Row-only requirements, resolution, scope, occupant view, and resolved-plan access. |
| `search_page_track_plan.dart` | Unordered Search-page occupant bag and row-plan construction. |
| `search_page_conversation_track_occupants.dart` | Conditional Conversation contributions supplied as `additionalOccupants`. |
| `macos_app_shell.dart` and `workspace_layout.dart` | More than one current location can construct and distribute a Search-page row plan. |
| `vertical_column_bands.dart` | Render allocation selected by `TrackId` rather than complete `CellId`. |
| Sidebar, Messages, and Conversations presentation trees | Distributed knowledge of column placement, local occupant choice, and alignment. |

The implementation pass must confirm the precise lifecycle that produces the
currently observed incomplete initial geometry. This plan does not assume that
widget mounting alone is the cause.

## Compatibility Boundary

The only approved compatibility direction is:

```text
PageTrackLayoutMatrix
    -> temporary row-plan adapter
    -> existing row-based renderers
```

The reverse direction is forbidden. Existing occupant bags, wrapper order, or
mounted widgets must not reconstruct or amend the matrix.

The adapter begins in Phase 2, remains only while renderers are migrated, and
is deleted in Phase 5.

## Phase 1 — Matrix Identity And Infrastructure

### Objective

Introduce the generic two-dimensional vocabulary without changing Search-page
rendering.

### Work

- Introduce ordinal `TrackColumnId`.
- Introduce complete `CellId` composed from `TrackId` and `TrackColumnId`.
- Introduce matrix and matrix-cell infrastructure sufficient to represent an
  occupied or empty cell.
- Reuse the approved vertical alignment vocabulary: top, center, and bottom.
- Keep Tracks and columns semantically neutral.
- Add concise, stable diagnostic formatting for coordinates such as A1 and C3.

Do not yet build the Search-page matrix or alter the current row plan.

### Verification

- Every valid Track-and-column pair produces a unique `CellId`.
- Equality, hashing, ordering where needed, and diagnostic formatting are
  deterministic.
- Empty and occupied matrix cells cannot be confused.
- Generic types contain no Search, Sidebar, Messages, or Conversations roles.
- Existing Track tests and application rendering remain unchanged.

### Done Means

The repository can describe a two-dimensional Track coordinate and matrix cell
without any production rendering path depending on it.

## Phase 2 — Authoritative Search-Page Matrix And Temporary Bridge

### Objective

Create the one authoritative Search-page composition while preserving current
row-based rendering through a short-lived derived adapter.

### Work

- Identify the intended Search-page state needed to compose all three columns,
  including whether a Conversation excerpt is requested and the current
  readiness of its prepared presentation.
- Build one `PageTrackLayoutMatrix` from that intended page state.
- Declare every current Search-page Track cell explicitly as occupied or
  empty.
- Place every visible Track-region element exactly once.
- Record vertical occupant alignment in each matrix cell.
- Keep optional semantic labels diagnostic-only.
- Derive the existing row-height input from the matrix through one temporary
  compatibility adapter.
- Ensure every participating subtree receives the same derived plan instance.

The matrix, not `additionalOccupants`, widget-tree order, or local wrapper
arguments, becomes the placement authority in this phase.

### Lifecycle Requirement

The complete intended matrix must exist before participating panels render.
If presentation data can be asynchronous, implementation must represent that
intended state explicitly rather than allowing a late widget or occupant to
silently change page geometry.

### Verification

- A matrix test asserts the complete current Search-page occupancy by
  `CellId`.
- No visible Track-region element is absent or duplicated.
- Matrix diagnostics make the complete composition inspectable in one place.
- The derived row plan matches current resolved Track heights.
- Search page without a right panel is unchanged.
- Search page with a Conversation excerpt is unchanged.
- Initial load and opening the excerpt use one page-derived composition.

### Done Means

Moving an existing element to another cell changes its placement declaration
only in the matrix, even though existing renderers still consume a derived
row-height plan.

## Phase 3 — Placement-Independent Occupants And Dimensional Claims

### Objective

Remove page placement from occupants and replace row-oriented requirements
with truthful presentation-derived dimensional claims.

### Work

- Remove `TrackId`, column, `CellId`, page, and alignment knowledge from every
  Search-page `TrackOccupant`.
- Introduce `PresentationConstraints` carrying only demonstrated inputs such
  as available width, text scaling, locale, and text direction.
- Introduce:

  ```dart
  OccupantDimensionalClaim(
    naturalHeight: ...,
    preferredWidth: ...,
    minimumWidth: ...,
  )
  ```

- Produce each claim from the same prepared presentation and presentation
  constraints used to construct the feature-owned widget.
- Preserve feature ownership: occupants delegate construction of approved
  feature presentation rather than defining feature UI in generic Track code.
- Convert fixed-height spacing to an ordinary placement-independent occupant.
- Remove Track-specific occupant subclasses whose only purpose was placement.

### Verification

Focused tests must cover dimensional truth for the current occupant classes,
including:

- sidebar top menu;
- title and metadata text;
- Search controls;
- supporting context text;
- Conversation Card;
- Conversation excerpt label;
- fixed-height spacing.

Tests must use the same presentation contracts and constraints used by
rendering. Character-count estimates, post-frame measurement, GlobalKeys, and
parallel sizing formulas are prohibited.

### Done Means

Any Search-page occupant can be moved to another cell without changing the
occupant, and each occupant produces one truthful dimensional claim independent
of page placement.

## Phase 4 — Complete Matrix Resolution And Cell-Based Rendering

### Objective

Resolve one complete matrix and make every participating renderer consume a
resolved cell by `CellId`.

### Work

- Resolve each Track height from the maximum `naturalHeight` claimed by its
  occupied cells or explicitly reserved by its matrix cells. Each cell's
  effective height is
  `max(minimumReservedHeight, live naturalHeight or zero)`.
- Produce one immutable `ResolvedTrackLayoutMatrix` containing the geometry
  and resolved cell information needed by renderers.
- Distribute that one resolved matrix to the sidebar, center panel, and right
  panel.
- Introduce or complete `TrackCellView` as the intentionally simple cell
  renderer.
- Migrate every Search-page Track-region renderer from row-only `TrackId`
  access to complete `CellId` access.
- Remove local occupant selection and duplicate alignment declarations from
  the participating presentation trees as each cell migrates.
- Keep construction of approved feature presentation delegated to
  feature-owned code.

### Verification

- Every rendered Track-region cell reads allocation, occupant, and alignment
  from the same resolved matrix.
- Empty cells receive shared Track geometry without manufacturing occupants.
- Optional cells that belong to the intended resting composition preserve
  page-owned minimum geometry while their live occupants are absent.
- Live content larger than a reservation expands its Track, and removal returns
  the Track to the reservation rather than zero.
- Reservations derive from the exact feature-owned presentation contracts used
  by the eventual occupants.
- Track height is independent of renderer order and widget mounting order.
- Initial Search-page load is stable.
- Opening and closing the Conversation excerpt is stable.
- Loading and ready Conversation presentation states obey the same intended
  page composition.
- Window resize, text scaling, and relevant width changes recompute truthful
  claims and one resolved matrix.
- Developer Track diagnostics continue to describe geometry and occupancy
  without affecting either.
- Light and dark mode remain visually correct.

### Done Means

The sidebar, center panel, and right panel all render their Track regions by
complete `CellId` from one page-state-derived `ResolvedTrackLayoutMatrix`.

## Phase 5 — Compatibility Retirement And Final Proof

### Objective

Delete the transitional architecture and prove that the matrix is the only
remaining composition authority.

### Remove

- the unordered occupant bag;
- `additionalOccupants`;
- the temporary matrix-to-row-plan adapter;
- row-only renderer lookups;
- obsolete `ResolvedTrackPlan` APIs and scopes once no consumer remains;
- duplicate local alignment declarations;
- placement-only occupant subclasses;
- compatibility wrappers that exist only to consume row heights;
- obsolete diagnostics and documentation describing the retired path.

Removal must follow reference verification. Do not preserve dead aliases or
fallbacks for speculative compatibility.

### Final Verification

- Run focused matrix, occupant, Message Evidence header, Conversation excerpt,
  Conversation Card, and sidebar top-menu tests.
- Run the relevant architecture tests.
- Run `flutter analyze`.
- Manually verify Search with and without the Conversation panel.
- Verify initial load, excerpt opening and closing, search interaction, window
  resize, light mode, dark mode, and developer diagnostics.
- Confirm repository search finds no retired bag, `additionalOccupants`,
  row-only renderer, or duplicate placement path.
- Confirm a representative layout change is expressible as one matrix edit.

### Done Means

The Search page contains:

- one `PageTrackLayoutMatrix`;
- one `ResolvedTrackLayoutMatrix`;
- one `CellId`-based rendering path;
- no competing placement or geometry authority.

## Phase Gate Checklist

Every phase must satisfy all applicable gates before the next begins:

- [x] Scope remains limited to the Search-page Track region.
- [x] Application compiles and remains usable.
- [x] Focused tests pass.
- [x] `flutter analyze` passes.
- [x] Search-page visual behavior is manually checked.
- [x] No feature presentation moved into generic Track infrastructure.
- [x] No semantic Track or column roles were introduced.
- [x] Superseded code scheduled for that phase was removed.
- [x] Canonical documentation and the implementation record were updated.

## Completion Criteria

The migration is complete only when:

1. every visible Search-page Track-region element appears exactly once in the
   matrix;
2. the page owns cell placement through its matrix, and matrix cells alone own
   occupant placement and alignment within those coordinates;
3. occupants are placement-independent;
4. dimensional claims derive solely from approved presentation contracts and
   current presentation constraints;
5. geometry resolves from the complete intended matrix before participating
   panels render;
6. renderers consume complete `CellId` allocations;
7. layout tuning consists of editing one matrix;
8. optional Search-page cells preserve intended resting geometry through
   explicit `minimumReservedHeight` values rather than placeholder occupants,
   padding, or frozen Track heights;
9. all transitional row-only mechanisms have been removed.

Document 04 records the completed implementation, verification evidence,
deviations, and close-out assessment against this plan.
