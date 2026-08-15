# 03 — PageTrackLayoutMatrix Migration Plan

## Purpose

Convert the approved PageTrackLayoutMatrix architecture into a practical, low-risk implementation plan.

This is an engineering document.

It is not an architecture proposal.

It is not an implementation report.

The objective is to migrate the Search-page Track system in small, verifiable steps while keeping the application functional throughout.

At every phase:

- introduce one new authoritative concept;
- migrate the Search page onto it;
- remove the superseded implementation;
- verify correctness;
- proceed.

Avoid prolonged compatibility layers.

When a new mechanism becomes authoritative, remove the corresponding old mechanism before continuing.

There is only one current user of this application.

Do not optimize the migration for backwards compatibility at the expense of architectural clarity.

---

# Migration Principles

The migration should satisfy the following rules.

## One source of truth

Never maintain two competing authoritative systems longer than necessary.

Temporary compatibility is acceptable.

Permanent duplication is not.

---

## Continuous operation

The application should remain usable after every migration phase.

Do not plan a flag-day rewrite.

---

## Immediate retirement

As each new capability becomes authoritative:

- remove obsolete APIs;
- remove obsolete wrappers;
- remove obsolete compatibility code;
- remove obsolete documentation.

Do not accumulate technical debt during the migration.

---

## Small verified steps

Each phase should end with:

- successful build;
- analyzer;
- focused tests;
- manual visual verification.

---

# Phase 1 — Complete Cell Identity

Introduce:

```text
TrackColumnId

CellId
```

Convert row-only identity:

```text
TrackId
```

into complete page coordinates:

```text
A1
A2
A3

...

D3
```

No visual behaviour changes.

No rendering changes.

No layout changes.

Verify:

- Cell identities are unique.
- Existing Track resolution continues to work.

---

# Phase 2 — Introduce PageTrackLayoutMatrix

Create one authoritative Search-page matrix.

The matrix should become the only place where page composition is declared.

Initially it may simply reproduce the existing layout.

No rendering changes yet.

No removal of existing render paths.

Verify:

- every intended cell exists;
- every occupied cell has an occupant;
- every empty cell is explicit;
- current page appearance is unchanged.

---

# Phase 3 — Remove Placement From Occupants

Move Track ownership out of occupant classes.

TrackOccupants become placement-independent.

The matrix becomes solely responsible for placing occupants.

Immediately remove:

- hidden TrackIds;
- explicit TrackIds on occupants;
- Track-specific occupant subclasses whose only purpose is placement.

Verify:

- moving an occupant between cells requires changing only the matrix.

---

# Phase 4 — Introduce OccupantDimensionalClaim

Replace the current Track-oriented requirement object.

Occupants now declare:

```dart
OccupantDimensionalClaim(
    naturalHeight: ...,
    preferredWidth: ...,
    minimumWidth: ...,
)
```

Track resolution becomes based on occupant dimensional claims.

Immediately retire the previous requirement abstraction once parity is achieved.

Verify:

- Conversation Card
- Search controls
- metadata
- fixed-height spacing

all produce correct dimensional claims.

---

# Phase 5 — Resolve The Matrix

Replace the unordered occupant bag.

Resolution now operates directly on the matrix.

For every Track:

```text
inspect occupied cells

↓

read OccupantDimensionalClaims

↓

resolve maximum naturalHeight

↓

produce ResolvedTrackLayoutMatrix
```

Immediately remove:

- unordered occupant list;
- additional geometry contributors;
- duplicated Track resolution logic.

Verify:

- Track heights remain correct.
- Visual layout remains unchanged.

---

# Phase 6 — Migrate Renderers

Update Track renderers.

Renderers now identify themselves by:

```text
CellId
```

rather than:

```text
TrackId
```

Each renderer retrieves:

- resolved height;
- alignment;
- occupant information;

from the resolved matrix.

Immediately retire row-only rendering APIs.

Verify:

- every rendered cell receives geometry from the matrix.

---

# Phase 7 — Resolve Before Rendering

Construct the complete matrix from page state.

Not from mounted widgets.

If the page state includes a Conversation excerpt:

the matrix already contains:

```text
A3

C3

D3
```

before the end panel is mounted.

The resolved geometry therefore exists before rendering begins.

Immediately retire lifecycle-dependent geometry mechanisms.

Verify:

- initial Search-page load;
- opening Conversation excerpt;
- window resize;
- Search control overflow;
- metadata placement.

The page should no longer depend upon the end sidebar existing before Track geometry can be resolved.

---

# Phase 8 — Remove Transitional Code

Retire all compatibility code.

Examples include:

- hidden TrackIds;
- additionalOccupants;
- duplicate placement logic;
- obsolete wrappers;
- obsolete Track requirement objects;
- obsolete diagnostics.

The final implementation should contain:

- one PageTrackLayoutMatrix;
- one ResolvedTrackLayoutMatrix;
- one rendering path.

---

# Testing Strategy

Each phase should include:

- analyzer;
- focused tests;
- manual visual verification.

Prefer many small successful phases over one large conversion.

---

# Documentation

After each completed phase:

- update canonical Track documentation;
- update implementation checklist;
- append DOCUMENTATION_PASS_LOG.

Do not wait until the end of the migration.

---

# Success Criteria

The migration is complete when:

- the Search page owns one authoritative PageTrackLayoutMatrix;
- occupants are placement-independent;
- renderers identify themselves using CellId;
- geometry is resolved entirely from the matrix;
- the end sidebar no longer affects Track negotiation timing;
- layout tuning consists only of editing the matrix;
- obsolete placement and requirement systems have been removed.

---

# Deliverable

Complete:

```text
03-PAGE-TRACK-LAYOUT-MATRIX-MIGRATION-PLAN.md
```

The document should be concise, practical, and implementation-oriented.

A developer should be able to execute the migration one phase at a time without further architectural design.
