# 00-TERMINOLOGY

## Purpose

This document defines the core terminology used by the Readers → Integrators → Orchestrators architectural responsibility model.

The purpose of this terminology document is to:

- stabilize architectural language
- reduce semantic drift between agents and humans
- improve consistency across feature implementations
- clarify responsibility boundaries
- prevent accidental architectural layer mixing

This document should be treated as authoritative terminology for this experimental architecture model.

---

# Core Responsibility Layers

## Reader

A Reader is responsible for acquiring factual state from a low-level system.

Readers answer questions like:

```text
"What is true right now?"
```

Examples:

- current MAX(ROWID)
- imported message count
- attachment existence
- execution gate state
- projection completion state

Readers should:

- perform focused reads
- avoid orchestration
- avoid timers/listeners
- avoid retries/debounce
- avoid semantic interpretation
- avoid execution triggering
- avoid mutation of application pipeline state

Readers should preferably return:

- immutable snapshots
- simple value objects
- deterministic outputs

Readers are intentionally narrow in scope.

---

## Integrator

An Integrator combines reader outputs into semantic conclusions.

Integrators answer questions like:

```text
"What does this set of facts mean?"
```

Examples:

- "ledger is behind live chat.db"
- "projection appears incomplete"
- "incremental import should be scheduled"
- "attachment archive drift exists"

Integrators should:

- combine facts into meaning
- prefer immutable outputs
- prefer deterministic evaluation
- prefer pure functions where practical
- avoid lifecycle ownership
- avoid orchestration concerns
- avoid timers/listeners
- avoid pipeline mutation

Integrators are semantic interpreters rather than lifecycle coordinators.

---

## Orchestrator

An Orchestrator owns lifecycle coordination and execution flow.

Orchestrators answer questions like:

```text
"What should happen next?"
```

Examples:

- polling timers
- retry scheduling
- debounce coordination
- import triggering
- migration triggering
- attachment sweep scheduling
- execution gate coordination

Orchestrators may:

- own timers/listeners
- coordinate async flows
- acquire execution ownership
- trigger imports/migrations
- publish meaningful application state
- coordinate retries/debounce

Orchestrators should avoid directly performing low-level factual reads when practical.

They should prefer consulting Readers and Integrators.

---

# Architectural Concepts

## Concern

A Concern is a coherent domain-level behavioral area.

Examples:

- messages
- attachments
- projection state
- execution gating
- onboarding archive import

Concerns are organized primarily around:

- causal narrative
- lifecycle coherence
- human comprehensibility

rather than strict physical isolation.

Concerns may depend on each other while still remaining separate architectural slices.

---

## Snapshot

A Snapshot is an immutable factual representation of a system at a moment in time.

Examples:

- live database row counts
- imported ledger counts
- projection completion state
- attachment archive existence state

Snapshots should:

- avoid semantic interpretation
- avoid orchestration state
- represent observed facts only

Snapshots are commonly produced by Readers.

---

## Semantic State

Semantic State is meaning derived from multiple facts.

Examples:

- "ledger lagging"
- "projection incomplete"
- "startup reconciliation required"

Semantic state is generally produced by Integrators.

---

## Policy Decision

A Policy Decision is meaning derived from Semantic State that describes whether execution may be considered, should do nothing, or must be blocked.

Examples:

- `ImportDecision.considerIncrementalImport`
- `ImportDecision.blockAndReportLedgerAhead`
- `MigrationDecision.considerShadowMigration`

Policy Decisions should not mutate state directly. They are inputs to Orchestrators, not Executors.

---

## Narrow Executor

A Narrow Executor performs an explicitly scoped mutation after an Orchestrator decides execution is allowed.

Examples:

- `ShadowMessageImportExecutor`
- `ShadowMessageMigrationExecutor`

Executors should not own polling, derive semantic meaning, or decide whether work should occur.

---

## Comparative Validation

Comparative Validation compares production facts or conclusions with shadow facts or conclusions without becoming authoritative.

Validated comparison outcomes include:

```text
MATCH
PHASE SKEW
MISMATCH
NOT COMPARABLE
```

`PHASE SKEW` means systems appear valid but are being observed at different moments in asynchronous execution. It is not automatically a failure.

---

## Behavioral Equivalence

Behavioral Equivalence means a shadow architecture reaches the same durable conclusions and steady state as production under equivalent real-world conditions.

Behavioral equivalence does not require identical timing. Temporary phase skew can be acceptable if both systems converge to the same durable meaning.

---

## Operational Divergence

Operational Divergence is an observed difference in runtime behavior between production and shadow systems.

Examples:

- one system reaches projection current earlier
- one system requires more polling ticks to converge
- one system batches work differently
- one system reports a different durable conclusion

Operational divergence should be classified before promotion as intentional, acceptable, accidental, or unresolved.

---

## Convergence Latency

Convergence Latency is the observed duration or tick count between first detected drift and return to steady state.

Examples:

- first observed shadow import lag → shadow import caught up
- shadow ledger caught up → shadow projection caught up
- first observed production pending state → production comparison returns to match

Convergence latency is observational. It should not by itself trigger retries, cadence changes, or production execution.

---

## Execution Ownership

Execution Ownership refers to the right to perform a mutation-producing orchestration task.

Examples:

- import execution
- migration execution
- attachment archival execution

Execution ownership is commonly arbitrated by:

```text
ImportExecutionGate
```

Execution ownership exists to prevent conflicting concurrent orchestration.

---

## Pipeline Mutation

Pipeline Mutation refers to any operation that changes authoritative application state.

Examples:

- importing rows into macos_import.db
- running migration projection
- updating projection state
- archiving attachments

Pipeline mutation should generally occur only inside Orchestrators or explicitly designated execution services.

Readers and Integrators should avoid pipeline mutation.

---

## Shadow Implementation

A Shadow Implementation is a parallel experimental implementation that:

- observes the same inputs
- produces comparable outputs
- does not become authoritative
- does not interfere with production orchestration

Shadow implementations exist to safely evaluate architectural alternatives.

Preferred shadow implementation progression:

```text
shadow readers
→ shadow integrators
→ shadow orchestrators
→ comparative logging
→ behavioral validation
→ limited adoption
→ possible production promotion
```

---

# Architectural Smells

## Responsibility Compression

Responsibility Compression occurs when a single actor combines too many abstraction layers simultaneously.

Examples:

- factual reads
- semantic interpretation
- lifecycle ownership
- retry coordination
- pipeline execution
- state publication

Responsibility compression increases:

- cognitive load
- causal opacity
- modification risk
- onboarding difficulty

This architecture model exists largely to reduce responsibility compression.

---

## Horizontal Technical Slicing

Horizontal Technical Slicing organizes architecture primarily by technical layer rather than concern narrative.

Example:

```text
readers/
integrators/
orchestrators/
```

This architecture model generally prefers:

```text
messages/
attachments/
projection_state/
```

with responsibility layers inside each concern.

Humans reason more naturally through domain narratives than horizontal technical partitions.

---

# Important Clarification

This terminology model does NOT imply:

- maximal abstraction
- provider proliferation
- elimination of orchestration complexity
- strict purity at all costs

The purpose is:

- responsibility clarity
- causal traceability
- human comprehensibility
- safe evolution of complex orchestration systems
