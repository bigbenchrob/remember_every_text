---
tier: project
scope: track-cell-rendering-anatomy
owner: agent-per-project
last_reviewed: 2026-07-16
source_of_truth: doc
links:
  - ./00-cross-column-layout-contract.md
  - ./01-column-band-wrappers.md
  - ./03-search-page-current-implementation.md
  - ../../../lib/config/theme/widgets/layout/cross_column_track_plan.dart
  - ../../../lib/config/theme/widgets/layout/vertical_column_bands.dart
  - ../../../lib/essentials/navigation/presentation/layout/search_page_track_plan.dart
tests: []
---

# Anatomy Of Track Cell Rendering

This document explains how the current Search-page layout tracks become a
Flutter widget tree.

It is deliberately mechanical. For the architectural rule that tracks are
ordinal geometry only, see
[`00-cross-column-layout-contract.md`](00-cross-column-layout-contract.md).

## Core Point

`TrackCellColumnBand` does not discover its peers.

It does not ask:

```text
Who else is in my row?
```

The page composition declares the participating occupants first. The track plan
is resolved before descendant track-cell wrappers render.

## Rendering Chain

The Search-page chain is:

```text
Page composition
  declares TrackOccupants

TrackOccupants
  declare TrackRequirements

ResolvedTrackPlan
  resolves max requirement per TrackId

ResolvedTrackPlanScope
  provides the resolved plan to the subtree

TrackCellColumnBand
  reads the resolved height for its TrackId

Child presentation widget
  renders inside that cell
```

## Step By Step

### 1. Page Composition Declares Occupants

The Search page calls `resolveSearchPageTrackPlan(...)`.

That function explicitly declares the current Search-page occupants. For
example:

```text
A1: TopMenuTrackOccupant
A2: TextTrackOccupant("All messages")
A3: TextTrackOccupant("Conversation")
B2: metadata text occupant
C2: search controls occupant
D2: supporting context occupant
E: fixed-height occupant
```

Optional right-panel occupants, such as the Conversation Card and excerpt label,
are added by the page when the right Conversation excerpt panel is visible.

No `TrackCellColumnBand` searches for these peers. They are known because the
page composition declared them.

### 2. Occupants Declare Requirements

Each `TrackOccupant` answers:

```text
What TrackRequirement do I declare?
```

Examples:

- a top-menu occupant can use a known presentation contract;
- a text occupant can use text metrics;
- a Conversation Card occupant can use Conversation Card presentation metrics;
- a fixed-height occupant can declare a constant height.

The page coordinator does not need to know what kind of content produced the
requirement.

### 3. The Page Resolves The Track Plan

`ResolvedTrackPlan.fromOccupants(...)` asks each occupant for a
`TrackRequirement`, then resolves the maximum height for each `TrackId`.

Conceptually:

```text
Track A = max(A1 requirement, A2 requirement, A3 requirement)
Track B = max(B2 requirement)
Track C = max(C2 requirement, optional C3 requirement)
Track D = max(D2 requirement, optional D3 requirement)
Track E = max(E fixed-height requirement)
```

The resolved plan is just data:

```text
Track A -> 30
Track B -> 18
Track C -> 96
Track D -> 34
Track E -> 16
```

It does not know that Track A currently contains titles or that Track E
currently creates visual separation. Those are page-composition effects, not
track semantics.

### 4. The Plan Is Placed In The Widget Tree

The resolved plan is passed down through `ResolvedTrackPlanScope`.

`ResolvedTrackPlanScope` is a Flutter `InheritedWidget`. Its job is only to
make the already-resolved plan available to descendant widgets.

The main workspace receives a scope in `workspace_layout.dart`.

The macOS end sidebar is built through a separate `MacosWindow` sidebar
builder, so the right panel receives a corresponding scope in
`macos_app_shell.dart`.

Both scopes call the same Search-page resolver, so the center and right panel
receive the same geometry.

### 5. TrackCellColumnBand Reads The Plan

When Flutter later builds a widget such as:

```dart
TrackCellColumnBand(trackId: TrackId.trackA, ...)
```

that wrapper asks:

```text
What height did the page resolve for Track A?
```

It reads that value from `ResolvedTrackPlanScope`.

If a resolved plan exists, the track cell uses the resolved height. If no plan
exists, it uses its fallback height for compatibility with non-participating
surfaces.

### 6. The Child Renders Inside The Cell

The child widget is then placed inside the resolved cell according to the
page-composition placement rules.

The child does not own cross-column alignment.

The cell does not calculate track requirements.

The page does not inspect already-built Flutter widgets.

## Inspector Notes

Flutter Inspector may show internal Flutter element types such as:

```text
SingleChildRenderObjectElement
```

That is not the MessageLens `TrackOccupant`.

The MessageLens occupant is the Dart object that implements `TrackOccupant` and
declares a `TrackRequirement`. Flutter's element tree is the rendered result of
the already-resolved plan.

## Correct Mental Model

Use this model:

```text
Page composition declares occupants.
Occupants declare requirements.
Page resolves geometry.
Track cells consume geometry.
Widgets render presentation.
```

Avoid this model:

```text
TrackCellColumnBand finds its peers and asks them how tall they are.
```

That is not how the system works.
