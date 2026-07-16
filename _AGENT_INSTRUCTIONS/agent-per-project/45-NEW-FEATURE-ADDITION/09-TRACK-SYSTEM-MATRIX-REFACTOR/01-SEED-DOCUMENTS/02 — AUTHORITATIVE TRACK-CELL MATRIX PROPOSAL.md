# 02 — Authoritative PageTrackLayoutMatrix Architecture

## Purpose

Define the replacement architecture for the Search-page Track system.

This document intentionally ignores the current implementation except where compatibility affects the migration.

The purpose of this document is to define the target architecture clearly enough that implementation can proceed without inventing additional concepts.

Do not implement during this task.

Design only.

---

# Design Goals

The new architecture must satisfy the following principles.

## One authoritative page composition

Every Track-enabled page owns exactly one:

```text
PageTrackLayoutMatrix
```

The `PageTrackLayoutMatrix` is the missing composition authority.

It completely describes the page's Track region and is the one authoritative
record of where each occupant belongs and how each cell places it.

It is the single source of truth for:

- Track-cell placement
- Occupant placement
- Cell alignment
- the inputs from which Track geometry is resolved

The resolver calculates geometry from that composition and stores the result in
the resolved matrix. No other object may redefine page composition or supply a
competing geometry input.

Layout tuning therefore becomes editing one matrix. A designer should be able
to make changes such as:

- move Search metadata from D2 to C2;
- center Search controls in C2;
- move the Conversation Card from C3 to D3;

without coordinating separate occupant declarations, widget trees, wrappers,
and alignment maps.

---

## Geometry Is Separate From Meaning

The responsibility chain is:

```text
Feature presentation
    owns the widget definition

TrackOccupant
    owns dimensional calculation
    and delegates construction of the approved feature presentation

PageTrackLayoutMatrix
    owns placement

Resolver
    owns geometry

TrackCellView
    consumes the resolved cell
```

These responsibilities must remain separate.

The generic Track system must never become a warehouse for Search, Messages,
Conversation, or Sidebar widget construction. Feature presentation remains
feature-owned even when a TrackOccupant adapts it to the Track system.

---

## The Matrix Is Two-Dimensional

The page composition is expressed as a true matrix.

Conceptually:

```text
                Column 1        Column 2        Column 3

Track A         A1              A2              A3

Track B         B1              B2              B3

Track C         C1              C2              C3

Track D         D1              D2              D3
```

The matrix is the primary architectural object and the missing authority over
page composition.

Everything else exists to support it.

---

# Core Types

The architecture should revolve around only a small number of concepts.

---

## PageTrackLayoutMatrix

The master page composition.

Responsibilities:

- defines every Track
- defines every column
- defines every occupied cell
- defines every empty cell
- owns page composition
- owns vertical alignment
- owns placement

It does not:

- calculate presentation metrics
- build widgets
- perform rendering
- know feature semantics

---

## Track

A Track is a shared horizontal row.

Tracks are ordinal only.

Examples:

```text
Track A
Track B
Track C
```

Tracks do not know:

- title
- context
- metadata
- controls
- Conversation
- shim
- semantic role

Tracks are geometry.

Nothing more.

---

## Column

Columns are ordinal only.

Examples:

```text
Column 1
Column 2
Column 3
```

The generic Track system should not know:

- sidebar
- center
- right panel

Those meanings belong only to page composition.

---

## CellId

A complete coordinate.

Examples:

```text
A1
A2
A3

C2
C3
```

A renderer always identifies itself using a complete CellId.

Never only a TrackId.

---

## Cell

A Cell represents one position in the matrix.

Responsibilities:

- CellId
- occupant
- optional debug label
- vertical alignment

Nothing else.

---

## TrackOccupant

Represents one presentation participant.

Responsibilities:

- calculate dimensional truth from prepared presentation and genuine
  presentation constraints
- delegate construction of the approved feature-owned presentation

A TrackOccupant knows nothing about:

- Track
- column
- CellId
- page
- alignment
- sibling occupants

The matrix places it.

---

## OccupantDimensionalClaim

This replaces the Track-oriented requirement vocabulary.

Conceptually:

```dart
OccupantDimensionalClaim(
    naturalHeight: ...,
    preferredWidth: ...,
    minimumWidth: ...,
)
```

The claim is produced from:

```text
prepared presentation
        +
presentation constraints
        ↓
OccupantDimensionalClaim
```

Presentation constraints may include:

- available width
- text scaling
- locale
- text direction

Only genuine presentation constraints belong in this input.

The occupant says:

> I do not know where you will place me.

> I do know the dimensions required for my truthful presentation.

The resolver decides how those claims are satisfied within the matrix.

---

## ResolvedTrackLayoutMatrix

Produced after negotiation.

Contains:

- resolved Track heights
- resolved cells
- alignment
- allocations

This object is immutable.

No renderer modifies it.

---

# Responsibility Chain

The architecture should read naturally:

