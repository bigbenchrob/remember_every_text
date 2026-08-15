---
tier: project
scope: column-specific-shared-track-boundaries
owner: agent-per-project
last_reviewed: 2026-07-26
source_of_truth: doc
links:
  - ./00-cross-column-layout-contract.md
  - ./01-column-band-wrappers.md
  - ./02-sidebar-cassette-content-start-seam.md
  - ./05-anatomy-of-track-cell-rendering.md
  - ./06-unfamiliar-sources-page-current-implementation.md
tests:
  - ../../../test/essentials/navigation/application/panel_widget_providers_test.dart
---

# Column-Specific Shared Track Boundaries

The Track system distinguishes between:

- the final Track on the page; and
- the final Track shared by a particular column.

These are independent composition decisions.

## Governing Principle

> A column participates in shared Track coordination only while it has a
> genuine cross-column alignment responsibility.

Native flow means the rendering mechanism already owned by that column after
shared cross-column coordination ends, such as the sidebar cassette chain or a
feature-owned content layout.

After its final shared Track, that column resumes its own native flow even when
other columns continue through later page Tracks.

For example:

```text
Page Tracks:                 A B C D E F G H I
Column 1 shared lifetime:    A
Column 2 shared lifetime:    A B C D E F G H I
```

The page still owns Tracks A through I. Column 1 stops rendering
`TrackCellView`s after its declared shared boundary and resumes its native flow.
The matrix still contains the later cells, and the resolver still resolves the
complete page matrix.

The Matrix coordinates shared geometry. It does not require unrelated columns
to share a common vertical lifetime.

## Explicit Page Composition

The final shared Track is declared by page composition for each participating
column. It is not necessarily:

- the final page Track;
- the final occupied Track in the column;
- the final non-empty cell;
- the final Track currently containing live content; or
- a boundary inferred from a run of empty cells.

The declaration represents a stable geometric relationship. It must not change
merely because a selected target, loading state, optional control, or
temporarily unavailable presentation changes current occupancy.

The current sidebar renderer receives this declaration through
`_SidebarContentSeamLayout.lastSharedTrackId`. That private implementation name
is not the architecture. The durable contract is the page-owned,
column-specific shared boundary.

## Native-Flow Ownership Restoration

> Ending shared Matrix participation restores the native layout system's full
> ownership, including its ordinary leading rhythm, unless page composition
> explicitly declares that shared geometry already supplied that separation.

Leaving shared Track coordination does not transfer spacing ownership to the
Track system. When a sidebar resumes its cassette chain, the existing cassette
sectioning rules continue to own the vertical rhythm between adjacent cassette
sections.

The handoff restores responsibilities, not merely rendering order. A native
layout system that resumes after the shared boundary again owns all of its
ordinary policies, including section transitions, spacing, overflow, and
content sequencing. Compatibility behavior that suppressed one of those
policies while shared Tracks supplied it must not survive after that geometric
relationship ends.

Page composition declares only which handoff applies:

- preserve the cassette rhythm when native flow follows the shared boundary
  directly; or
- resume flush when the shared Track composition has already supplied the
  reviewed separation before native flow.

The current renderer expresses that distinction through
`_SidebarContentSeamLayout.nativeFlowSpacing`. That private implementation name
is not the architecture. A seam must not unconditionally erase
coordinator-resolved cassette spacing merely to make the cassette chain follow
shared Track cells.

This keeps the ownership boundary explicit:

- the Matrix owns shared cross-column geometry;
- page composition owns the location and handoff of the native-flow seam; and
- the cassette sectioning system owns cassette-stack spacing values.

No feature-specific padding, invisible Track occupant, or manual gap widget is
required to separate native sidebar cassettes.

## Never Infer The Boundary From Empty Cells

The renderer must not reason:

```text
the remaining cells are empty
therefore this column may leave the Matrix
```

An empty shared cell still receives resolved geometry when the page has
declared that the column participates in that Track. Conversely, a column must
not emit empty cells through the page's final Track merely because another
column continues to participate.

