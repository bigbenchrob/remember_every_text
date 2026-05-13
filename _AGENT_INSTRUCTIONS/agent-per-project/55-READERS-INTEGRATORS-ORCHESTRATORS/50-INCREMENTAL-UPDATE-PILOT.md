# 50-INCREMENTAL-UPDATE-PILOT

## Purpose

This document defines the shadow incremental-update pilot for the Readers → Integrators → Orchestrators architectural responsibility model.

The message sync pilot under `lib/essentials/incremental_update/` is now a working, validated implementation of the model. It remains shadow/dev-only and non-authoritative, but it has proven the responsibility split, the correct invalidation boundary for polling, and the first closed-loop execution boundary.

Initial pilot target:

```text
Incremental update detection
```

Current validated milestone:

```text
shadow message import execution loop
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

The current pilot has advanced one narrow step beyond detection: it can execute a minimal shadow-only message import into `macos_import_shadow.db` when `ImportDecision.considerIncrementalImport` is observed.

NOT:

- full import replacement
- full migration replacement
- full attachment archival replacement
- projection ownership replacement
- production import execution

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

# Validated Shadow Incremental-Update Pipeline

The implemented shadow message pipeline now follows this flow:

```text
poll tick
→ invalidate reader snapshot providers
→ readers re-query source/ledger databases
→ delta integrator recomputes numeric drift
→ sync-state integrator derives semantic meaning
→ import-decision integrator derives policy meaning
→ polling orchestrator observes transitions
→ shadow execution orchestrator performs shadow-only import when requested
```

Concrete implemented examples:

```text
liveChatDbMessageSnapshotProvider
importLedgerMessageSnapshotProvider
→ snapshotDeltaIntegratorProvider
→ messageSyncStateProvider
→ importDecisionProvider
→ SyncStatePollingOrchestrator
→ ShadowImportExecutionOrchestrator
→ ShadowMessageImportExecutor
```

The reader snapshot providers are the external observation boundary:

- `liveChatDbMessageSnapshotProvider` observes live `chat.db`
- `importLedgerMessageSnapshotProvider` observes shadow `macos_import_shadow.db`

The derived providers do not observe external reality directly. They compose values and derive meaning.

---

# Closed-Loop Shadow Import Milestone

The pilot has now validated the first real execution boundary while staying shadow-only:

```text
observe drift
→ derive MessageSnapshotDelta
→ derive MessageSyncState
→ derive ImportDecision
→ execute minimal shadow import
→ observe updated shadow ledger
→ resolve to ImportDecision.doNothing
```

This is not a production importer replacement. The execution path exists to prove the architecture at the boundary where policy meaning becomes action.

Validated execution components:

```text
ShadowImportExecutionOrchestrator
ShadowMessageImportExecutor
```

The executor performs the smallest useful write path:

```text
live chat.db.message rows
→ macos_import_shadow.db.messages
```

The executor imports only enough fields to keep the shadow ledger useful for incremental continuation and message counting:

- `id`
- `source_rowid`
- `source_id`
- `source_kind`
- `guid`
- `chat_id`
- `service`
- `is_from_me`
- `text`
- source-presence booleans required by the schema
- `is_system_message`
- `batch_id`

Because the existing import ledger schema has foreign keys, the shadow executor may create shadow-only support rows in `import_batches` and a placeholder `chats` row inside `macos_import_shadow.db`. These support rows are schema compatibility scaffolding, not a reimplementation of legacy chat import behavior.

The closed-loop proof is:

```text
ImportDecision.considerIncrementalImport
→ shadow message import executes
→ macos_import_shadow.db.messages catches up to live chat.db.message
→ reader invalidation observes the new ledger state
→ MessageSyncState resolves
→ ImportDecision.doNothing
```

This milestone validates that execution can remain downstream of policy meaning without collapsing readers, integrators, and orchestration back into one responsibility-compressed object.

---

# Validated Implementation Structure

Current implemented structure:

```text
incremental_update/
  messages/
    executors/
    readers/
    integrators/
    orchestrators/
