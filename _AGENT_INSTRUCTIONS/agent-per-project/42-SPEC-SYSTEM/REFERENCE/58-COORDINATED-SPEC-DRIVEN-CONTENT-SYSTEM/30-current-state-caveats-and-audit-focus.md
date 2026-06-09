# Current State, Caveats, and Audit Focus

## Why this file matters

This file is intentionally blunt.

The goal is not to describe a polished ideal system and quietly omit the places
where the current code still violates that ideal. The point is to make the gap
easy to audit.

## What improved during this session

Several structural corrections were made or validated:

- the left sidebar no longer transports a cached `List<Widget>` snapshot
- the sidebar coordinator now returns `ResolvedSidebarCassette` data instead of
  prebuilt cassette widgets
- sidebar wrapper chrome is now rebuilt at the render edge from resolved
  payloads
- mounted center and right panel hosts watch `PanelStack` state directly
- runtime logging confirmed that canonical center-panel clearing was occurring
  even when stale content still appeared live

Those changes matter because they move the architecture away from widget-as-
state transport.

## What is still not pure

The system is better, but it is not yet a fully immutable declarative pipeline.

### One important caveat

One important caveat: although the left sidebar no longer snapshots fully built
cassette lists, the payload layer still permits feature-owned widget subtrees
to cross the boundary through `SidebarCassetteCardViewModel.featureComplex`.

The contact chooser currently does exactly that. `ContactChooserResolver`
returns a `featureComplex` payload whose `child` is either
`ContactFlatListWidget` or `ContactGroupedPickerWidget`.

That means the chooser branch is still not fully represented as immutable data.
It is cleaner than the old widget snapshot cache, but it is not the final
declarative endpoint.

If the stale picker behavior persists, this is the first place an auditing agent
should press on.

## Additional contamination points

### 1. Multiple imperative writers still exist for panel coherence

The center/right panel story is still split across multiple mechanisms:

- `SidebarFlow._syncProjectedCenterPanel()`
- `reconcileSidebarPanels(...)`
- deferred clear logic for null projected center content

These mechanisms were useful stabilizers, but they also prove the system has
not yet reduced panel projection to one clean semantic writer plus one passive
render layer.

### 2. Recovered evidence remains a distinct semantic scope

Recovered evidence now routes through the shared Message Evidence Spine, but it
remains semantically distinct from ordinary conversation evidence:

- recovered rows represent source-retained rows without ordinary current
  conversation topology.
- recovered scopes must remain visibly distinct from ordinary timelines.
- archive/recovery compatibility code may still exist behind named boundaries.

That is intentional semantic separation, not permission to create a separate
message renderer.

### 3. Sidebar layout still inspects built widgets for some decisions

The left-sidebar surface still unwraps built widgets to determine things like:

- pinned app-control status
- `shouldExpand`

That is not the worst impurity in the system, but it is still downstream
inspection of already-built widgets rather than layout derived purely from
resolved descriptors.

### 4. Right-panel validity remains enforced as a compatibility check

The right panel still depends on explicit compatibility logic rather than being
obviously impossible by construction.

That is acceptable as a backstop, but it signals the architecture still relies
on a cleanup rule to restore invariants after change rather than making those
invalid states unrepresentable.

## What the auditing agent should verify

An audit should check whether the system is actually converging toward these
properties, or merely layering more repair logic on top of stale state.

### Audit question 1

Can the contact chooser be re-expressed as immutable sidebar body data or a
strictly governed render contract instead of a transported feature widget
subtree?

### Audit question 2

Can the flow-managed messages branch reduce panel writing to a single semantic
projection path, leaving reconciliation as a debug/assertion backstop only?

### Audit question 3

Should the sidebar surface operate on resolved cassette descriptors directly,
instead of first building widgets and then re-inspecting those widgets for
layout decisions?

### Audit question 4

Should recovered timelines become a first-class message-scope implementation
that plugs into the same surface contract all the way through, instead of
remaining partially special-cased?

### Audit question 5

Are there remaining places where widget mount effects can still author or
re-author semantic surface state after canonical flow has already changed?

## Standard for judging the architecture

The correct standard is not "does it usually work after enough defensive
patches?"

The correct standard is:

- does one semantic state model explain all visible surfaces?
- are incompatible surface combinations unrepresentable or immediately
  invalidated by construction?
- are widgets terminal outputs rather than transported or cached state?
- can a reader predict the center and right surfaces from canonical flow state
  without having to reason about stale render artifacts?

If the answer is still "not quite," then the refactor is not finished.
