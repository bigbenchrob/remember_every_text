# Implementation Checklist

## Purpose

This checklist must be completed mentally — and preferably explicitly in writing — before implementing any significant MessageLens change.

The purpose of this checklist is to prevent:

- architectural drift
- authority leakage
- imperative repair logic
- projection instability
- semantic collapse
- shortcut-driven entropy

This checklist exists because many architectural failures initially appear:

- harmless
- temporary
- pragmatic
- locally convenient

The architecture repeatedly evolved to eliminate those exact failure modes.


---


## Rule Zero

Before implementation:

Read:

- [10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md](10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md)
- [20-COMMON-DRIFT-PATTERNS.md](20-COMMON-DRIFT-PATTERNS.md)

Implementation speed does NOT take precedence over architectural integrity.


---


## Section 1: Define The Responsibility

### Questions

1. What semantic responsibility is being added or modified?
2. Is this:
   - domain semantics
   - orchestration
   - persistence
   - rendering
   - projection composition
   - graph traversal
   - semantic interpretation
3. Which architectural layer owns this responsibility?


---


### Required Outcome

There must be exactly one primary owner.

If ownership feels ambiguous:

- the architecture is probably not yet clear enough.


---


## Section 2: Identify Authoritative State

### Questions

1. What state is authoritative?
2. What structures are projections only?
3. Is any visible topology accidentally becoming semantic state?
4. Is any local cache becoming authoritative?
5. Is any renderer holding durable semantic meaning?


---


### Required Outcome

Semantic intent must remain primary.

Visible structures must remain derived.


---


### Constitutional Reminder

Invalid states must be unrepresentable.


---


## Section 3: Verify DDD Boundaries

### Questions

1. Does application code contain:
   - SQL
   - SQLite imports
   - persistence mechanics
2. Does presentation code contain:
   - orchestration
   - semantic policy
   - graph construction
3. Does infrastructure contain:
   - semantic workflow decisions
   - UI concerns
4. Is any repository located outside infrastructure?


---


### Required Outcome

Each layer retains bounded authority.


---


### Automatic Violation Triggers

STOP if:

- raw SQL appears outside infrastructure
- repository implementation appears outside infrastructure
- widgets begin making semantic decisions
- orchestration enters rendering layer


---


## Section 4: Verify Projection Architecture

### Questions

1. Is UI emerging deterministically from semantic state?
2. Is there any:
   - clear()
   - reset()
   - force refresh
   - synchronization patch
3. Is visible UI topology being treated as authoritative?
4. Is stale content being repaired imperatively?


---


### Required Outcome

Projection systems must derive naturally from semantic state.


---


### Constitutional Reminder

When a bug appears, fix derivation, invalidation, ownership, or projection.

Do NOT add imperative repair.

Correct repair fixes:

- derivation
- invalidation
- ownership
- semantic flow

Not:

- UI symptoms


---


## Section 5: Verify RIO (Reader / Integrator / Orchestrator)

### Questions

1. Is observation separated from interpretation?
2. Is orchestration separated from data collection?
3. Is rendering separated from orchestration?
4. Is polling being treated as:
   - observation
     rather than:
   - semantic refresh?


---


### Required Outcome

Maintain:
facts → meaning → orchestration


---


### Automatic Violation Triggers

STOP if:

- orchestrator accumulates SQL
- reader performs semantic policy
- integrator performs lifecycle management
- rendering logic enters orchestration


---


## Section 6: Verify Resolver / Coordinator / Renderer Separation

### Questions

1. Is renderer performing semantic interpretation?
2. Is coordinator accumulating rendering logic?
3. Is resolver controlling topology?
4. Is any widget gaining hidden authority?


---


### Required Outcome

- Resolver derives semantics
- Coordinator composes semantics
- Renderer renders semantics

Nothing else.


---


## Section 7: Verify Sidebar Flow Invariants

### Questions

1. Does sidebarFlowState remain authoritative?
2. Is cassette topology remaining derived?
3. Could invalid sidebar/center combinations exist?
4. Is any implementation relying on imperative cleanup?


---


### Required Outcome

Sidebar topology must emerge deterministically from semantic intent.


---


### Automatic Violation Triggers

STOP if:

- center panel requires clearing
- cassette stack becomes authoritative state
- sidebar reconstruction becomes imperative


---


## Section 8: Verify SS Graph Invariants

### Questions

1. Is source-scoped identity preserved?
2. Is graph traversal remaining explicit?
3. Is any convenience shortcut bypassing SS identity?
4. Is any hidden deduplication occurring?
5. Is provenance reconstruction reappearing?


---


### Required Outcome

Stable occurrence identity remains foundational.


---


### Automatic Violation Triggers

STOP if:

- GUID shortcuts bypass graph traversal
- occurrence identity collapses
- provenance chains reappear
- graph semantics become implicit


---


## Section 9: Verify Message Evidence Consistency

### Questions

1. Does this introduce a new message rendering language?
2. Does this diverge from canonical MessageEvidenceList semantics?
3. Are projection-specific rendering rules emerging?
4. Does this fragment evidence coherence?


---


### Required Outcome

All evidence surfaces must feel like:

- one coherent semantic evidence system


---


## Section 10: Verify Semantic Preservation

### Questions

1. Is a field being restored merely because legacy had it?
2. Does the semantic actually support:
   - traversal
   - search
   - review
   - classification
   - named product behavior?
3. Is semantic preservation being confused with field preservation?


---


### Required Outcome

Preserve:

- semantic integrity

Not:

- historical baggage


---


## Section 11: Identify Tempting Shortcuts

### Mandatory Question

What tempting shortcut exists here?

Examples:

- “just add clear()”
- “just run the query here”
- “just cache this locally”
- “just rebuild the sidebar”
- “just patch the widget”
- “just bypass the graph”
- “just restore the legacy field”


---


### Mandatory Follow-Up Question

What architectural entropy would this shortcut reintroduce?

Possible answers:

- stale state
- authority leakage
- hidden coupling
- projection instability
- semantic ambiguity
- provenance loss
- topology instability


---


## Section 12: Verify Invalid States Remain Unrepresentable

### Final Questions

After this implementation:

1. Could contradictory semantic states coexist?
2. Could stale projections persist?
3. Could topology diverge from semantic intent?
4. Could hidden synchronization become necessary later?
5. Could semantic authority become ambiguous?
6. Could local convenience override graph semantics?


---


### Required Outcome

If the answer to ANY question is “yes,” the implementation is incomplete or architecturally defective.


---


## Required Implementation Mindset

Do NOT think:

“How do I make this work?”

Think:

“How do I preserve deterministic semantic architecture while implementing this capability?”


---


## Final Reminder

MessageLens repeatedly evolved away from:

- imperative repair
- mutable topology
- hidden coupling
- feature-owned global state
- semantic ambiguity
- provenance reconstruction burden

and toward:

- deterministic semantic projection
- stable graph traversal
- explicit authority boundaries
- compositional topology
- semantic clarity

Every implementation must continue moving in that direction.

Not backward.
