---
tier: project
scope: feature-package
owner: agent-per-project
last_reviewed: 2026-07-16
source_of_truth: proposal
status: c2-fixed-height-occupant-implemented
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

The current model uses ordinal track-cell wrappers. Earlier fixed named
wrappers proved the value of an explicit page-level alignment contract by
making sidebar, center-panel, and end-panel content starts coordinate for the
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

This package began as exploratory. The current Search-page composition uses
resolved track cells A1/A2/A3, B2, and C2 only. The first `TrackOccupant` slice
now derives those requirements from presentation occupants rather than
page-owned numbers. It does not supersede `09-CROSS-COLUMN-LAYOUT/` yet.

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

## Track Cells

Track cells are named by combining the track letter with the column number:

```text
Track A: A1  A2  A3
Track B: B1  B2  B3
Track C: C1  C2  C3
```

The letter identifies the shared horizontal track. The number identifies the
column:

- `1` = left sidebar;
- `2` = center panel;
- `3` = right/end panel.

For example, `A1` means Track A in the left sidebar, `B2` means Track B in the
center panel, and `C3` means Track C in the right/end panel.

Designers may describe an intended effect semantically, such as "shim" or
"context," while discussing a composition. The layout engine records only
geometry and occupancy: track letter, column cell, occupant requirement,
resolved allocation, and eventual cell placement.

## Track Cell Alignment

Track height, occupant requirement, and track cell alignment are separate
concepts:

```text
Track height:
  How tall is this track after negotiation?

TrackRequirement:
  How much vertical space does this occupant naturally require?

Track cell alignment:
  Where should this occupant sit inside the resolved cell allocation?
```

Track cell alignment belongs to the page composition. It does not belong to the
track, the `TrackOccupant`, or the underlying presentation widget.

The same occupant may be aligned differently on different pages:

```text
Search page:
  C2: metadata occupant, alignment = bottom

Another page:
  C2: same metadata occupant, alignment = top
```

The occupant has not changed. Only the page composition has changed.

Initial alignment options should remain deliberately small:

- top;
- center;
- bottom.

Alignment is not padding and must not become hidden spacing. It never changes
track height, occupant requirements, or negotiation. It affects only placement
inside an already-resolved cell.

## Implemented Slices

The current implementation proves track negotiation on the Search page.

Tracks are ordinal geometric coordinates only. Track A, Track B, Track C, and
future tracks do not mean identity, metadata, controls, content, or spacing.
Those descriptions may explain one page composition, but they are not
properties of the tracks.

Current Search-page occupancy:

```text
A1: Search top menu occupant
A2: "All messages" text occupant
A3: "Conversation" text occupant

B1: no occupant
B2: metadata text occupant
B3: no occupant

C1: no occupant
C2: MessageEvidenceSearchControlsTrackOccupant
C3: optional ConversationSignatureCardTrackOccupant when a Conversation excerpt
    is visible

D1: no occupant
D2: MessageEvidenceSupportingContextTrackOccupant
D3: optional ConversationExcerptLabelTrackOccupant when a Conversation excerpt
    is visible

E1/E2/E3: one FixedHeightTrackOccupant(height: 16) contributes the shared
    allocation; every column renders the resolved E cell before primary
    content
```

The fact that C2 currently contains a search-controls occupant assigns no
meaning to Track C itself. It only means that this Search-page composition has
placed the Message Evidence search controls in cell C2.

The fact that C3 may contain a Conversation Card occupant also assigns no
meaning to Track C itself. It only means that the current Search-page
composition places a Conversation-owned presentation occupant in cell C3 when
the right Conversation excerpt is open.

The fact that D2 and D3 currently contain supporting text occupants assigns no
meaning to Track D itself. It only means that this Search-page composition has
placed those occupants in those cells.

The fact that one E cell currently contains a fixed-height occupant assigns no
meaning to Track E itself. Designers may describe the effect as a spacer, but
the layout engine records only geometry and occupancy.

The first implementation adds a small `TrackRequirement` /
`ResolvedTrackPlan` model, scopes the Search page with a resolved plan, and
lets the existing compatibility wrappers consume resolved track heights.

Each resolved track is sized from the maximum actual requirement of its
occupants. The Search page currently uses no page-top inset; the first track
starts flush with the page content surface. If vertical separation is needed
later, it should be introduced by placing an explicit fixed-height occupant in
a chosen cell of an ordinary track.

Everything outside the participating cells remains owned by the existing
layout:

- no sidebar cassette placement has changed;
- no Contacts or Conversations page migration has occurred;
- the existing wrapper system remains in place.

The point of the slice is proof of ownership, not broad visual change:

```text
columns declare TrackRequirements through occupants
page resolves one height per occupied track
track cells render inside resolved allocations
content below a resolved track begins from the same boundary
```

The current B2 occupant demonstrates that one column can occupy a track while
peer columns receive the same resolved vertical allocation without contributing
empty requirements.

The same rule applies to all occupied tracks and cells:

> Occupied tracks contain no discretionary spacing. Their height is the maximum
> natural requirement declared by their occupants. All intentional cross-column
> spacing is modeled by placing fixed-height occupants in ordinary track cells.

During the compatibility-wrapper phase, wrappers may still provide horizontal
inset and default child placement. Once Track Cell Alignment is implemented,
that placement should be expressed by the page composition. In either case,
wrappers must not contribute vertical padding to a resolved occupied track.

The current C2 and D2 occupants demonstrate the visible-content side of the
same rule:

> The Message Evidence search controls and supporting context line each
> contribute ordinary occupant requirements to ordinary track cells. The
> standard negotiation mechanism resolves those requirements across all
> columns. Tracks never receive direct fixed heights independently of
> occupants.

In short: visible content and spacing occupants use the same mechanism.

The current C3 occupant demonstrates variable-height track negotiation:

> `ConversationSignatureCardTrackOccupant` derives its natural requirement from
> `ConversationSignatureCardPresentationMetrics`, the same presentation metrics
> used by the rendered Conversation Card. Glyph row count, card padding, border
> extent, optional hooks/tags, and canonical card width all contribute to the
> occupant requirement. The page coordinator still sees only a
> `TrackRequirement`.

Canonical `ConversationSignatureCard` presentation has a stable width. The
authoritative width is
`ConversationSignatureCardPresentationMetrics.canonicalWidth`. Containers must
accommodate that width and may place the fixed-width card inside wider space,
but they do not stretch the card or redefine its glyph geometry. This keeps
glyph row count and natural-height calculation deterministic across the
Conversations sidebar and right/end Conversation excerpt panel.

The right/end Conversation excerpt panel may center the fixed-width canonical
card for visual balance. That is horizontal presentation placement owned by
the Conversation Card surface, not Track Cell Alignment and not a new track
abstraction.

## TrackOccupant Slice

The first `TrackOccupant` implementation slice replaces Search-page Track A/B
numeric declarations with declarative occupants:

- `TopMenuTrackOccupant` owns the Search sidebar top-menu requirement and
  constructs the matching top-menu presentation widget.
- `TextTrackOccupant` owns text requirements and presentation construction for
  the center/right titles and center metadata line.
- `ResolvedTrackPlan.fromOccupants` remains feature-blind: it collects
  `TrackRequirement` values, resolves maximum height per track, and creates the
  shared plan.

Empty cells are represented by the absence of an occupant. The coordinator does
not branch on top menu, title, metadata, sidebar, Search, or Conversation
types.

## Remaining Scope

The next implementation target, if approved later, should remain the Search page
only.

For the next slice:

- a later context/control track may be introduced;
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
