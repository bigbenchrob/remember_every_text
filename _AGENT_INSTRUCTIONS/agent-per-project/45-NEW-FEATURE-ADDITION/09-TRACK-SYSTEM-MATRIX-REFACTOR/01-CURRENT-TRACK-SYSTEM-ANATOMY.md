---
tier: project
scope: track-system-matrix-current-state
owner: agent-per-project
last_reviewed: 2026-07-16
source_of_truth: doc
links:
  - ./README.md
  - ./02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md
  - ./03-PAGE-TRACK-LAYOUT-MATRIX-MIGRATION-PLAN.md
  - ./01-SEED-DOCUMENTS/02%20%E2%80%94%20AUTHORITATIVE%20TRACK-CELL%20MATRIX%20PROPOSAL.md
  - ../../09-CROSS-COLUMN-LAYOUT/05-anatomy-of-track-cell-rendering.md
tests:
  - test/config/theme/widgets/layout/cross_column_track_plan_test.dart
---

# Current Track System Anatomy

## Purpose

This document records why the current Search-page Track implementation must
become an authoritative page Track-cell matrix. It describes only enough of the
transitional system to establish the replacement direction.

No application implementation is authorized by this document.

## What The Current System Proved

The current implementation successfully proved shared vertical negotiation:

```text
collect occupant height requirements
    -> group requirements by TrackId
    -> take the maximum height per Track
    -> give every participating column the same Track height
```

This is the mechanism worth preserving.

## The Missing Authority

The current system is an unordered bag of row-level requirement contributors.
It knows that an occupant contributes to Track C, but not whether that occupant
belongs in C1, C2, or C3.

Composition is therefore divided between two authorities:

```text
search_page_track_plan.dart
    knows occupant requirements and Track membership

distributed sidebar, Messages, and Conversations widget trees
    know column placement, rendering, and alignment
```

The requirement plan can answer:

```text
How tall should Track C be?
```

It cannot authoritatively answer:

```text
What occupies C2?
What occupies C3?
How is each cell aligned?
Which renderer presents each occupant?
```

Those answers must be reconstructed from several files.

## Why Row Identity Is Insufficient

A `TrackId` is only a row coordinate:

```text
Track C
```

A page composition needs complete coordinates:

```text
C1
C2
C3
```

Without complete cell identity, placement knowledge is distributed:

```text
occupant
    may know its Track

widget tree
    knows its column

wrapper
    knows its resolved height source

local presentation code
    may know its alignment
```

No single object describes the whole page.

## Practical Consequence

Layout tuning currently requires coordinated edits across requirement
declarations and feature-owned widget trees. A designer cannot reliably make a
change such as:

```text
Move Search metadata from D2 to C2.
Center Search controls in C2.
Move the Conversation Card from C3 to D3.
```

by editing one authoritative composition.

This is the central defect. The current system coordinates heights but does not
own page composition.

## Initial-Resolution Risk

The current geometry can also be resolved from incomplete page composition.
Potential contributors include:

- late Conversation presentation data;
- late occupant contribution;
- separate resolved-plan instances;
- asynchronous presentation readiness;
- participating panel lifecycle.

This pass does not diagnose the precise runtime cause. That belongs in the
implementation investigation.

The replacement architecture must enforce this invariant:

> The complete page geometry must be derived from intended page state before
> participating panels render.

The physical timing of a right-panel widget must not determine shared page
geometry.

## Target Direction

Introduce one Search-page:

```text
PageTrackLayoutMatrix
```

The matrix is a true two-dimensional composition:

```text
                Column 1    Column 2    Column 3

Track A         A1          A2          A3
Track B         B1          B2          B3
Track C         C1          C2          C3
Track D         D1          D2          D3
Track E         E1          E2          E3
```

Each cell records:

- complete `CellId`;
- occupant, if any;
- vertical alignment;
- optional human-readable diagnostic label.

Tracks and columns remain ordinal geometry. They acquire no semantic roles.

## Responsibility Direction

The replacement preserves feature ownership:

```text
Feature presentation
    owns the widget definition

TrackOccupant
    owns dimensional calculation
    and delegates approved presentation construction

Page composition
    owns cell placement through PageTrackLayoutMatrix

MatrixCell
    owns occupant placement and alignment

Resolver
    owns geometry

TrackCellView
    consumes the resolved cell
```

The generic Track system must not own Search, Messages, Conversations, or
Sidebar presentation.

## Migration Direction

The migration proceeds through a short compatibility period:

1. Introduce `TrackColumnId`, `CellId`, and matrix infrastructure.
2. Build the Search-page matrix and temporarily derive the existing row-height
   plan from it.
3. Make occupants placement-independent and introduce truthful dimensional
   claims.
4. Resolve the complete matrix and migrate renderers to `CellId`.
5. Remove the occupant bag, `additionalOccupants`, row-only lookups, duplicate
   alignment, and the compatibility bridge.

The application must remain operational after each phase, but two competing
composition authorities must not survive the migration.

## Scope Constraints

This work applies only to the Search-page Track region.

It does not include:

- matrices for Contacts or Conversations Browse;
- automatic sidebar cassette placement;
- arbitrary column counts;
- cell spanning or merging;
- horizontal alignment architecture;
- post-frame measurement;
- custom RenderObjects;
- unrelated UI redesign.

## Result Of This Pass

This diagnosis establishes that the current system's valuable mechanism is
shared Track-height negotiation, while its architectural defect is the absence
of one complete cell-level composition authority.

Document 02 defines the replacement `PageTrackLayoutMatrix` architecture.
Document 03 defines its migration. Document 04 records implementation evidence.
