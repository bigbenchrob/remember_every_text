# Message Lens Architectural Constitution

## Purpose

This document defines the architectural constitution of MessageLens.

It is not:

- a suggestion
- a style guide
- a historical overview
- optional guidance

It IS:

- a binding architectural contract
- a set of hard invariants
- a description of valid system structure
- a catalog of forbidden drift patterns
- a defense against entropy and shortcut-driven collapse

Code that compiles but violates this constitution is architecturally defective.

The purpose of this constitution is to preserve:

- deterministic semantic flow
- stable graph identity
- projection-oriented UI architecture
- bounded authority
- semantic clarity
- long-term maintainability
- traversal-oriented communication intelligence


---


## Foundational Principle

MessageLens is NOT:

- a traditional messaging client
- a collection of isolated features
- a set of imperative screens

MessageLens IS:

- a semantic communication exploration system
- a traversable communication graph
- a projection-oriented evidence browser
- a relational intelligence system over message archives

Architecture must optimize for:

- semantic integrity
- graph traversal
- deterministic projection
- explicit authority boundaries
- compositional semantics

Not:

- local convenience
- shortcut implementation
- imperative repair
- feature ownership of global state


---


## Core Constitutional Rule

Invalid states must be unrepresentable.

Correct architecture prevents invalid semantic states from existing.

When a bug appears, fix derivation, invalidation, ownership, or projection.

Do NOT add imperative repair.

The solution to invalid state is:

- derivation correction
- invalidation correction
- ownership correction
- projection correction

Not:

- imperative cleanup
- manual synchronization
- reset hacks
- stale-state clearing

If a bug appears to require:

- clear()
- reset()
- force refresh
- manual synchronization

then the architecture has probably been violated upstream.


---


## Domain-Driven Design (ddd)

### Principle

System responsibilities are separated into:

- domain
- application
- infrastructure
- presentation

Each layer has intentionally limited authority.


---


## Allowed Responsibilities

### Domain Layer

Owns:

- semantic concepts
- business meaning
- immutable conceptual rules
- pure domain semantics

Must NOT own:

- SQL
- persistence
- UI rendering
- orchestration
- Flutter widgets


---


### Application Layer

Owns:

- orchestration
- semantic pipelines
- use-case coordination
- semantic interpretation
- graph traversal coordination
- projection composition

May depend on:

- repository abstractions
- semantic services

Must NOT own:

- raw SQL
- SQLite mechanics
- persistence implementation
- Flutter rendering
- imperative UI mutation


---


### Infrastructure Layer

Owns:

- SQL
- SQLite access
- repository implementation
- persistence mechanics
- external system integration
- row/materialization concerns

Must NOT own:

- semantic orchestration
- UI concerns
- business workflow decisions
- projection policy


---


### Presentation Layer

Owns:

- rendering
- interaction forwarding
- visual projection
- display composition

Must NOT own:

- SQL
- persistence mechanics
- orchestration
- semantic policy
- graph construction logic


---


### Invariants

- SQL must never appear outside infrastructure.
- Repository implementations belong only in infrastructure.
- Application layer depends on abstractions, not DB mechanics.
- Widgets render semantics; they do not decide semantics.
- Presentation must not become a coordinator substitute.
- `feature_level_providers.dart` is an outward-facing public seam. Internal
  code inside the same feature or essential module must not import its own
  `feature_level_providers.dart` as a convenience barrel. Internal code must
  import the exact sibling provider, repository, action, model, or type file it
  actually depends on.
- `feature_level_providers.dart` must remain export-only and must not have a
  generated `feature_level_providers.g.dart` sibling. Provider state belongs in
  named application/provider files, not in the public seam.


---


### Common Drift Patterns

### Drift Pattern: Application class directly executes SQL “because it is only one query.”

### Why This Is Dangerous

Causes:

- persistence leakage
- layer collapse
- orchestration coupling
- testing difficulty
- semantic contamination

### Correct Repair

Create:

- repository abstraction
- infrastructure implementation

Consume abstraction from application layer.


---


### Drift Pattern: Repository placed beside caller “for convenience.”

### Why This Is Dangerous

Destroys:

- layer boundaries
- architectural predictability
- persistence isolation

### Correct Repair

Repositories belong in infrastructure.

Always.


---


### Drift Pattern: Internal code imports its own feature-level provider barrel.

### Why This Is Dangerous

Hides:

- real dependencies
- provider-definition ownership
- authority boundaries
- future refactor cost

It allows internal files to reach through the same public surface intended for
external consumers, making local dependencies look smaller while broadening
actual authority.

### Correct Repair

Internal files should import:

- the exact sibling provider file
- the exact repository abstraction or implementation
- the exact action/controller file
- the exact display model or domain type

If the needed provider exists only in `feature_level_providers.dart`, treat that
as transitional provider-definition debt. Move the provider to an owned sibling
file before removing the self-barrel import.

