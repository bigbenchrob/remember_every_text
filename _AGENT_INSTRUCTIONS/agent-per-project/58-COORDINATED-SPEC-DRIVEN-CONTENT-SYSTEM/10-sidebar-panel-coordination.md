# Sidebar and Panel Coordination

## Scope of this document

This document describes how the sidebar cassette system, center panel, and
right panel should coordinate in a declarative system, and where the current
implementation is still mixed.

## Sidebar responsibilities

The sidebar has two distinct responsibilities that must stay separate:

1. It expresses branch context and available controls
2. It renders a vertical composition of cassettes with shared layout rules

Those two responsibilities are related, but they are not the same.

### Semantic sidebar state

The semantic meaning of the messages-mode sidebar belongs primarily in
`SidebarFlowState`.

Today that state includes:

- active top-menu branch
- chosen contact
- selected handle
- scroll target
- regular versus recovered-deleted mode

This state answers questions like:

- Are we in the contacts branch or a global branch?
- Is a contact chosen?
- If a contact is chosen, are we showing regular messages or recovered
  deleted-message candidates?
- Is a handle filter active?

The sidebar rack should not have to be reverse-engineered to answer those
questions.

### Sidebar cassette layout

`CassetteRackState` still matters, but it should be understood as the authored
sidebar composition, not the ultimate owner of all branch meaning.

Its job is:

- order cassette specs
- apply cascade rules
- present a coherent vertical branch

The recent structural improvement is that the sidebar transport layer now moves
`ResolvedSidebarCassette` objects instead of `List<Widget>`.

Each resolved cassette now carries:

- the source `CassetteSpec`
- its cassette index
- a semantic payload object
- computed top spacing

That is meaningfully better than transporting already-built cassette widgets.

## Sidebar cassette payloads versus widgets

The sidebar system has to distinguish between three different concepts:

1. Rack spec
   What cassette exists in the branch
2. Resolved payload
   What semantic content and layout role the cassette needs
3. Render widget
   The actual `SidebarCassetteCard`, `SidebarInfoCard`, or
   `SidebarNavigationCard` placed into the tree

The desired direction is:

- specs and payloads travel through coordination layers
- widgets are built only at the render edge

### Current good direction

The current left-sidebar host now renders wrapper chrome at the edge in
`panel_widget_providers.dart`.

That is an important architectural correction because:

- it removes the old left-panel widget snapshot cache
- it stops transporting a precomposed `List<Widget>` through the coordinator
- it makes section spacing and card wrapping depend on current resolved payloads

### Remaining impurity

The system still allows `SidebarCassetteCardViewModel.featureComplex`, which
means a feature can hand the sidebar payload layer an already-built child widget
subtree.

This is the most important remaining impurity in the sidebar architecture.

The transport is cleaner than before, but it is not yet fully immutable data
all the way down.

## Sidebar layout should not infer meaning from widget shape

The layout host still performs widget-shape inspection in order to decide:

- whether something is a pinned app control cassette
- whether something should expand vertically

That is better than caching stale subtrees, but it still means some layout
decisions are discovered by looking at built widgets rather than handled purely
from semantic descriptors.

The ideal end state is for layout decisions to operate directly on resolved
cassette descriptors, not on widget wrappers after they have already been
materialized.

## Center panel as a projection of sidebar flow

For the flow-managed messages branch, the center panel should derive from the
same canonical branch state that drives the sidebar.

In current code, `SidebarFlowState.projectedCenterSpec` already expresses this
idea. For example:

- contacts branch + chosen contact + regular scope -> `MessagesSpec.forContact`
- contacts branch + chosen contact + recovered scope ->
  `MessagesSpec.recoveredUnlinkedMessages(contactId: ...)`
- global search branch -> `MessagesSpec.globalTimeline`
- global recovered branch -> `MessagesSpec.recoveredUnlinkedMessages`

This is the correct architectural direction.

### What should happen on a semantic transition

When canonical sidebar flow changes:

1. flow state changes
2. rack projection changes
3. projected center spec changes
4. incompatible center/right panel content is removed or replaced

The transition should be understood as one semantic change with multiple
surface projections.

The center panel should not act as an independent second source of truth for
flow-managed message content.

## Right panel as a dependent surface

The right panel is not a free-standing peer of the center panel in the messages
branch.

It is subordinate content.

If the active center spec no longer supports recovered attachment context, the
right panel must become invalid immediately.

That is a dependency rule, not a visual preference.

## Sidebar-independent center surfaces

Not every center panel needs to be governed by sidebar-flow meaning.

There are legitimate sidebar-independent surfaces such as:

- import
- onboarding
- environment readiness
- other explicit system-level surfaces marked as sidebar-independent

Those surfaces are allowed to park the sidebar or override normal flow-driven
projection.

The key distinction is explicitness:

- sidebar-independent surfaces are explicitly declared as such
- flow-managed message surfaces are not

## The single-writer goal

The long-term goal is single-writer semantics per surface meaning.

For the messages branch, that implies:

- `SidebarFlowState` owns branch meaning
- rack and center projection are derived from it
- reconciliation is a defensive guard, not an alternate authoring path

## Where the current implementation is still muddled

The current implementation still has multiple imperative pathways affecting
panel state:

- `SidebarFlow._syncProjectedCenterPanel()`
- `reconcileSidebarPanels(...)`
- deferred clear logic such as `_schedulePanelClearIfNoProjectedCenter()`

Those paths were introduced to keep the UI coherent in the presence of rebuild
races, and they are understandable as stabilizing measures.

However, they also mean the architecture has not fully achieved a single,
unambiguous projection path yet.

## What a stricter end state would look like

In a stricter design:

- semantic transitions update only canonical flow state
- rack and panel projections derive from that state
- reconciliation becomes an assertion-oriented fail-safe, or disappears for the
  fully flow-managed branch
- no downstream layer can revive stale center content by mounting a widget with
  its own old assumptions

That is the standard the system should be evaluated against.