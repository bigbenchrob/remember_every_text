# 20-ALLOWED-DEPENDENCIES

## Purpose

This document defines preferred dependency direction and prohibited dependency relationships for the Readers → Integrators → Orchestrators architectural responsibility model.

The purpose of these dependency rules is to:

- preserve responsibility clarity
- reduce architectural entanglement
- prevent orchestration compression
- improve causal traceability
- improve safe long-term evolution

This document defines architectural intent rather than rigid compiler-enforced constraints.

---

# Core Dependency Direction

Preferred dependency flow:

```text
Readers
→ Integrators
→ Orchestrators
```

Equivalent interpretation:

```text
facts
→ meaning
→ execution coordination
```

---

# Dependency Graph

Preferred conceptual dependency graph:

```text
Readers
    ↑
Integrators
    ↑
Orchestrators
```

Meaning:

- Integrators may depend on Readers
- Orchestrators may depend on Integrators and Readers
- Lower layers should not depend upward

---

# Reader Dependency Rules

## Readers MAY Depend On

Readers MAY depend on:

- database services
- filesystem services
- projection inspection services
- low-level repositories
- immutable data models
- execution-neutral utility services

Examples:

```text
sqlite readers
filesystem inspection
projection state readers
attachment existence readers
```

---

## Readers MUST NOT Depend On

Readers MUST NOT depend on:

- Integrators
- Orchestrators
- orchestration lifecycle actors
- retry/debounce systems
- execution ownership systems
- import scheduling systems

Readers should avoid hidden orchestration behavior.

---

## Reader Philosophy

Readers should remain:

```text
execution-neutral
```

A Reader should ideally be understandable without understanding the surrounding orchestration system.

---

# Integrator Dependency Rules

## Integrators MAY Depend On

Integrators MAY depend on:

- Readers
- immutable snapshots
- immutable semantic models
- pure reconciliation helpers
- deterministic evaluation utilities

Examples:

```text
startup reconciliation evaluators
ledger drift evaluators
projection completeness evaluators
```

---

## Integrators SHOULD Prefer

Integrators should preferably:

- consume immutable reader outputs
- expose immutable semantic outputs
- prefer deterministic evaluation
- remain side-effect minimal

Integrators should make semantic reasoning explicit and inspectable.

---

## Integrators MUST NOT Depend On

Integrators MUST NOT depend on:

- Orchestrators
- polling systems
- timers/listeners
- retry/debounce coordinators
- import execution systems
- migration execution systems

Integrators should not directly coordinate lifecycle behavior.

---

# Orchestrator Dependency Rules

## Orchestrators MAY Depend On

Orchestrators MAY depend on:

- Integrators
- Readers
- execution gates
- retry/debounce services
- scheduling services
- import coordinators
- migration coordinators

Examples:

```text
polling orchestrators
startup orchestration
attachment sweep orchestration
incremental import orchestration
```

---

## Orchestrators SHOULD Prefer

Orchestrators should preferably:

- delegate factual reads to Readers
- delegate semantic interpretation to Integrators
- centralize lifecycle coordination
- centralize execution coordination

Orchestrators should expose understandable execution narratives.

---

## Orchestrators SHOULD Avoid

Orchestrators SHOULD avoid becoming:

```text
god objects
```

Meaning:

- excessive embedded read logic
- excessive embedded semantic reconciliation
- excessive unrelated lifecycle ownership
- excessive unrelated orchestration concerns

Responsibility compression should be treated as an architectural smell.

---

# Concern-Oriented Organization

Preferred organization approach:

```text
concern first
→ responsibility layer second
```

Preferred:

```text
messages/
  readers/
  integrators/
  orchestrators/

attachments/
  readers/
  integrators/
  orchestrators/
```

Not preferred:

```text
readers/
  messages/

integrators/
  messages/

orchestrators/
  messages/
```

Humans reason more naturally through coherent concern narratives than horizontal technical partitions.

---

# Shared Dependencies

## Shared Utilities

Shared utility layers MAY exist for:

- immutable models
- deterministic helpers
- low-level repositories
- execution-neutral infrastructure

Examples:

```text
shared/database/
shared/models/
shared/filesystem/
```

---

## Shared Logic Smell

If large amounts of orchestration logic become duplicated across concerns:

```text
messages/
attachments/
```

this should trigger architectural review.

Possible outcomes:

- shared abstraction extraction
- shared orchestration services
- revised concern boundaries
- acceptance of intentional duplication

Duplication is not automatically incorrect.

Premature abstraction is often more dangerous than temporary duplication.

---

# Pipeline Mutation Rules

## Mutation-Producing Operations

Operations that mutate authoritative application state should generally occur only inside:

- Orchestrators
- explicitly designated execution services

Examples:

- importing rows
- migration execution
- projection updates
- attachment archival writes

---

## Readers and Integrators

Readers and Integrators should avoid mutation-producing behavior.

They should preferably remain:

```text
observation and interpretation layers
```

rather than execution layers.

---

# Execution Ownership Dependencies

Execution ownership systems MAY be depended upon by Orchestrators.

Example:

```text
ImportExecutionGate
```

Execution ownership systems exist to prevent:

- overlapping orchestration
- conflicting mutation flows
- inconsistent projection visibility

Readers and Integrators should generally avoid direct execution ownership coordination.

---

# Architectural Drift

Architectural drift commonly appears as:

- Readers acquiring orchestration behavior
- Integrators owning lifecycle
- Orchestrators embedding semantic reconciliation
- horizontal technical slicing
- uncontrolled cross-layer dependencies

These should be treated as signals for architectural review.

---

# Important Clarification

These dependency rules are intended to improve:

- human comprehensibility
- causal visibility
- architectural traceability
- safe long-term modification

They are not intended to create abstraction purity for its own sake.

Complex orchestration systems inevitably contain tradeoffs.

The goal is:

```text
understandable complexity
```

rather than:

```text
maximal abstraction
```
