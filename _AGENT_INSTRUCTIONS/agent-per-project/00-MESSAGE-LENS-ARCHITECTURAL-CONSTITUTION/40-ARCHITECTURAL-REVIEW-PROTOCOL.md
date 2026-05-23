# Architectural Review Protocol

## Purpose

This protocol defines the required architectural review process for MessageLens implementation work.

Traditional code review focuses on:

- compilation
- correctness
- local logic
- visible functionality

That is NOT sufficient for MessageLens.

MessageLens is a:

- semantic
- projection-oriented
- graph-based
- invariant-driven system

Therefore:
architectural correctness must be reviewed independently from implementation correctness.

A feature may:

- compile
- pass tests
- appear functional

and still be architecturally defective.

This protocol exists to detect:

- authority leakage
- semantic drift
- projection corruption
- shortcut-driven entropy
- invalid repair patterns
- graph invariant violations

before they become structural debt.


---


## Required Review Modes

Every significant implementation must undergo:

1. Functional Review
2. Architectural Review

These are separate activities.


---


## Functional Review

### Questions

- Does the feature work?
- Does it compile?
- Are tests passing?
- Does the UI behave correctly?
- Are edge cases handled?

Functional correctness alone is NOT approval.


---


## Architectural Review

### Core Question

Does this implementation preserve constitutional invariants?


---


### Architectural Review Checklist

## Section 1: Layer Ownership Review

### Questions

Did any layer gain forbidden authority?

Specifically:

### Domain Layer

Did domain gain:

- persistence concerns
- rendering concerns
- orchestration logic?


---


### Application Layer

Did application gain:

- SQL
- SQLite mechanics
- repository implementation details
- rendering responsibilities?


---


### Infrastructure Layer

Did infrastructure gain:

- semantic workflow decisions
- UI semantics
- projection policy?


---


### Presentation Layer

Did presentation gain:

- semantic interpretation
- graph traversal logic
- orchestration
- persistence mechanics?


---


### Automatic Failure Conditions

FAIL review if:

- SQL exists outside infrastructure
- repositories exist outside infrastructure
- widgets own semantic policy
- orchestration leaks into rendering


---


## Section 2: Projection Review

### Questions

Is visible UI topology still a projection?

Or did:

- local caches
- widget state
- cassette stacks
- renderer assumptions

become authoritative semantic state?


---


### Questions

Did implementation introduce:

- clear()
- reset()
- force refresh
- synchronization patches
- imperative invalidation repairs?


---


### Automatic Failure Conditions

FAIL review if:

- stale-state repair logic exists
- imperative synchronization exists
- projection topology became authoritative


---


### Constitutional Reminder

Invalid states must be unrepresentable.


---


## Section 3: Authority Boundary Review

### Questions

Did any component gain hidden authority?

Examples:

- renderer making semantic decisions
- feature managing global topology
- coordinator interpreting facts
- resolver performing orchestration


---


### Automatic Failure Conditions

FAIL review if:

- renderers interpret semantics
- coordinators own rendering
- features own shared topology
- orchestration collapses into one class


---


## Section 4: Sidebar Flow Review

### Questions

Does sidebarFlowState remain authoritative?

Or is:

- cassette topology
- visible UI state
- renderer-local state

becoming semantic truth?


---


### Questions

Could invalid sidebar/center combinations exist?

Could stale center content survive topology change?


---


### Automatic Failure Conditions

FAIL review if:

- center panel requires clearing
- cassette stack becomes semantic state
- imperative sidebar synchronization exists


---


## Section 5: RIO Review

### Questions

Are:

- readers
- integrators
- orchestrators

still semantically separated?


---


### Questions

Did:

- readers gain semantic policy?
- integrators gain lifecycle orchestration?
- orchestrators gain SQL?
- rendering enter orchestration?


---


### Automatic Failure Conditions

FAIL review if:

- observation and orchestration collapse
- semantic derivation enters polling logic
- orchestrators accumulate unrelated authority


---


## Section 6: SS Graph Review

### Questions

Does implementation preserve:

- source-scoped identity
- occurrence identity
- explicit traversal semantics?


---


### Questions

Did any convenience shortcut:

- bypass graph traversal?
- collapse identity?
- reintroduce provenance reconstruction?
- rely on hidden GUID semantics?


---


### Automatic Failure Conditions

FAIL review if:

- traversal bypasses SS identity
- provenance ambiguity reappears
- hidden deduplication occurs
- graph semantics become implicit


---


## Section 7: Message Evidence Review

### Questions

Does implementation preserve:

- canonical message evidence semantics?
- consistent rendering language?
- projection coherence?


---


### Questions

Did implementation introduce:

- feature-specific rendering behavior?
- projection-specific message semantics?
- visual fragmentation?


---


### Automatic Failure Conditions

FAIL review if:

- multiple message rendering languages emerge
- evidence semantics diverge by feature
- projections feel like separate mini-apps


---


## Section 8: Semantic Preservation Review

### Questions

Were fields restored because:

- legacy had them
- they “might be useful”
- restoring them was easier?


---


### Questions

Does restored data support:

- semantic classification?
- graph traversal?
- search/review?
- named product behavior?


---


### Automatic Failure Conditions

FAIL review if:

- schema accumulation occurs without justification
- payload baggage returns
- semantic preservation becomes field preservation


---


## Section 9: Shortcut Review

### Mandatory Question

What shortcut temptation existed during implementation?

Examples:

- “just patch the widget”
- “just clear the state”
- “just run the query here”
- “just bypass the graph”
- “just store it locally”
- “just rebuild the sidebar”


---


### Mandatory Follow-Up

Was the shortcut rejected?

If yes:

- how?
- what architectural correction replaced it?


---


## Automatic Failure Condition

FAIL review if:
- local convenience overrode constitutional invariants.


---


## Section 10: Entropy Review

### Core Question

Did this implementation reduce or increase architectural entropy?


---


## Entropy Indicators

### Increased Entropy

- hidden coupling
- duplicated authority
- imperative repair
- stale-state risk
- semantic ambiguity
- topology instability
- reconstruction burden
- hidden synchronization


---


### Reduced Entropy

- clearer authority
- deterministic derivation
- explicit semantics
- compositional topology
- graph traversal clarity
- invariant preservation


---


## Section 11: Future Pressure Review

### Critical Question

Under future feature pressure, will this implementation:

- remain stable?
  or:
- encourage more shortcuts?


---


## Review Goal

Architectural work should:

- absorb future complexity cleanly

Not:

- normalize future violations


---


## Required Review Conclusion

Every architectural review must end with one of:

### Pass

Implementation preserves constitutional invariants.

OR

### Fail

Implementation introduces architectural drift.

“Works correctly” is NOT sufficient justification for PASS.


---


## Final Constitutional Reminder

The MessageLens architecture evolved through repeated elimination of:

- stale state
- imperative repair
- authority leakage
- hidden coupling
- topology instability
- provenance ambiguity
- reconstruction burden

Architectural review exists to prevent those failure modes from silently re-entering the system.

The purpose of this protocol is not perfectionism.

It is preservation of semantic architectural integrity under long-term feature pressure.
