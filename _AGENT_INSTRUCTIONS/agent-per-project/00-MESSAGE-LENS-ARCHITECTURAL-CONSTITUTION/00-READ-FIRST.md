# Read This First

Before performing any implementation work in MessageLens, read:

- [10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md](10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md)

This document is NOT:

- optional guidance
- background reading
- architectural philosophy
- stylistic preference

It IS:

- a binding architectural contract
- the governing constitution of the project
- the definition of valid architectural behavior

Code that compiles but violates the constitution is defective.


---


## Critical Principle

MessageLens is a semantic, projection-oriented, graph-based communication exploration system.

When a bug appears, fix derivation, invalidation, ownership, or projection.

Do NOT add imperative repair.

The architecture evolved through repeated encounters with:

- stale state
- authority leakage
- imperative repair
- topology instability
- semantic ambiguity
- provenance reconstruction burden
- feature ownership creep
- hidden coupling

The constitutional rules exist because these failure modes were previously encountered in real development.

They are not theoretical preferences.

They are protections against known architectural collapse patterns.


---


## Before Implementing Any Change

You MUST identify:

1. Which constitutional sections apply
2. Which architectural layer owns the responsibility
3. What state is authoritative
4. What structures are merely projections
5. What tempting shortcut exists
6. Why that shortcut is dangerous
7. Which invariants must remain true
8. How deterministic semantic flow is preserved


---


## Invalid Repairs

If your implementation introduces:

- clear()
- reset()
- force refresh
- synchronization patches
- local convenience SQL
- renderer-owned semantics
- feature-owned global topology
- stale-state repair logic
- bypasses around source-scoped graph traversal

STOP.

You are probably repairing symptoms instead of fixing the architectural violation.

The correct response is to repair the semantic path that should have made the
state correct in the first place:

- derivation
- invalidation
- ownership
- projection

not a compensating command after the fact.


---


## Most Important Rule

Invalid states must be unrepresentable.

Correct architecture prevents semantic inconsistency through:

- derivation
- projection
- bounded authority
- deterministic state flow
- stable graph identity

Not through:

- imperative repair
- synchronization
- cleanup commands
- local patches


---


## Implementation Standard

All implementation work must preserve:

- DDD boundaries
- projection-oriented UI architecture
- sidebarFlowState determinism
- resolver/coordinator/renderer authority separation
- reader/integrator/orchestrator separation
- source-scoped graph identity
- semantic preservation principles
- canonical message evidence rendering semantics

Local convenience is NOT architectural justification.

The architecture must continue evolving:

- toward deterministic semantic projection
- toward stable graph traversal
- toward explicit authority boundaries
- toward semantic clarity

Not backward toward:

- imperative reconstruction
- hidden coupling
- mutable topology
- authority leakage
- shortcut-driven entropy


---


## If Unsure

Do NOT implement speculative repairs.

Instead:

- identify the violated invariant
- identify the broken authority boundary
- identify the incorrect derivation/projection relationship
- propose the architectural correction first

Architecture correctness takes precedence over implementation speed.