```text
Feature-owned prepared presentation
    +
Presentation constraints

↓

TrackOccupants produce OccupantDimensionalClaims

↓

PageTrackLayoutMatrix places occupants in Cells

↓

Resolver produces ResolvedTrackLayoutMatrix

↓

TrackCellViews consume resolved Cells

↓

Feature-owned presentation renders
```

Each concept owns exactly one responsibility.

---

# OccupantDimensionalClaim

The first implementation should remain deliberately small.

Conceptually:

```dart
OccupantDimensionalClaim(

    naturalHeight: ...,

    preferredWidth: ...,

    minimumWidth: ...,

)
```

Do not speculate beyond demonstrated need.

These three fields are justified by current presentation work. In particular,
the canonical Conversation Card demonstrates the need for preferred and minimum
width as well as natural height.

Do not add speculative dimensions beyond these fields.

---

# Cell Alignment

Alignment belongs to the Cell.

Supported values:

```text
top

center

bottom
```

The same occupant may be placed differently on another page.

Therefore alignment must not belong to:

- TrackOccupant
- Track
- widget
- renderer

---

# Semantic Labels

A Cell may carry an optional human-readable label.

Examples:

```text
Search controls

Conversation Card

Search metadata
```

These labels exist only to support:

- design discussion
- debugging
- diagnostics

They do not affect layout.

---

# Rendering

Rendering remains distributed.

Feature-owned widgets remain feature-owned. A TrackOccupant delegates
construction of that approved presentation; it does not transfer presentation
ownership into generic Track infrastructure.

Each `TrackCellView` simply asks:

```text
Who am I?

↓

C2

↓

How tall am I?

↓

Resolved Track height

↓

How should I position my child?

↓

Center
```

The cell view never decides geometry or reconstructs page composition.

---

# Page Lifecycle

The currently observed initial-layout behavior appears to result from incomplete
page composition at initial resolution. Possible contributors include late
Conversation presentation data, late occupant contribution, multiple plan
instances, asynchronous presentation readiness, and panel lifecycle.

This architecture does not diagnose the exact current cause. The implementation
work must do that.

The target invariant is:

> The complete page geometry must be derived from intended page state before
> participating panels render.

Page composition is therefore derived from intended page state, not from which
participating widgets happen to have mounted.

Therefore:

the page resolves its matrix

↓

produces one immutable ResolvedTrackLayoutMatrix

↓

all renderers consume it

Whether the right panel has mounted yet must not determine Track geometry.

---

# Migration Strategy

The matrix will become authoritative through a short, explicit compatibility
period.

## Phase 1 — Matrix Infrastructure

Introduce `TrackColumnId`, `CellId`, and the matrix infrastructure without
changing rendering.

## Phase 2 — Search-Page Matrix And Compatibility Bridge

Build the Search-page matrix. Derive the existing row-height plan from that
matrix through a short-lived compatibility bridge.

The bridge is temporary. It exists only to keep the application operational
while renderers migrate.

## Phase 3 — Placement-Independent Occupants

Remove Track and column placement from occupants. Introduce
`OccupantDimensionalClaim`, calculated from prepared presentation and
presentation constraints.

## Phase 4 — Resolve And Render The Complete Matrix

Resolve the complete matrix and migrate renderers from row-only `TrackId`
lookups to complete `CellId` lookups.

## Phase 5 — Retire Transitional Authority

Remove:

- the unordered occupant bag;
- `additionalOccupants`;
- row-only renderer lookups;
- duplicate alignment declarations;
- the compatibility bridge.

The completed Search page has one composition authority, one resolved matrix,
and one cell-based rendering path.

---

# Fixed-Height Spacing

Spacing is not a Track type.

Spacing is an ordinary TrackOccupant.

Conceptually:

```text
Track E

E2

FixedHeightTrackOccupant(
    naturalHeight: 16,
)
```

Humans may call this a shim.

The architecture does not.

---

# Future Compatibility

The architecture deliberately leaves room for:

- conditional occupancy
- merged cells
- additional columns
- richer dimensional claims

without changing the fundamental ownership model.

The core abstractions should remain stable.

---

# Architectural Invariants

The following become permanent rules.

1. Every Track-enabled page owns exactly one PageTrackLayoutMatrix.

2. Tracks are ordinal geometric coordinates only.

3. Cells own placement only.

4. Feature presentation owns widget definitions.

5. Occupants calculate dimensional truth and delegate approved presentation
   construction.

6. The matrix owns placement and is the sole composition authority.

7. The resolver owns geometry and produces one immutable resolved matrix.

8. TrackCellViews consume resolved cells and do not decide geometry.

9. Rendering order does not affect page geometry.

10. Widget trees do not define page composition.

11. There is exactly one authoritative page matrix.

---

# Deliverable

Complete:

```text
02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md
```

This document should become the canonical architectural description of the new Track system.

It should intentionally be concise.

A future developer should be able to understand the entire architecture by reading only this document.
