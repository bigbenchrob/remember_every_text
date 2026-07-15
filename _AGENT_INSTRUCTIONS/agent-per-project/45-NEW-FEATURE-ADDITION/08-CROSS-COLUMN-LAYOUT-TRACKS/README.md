---
tier: project
scope: feature-package
owner: agent-per-project
last_reviewed: 2026-07-14
source_of_truth: proposal
status: second-slice-implemented
links:
  - ../../09-CROSS-COLUMN-LAYOUT/README.md
  - ../../09-CROSS-COLUMN-LAYOUT/00-cross-column-layout-contract.md
  - ../../09-CROSS-COLUMN-LAYOUT/01-column-band-wrappers.md
  - ../../09-CROSS-COLUMN-LAYOUT/02-sidebar-cassette-content-start-seam.md
  - ../../95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/README.md
tests: []
---

# Cross-Column Layout Tracks

This package explores a possible successor to the current cross-column layout
contract documented in [`../../09-CROSS-COLUMN-LAYOUT/`](../../09-CROSS-COLUMN-LAYOUT/).

The current model uses fixed title and context band wrappers. That model has
proved valuable: it gave MessageLens an explicit page-level alignment contract
and made sidebar, center-panel, and end-panel content starts coordinate for the
first time.

The next question is whether the same idea should evolve from fixed bands into
shared horizontal layout tracks.

## Core Idea

The page should own shared layout tracks.

Columns should own their content.

Participating columns should declare the requirements of the tracks they
occupy.

The page should resolve one shared `ResolvedTrackPlan` and give every
participating column the same resolved track allocations.

In short:

```text
columns declare requirements
page resolves a shared track plan
columns render inside the resolved plan
```

This package began as exploratory. The first two vertical slices have now been
implemented for Search-page Track A and Track B only. It does not supersede
`09-CROSS-COLUMN-LAYOUT/` yet.

## Package Contents

- [`PROPOSAL.md`](PROPOSAL.md) - product and architectural proposal.
- [`DESIGN_NOTES.md`](DESIGN_NOTES.md) - layout philosophy, ownership, and
  migration notes.
- [`FLUTTER_IMPLEMENTATION_INVESTIGATION.md`](FLUTTER_IMPLEMENTATION_INVESTIGATION.md)
  - evaluates Flutter-native implementation mechanisms and recommends the
  first implementation strategy.
- [`TRACK_OCCUPANT_ARCHITECTURE_ANALYSIS.md`](TRACK_OCCUPANT_ARCHITECTURE_ANALYSIS.md)
  - evaluates a future `TrackOccupant` seam for deriving track requirements
  from presentation contracts without post-frame widget measurement.
- [`CHECKLIST.md`](CHECKLIST.md) - phased planning and implementation checklist.
- [`TESTS.md`](TESTS.md) - validation strategy for a future implementation.

## Implemented Slices

The first implementation proves Track A negotiation on the Search page.

Track A represents panel identity:

- sidebar: `Search all messages` top menu;
- center: `All messages` title;
- right panel: `Conversation` title.

The implemented slice adds a small `TrackRequirement` / `ResolvedTrackPlan`
model, scopes the Search page with a resolved Track A plan, and lets the
existing `TitleColumnBand` compatibility wrapper consume that resolved height.

Track A itself is sized from the maximum actual requirement of its occupants:
the sidebar selector, center title, and right title. The Search page currently
uses no page-top inset; Track A starts flush with the page content surface.
If vertical separation is needed later, it should be introduced as an explicit
shim track rather than hidden above Track A.

Everything below Track A remains owned by the existing layout:

- no Track B has been introduced;
- no sidebar cassette placement has changed;
- no Contacts or Conversations page migration has occurred;
- the existing wrapper system remains in place.

The point of the slice is proof of ownership, not broad visual change:

```text
columns declare Track A requirements
page resolves one Track A height
title bands render inside that resolved height
content below Track A begins from the same resolved boundary
```

The second implementation proves Track B negotiation on the Search page.

Track B represents supporting identity metadata:

- sidebar: empty allocation;
- center: result date range, message count, and closely related metadata;
- right panel: empty allocation.

The implemented slice demonstrates that one column can occupy a track while
peer columns receive the same empty vertical allocation.

Search controls, sidebar orientation text, Conversation Cards, and excerpt
descriptions do not participate in Track B.

Track B is intentionally tight. It exists only to hold the supporting metadata
line. It should not create general vertical separation between the title and
the rest of the page. If separation is needed later, it should be introduced as
an explicit reviewed spacing decision or a separate empty track, not hidden
inside Track B.

The same rule applies to all occupied tracks:

> Occupied tracks contain no discretionary spacing. Their height is the maximum
> natural requirement declared by their occupants. All intentional cross-column
> spacing is modeled as explicit empty tracks.

This means compatibility wrappers may provide horizontal inset and child
alignment, but they must not contribute vertical padding to a resolved occupied
track.

## Remaining Scope

The next implementation target, if approved later, should remain the Search page
only.

For the next slice:

- Track C or a later context/control track may be introduced;
- the rest of the sidebar continues using the existing cassette flow;
- automatic sidebar cassette placement is deferred;
- Contacts and other surfaces are not migrated;
- the existing wrapper system remains in place until the track model is proven.

## Relationship To Current Canonical Layout

`09-CROSS-COLUMN-LAYOUT/` remains the current canonical implementation
reference.

This package records a potential future direction:

- what remains valid from the current model;
- what would change if tracks replace fixed wrappers;
- how migration could happen gradually without destabilizing the app.

Do not expand beyond the implemented Track A/Track B slices until a later prompt
explicitly approves the next implementation slice.
