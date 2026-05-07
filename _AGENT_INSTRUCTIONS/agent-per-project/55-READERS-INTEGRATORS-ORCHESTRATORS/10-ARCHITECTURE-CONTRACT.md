# 10-ARCHITECTURE-CONTRACT

## Purpose

This document defines the architectural contracts for the Readers → Integrators → Orchestrators responsibility model.

These contracts exist to:

- preserve responsibility clarity
- reduce abstraction leakage
- improve causal traceability
- prevent orchestration compression
- improve long-term maintainability

This document defines intended behavior, not merely preferred style.

---

# Architectural Direction

The preferred responsibility flow is:

```text
Readers
→ Integrators
→ Orchestrators
```

Meaning:

```text
facts
→ meaning
→ execution
```

This architecture attempts to separate:

- observation
- interpretation
- coordination

into distinct conceptual layers.

---

# Reader Contracts

## Purpose

Readers acquire factual state from low-level systems.

Readers are intentionally narrow.

Readers should answer questions like:

```text
"What is true right now?"
```

---

## Allowed Responsibilities

Readers MAY:

- query databases
- read filesystem state
- inspect projection state
- inspect execution gate state
- produce immutable snapshots
- expose small deterministic value objects

Examples:

- MAX(ROWID)
- imported message count
- attachment existence
- projection completion status

---

## Prohibited Responsibilities

Readers MUST NOT:

- own timers
- own retries/debounce
- schedule work
- trigger imports/migrations
- acquire execution gates
- perform semantic interpretation
- publish orchestration state
- mutate pipeline state

Readers should avoid hidden orchestration behavior.

---

## Preferred Characteristics

Readers should preferably be:

- deterministic
- side-effect minimal
- immutable-output oriented
- highly testable
- narrow in scope

Readers should ideally be understandable in isolation.

---

# Integrator Contracts

## Purpose

Integrators combine reader outputs into semantic conclusions.

Integrators answer questions like:

```text
"What does this set of facts mean?"
```

---

## Allowed Responsibilities

Integrators MAY:

- combine multiple reader outputs
- evaluate semantic conditions
- determine reconciliation states
- produce immutable semantic models
- determine whether orchestration SHOULD occur

Examples:

- ledger lagging
- startup reconciliation required
- projection appears incomplete
- attachment archive drift detected

---

## Prohibited Responsibilities

Integrators MUST NOT:

- own timers/listeners
- own retries/debounce
- acquire execution gates
- directly trigger imports/migrations
- mutate pipeline state
- publish long-lived orchestration lifecycle

Integrators should remain primarily semantic rather than procedural.

---

## Preferred Characteristics

Integrators should preferably be:

- deterministic
- immutable-output oriented
- pure-function friendly
- independently testable
- causally explicit

Integrators should make semantic reasoning visible and understandable.

---

# Orchestrator Contracts

## Purpose

Orchestrators coordinate lifecycle and execution behavior.

Orchestrators answer questions like:

```text
"What should happen next?"
```

---

## Allowed Responsibilities

Orchestrators MAY:

- own timers
- own listeners
- coordinate async flows
- coordinate retries/debounce
- acquire execution gates
- trigger imports/migrations
- coordinate attachment sweeps
- publish meaningful application state
- manage orchestration lifecycle

Examples:

- polling loops
- startup coordination
- retry scheduling
- debounce scheduling
- import coordination
- migration coordination

---

## Prohibited Responsibilities

Orchestrators SHOULD avoid:

- low-level factual database reads where practical
- embedded semantic reconciliation logic
- broad responsibility accumulation

Orchestrators should prefer consulting:

- Readers for facts
- Integrators for meaning

rather than collapsing all concerns internally.

---

## Preferred Characteristics

Orchestrators should preferably be:

- lifecycle explicit
- causally traceable
- externally observable
- narrowly scoped around a coherent orchestration concern

Orchestrators should expose understandable execution narratives.

---

# Concern-Oriented Structure

The preferred structure is:

```text
concern
→ responsibility layer
```

Example:

```text
messages/
  readers/
  integrators/
  orchestrators/
```

NOT:

```text
readers/
  messages/
```

Humans reason primarily through domain narratives rather than horizontal technical slices.

---

# Dependency Contracts

Preferred dependency direction:

```text
Readers
→ low-level systems only

Integrators
→ Readers

Orchestrators
→ Integrators
→ Readers
```

Preferred dependency graph:

```text
Readers
    ↑
Integrators
    ↑
Orchestrators
```

---

# Dependency Restrictions

## Readers

Readers MUST NOT depend on:

- Integrators
- Orchestrators

---

## Integrators

Integrators MUST NOT depend on:

- Orchestrators

Integrators SHOULD avoid orchestration ownership concepts where practical.

---

## Orchestrators

Orchestrators MAY depend on:

- Integrators
- Readers
- execution coordination services

Orchestrators SHOULD avoid directly embedding large amounts of:

- low-level read logic
- semantic reconciliation logic

when those concerns can reasonably be externalized.

---

# Execution Ownership

Execution ownership refers to the authority to perform mutation-producing work.

Examples:

- import execution
- migration execution
- attachment archival execution

Execution ownership should generally be coordinated explicitly.

Example:

```text
ImportExecutionGate
```

This prevents:

- overlapping orchestration
- conflicting mutations
- inconsistent projection state

---

# Pipeline Mutation Contract

Pipeline mutation should generally occur only inside:

- Orchestrators
- explicitly designated execution services

Readers and Integrators should avoid pipeline mutation.

Examples of pipeline mutation:

- importing rows
- running migrations
- updating projection state
- archiving attachments

---

# Architectural Goal

This architecture does NOT exist to maximize abstraction.

The goal is:

- responsibility clarity
- causal visibility
- human comprehensibility
- safe modification of complex orchestration flows

This architecture recognizes that orchestration complexity is real and unavoidable.

The objective is to make that complexity understandable rather than hidden.
