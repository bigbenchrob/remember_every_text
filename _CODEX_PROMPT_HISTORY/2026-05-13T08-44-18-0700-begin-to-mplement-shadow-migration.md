---
created_at: 2026-05-13T08:44:18-07:00
title: "Begin to mplement shadow migration"
tags: []
source: codex_prompt_history.html
---

# Begin to mplement shadow migration

## Prompt

```text
Task: Begin the next shadow incremental-update phase: shadow migration into working_shadow.db

Context

The shadow incremental-update pilot has now validated a complete closed-loop shadow import flow:

facts
→ semantic meaning
→ policy meaning
→ shadow import execution
→ updated facts
→ resolved policy state

Current validated shadow execution:

live chat.db.messages
→ macos_import_shadow.db.messages

The next phase is:

macos_import_shadow.db
→ working_shadow.db

IMPORTANT

This is still:
- shadow-only
- non-authoritative
- architectural validation
- not a production replacement

We must preserve the Readers → Integrators → Orchestrators responsibility model and avoid importing legacy responsibility-compressed migration behavior into the pilot.

Critical guardrails

DO NOT:
- mutate production working.db
- mutate production macos_import.db
- invoke legacy migration orchestration
- invoke production search indexing
- invoke production onboarding/recovery flows
- invoke production execution gates
- invoke production projection-state ownership
- collapse migration semantics into one large orchestrator
- broaden scope into attachment migration

Goal

Implement the smallest useful shadow migration slice:

macos_import_shadow.db.messages
→ working_shadow.db.messages

ONLY.

Architectural intent

Validate another closed-loop boundary:

shadow ledger facts
→ migration semantic meaning
→ migration decision
→ shadow migration execution
→ updated projection facts
→ resolved migration state

We are proving that migration execution can also remain downstream of semantic meaning rather than becoming responsibility-compressed.

Suggested responsibility structure

Prefer structure analogous to the import pilot:

readers/
integrators/
orchestrators/
executors/

Suggested new concepts

Readers:
- shadow working projection snapshot reader
- shadow import ledger projection snapshot reader

Integrators:
- migration delta / projection state meaning
- migration decision derivation

Orchestrators:
- polling / transition observation
- migration execution coordination

Executors:
- narrow shadow-only migration writes

Preferred initial migration scope

The first shadow migration slice should be intentionally tiny.

Recommended first target:

Copy/import enough message rows into working_shadow.db.messages so that:
- message counts can be compared
- projection catch-up can be observed
- semantic migration state can resolve

Do NOT attempt:
- full production-equivalent migration
- search index rebuilds
- reactions
- attachments
- handles reconciliation
- contact resolution
- timeline index rebuilds
- projection metadata completeness
- startup recovery behavior

Strong simplification preference

Prefer:
- explicitness
- narrow causal flow
- obvious semantics
- tiny responsibilities

over:
- abstraction
- reuse
- production completeness

Desired causal flow

poll tick
→ invalidate shadow migration readers
→ derive migration semantic state
→ derive migration decision
→ if migration needed:
    execute minimal shadow migration
→ readers observe updated projection state
→ semantic state resolves
→ migration decision resolves

Safety requirements

All writes must remain confined to:

working_shadow.db

The shadow migration path must not:
- open production working.db for mutation
- reuse production migration orchestration
- mutate projection_state in production DBs
- interact with user_overlays.db

Testing expectations

Prefer the same testing strategy used for the import pilot:

1. Pure semantic derivation tests
2. Migration decision tests
3. Execution eligibility/blocking tests
4. Narrow executor/orchestrator tests

Avoid broad integration tests initially.

Suggested milestone target

The first success condition should be conceptually simple:

before migration:
- shadow ledger ahead of shadow working projection
- migration decision requests migration

after migration:
- shadow working projection catches up
- migration semantic state resolves
- migration decision becomes doNothing

Verification

Run:
- dart analyze on changed files

Report:
- new readers/integrators/orchestrators/executors introduced
- what semantic migration state means
- what migration decision means
- exactly which working_shadow.db tables are touched
- confirmation that production DBs were not modified
- confirmation that legacy migration orchestration was not reused
```
