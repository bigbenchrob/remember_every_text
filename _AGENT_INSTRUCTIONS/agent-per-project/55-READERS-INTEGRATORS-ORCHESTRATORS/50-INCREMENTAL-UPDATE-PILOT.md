# 50-INCREMENTAL-UPDATE-PILOT

## Purpose

This document defines the initial pilot implementation target for the Readers → Integrators → Orchestrators architectural responsibility model.

Initial pilot target:

```text
Incremental update detection
```

This pilot exists to evaluate whether responsibility decomposition can improve:

- human comprehensibility
- causal traceability
- orchestration clarity
- safe architectural evolution

without destabilizing existing production behavior.

---

# Why Incremental Update Detection?

The existing incremental update flow is a strong pilot candidate because it currently combines multiple abstraction layers simultaneously:

- factual reads
- semantic reconciliation
- polling lifecycle
- startup reconciliation
- debounce scheduling
- execution gating
- import triggering
- migration triggering
- attachment sweep scheduling
- orchestration state publication

This makes it an excellent candidate for responsibility decomposition experiments.

---

# Pilot Scope

Initial pilot scope should remain intentionally narrow.

Preferred initial target:

```text
message incremental detection only
```

NOT:

- full import replacement
- full migration replacement
- full attachment archival replacement
- projection ownership replacement

The purpose is architectural evaluation, not immediate production replacement.

---

# Existing Production Flow

Current production flow broadly performs:

```text
1. Observe live chat.db
2. Compare against imported ledger state
3. Determine whether incremental work is required
4. Coordinate execution ownership
5. Trigger import/migration
6. Publish resulting state
```

Currently, many of these responsibilities are concentrated inside:

```text
chatDbChangeMonitorProvider
```

The pilot explores whether these responsibilities can be decomposed more clearly.

---

# Initial Experimental Structure

Preferred experimental structure:

```text
incremental_updates/
  messages/
    readers/
    integrators/
    orchestrators/
```

Initial pilot should remain isolated from production orchestration ownership.

---

# Initial Reader Candidates

Examples:

```text
live_chat_db_rowid_reader
imported_message_rowid_reader
live_importable_message_count_reader
imported_message_count_reader
projection_completion_reader
execution_gate_state_reader
```

Reader goal:

```text
factual observation only
```

Readers should avoid:

- orchestration
- retries/debounce
- execution triggering
- semantic interpretation

---

# Initial Integrator Candidates

Examples:

```text
startup_reconciliation_integrator
ledger_drift_integrator
incremental_update_required_integrator
projection_consistency_integrator
```

Integrator goal:

```text
semantic interpretation
```

Integrators should answer questions like:

```text
Is the ledger behind?
Does startup reconciliation appear necessary?
Does imported state appear inconsistent with live state?
```

Integrators should avoid:

- lifecycle ownership
- retries/debounce
- execution triggering
- mutation-producing work

---

# Initial Orchestrator Candidates

Examples:

```text
polling_orchestrator
startup_probe_orchestrator
incremental_update_scheduler
```

Orchestrator goal:

```text
execution coordination
```

Orchestrators should own:

- polling cadence
- startup coordination
- retry/debounce
- execution ownership coordination
- scheduling behavior

Orchestrators should preferably consult:

- Readers for facts
- Integrators for meaning

rather than embedding all logic internally.

---

# Important Architectural Clarification

The pilot does NOT attempt to eliminate orchestration complexity.

The incremental update pipeline genuinely contains complex coordination concerns:

- asynchronous polling
- startup reconciliation
- execution ownership
- retry behavior
- projection synchronization
- attachment coordination

These concerns are real.

The goal is:

```text
understandable orchestration
```

rather than:

```text
minimal orchestration
```

---

# Shadow Implementation Strategy

Initial pilot behavior should remain:

```text
parallel
non-authoritative
observable
reversible
```

Preferred initial behavior:

- observe production state
- produce comparable semantic outputs
- log decisions
- avoid authoritative execution ownership

The pilot should initially avoid:

- production mutation
- production scheduling ownership
- production migration ownership

---

# Comparative Validation

The pilot should preferably compare itself against existing production behavior.

Examples:

## Factual Comparison

```text
live rowid
imported rowid
message counts
projection completion state
```

---

## Semantic Comparison

```text
ledger behind?
startup reconciliation required?
incremental update required?
projection inconsistent?
```

---

## Scheduling Comparison

```text
would incremental work be scheduled?
would retry occur?
would debounce occur?
```

Differences should be:

- logged
- reviewed
- explained

before production adoption occurs.

---

# Logging Philosophy

Preferred logging style:

```text
[legacy]
startup probe → schedule incremental import

[shadow]
startup probe → identical decision
```

or:

```text
[legacy]
ledger current

[shadow]
ledger behind
reason: imported count mismatch
```

Goal:

```text
causal architectural visibility
```

rather than merely low-level debugging.

---

# Attachment Relationship Clarification

Attachments are related to message orchestration but may still represent a distinct concern slice.

Reason:

- independent scheduling cadence
- independent maintenance behavior
- independent retry semantics
- independent orchestration narrative

Therefore, future structure may resemble:

```text
incremental_updates/
  messages/
  attachments/
```

even though attachments remain semantically connected to messages.

Concern separation is based primarily on:

- causal coherence
- orchestration coherence
- human comprehensibility

rather than complete physical independence.

---

# Success Criteria

Pilot success is NOT defined solely by runtime correctness.

Success also includes:

- improved explainability
- improved causal traceability
- improved architectural readability
- easier onboarding
- easier modification safety
- clearer orchestration narratives

The pilot should help humans more easily answer:

```text
What facts were observed?
What meaning was derived?
What execution occurred?
Why did execution occur?
```

---

# Promotion Criteria

Experimental architecture should only become production-authoritative after:

- behavioral equivalence
- comparative validation
- orchestration observability
- safe rollback capability
- sufficient confidence

Promotion should preferably occur incrementally rather than through wholesale replacement.

Examples:

- production Readers first
- production Integrators second
- production Orchestrators last

Or:

- attachment orchestration first
- message orchestration later

Incremental adoption is preferred over abrupt replacement.

---

# Final Clarification

This pilot should be treated as:

```text
architectural exploration
```

rather than:

```text
mandatory architectural replacement
```

The purpose is to evaluate whether responsibility decomposition produces a system that is:

- easier for humans to understand
- easier to reason about
- easier to safely evolve

while preserving the strengths of the existing deterministic pipeline architecture.