The root `providers.dart` barrel is even narrower: it is a bootstrap artifact.
Production code should not import it directly. If a root provider must remain
defined there temporarily, expose it through a narrow essential seam such as
`essentials/paths/feature_level_providers.dart` or
`essentials/app_mode/feature_level_providers.dart` and consume that seam instead.

Do not add `part 'feature_level_providers.g.dart';` or regenerate
`feature_level_providers.g.dart` for public feature/essential seams. Physical
database provider construction still belongs in `essentials/db`, but generated
provider state must live in named implementation files under
`essentials/db/feature_level_providers/`, not in the public DB seam itself.


---


## Projection-Oriented UI Architecture

### Principle

Visible UI is a projection of semantic state.

UI topology is derived.

It is not authoritative.


---


### Invariants

- Semantic state is primary.
- Visible structures are derived projections.
- UI must deterministically emerge from semantic state.
- View topology must never become durable semantic state.
- Invalid UI combinations must be impossible to represent.


---


### Common Drift Pattern

### Drift Pattern: Stale UI appears.
Agent adds:

- clear command
- reset command
- force refresh

### Why This Is Dangerous

Converts:

- deterministic projection
  into:
- imperative synchronization

Reintroduces:

- stale-state races
- ordering dependence
- hidden repair logic
- topology divergence

### Correct Repair

Fix:

- derivation
- invalidation
- ownership
- semantic flow

Not:

- imperative clearing


---


## ViewSpec System

### Principle

Views are declarative semantic projections.

Features do not imperatively construct global UI topology.


---


### Invariants

- ViewSpec expresses semantic intent.
- Features describe projections.
- UI emerges from state/specification.
- View composition remains declarative.


---


### Forbidden Patterns

- Imperative reconstruction of entire views
- Feature ownership of global window topology
- Widget-driven navigation mutation


---


## Sidebar Cassette System

### Principle

Sidebar authority is compositional, not monolithic.

Features own only their cassette contribution.

No feature owns the entire sidebar.


---


### Invariants

- Features may contribute sidebar cassettes.
- Features may NOT redraw global sidebar topology.
- Top menu ownership is centralized.
- Sidebar structure is coordinated compositionally.


---


### Common Drift Pattern

### Drift Pattern: Feature begins managing:

- sidebar redraw
- cassette ordering
- top-level topology

### Why This Is Dangerous

Creates:

- authority explosion
- sidebar coupling
- topology instability
- feature territoriality

### Correct Repair

Return topology coordination to:

- coordinator
- cassette composition system

Feature owns only:

- its semantic cassette contribution


---


## Coordinator / Resolver / Renderer Split

### Principle

Semantic authority must be separated.


---


### Resolver Responsibilities

Own:

- fact derivation
- semantic resolution
- graph interpretation

Must NOT own:

- rendering
- topology composition
- orchestration


---


### Coordinator Responsibilities

Own:

- composition
- ordering
- topology coordination
- semantic flow assembly

Must NOT own:

- rendering
- raw fact collection


---


### Renderer Responsibilities

Own:

- visual rendering only

Must NOT own:

- orchestration
- semantic interpretation
- policy decisions
- topology control


---


### Invariants

- Renderers render already-decided semantics.
- Coordinators compose semantics.
- Resolvers derive semantics.
- Authority boundaries remain explicit.


---


### Common Drift Pattern

### Drift Pattern: Widget starts:

- making policy decisions
- holding semantic state
- coordinating topology

### Why This Is Dangerous

Creates:

- stale semantic assumptions
- hidden orchestration
- authority leakage
- nondeterministic UI behavior

### Correct Repair

Move:

- semantic derivation → resolver
- topology assembly → coordinator
- rendering → renderer only


---


## Sidebar Flow State

### Principle

Visible sidebar topology is not authoritative state.

Durable semantic intent is authoritative state.


---


### Invariants

- sidebarFlowState is primary.
- Cassette stacks are projections.
- Center panel derives from sidebar semantic state.
- Invalid sidebar/center combinations must be impossible.


---


### Forbidden Patterns

- Manual clearing of center panel
- Cassette stack treated as durable semantic truth
- UI repair through imperative synchronization


---


### Common Drift Pattern

### Drift Pattern: Conversation UI lingers after sidebar changes.
Agent adds:

- clear panel command
- force rebuild
- synchronization patch

### Why This Is Dangerous

Reintroduces:

- state duplication
- stale topology
- ordering dependencies
- imperative repair logic

### Correct Repair

Fix:

- sidebarFlowState derivation
- projection invalidation
- semantic ownership boundaries


---


## Reader / Integrator / Orchestrator (rio)

### Principle

Observation, interpretation, and orchestration are distinct responsibilities.


---


### Reader Responsibilities

Own:

- observation of external reality
- snapshot acquisition
- raw fact collection

Must NOT own:

- orchestration
- semantic decisions
- rendering


---


### Integrator Responsibilities

Own:

- semantic interpretation
- state derivation
- meaning extraction

