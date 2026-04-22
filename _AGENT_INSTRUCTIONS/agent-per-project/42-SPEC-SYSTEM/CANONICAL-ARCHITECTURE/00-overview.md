TL;DR

The app is built around a spec-driven pipeline that separates intent, orchestration, data resolution, and rendering.

All cross-surface behavior follows this pattern:

Spec → Coordinator → Resolver → Payload / ViewModel → Rendering

This structure exists to enforce:

* clear ownership boundaries
* deterministic UI reconstruction from state
* cross-surface consistency across sidebar, panel, onboarding, and related surfaces
* prevention of feature-level orchestration drift

If you are adding or modifying behavior, your primary responsibility is to place your logic in the correct stage of this pipeline.

---

# Spec System Overview

## Purpose of the spec system

The spec system exists to solve a specific problem:

How do we allow features to contribute rich UI behavior without allowing them to take over application orchestration?

Without structure, feature code tends to:

* directly build widget trees
* embed navigation logic
* manage its own state transitions
* diverge from other surfaces

The spec system prevents this by:

1. representing intent and state as explicit specs
2. routing those specs through a controlled orchestration layer
3. restricting features to data production and approved interpretation roles
4. centralizing rendering decisions at the appropriate downstream layer

The result is a system where:

* behavior is predictable
* UI can be reconstructed from state
* features remain modular
* multiple surfaces stay aligned

## The canonical pipeline

All spec-driven behavior follows this pipeline:

Spec → Coordinator → Resolver → Payload / ViewModel → Rendering

Each stage has a strict role.

## Spec

A spec is a declarative description of what should happen or what should be shown.

Examples:

* a sidebar cassette spec
* a panel view spec
* a settings menu spec
* a cross-surface intent encoded as a spec variant

A spec must:

* be serializable or reconstructable
* contain no rendering logic
* represent intent or configuration, not execution

Specs are the boundary between:

* global flow state / user intent
* the rendering system

## Coordinator

The coordinator is responsible for:

* receiving a spec
* selecting the correct handling path
* orchestrating any required resolution work
* producing structured output suitable for rendering

The coordinator must:

* be asynchronous where the surface contract requires it
* return data, payloads, or view models as defined by the canonical surface contract
* not perform rendering
* not contain business logic
* not watch reactive providers for layout or structural decisions

The coordinator is the bridge between:

* declarative intent
* resolved data suitable for presentation

## Resolver

Resolvers are responsible for:

* fetching or deriving data required by the spec
* transforming app or feature data into structured payloads or view models

Resolvers:

* may access databases, services, or providers through approved project patterns
* must return data, not chrome
* must remain side-effect controlled and predictable

Resolvers are the data-resolution layer of the spec pipeline.

## Payload / ViewModel

The payload or view model is the structured data passed to rendering.

It includes:

* content data
* rendering hints such as layout role, alignment, placement, or surface role
* metadata needed for consistent presentation

It must:

* be inert
* be serializable or easily testable where practical
* contain no app-level orchestration
* contain no widget references for new canonical work

## Panel legacy note

Older panel reference material may describe synchronous widget-returning feature coordinators for `ViewSpec` handling. Treat that as a legacy/current-state migration boundary, not as an approved pattern for new work.

New work must preserve the data-only coordinator boundary:

* coordinators route and return structured data, payloads, or view models
* resolvers produce resolved data
* widgets are constructed only downstream at the render edge

This layer defines what will be rendered, not how app-level flow is controlled.

## Rendering

Rendering is the final stage where:

* widgets are constructed
* layout decisions are applied
* design system constraints are enforced

Rendering happens:

* in essentials-owned components for shared structures, chrome, and surface composition
* in feature-owned render-edge components for feature-specific content when the surface contract allows it

Rendering must respect:

* the data-only boundary from previous stages
* layout constraints defined by essentials
* cross-surface consistency rules

## Cross-surface model

The spec system is not limited to one UI surface.

It coordinates behavior across:

* sidebar cassette surfaces
* center and right panel surfaces
* onboarding and readiness surfaces
* settings and future contextual surfaces

A single user action or state change may:

* update global flow state
* produce new specs for multiple surfaces
* trigger coordinated sidebar and panel updates
* invalidate downstream surfaces that no longer match the current flow

This is why specs are necessary: they provide a common language across surfaces.

## Global flow state

The system is driven by global flow state that represents durable application meaning.

It may include:

* current context such as selected contact, active branch, or active mode
* active filters and settings
* durable state distinct from ephemeral projection

Global flow state:

* feeds spec generation
* ensures consistent reconstruction of UI
* prevents divergence between surfaces

Key principle:

UI is not the source of truth.
State is the source of truth.
Specs are derived from that state.

## Stable vs ephemeral behavior

Not all user actions should persist.

The system distinguishes between:

Stable specs:

* derived from durable state
* persist across navigation and surface changes
* reconstructable from global flow state

Ephemeral specs:

* transient projections
* do not persist
* are replaced or discarded on context changes

This distinction prevents:

* accidental persistence of temporary UI states
* corruption of the global flow model
* procedural reconstruction of topology from visible widgets

## Feature responsibilities

Features participate in the system, but do not control it.

Features are responsible for:

* defining and interpreting approved feature-owned spec variants
* resolving data through resolvers
* producing payloads or view models
* providing feature-specific render-edge components when the surface contract allows it

Features must not:

* own app-level orchestration or navigation
* bypass the spec system
* introduce hidden state outside global flow
* return widgets across coordinator boundaries for new work
* construct shared sidebar chrome

The boundary is strict:

Features provide content.
The app controls flow.

## Where to go next

Read:

1. [10-cross-surface-model.md](10-cross-surface-model.md) for the shared model across surfaces
2. [20-sidebar-cassette-system.md](20-sidebar-cassette-system.md) for sidebar cassette specialization
3. [30-panel-viewspec-system.md](30-panel-viewspec-system.md) for panel view-spec handling
4. [40-feature-responsibilities.md](40-feature-responsibilities.md) for feature boundaries
5. [90-invariants-and-contracts.md](90-invariants-and-contracts.md) before implementing any spec-system change
