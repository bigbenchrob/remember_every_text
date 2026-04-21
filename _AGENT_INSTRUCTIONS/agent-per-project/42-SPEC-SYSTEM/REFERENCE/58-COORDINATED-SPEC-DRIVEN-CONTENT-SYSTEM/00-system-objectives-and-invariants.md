# System Objectives and Invariants

## Purpose

The application needs a coordinated content system across three visible
surfaces:

1. Left sidebar
2. Center panel
3. Right panel

For the messages mode branch in particular, those surfaces should behave like
interlocking gears.

If one gear changes, every dependent gear must rotate into a compatible state.
The system should not permit semantically impossible combinations to linger due
to rebuild timing, widget caching, or stale post-frame effects.

## The target model

The intended model is:

`user intent -> canonical semantic state -> derived specs/payloads -> render-edge widgets`

That means:

- User actions should update canonical semantic state, not directly mutate
  ad hoc widget state across multiple layers.
- Sidebar cassette order should be a projection of semantic state.
- Center-panel `ViewSpec` should be a projection of the same semantic state.
- Right-panel eligibility should be a projection of the active center spec.
- Message rows should be hydrated from scope and ordinal information, not from
  retained widget subtrees.

## The interlocking gears

In messages mode, the gears are:

1. Canonical flow meaning
   `SidebarFlowState` owns branch meaning such as:
   - top menu branch
   - chosen contact
   - selected handle
   - regular versus recovered-deleted scope
   - optional scroll target
2. Sidebar branch projection
   `CassetteRackState` expresses which cassettes should appear and in what
   order
3. Center-panel projection
   `SidebarFlowState.projectedCenterSpec` expresses the correct center-surface
   `ViewSpec` for the current flow state
4. Right-panel compatibility
   The right panel may only exist if the active center spec supports that
   subordinate content
5. Timeline scope
   Message surfaces interpret the center-panel spec as a
   `MessageTimelineScope`
6. Ordinal access and row hydration
   Message rows are loaded by stable ordinal and hydrated on demand

Each lower gear depends on the higher gear. None of those downstream gears
should be required to infer the meaning of the upstream state by inspecting
widgets.

## What the system should make impossible

The target system should make these configurations impossible, not merely
unlikely:

- Contact-scoped regular messages in the center while the sidebar is in a
  recovered-deleted branch for that contact
- Messages for contact A in the center while the sidebar hero/info/filter
  branch is showing contact B
- A right-side recovered-attachment panel remaining open after the center panel
  leaves a recovered-capable message surface
- A stale contact picker subtree continuing to render old filter state after
  canonical picker state has changed
- A sidebar section appearing to belong to one branch while its center panel
  still reflects an older branch

If the architecture allows those states to appear, the architecture is not yet
declarative enough.

## Immutable boundary goals

To achieve the target model, the system should preserve these boundaries:

### 1. Semantic state boundary

Semantic meaning belongs in state objects such as `SidebarFlowState`,
`CassetteRack`, `PanelStack`, and scope/spec classes.

It must not live implicitly in:

- a prebuilt widget subtree
- a stale cached `Widget`
- a post-frame closure that captured outdated state
- a local render wrapper that became detached from canonical meaning

### 2. Transport boundary

Providers that connect architecture layers should transport only semantic data
or immutable render payloads, not already-built widget trees wherever that can
be avoided.

Transport objects may include:

- specs
- payload view models
- identifiers
- layout roles
- placement constraints

They should ideally not include:

- feature-owned child widget subtrees
- stale snapshots of previously rendered surfaces

### 3. Render-edge boundary

Actual widgets should be built as late as possible, at the surface host or the
final presentation layer that owns the rendering contract.

This keeps rendering a pure function of current state.

## Why this matters

The bug pattern from this session was not simply "a panel forgot to clear."

The deeper issue was that semantic truth and render truth had drifted apart.
Canonical state said one thing, but mounted widget trees and multiple
imperative writers allowed older meaning to remain visible.

The long-term objective is therefore stronger than "clear the panel correctly."
It is:

- one semantic owner per piece of meaning
- one clear projection path per surface
- render widgets as a terminal output, not as state carried between layers

## Success criteria

The system is working when these statements are true:

- Inspecting canonical flow state is sufficient to predict the sidebar branch
  and center panel without reading UI code.
- Changing a branch by semantic transition automatically invalidates
  incompatible downstream content.
- Widget rebuild order cannot resurrect semantically obsolete content.
- Attachment availability changes do not alter message meaning, only message
  hydration/provenance.
- The same message can render coherently whether its image comes from the live
  Messages directory, the MessageLens archive, or a deterministic historical
  import.