Must NOT own:

- polling lifecycle
- orchestration timing
- rendering


---


### Orchestrator Responsibilities

Own:

- lifecycle coordination
- execution sequencing
- semantic transition management

Must NOT own:

- raw data collection
- rendering
- direct persistence concerns


---


### Invariants

- Facts flow into meaning.
- Meaning flows into orchestration.
- Polling is observation, not semantic refresh.
- Readers observe reality.
- Integrators derive meaning.
- Orchestrators coordinate action.


---


### Common Drift Pattern

### Drift Pattern: Large orchestration class accumulates:

- SQL
- semantic interpretation
- polling
- rendering concerns

### Why This Is Dangerous

Creates:

- semantic collapse
- unreadable orchestration
- hidden coupling
- nondeterministic update behavior

### Correct Repair

Separate:

- observation
- interpretation
- orchestration

into distinct semantic stages.


---


## Source-Scoped (ss) Graph Architecture

### Principle

Source-scoped identity is foundational architecture.

It is NOT an implementation detail.


---


## Core Insight

Stable source-scoped identity transforms:

- relational reconstruction
  into:
- traversable semantic graph structure


---


### Invariants

- Every imported occurrence receives stable source-scoped identity.
- Relationship traversal preserves occurrence identity.
- Graph traversal must not require provenance reconstruction chains.
- Semantic layers interpret the graph.
- Semantic layers do NOT replace base occurrence identity.


---


### Forbidden Patterns

- GUID-collapse replacing occurrence identity
- Provenance reconstruction chains
- Hidden deduplication semantics
- Identity mutation during projection


---


### Common Drift Pattern

### Drift Pattern: Convenience lookup bypasses source-scoped traversal.

### Why This Is Dangerous

Reintroduces:

- provenance ambiguity
- reconstruction burden
- identity collapse
- graph instability

### Correct Repair

Traverse:

- explicit graph relationships
- stable SS identity endpoints


---


## Graph Semantics

### Principle

Relationships are primary.

Tables materialize relationships.


---


### Invariants

- Conversations are first-class graph entities.
- Traversal paths should be direct and explicit.
- Semantic overlays operate on graph structure.
- Query behavior should align with human associative recall.


---


### Forbidden Patterns

- Reconstructing conversations repeatedly from raw lookup chains
- Feature-local relationship logic
- Hidden graph semantics


---


## Message Evidence System

### Principle

All message evidence surfaces are projections over the same communication graph.

The system must feel coherent.


---


### Invariants

There must be ONE canonical message evidence rendering language.

All evidence surfaces share:

- alignment semantics
- spacing rules
- metadata treatment
- timestamp behavior
- attachment rendering
- search highlighting
- reaction rendering
- semantic overlay behavior

Only:

- projection/query source
  may vary.


---


## Preferred Direction

Aligned conversational rendering is preferred over flat archival rendering.

Reason:
alignment emphasizes:

- conversational directionality
- participant interaction
- relational flow
- communication topology


---


### Forbidden Patterns

- Multiple unrelated message rendering systems
- Surface-specific visual semantics
- Projection-specific message formatting rules


---


## Semantic Preservation Vs Field Preservation

### Principle

Legacy parity does NOT mean field parity.

The goal is:

- semantic integrity

Not:

- schema accumulation


---


### Invariants

Preserve:

- important source facts
- semantic classification primitives
- traversal semantics
- investigative/search semantics

Do NOT blindly restore:

- legacy blobs
- unused payloads
- implementation artifacts
- obsolete fields


---


### Common Drift Pattern

### Drift Pattern: Legacy field restored “because legacy had it.”

### Why This Is Dangerous

Creates:

- schema bloat
- semantic confusion
- accidental architecture regression
- payload accumulation

### Correct Repair

Restore only if:

- it preserves source integrity
- supports semantic classification
- improves traversal/search/review
- supports named product behavior


---


## Tempting Shortcut Rule

### Principle

Local convenience is not architectural justification.


---


## Mandatory Question

Before implementing ANY shortcut, ask:

“What architectural entropy does this reintroduce?”


---


## Common Shortcut Smells

- “Just add a clear()”
- “Just run the SQL here”
- “Just store state locally”
- “Just rebuild the sidebar”
- “Just patch the renderer”
- “Just bypass the graph”
- “Just cache this semantic assumption”


---


## Why These Are Dangerous

These shortcuts usually reintroduce:

- stale state
- authority leakage
- hidden coupling
- provenance ambiguity
- semantic collapse
- topology instability

These are exactly the failure modes this architecture evolved to eliminate.


---


## Final Constitutional Principle

The architecture repeatedly evolved away from:

- imperative reconstruction
- mutable topology
- implicit coupling
- feature-owned global state
- identity ambiguity

and toward:

- deterministic semantic projection
- explicit authority boundaries
- compositional topology
- stable graph identity
- semantic traversal

Future implementation work must continue moving in that direction.

Not backward.
