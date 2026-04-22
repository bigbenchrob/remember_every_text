TL;DR

The spec system is cross-surface because durable app meaning usually affects more than one surface. Global flow state is the source of durable truth; specs are the common language that projects that truth into sidebar, panel, onboarding, settings, and future surfaces.

# Cross-Surface Model

## Why this is not sidebar-only

The sidebar cassette system is one specialization of the spec system, not the whole system.

The app has multiple coordinated surfaces:

* left sidebar
* center panel
* right panel
* onboarding and readiness flows
* settings surfaces
* future contextual surfaces such as tooltips or assistants

Those surfaces can display different projections of the same user intent. A selected contact, active message scope, or onboarding state may need to affect both the sidebar composition and the panel content. If each surface owns its own interpretation, the app can display semantically impossible combinations.

The cross-surface model prevents that by making state, specs, resolution, and rendering distinct layers.

## Canonical flow

The system-level flow is:

User intent / global flow state
→ Spec
→ Coordinator
→ Resolver
→ Payload / ViewModel
→ Rendering

This is a single architecture with surface-specific contracts.

## Global flow state is durable truth

Global flow state owns durable semantic meaning.

Examples of durable meaning include:

* active sidebar mode
* active top-level branch
* chosen contact
* selected handle
* message scope such as regular or recovered
* onboarding or readiness gate state

Durable meaning must be inspectable without reading rendered widgets. If a future agent needs to know what branch the app is in, it should read semantic state and specs, not a mounted tree.

## Specs are the common language

Specs translate durable meaning into surface-specific declarations.

Examples:

* `CassetteSpec` declares sidebar cassette structure.
* `ViewSpec` declares panel content selection.
* onboarding or readiness specs can declare system surfaces without coupling those surfaces to feature internals.

Specs are common language because they are:

* declarative
* exhaustively handled
* owned at explicit boundaries
* reconstructable from state
* independent of rendered widgets

## Surface participation

Each surface participates in the shared model through its own state and coordinator.

Sidebar:

* uses cassette specs and rack/topology projection
* renders a vertical stack under essentials-owned layout constraints
* distinguishes stable projection from ephemeral projection

Panel:

* uses view specs and panel stacks
* renders center/right content selected by semantic navigation
* clears or replaces content that no longer matches active flow

Onboarding and readiness:

* may temporarily dominate or park normal app surfaces
* must be explicit system-level states, not hidden widget-only gates
* should project into specs or equivalent semantic surface declarations when they coordinate with other surfaces

Settings and future surfaces:

* should use the same Spec → Coordinator → Resolver → Payload / ViewModel → Rendering model
* must not create ad hoc routing paths because the surface appears small

## Coordinated behavior

A single semantic transition may need to update several projections.

Example:

1. User selects a contact.
2. Global flow state records the selected contact and message scope.
3. Sidebar cassette projection updates to contact-specific cassettes.
4. Center panel projection updates to the matching `ViewSpec`.
5. Right panel content is cleared unless still compatible.

The transition is one semantic change with multiple surface projections. Do not treat the panel update and sidebar update as unrelated UI actions.

## Deterministic reconstruction

The system must be reconstructable from durable state.

That means:

* stable sidebar topology can be regenerated from flow state
* active panel content can be predicted from flow-managed state
* onboarding gates can be re-entered from durable readiness state
* widget rebuild order cannot resurrect obsolete meaning

Deterministic reconstruction is the reason specs must stay declarative and why rendering must remain downstream.

## Independent surfaces are explicit

Some surfaces are legitimately sidebar-independent. Import, onboarding, environment readiness, and other system flows may override or park normal sidebar-driven projection.

That independence must be explicit.

Allowed:

* a declared sidebar-independent system surface
* a flow state transition that intentionally clears or parks dependent surfaces
* a spec variant that encodes the independent surface

Forbidden:

* panel content that silently ignores active sidebar flow
* sidebar widgets that imperatively insert unrelated center content
* hidden local widget state that acts as a second source of truth

## Reference material

For deeper historical detail, use:

* [REFERENCE/50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/](../REFERENCE/50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/)
* [REFERENCE/58-COORDINATED-SPEC-DRIVEN-CONTENT-SYSTEM/](../REFERENCE/58-COORDINATED-SPEC-DRIVEN-CONTENT-SYSTEM/)
