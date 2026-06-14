# Common Drift Patterns

## Purpose

This document catalogs the most common forms of architectural drift encountered during MessageLens development.

These are NOT hypothetical examples.

These are recurring failure modes that repeatedly emerge when:

- local convenience overrides architecture
- implementation shortcuts bypass invariants
- semantic boundaries become blurred
- authority leaks between layers

The purpose of this document is to help agents recognize:

- dangerous implementation instincts
- invalid repairs
- architectural regression patterns
- entropy reintroduction

Many of these shortcuts initially appear:

- harmless
- faster
- pragmatic
- temporary

In practice, they almost always:

- accumulate hidden coupling
- reintroduce stale state
- destabilize projections
- collapse semantic boundaries
- increase long-term implementation difficulty


---


## Drift Pattern: Imperative UI Repair

### Example

- clear()
- reset()
- force refresh
- manual synchronization
- explicit UI invalidation patch

added because:

- stale content appeared
- sidebar changed
- center panel did not update correctly


---


### Why This Happens

The agent attempts to repair:

- symptoms
  rather than:
- semantic derivation failure


---


### Why This Is Dangerous

This converts:

- deterministic projection
  into:
- imperative synchronization

It reintroduces:

- stale-state races
- ordering dependence
- hidden repair logic
- projection instability
- duplicated state authority


---


### Correct Architectural Response

When a bug appears, fix derivation, invalidation, ownership, or projection.

Do NOT add imperative repair.

Identify:

- authoritative semantic state
- broken derivation
- invalid invalidation boundary
- projection ownership violation

Fix:

- semantic flow

Not:

- UI symptoms


---


### Constitutional Reminder

Invalid states must be unrepresentable.


---


## Drift Pattern: SQL Leaking Into Application Layer

### Example

Application class directly executes SQL because:

- “it is only one query”
- “this is temporary”
- “the repository abstraction would take longer”


---


### Why This Happens

Local convenience optimization.


---


### Why This Is Dangerous

Reintroduces:

- persistence leakage
- layer collapse
- infrastructure/application coupling
- hidden DB dependencies
- testability degradation


---


### Correct Architectural Response

- Define repository abstraction
- Implement in infrastructure layer
- Consume abstraction from application layer


---


### Constitutional Reminder

SQL belongs ONLY in infrastructure.

Always.


---


## Drift Pattern: Repository Placed Beside Caller

### Example

Repository created adjacent to application/presentation code for convenience.


---


### Why This Happens

Agent attempts local organizational simplification.


---


### Why This Is Dangerous

Destroys:

- predictable layering
- persistence isolation
- DDD structure
- long-term navigability

Creates:

- pseudo-layers
- local architecture forks


---


### Correct Architectural Response

Repositories belong in infrastructure.

The caller location does not determine repository placement.


---


## Drift Pattern: Renderer Authority Leak

### Example

Widget begins:

- making semantic decisions
- holding semantic state
- coordinating topology
- interpreting graph meaning
- applying policy logic


---


### Why This Happens

Renderers are close to user interaction, so semantic logic “accumulates naturally.”


---


### Why This Is Dangerous

Creates:

- hidden orchestration
- stale semantic assumptions
- duplicated policy logic
- nondeterministic rendering behavior
- authority collapse


---


### Correct Architectural Response

Move:

- semantic derivation → resolver/integrator
- topology coordination → coordinator
- rendering → renderer only


---


### Constitutional Reminder

Widgets render already-decided semantics.

They do not decide semantics.


---


## Drift Pattern: Feature-Owned Global Topology

### Example

Feature:

- redraws sidebar
- mutates top-level navigation
- controls cassette ordering
- reconstructs shared UI topology


---


### Why This Happens

Feature implementation begins solving broader UI coordination problems.


---


### Why This Is Dangerous

Creates:

- authority explosion
- topology instability
- feature territoriality
- hidden coupling
- sidebar inconsistency


---


### Correct Architectural Response

Features contribute:

- semantic projections
- cassette contributions

Global topology remains:

- coordinator-owned
- compositionally assembled


---


## Drift Pattern: Local State Becomes Authoritative

### Example

Widget/service locally caches:

- semantic assumptions
- selected entities
- projection state
- graph interpretation

instead of deriving from authoritative semantic state.


---


### Why This Happens

Local caching initially appears simpler and faster.


---


### Why This Is Dangerous

Creates:

