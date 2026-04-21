TL;DR

The app is built around a spec-driven pipeline that separates intent, orchestration, data resolution, and rendering.

All cross-surface behavior follows this pattern:

Spec → Coordinator → Resolver → Payload / ViewModel → Rendering

This structure exists to enforce:

* clear ownership boundaries
* deterministic UI reconstruction from state
* cross-surface consistency (sidebar, panel, onboarding)
* prevention of feature-level orchestration drift

If you are adding or modifying behavior, your primary responsibility is to place your logic in the correct stage of this pipeline.

⸻

Purpose of the spec system

The spec system exists to solve a specific problem:

How do we allow features to contribute rich UI behavior without allowing them to take over application orchestration?

Without structure, feature code tends to:

* directly build widget trees
* embed navigation logic
* manage its own state transitions
* diverge from other surfaces

The spec system prevents this by:

1. Representing intent and state as explicit specs
2. Routing those specs through a controlled orchestration layer
3. Restricting features to data production and interpretation roles
4. Centralizing rendering decisions at the appropriate layer

The result is a system where:

* behavior is predictable
* UI can be reconstructed from state
* features remain modular
* multiple surfaces stay aligned

⸻

The canonical pipeline

All spec-driven behavior follows this pipeline:

Spec
→ Coordinator
→ Resolver
→ Payload / ViewModel
→ Rendering

Each stage has a strict role.

⸻

Spec

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
    and
* the rendering system

⸻

Coordinator

The coordinator is responsible for:

* receiving a spec
* selecting the correct handling path
* orchestrating any required resolution work
* producing a view model (or equivalent structured output)

The coordinator must:

* be asynchronous where necessary
* NOT return widgets
* NOT perform rendering
* NOT watch reactive providers for layout or structural decisions

The coordinator is the bridge between:

* declarative intent (spec)
    and
* resolved data suitable for presentation

⸻

Resolver

Resolvers are responsible for:

* fetching or deriving data required by the spec
* transforming app or feature data into structured payloads

Resolvers:

* may access databases, services, or providers
* must return data, not UI
* must remain side-effect controlled and predictable

Resolvers are the data layer of the spec pipeline.

⸻

Payload / ViewModel

The payload or view model is the structured data passed to rendering.

It includes:

* content data
* rendering hints (e.g. layout style, role, alignment)
* any metadata needed for consistent presentation

It must:

* be inert (no behavior)
* be serializable or easily testable
* contain no widget references or build logic

This layer defines WHAT will be rendered, not HOW it is built in Flutter.

⸻

Rendering

Rendering is the final stage where:

* widgets are constructed
* layout decisions are applied
* design system constraints are enforced

Rendering happens:

* in essentials-owned components for shared structures
* in feature-owned builders for feature-specific content (when appropriate)

Rendering must respect:

* the data-only boundary from previous stages
* layout constraints defined by essentials
* cross-surface consistency rules

⸻

Cross-surface model

The spec system is not limited to one UI surface.

It coordinates behavior across:

* sidebar (cassette system)
* panel (view spec system)
* onboarding and other surfaces

A single user action or state change may:

* update the global flow state
* produce new specs for multiple surfaces
* trigger coordinated updates across sidebar and panel

This is why specs are necessary:
they provide a common language across surfaces.

⸻

Global flow state

The system is driven by a global flow state that represents:

* current context (e.g. selected contact, mode)
* active filters and settings
* durable vs ephemeral state

The global flow state:

* feeds spec generation
* ensures consistent reconstruction of UI
* prevents divergence between surfaces

Key principle:

UI is not the source of truth.
State is the source of truth.
Specs are derived from that state.

⸻

Stable vs ephemeral behavior

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

⸻

Feature responsibilities

Features participate in the system, but do not control it.

Features are responsible for:

* interpreting their spec variants
* resolving data through resolvers
* producing payloads or view models
* providing feature-specific rendering components when needed

Features must NOT:

* return widgets from coordinators
* own orchestration or navigation
* bypass the spec system
* introduce hidden state outside the global flow

The boundary is strict:

Features provide content.
The app controls flow.

⸻

Essentials responsibilities

The essentials layer is responsible for:

* orchestrating the pipeline
* enforcing layout and rendering constraints
* maintaining the cassette rack and panel structures
* ensuring cross-surface consistency

Essentials decides:

* where content appears
* how it is structured
* how multiple specs interact

⸻

Invariants

The system relies on several non-negotiable invariants:

* No widgets cross the coordinator boundary
* Specs are the only input to orchestration
* Global flow state is the only source of durable truth
* Rendering is downstream of data, not mixed with it
* Ephemeral behavior must not leak into stable state
* Cross-surface behavior must be consistent and spec-driven

Violating these invariants leads to:

* architectural drift
* inconsistent UI behavior
* fragile state reconstruction
* tight coupling between features and app flow

⸻

Mental model

The system should be understood as:

A deterministic pipeline, not an event-driven UI patchwork.

User intent and state changes:

* do not directly build UI
* do not directly manipulate widgets

Instead, they:

* update state
* produce specs
* flow through controlled layers
* result in consistent rendering across surfaces

⸻

When implementing changes

Before writing code, determine:

1. What is the spec?
2. Which coordinator handles it?
3. What data must be resolved?
4. What payload or view model should be produced?
5. Where should rendering occur?

If you cannot answer these questions clearly, the design is likely violating the architecture.

⸻

Relationship to other documents

This document defines the system at a high level.

For deeper detail, see:

* 10-cross-surface-model.md
    How multiple surfaces are coordinated
* 20-sidebar-cassette-system.md
    Sidebar-specific behavior and topology
* 30-panel-viewspec-system.md
    Panel content and view selection
* 40-feature-responsibilities.md
    Strict rules for feature participation
* 90-invariants-and-contracts.md
    Non-negotiable rules and anti-patterns

⸻

Closing principle

The spec system is not just an implementation detail.

It is the mechanism that allows:

* complex UI behavior
* multiple coordinated surfaces
* clean feature boundaries
* long-term maintainability

Every change should reinforce that system, not bypass it.