Occupancy answers:

> Is there an occupant in this cell?

The shared boundary answers:

> Does this column still participate in cross-column geometry at this ordinal
> Track?

Those questions must remain separate.

## Relationship Test

When deciding whether a column should continue participating, ask:

> Should the height of content in one column determine the vertical position
> of the continuing content in this column?

If the answer is no, continued sharing is false composition even if the
elements could be made to occupy corresponding rows.

Do not invent pairings merely to stabilize geometry. A visually convenient
pairing is not sufficient; the relationship must remain truthful as transient
page state changes.

## Native Flow After The Boundary

Leaving the shared region is not opting out of the Track system. The Matrix
remains authoritative for every coordinate in which shared geometry is
required.

After the boundary, the column resumes its established local layout system. For
a sidebar this may be its cassette chain. For another panel it may be a
feature-owned content flow.

The Track Matrix owns genuine cross-column geometry. The local layout system
owns composition within the independent continuation. Neither system absorbs
the other.

## Unknown Sources Example

Unknown Sources has one durable cross-column relationship:

```text
A1: sidebar top menu
A2: persistent center-panel identity
```

The following are current occupants of the independent continuations. They do
not define the architecture.

After A:

```text
Column 1:
  Identify / Numeric IDs
  Phone # / Email / Business
  Show
  source list

Column 2:
  selected-source subject
  metrics
  search controls
  review actions
  message evidence
```

The later elements do not have a durable alignment relationship. Requiring
Column 1 to emit B1 through I1 made transient center details move persistent
sidebar controls by the sum of those resolved Track heights.

The correction is:

```text
Column 1 final shared Track: A
Column 2 final shared Track: I
```

The generic renderer follows the declared ordinal boundary. It knows nothing
about Unknown Sources, selected handles, source review, Messages, or cassette
types.

## Non-Goal: Rendering Optimization

The shared boundary is not a performance optimization. A column stops consuming
later `TrackCellView`s because no truthful cross-column relationship remains,
not to reduce widget construction or layout work.

Any efficiency benefit is incidental. The purpose of the declaration is
truthful composition.

## Search Example

Search currently keeps its sidebar in shared coordination through Track F
because its page composition has a longer truthful pre-content relationship.

This does not make F a globally meaningful boundary. Another page or column may
declare a different final shared Track.

## Recovered Messages Example

Recovered Deleted Messages and Recovered No-Handle Messages have one durable
cross-column relationship:

```text
A1: sidebar top menu
A2: recovered-message center-panel title
```

Both columns end shared participation after Track A. The sidebar resumes its
native cassette chain; the center panel resumes its Messages-owned supporting
context, search controls, and evidence flow. Neither continuation determines
the other's vertical position because no later cross-column relationship
exists.

See
[`08-recovered-messages-page-current-implementation.md`](08-recovered-messages-page-current-implementation.md)
for the concrete composition.

## Contacts Example

Contacts also has one durable cross-column relationship:

```text
A1: sidebar top menu
A2: effective center-panel ViewSpec title, when one exists
```

The effective A2 occupant may be prepared by Messages or Conversations. The
page matrix owns its placement without taking ownership of either feature's
presentation. Both columns resume their native flows after Track A.

See
[`09-contacts-page-current-implementation.md`](09-contacts-page-current-implementation.md)
for the concrete composition.

## Invariants

1. The final page Track and a column's final shared Track are distinct.
2. Shared participation is column-specific.
3. Page composition declares each boundary explicitly.
4. The renderer never infers a boundary from empty or occupied cells.
5. Empty cells inside a declared shared lifetime still receive shared geometry.
6. Cells after a column's boundary are not emitted before its independent flow.
7. A boundary expresses a geometric relationship, not feature semantics.
8. Different columns may have different shared lifetimes on the same page.
9. Native flow after the boundary remains owned by the column's established
   rendering system.
10. Ending participation early is a truthful Matrix composition decision, not
    a layout workaround.
11. A shared boundary exists for compositional truth, not as a rendering
    optimization.