- stale semantic state
- invalid projections
- synchronization requirements
- authority ambiguity


---


### Correct Architectural Response

Durable semantic intent belongs in:

- semantic state systems
- sidebarFlowState
- graph-derived projections

Visible UI structures remain projections only.


---


## Drift Pattern: Sidebar Topology Treated As State

### Example

Cassette stack itself becomes:

- semantic truth
- navigation authority
- durable state holder


---


### Why This Happens

Visible topology is mistakenly treated as authoritative.


---


### Why This Is Dangerous

Creates:

- stale cassette state
- reconstruction ambiguity
- invalid sidebar/center combinations
- imperative synchronization pressure


---


### Correct Architectural Response

sidebarFlowState is authoritative.

Cassette topology is derived projection only.


---


## Drift Pattern: Large Orchestration Class Collapse

### Example

Single orchestration class accumulates:

- polling
- SQL
- semantic interpretation
- orchestration
- rendering preparation
- synchronization logic


---


### Why This Happens

Convenience accumulation over time.


---


### Why This Is Dangerous

Creates:

- unreadable orchestration
- hidden coupling
- semantic collapse
- impossible debugging
- nondeterministic update flow


---


### Correct Architectural Response

Separate:

- readers
- integrators
- orchestrators

Maintain:
facts → meaning → orchestration


---


## Drift Pattern: GUID Shortcuts Bypassing SS Graph

### Example

Convenience lookup bypasses:

- source-scoped identity
- graph traversal
- occurrence preservation

using:

- GUID shortcuts
- ad hoc joins
- hidden deduplication logic


---


### Why This Happens

Graph traversal initially appears more complex than direct lookup.


---


### Why This Is Dangerous

Reintroduces:

- provenance ambiguity
- reconstruction burden
- identity collapse
- hidden semantic assumptions


---


### Correct Architectural Response

Traverse explicit graph relationships using stable source-scoped identity.


---


### Constitutional Reminder

Source-scoped identity is foundational architecture.

Not implementation detail.


---


## Drift Pattern: Legacy Field Accumulation

### Example

Field restored merely because:

- “legacy had it”
- “might be useful later”
- “easier than deciding now”

Examples:

- payload blobs
- balloon internals
- obsolete app-message structures


---


### Why This Happens

Fear of losing source information.


---


### Why This Is Dangerous

Creates:

- schema bloat
- semantic confusion
- accidental architecture regression
- unclear projection boundaries


---


### Correct Architectural Response

Preserve:

- source facts
- semantic primitives
- traversal semantics

Do NOT preserve:

- historical implementation baggage

without explicit product justification.


---


## Drift Pattern: Projection-Specific Message Rendering

### Example

Different message rendering systems emerge for:

- search
- heatmap
- conversation view
- recovered messages
- semantic overlays


---


### Why This Happens

Each feature evolves independently.


---


### Why This Is Dangerous

Creates:

- inconsistent evidence language
- cognitive fragmentation
- spatial instability
- UI incoherence


---


### Correct Architectural Response

One canonical MessageEvidenceList rendering language.

Different projections.
Same evidence semantics.


---


## Drift Pattern: Temporary Shortcut Normalization

### Example

Agent says:

- “temporary fix”
- “quick patch”
- “just for now”
- “fast exploratory implementation”


---


### Why This Happens

Local optimization pressure.


---


### Why This Is Dangerous

Temporary architectural violations almost always become permanent.

Entropy accumulates asymmetrically:

- shortcuts are easy to add
- expensive to remove


---


### Correct Architectural Response

Fast exploration must still respect:

- DDD boundaries
- semantic authority
- deterministic projection
- graph invariants


---


## Meta-Pattern:

## Symptom Repair Instead Of Invariant Repair

## Core Warning

Most architectural drift begins when:

- visible symptoms
  are repaired directly
  instead of:
- identifying violated invariants


---


## Correct Question

Do NOT ask:

“How do I patch this behavior?”

Ask:

“What invariant became violated such that this invalid state became representable?”


---


## Final Reminder

The MessageLens architecture evolved specifically to eliminate:

- stale state
- hidden coupling
- imperative synchronization
- authority leakage
- topology instability
- semantic ambiguity
- provenance reconstruction burden

Any implementation shortcut that reintroduces these failure modes is architectural regression even if:

- code compiles
- tests pass
- UI appears functional

Architecture integrity takes precedence over local convenience.
