# 30-INVARIANTS

## Purpose

This document defines architectural invariants for the Readers → Integrators → Orchestrators responsibility model.

These invariants exist to preserve:

- responsibility clarity
- causal traceability
- safe orchestration behavior
- human comprehensibility
- long-term architectural integrity

An invariant is a rule that should remain true regardless of implementation details.

---

# Core Architectural Invariant

The preferred conceptual flow is:

```text
facts
→ meaning
→ execution
```

Equivalent responsibility layers:

```text
Readers
→ Integrators
→ Orchestrators
```

Lower-level factual observation should not become entangled with higher-level orchestration concerns unless explicitly justified.

---

# Reader Invariants

## Readers Observe Facts

Readers should primarily observe and expose factual state.

Examples:

- MAX(ROWID)
- message counts
- attachment existence
- projection completion state
- execution gate state

Readers should not reinterpret facts into semantic conclusions.

---

## Readers Avoid Lifecycle Ownership

Readers should not own:

- timers
- polling
- retry scheduling
- debounce behavior
- orchestration lifecycle

Readers should preferably remain execution-neutral.

---

## Readers Avoid Pipeline Mutation

Readers should avoid mutation-producing behavior.

Examples of prohibited mutation:

- importing rows
- migration execution
- projection updates
- attachment archival writes

Readers should primarily observe rather than coordinate.

---

## Readers Are the Invalidation Boundary for External Observation

When polling exists to re-observe external reality, invalidation should target Readers or reader snapshot providers.

Examples of external observation:

- live `chat.db`
- `macos_import.db`
- filesystem state
- projection readiness state

Derived semantic providers should recompute through dependency propagation. Orchestrators should not compensate for an incorrect provider graph by invalidating semantic conclusions directly.

The validated message shadow pipeline follows:

```text
poll tick
→ invalidate reader snapshot providers
→ derived providers recompute naturally
```

This preserves the distinction between:

- observing facts again
- recomputing meaning from facts

---

# Integrator Invariants

## Integrators Interpret Facts

Integrators should combine factual reader outputs into semantic meaning.

Examples:

- "ledger behind"
- "projection incomplete"
- "startup reconciliation required"
- "attachment archive drift detected"

Integrators should not directly coordinate execution lifecycle.

---

## Integrators Keep Meaning Separate from Policy and Execution

Integrators should make each level of meaning explicit.

The validated message shadow pipeline separates:

```text
MessageSnapshotDelta
→ MessageSyncState
→ ImportDecision
```

Numeric drift, semantic sync state, and policy decision are related but distinct. Keeping them separate prevents facts from directly becoming execution and prevents policy decisions from acquiring side effects.

Decision integrators may convert semantic meaning into policy meaning, but they should remain side-effect free.

---

## Integrators Prefer Deterministic Evaluation

Given the same inputs, Integrators should preferably produce the same outputs.

Integrators should favor:

- immutable semantic models
- pure evaluation helpers
- explicit reconciliation logic

Integrators should avoid hidden orchestration state.

---

## Integrators Avoid Lifecycle Ownership

Integrators should avoid owning:

- polling loops
- timers/listeners
- retry coordination
- execution gates
- debounce scheduling

Lifecycle coordination belongs primarily to Orchestrators.

---

# Orchestrator Invariants

## Orchestrators Coordinate Execution

Orchestrators own:

- lifecycle coordination
- async flow coordination
- retries/debounce
- execution triggering
- scheduling behavior
- execution ownership coordination

Orchestrators answer:

```text
"What should happen next?"
```

---

## Orchestrators Prefer Delegation

Orchestrators should preferably:

- delegate factual reads to Readers
- delegate semantic interpretation to Integrators

rather than embedding all concerns internally.

---

## Orchestrators Expose Causal Narrative

Orchestrators should expose understandable execution flow.

Humans should be able to explain:

```text
what triggered execution
→ what semantic condition was detected
→ what execution occurred
```

Opaque orchestration behavior should be treated as an architectural smell.

---

# Concern Invariants

## Concerns Represent Coherent Narratives

Concerns should generally represent coherent behavioral narratives.

Examples:

- messages
- attachments
- projection state
- onboarding import
- execution gating

Concern separation is based primarily on:

- causal coherence
- lifecycle coherence
- human comprehensibility

rather than strict physical isolation.

---

## Concern Boundaries May Evolve

Concern boundaries are not rigid.

If duplication becomes excessive:

```text
messages/
attachments/
```

this should trigger architectural review.

Possible outcomes:

- shared abstraction extraction
- revised concern boundaries
- shared orchestration services
- acceptance of intentional duplication

Duplication alone is not automatically an architectural failure.

---

# Shadow Implementation Invariants

## Shadow Implementations Must Remain Non-Authoritative

Experimental implementations should initially avoid:

- production mutation
- production scheduling ownership
- authoritative projection ownership

Shadow implementations should primarily:

- observe
- compare
- validate
- log differences

before becoming production actors.

---

## Parallel Validation Preferred

Experimental architectures should preferably be validated against:

- existing orchestration behavior
- existing projection outputs
- existing reconciliation decisions

before promotion into production.

---

# Execution Ownership Invariants

## Mutation-Producing Work Requires Explicit Ownership

Operations such as:

- import execution
- migration execution
- projection mutation
- attachment archival writes

should preferably occur under explicit execution ownership coordination.

Example:

```text
ImportExecutionGate
```

This exists to prevent:

- overlapping orchestration
- conflicting mutations
- inconsistent projection visibility

---

## Ownership Arbitration Should Be Observable

Execution ownership systems should preferably expose observable state.

Examples:

- current owner
- denied requests
- retry opportunities
- contention state

This improves:

- diagnostics
- causal traceability
- supportability
- orchestration visibility

---

# Human Comprehensibility Invariant

The architecture should remain explainable in human causal terms.

Humans should be able to reasonably answer:

```text
What facts were observed?
What meaning was derived?
What execution occurred?
Why did it occur?
Who owned execution?
```

If answering these questions becomes difficult, responsibility compression or orchestration opacity may be increasing.

---

# Architectural Compression Invariant

Responsibility compression should be treated as an architectural smell.

Examples:

- factual reads
- semantic reconciliation
- retry coordination
- execution ownership
- mutation execution
- state publication

all occurring inside one actor.

Some orchestration complexity is unavoidable.

The goal is not:

```text
elimination of complexity
```

The goal is:

```text
understandable complexity
```

---

# Architectural Evolution Invariant

This responsibility model is experimental.

It should evolve through:

- observation
- pilot implementations
- comparative validation
- incremental adoption

rather than wholesale immediate replacement of functioning production systems.

Architectural evolution should prioritize:

- reversibility
- observability
- safety
- incremental confidence