```

The pilot remains isolated from production orchestration ownership.

---

# Reader Snapshot Providers

Validated reader snapshot providers:

```text
liveChatDbMessageSnapshotProvider
importLedgerMessageSnapshotProvider
```

Reader goal:

```text
factual observation only
```

Readers and reader snapshot providers:

- observe external reality
- execute factual database reads
- produce immutable snapshots

Readers should avoid:

- orchestration
- retries/debounce
- execution triggering
- semantic interpretation

---

# Integrators

Validated integrator providers:

```text
snapshotDeltaIntegratorProvider
messageSyncStateProvider
importDecisionProvider
```

Integrator goal:

```text
semantic interpretation
```

The implemented integrator sequence separates facts, semantic meaning, and policy meaning:

```text
live/import snapshots
→ MessageSnapshotDelta
→ MessageSyncState
→ ImportDecision
```

Integrator roles:

- `snapshotDeltaIntegratorProvider` computes numeric drift from factual snapshots
- `messageSyncStateProvider` converts numeric drift into semantic sync state
- `importDecisionProvider` converts semantic sync state into policy meaning

Integrators should remain synchronous and pure whenever practical. Providers may coordinate async reads, but the semantic transform itself should be deterministic:

```text
facts in
→ meaning out
```

Decision integrators are still integrators. Their input is semantic meaning and their output is policy meaning. They should not perform side effects.

Integrators and decision integrators should avoid:

- lifecycle ownership
- retries/debounce
- execution triggering
- mutation-producing work

---

# Orchestrator

Validated orchestrator:

```text
SyncStatePollingOrchestrator
ShadowImportExecutionOrchestrator
```

Orchestrator goal:

```text
execution coordination
```

Orchestrators should own:

- polling cadence
- polling lifecycle
- refresh triggering
- overlap prevention
- transition observation
- execution triggering when downstream policy meaning calls for it

The validated polling orchestrator does not own semantic interpretation. It invalidates the factual observation boundary, reads the final policy provider, triggers the shadow execution orchestrator, and logs transitions.

Orchestrators should prefer:

- readers for factual observation
- integrators for meaning
- providers for reactive composition and dependency propagation

rather than embedding all logic internally.

---

# Executor

Validated executor:

```text
ShadowMessageImportExecutor
```

Executor goal:

```text
narrow shadow-only mutation
```

The executor is deliberately not a Reader and not an Integrator:

- it performs writes
- it does not derive semantic meaning
- it does not decide whether import should occur
- it does not own polling lifecycle

The current executor is intentionally limited to:

```text
live chat.db.message
→ macos_import_shadow.db.messages
```

It must not call or reuse:

- legacy `MessagesImporter`
- legacy import orchestration
- migration orchestration
- attachment orchestration
- search indexing
- projection logic
- production `macos_import.db`
- production `working.db`
- overlay database

This keeps the pilot execution boundary understandable and prevents the shadow architecture from inheriting the responsibility compression it is meant to evaluate.

---

# Invalidation Boundary Principles

The main architectural discovery from the working pilot is:

```text
Invalidate at the external observation boundary,
not at semantic/derived providers.
```

Polling means:

```text
observe external reality again
```

It does not mean:

```text
refresh conclusions
```

For the validated message pilot, the polling orchestrator invalidates only:

```text
liveChatDbMessageSnapshotProvider
importLedgerMessageSnapshotProvider
```

It does not manually invalidate:

```text
snapshotDeltaIntegratorProvider
messageSyncStateProvider
importDecisionProvider
```

Those providers should recompute naturally because they depend on the reader snapshot providers.

If invalidating factual observation providers does not propagate upward, the provider graph is structured incorrectly. The correct fix is to repair the dependency graph, not to force-refresh semantic conclusions.

---

# Reactive vs Imperative Flow

The pilot clarified an important distinction:

```text
reactive provider graph
vs
imperative polling invalidation
```

Providers watching other providers creates a reactive dependency graph. It does not mean that invalidating an upper derived provider forces lower providers to re-query external reality.

The imperative polling action should be narrow:

```text
poll tick
→ invalidate factual observation providers
→ read final semantic/policy provider
```

The reactive graph then handles:

```text
reader snapshots changed
→ delta recomputed
→ sync state recomputed
→ import decision recomputed
```

This preserves responsibility separation:

- polling owns time
- readers own external observation
- providers own dependency propagation
- integrators own meaning

---

# Semantic State Derivation

The validated message pilot uses distinct layers of meaning:

```text
MessageSnapshotDelta
→ MessageSyncState
→ ImportDecision
```

`MessageSnapshotDelta` is factual numeric drift:

- row id delta
- message count delta

`MessageSyncState` is semantic sync meaning:

- cursors match
- source ahead of ledger
- ledger ahead of source

`ImportDecision` is policy meaning:

- do nothing
- consider incremental import
- block/report ledger-ahead condition

These should remain separate. A numeric fact should not directly schedule work. A semantic state should not perform side effects. A policy decision should not mutate production systems by itself.

---

# Why Sealed Unions Matter

Semantic states and policy decisions should use sealed unions when the set of meanings is intentionally finite.

The pilot validates this for:

```text
MessageSyncState
ImportDecision
```

Sealed unions make transitions explicit and force exhaustive handling. This matters because missing a state in incremental update logic can lead to silent import skips, unsafe execution, or confusing logs.

Prefer sealed unions for semantic meaning such as:

- source and ledger cursors match
- source is ahead of ledger
- ledger is ahead of source
- import should do nothing
- import should be considered
- import should be blocked and reported

Avoid encoding these as loose strings or unstructured booleans once they become orchestration-relevant.

---

# Why Readers Must Own External Observation

Readers are the right invalidation boundary because they are the only layer that observes external reality.

In the validated pilot, external reality is:

- live Messages `chat.db`
- shadow `macos_import_shadow.db`

The reader snapshot providers re-query those databases and produce factual snapshots. Everything above that layer should be a deterministic consequence of those facts.

This rule prevents semantic providers from becoming accidental lifecycle owners. It also makes logs easier to reason about:

```text
external facts changed
→ semantic meaning changed
→ policy meaning changed
```

instead of:

```text
some conclusion was refreshed
→ maybe facts changed
```

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
