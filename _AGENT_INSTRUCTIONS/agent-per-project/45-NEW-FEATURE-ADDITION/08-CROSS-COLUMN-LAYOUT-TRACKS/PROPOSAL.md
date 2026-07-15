---
tier: project
scope: proposal
owner: agent-per-project
last_reviewed: 2026-07-14
source_of_truth: proposal
status: second-slice-implemented
links:
  - ./README.md
  - ./DESIGN_NOTES.md
  - ../../09-CROSS-COLUMN-LAYOUT/README.md
tests: []
---

# Proposal: Cross-Column Layout Tracks

## Implementation Status

The first two vertical slices have been implemented for the Search page.

Implemented:

- `TrackRequirement`;
- `ResolvedTrackPlan`;
- Search-page scoping of a resolved Track A/Track B plan;
- `TitleColumnBand` consuming a resolved Track A height;
- Search-page Track A starts flush with the page content surface;
- `ContextColumnBand` consuming a resolved Track B height;
- center metadata occupying Track B;
- empty sidebar and right-panel Track B allocations.
- Track B sized tightly to the metadata line rather than used as a spacing
  band.

Not implemented:

- Track C or later tracks;
- automatic sidebar cassette participation;
- broad page migration;
- wrapper retirement.

The proposal below remains the architectural direction for later slices.

## Purpose

MessageLens increasingly presents several peer workspaces in one window:

```text
Sidebar / Center evidence / Right contextual lens
```

The current fixed title/context band model gives those workspaces a shared
vertical rhythm. It establishes that page-level layout is not owned by any one
feature.

The next refinement is to make that rhythm more general and less dependent on
hard-coded wrapper geometry.

## Problem

Fixed bands are a useful first implementation, but they have limits:

- the page has to choose band geometry before knowing each column's real
  requirements;
- conversation cards may need more or less vertical room depending on glyph
  density, tags, hooks, and metadata;
- some panels may not use a given band at all;
- fixed values encourage later local nudging when one panel's content feels
  cramped;
- the sidebar cassette system remains intentionally non-deterministic and
  should not be forced into a rigid multi-band frame.

The current model answers:

> How tall should the top and middle wrappers be?

The track model asks a better question:

> What horizontal tracks does this page need, and what does each track require
> after every participating column declares its requirements?

## Core Insight

The page should coordinate shared horizontal layout tracks.

Each participating column declares:

- which tracks it participates in;
- the `TrackRequirement` for each occupied track.

The page resolves a shared `ResolvedTrackPlan` from those requirements. Height
is the first requirement the architecture needs, but the model should not be
named as though height is the only possible requirement.

Every column then renders using the same resolved track plan.

This produces a shared page rhythm without requiring every column to have
identical content.

## Guiding Principle

The page owns the layout tracks.

Columns own their content.

Participating columns declare track requirements.

The page collects `TrackRequirement` values and resolves the shared
`ResolvedTrackPlan`.

Columns render inside that plan.

## What Is A Layout Track?

A layout track is a named horizontal region shared by peer columns.

Examples for the Search page might be:

- Track A: panel identity
- Track B: pre-content context
- Track C: primary content

The naming is intentionally abstract at the page-layout level. A track is not a
feature concept and not a widget type. It is a coordination surface.

Different columns may fill the same track with different kinds of content:

| Track | Sidebar | Center | Right panel |
| --- | --- | --- | --- |
| A | top menu selector | `All messages` title | `Conversation` title |
| B | empty | result metadata | empty |
| C | cassette flow / heatmap | message results | conversation excerpt |

The important invariant is that Track C begins at the same y-position in every
participating column.

## Why Tracks Are Preferable To Fixed Bands

Tracks preserve the alignment benefit of the current wrapper model while making
the layout responsive to content requirements.

They are preferable to fixed wrapper heights because:

- track geometry is derived from participating `TrackRequirement` values;
- larger Conversation Cards can enlarge the shared track rather than overflow;
- empty or lightweight columns can still align to the resolved plan;
- page rhythm remains centralized;
- local widget padding becomes less tempting;
- the model can extend to future lenses without inventing a new wrapper pair.

## Track Requirement Resolution

Initial algorithm:

```text
for each track:
  collect TrackRequirements from participating columns
  resolve the track's height from those requirements
  provide the resolved track allocation to every participating column
```

For the first slice, height resolution can be simple:

```text
resolved height = max(participant required heights)
```

But the architecture should remain centered on track requirements rather than
height alone.

Occupied tracks are content-tight:

```text
resolved occupied track height = max(natural occupant requirements)
```

They must not include discretionary breathing room. If the page needs
intentional spacing between tracks, that spacing should be modeled as an
explicit empty shim track rather than embedded in an occupied track's
requirement or wrapper padding.

A page does not ask widgets:

> How tall are you?

Participating columns or their layout adapters declare:

> What does this Track require?

The page negotiates declared requirements instead of discovering them after
layout.

Page insets are not track requirements. The current Search page uses no
page-top inset; Track A starts flush with the page content surface. Track A is
sized from the maximum actual requirement of the sidebar selector, center title,
and right title. If a future review calls for separation above Track A, that
spacing should be modeled explicitly rather than embedded in Track A's
requirement.

This is preferable to:

- hard-coded wrapper heights, which drift from actual requirements;
- post-layout measurement, which introduces imperatively repaired layout;
- ad hoc padding, which hides responsibility and breaks cross-column rhythm;
- widget nudging, which makes each panel solve a page-level problem locally.

## Empty Tracks

Some columns may not need meaningful content in a track.

That is acceptable.

A column can render an empty track region while still respecting the shared
resolved height. Empty participation is useful when the content start needs to
align but one column has no context content for that track.

## First Implementation Scope

The first implementation slice should be limited to the Search page.

The sidebar should participate only in Track A through its top menu. The
remaining sidebar content should continue using the existing cassette flow.

This deliberately avoids solving the harder autonomous cassette-placement
problem while still proving the page-level track model for center and right
panels.

## Non-Goals

Do not use this package to:

- rewrite the sidebar cassette system;
- migrate Contacts or other pages;
- remove `TitleColumnBand` / `ContextColumnBand` immediately;
- introduce post-frame measurement;
- create feature-specific layout hacks;
- make the page know about individual cassette types such as heatmaps.

## Success Criterion

A future implementation validates this proposal if:

- the Search page uses a resolved shared track plan;
- center and right panel content starts remain aligned;
- the sidebar top menu aligns with Track A while the rest of the sidebar remains
  cassette-owned;
- variable Conversation Card content can declare a larger track requirement
  without pushing only the right panel downward;
- existing wrapper mechanics can remain during migration.
