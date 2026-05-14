---
created_at: 2026-05-13T10:15:41-07:00
title: "Comparitive validation of shadow/legacy"
tags: []
source: codex_prompt_history.html
---

# Comparitive validation of shadow/legacy

## Prompt

```text
Task: Begin comparative validation between legacy incremental-update behavior and the shadow incremental-update architecture

Context

The shadow incremental-update pipeline is now fully functioning and validated:

live chat.db
→ macos_import_shadow.db
→ working_shadow.db

with:
- factual readers
- semantic-state integrators
- policy-decision integrators
- execution orchestrators
- narrow executors
- focused tests
- documented invariants

The next phase is NOT adding more features.

The next phase is comparative validation against production behavior.

Goal

Create the first comparative validation layer between:

legacy production incremental-update behavior
vs
shadow incremental-update behavior

This phase should initially focus on:
- observability
- comparison
- mismatch visibility
- causal traceability

NOT production replacement.

Primary objective

We now need to answer:

“Does the shadow architecture reach the same conclusions as the production system under real runtime conditions?”

Initial implementation scope

Start with logging-only comparative validation.

Do NOT build UI yet.

Do NOT change production behavior.

Do NOT let the shadow system influence production execution.

Required behavior

1. Observe existing legacy incremental-update state

Identify the existing production incremental-update signals already available.

Examples may include:
- production incremental import scheduled?
- production migration scheduled?
- production ledger current?
- production projection current?
- startup reconciliation state?
- existing chatDbChangeMonitorProvider outputs

Do not rewrite legacy behavior.
Do not replace legacy orchestration.

Only observe and expose enough production state for comparison.

2. Compare against shadow semantic/policy state

Compare production conclusions against:
- ImportDecision
- MigrationDecision
- MessageSyncState
- MessageMigrationState

3. Produce comparative logging

Preferred logging shape:

[legacy]
incremental import required

[shadow]
ImportDecision.considerIncrementalImport

or:

[legacy]
projection current

[shadow]
MigrationDecision.doNothing

or:

[comparison]
MATCH:
  legacy=incremental import required
  shadow=ImportDecision.considerIncrementalImport

or:

[comparison]
MISMATCH:
  legacy=projection current
  shadow=MigrationDecision.considerShadowMigration
  reason=shadow projection row count behind by 3

The goal is causal architectural visibility.

4. Introduce explicit comparison semantics

Prefer explicit comparison meaning such as:
- match
- mismatch
- unknown/not-comparable

Do not use loose booleans alone.

A sealed union is preferred if practical.

5. Keep comparison architecture clean

Prefer:

Readers
→ comparison integrators
→ comparison semantic state
→ comparison logger/orchestrator

Avoid:
- giant comparison objects
- compressed orchestration
- hidden conditional logic

Architectural intent

The comparison layer should answer:

What did production conclude?
What did shadow conclude?
Did they agree?
If not, why not?

This phase is epistemic validation, not execution ownership.

Guardrails

Do not:
- change production scheduling
- change production import execution
- change production migration execution
- let shadow execution trigger production execution
- let comparison logic mutate production DBs
- add UI surfaces yet
- broaden scope into attachments yet
- replace chatDbChangeMonitorProvider yet

Strong simplification preference

Prefer:
- narrow comparison slices
- logging
- explicit semantics
- readable causal flow

over:
- abstraction
- reuse
- completeness

Suggested first milestone

First useful milestone:

On each polling cycle:
- observe production incremental-update state
- observe shadow ImportDecision + MigrationDecision
- emit clear match/mismatch logs

Verification

Run:
- dart analyze on changed files

Then run the app and demonstrate:
- a matching state
- a shadow import cycle
- comparative logs during a new Messages.app message arrival

Report:
- new readers/integrators/orchestrators introduced
- how production state is observed
- comparison semantics used
- example comparison logs
- confirmation that production behavior was not modified
```
