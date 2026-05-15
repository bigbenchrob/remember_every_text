---
created_at: 2026-05-14T08:15:55-07:00
title: "incremental update validation documentation"
tags: []
source: codex_prompt_history.html
---

# incremental update validation documentation

## Prompt

```text
Task: Formalize the validated incremental-update architecture spine in documentation

Context

The shadow incremental-update pilot has now proven a full observable, testable, comparable, inspectable causal system.

Validated runtime behavior:

live chat.db changes
→ shadow import decision changes
→ shadow import executes into macos_import_shadow.db
→ shadow migration decision changes
→ shadow migration executes into working_shadow.db
→ comparative validation distinguishes MATCH / PHASE SKEW / MISMATCH / NOT COMPARABLE
→ system returns to steady state

This has been observed both in console logs and in the dev-only status panel.

Goal

Update architecture documentation to formalize the reusable architecture spine proven by the pilot.

Documentation-only task.

Do not modify Dart code.

Primary documents to update

Likely:

_AGENT_INSTRUCTIONS/agent-per-project/55-READERS-INTEGRATORS-ORCHESTRATORS/50-INCREMENTAL-UPDATE-PILOT.md

_AGENT_INSTRUCTIONS/agent-per-project/55-READERS-INTEGRATORS-ORCHESTRATORS/30-INVARIANTS.md

Also inspect nearby docs and update only if clearly appropriate.

Key concept to formalize

The validated architecture spine is:

facts
→ semantic state
→ policy decision
→ execution orchestration
→ narrow executor
→ updated facts
→ comparative validation

This pattern has now been validated for:

1. Shadow import

live chat.db + macos_import_shadow.db facts
→ MessageSyncState
→ ImportDecision
→ ShadowImportExecutionOrchestrator
→ ShadowMessageImportExecutor
→ updated macos_import_shadow.db facts

2. Shadow migration

macos_import_shadow.db + working_shadow.db facts
→ MessageMigrationState
→ MigrationDecision
→ ShadowMigrationExecutionOrchestrator
→ ShadowMessageMigrationExecutor
→ updated working_shadow.db facts

3. Comparative validation

production facts + shadow facts
→ comparison semantics
→ MATCH / PHASE SKEW / MISMATCH / NOT COMPARABLE
→ human-readable diagnostic visibility

Add documentation sections covering

1. Validated architecture spine

Explain that this is no longer theoretical. It has been validated in running app behavior and tests.

2. Closed-loop import + migration

Document that one polling loop now drives:

shadow import catch-up
then shadow migration catch-up
then comparative validation

3. Dev-only status panel

Document the panel as an observability surface, not a control plane.

It displays:
- polling status
- last refresh / transition
- import decision
- sync state
- deltas
- migration decision
- migration state
- migration deltas
- comparative validation outcomes

4. Comparative validation semantics

Document:

MATCH:
systems agree

PHASE SKEW:
systems are in valid but temporally offset pipeline phases

MISMATCH:
durable semantic disagreement

NOT COMPARABLE:
insufficient or invalid facts

Emphasize that phase skew is not a failure.

5. Safety invariants

Ensure docs clearly state:

- shadow execution writes only to shadow DBs
- production DBs are read-only for comparison
- raw facts never directly trigger mutation
- semantic states never mutate
- policy decisions do not mutate directly
- execution orchestrators decide whether narrow executors may run
- executors perform explicitly scoped mutation only

6. Promotion implications

Add a brief section explaining that this pattern is now a candidate template for future orchestration systems, but production promotion still requires:
- behavioral equivalence
- rollback plan
- explicit ownership/gating
- staged adoption
- continued comparison against production behavior

Guardrails

Do not:
- rewrite the docs wholesale
- overclaim production readiness
- claim the pilot is feature-complete
- imply legacy production code has been replaced
- add implementation plans for attachments unless briefly mentioned as future candidate
- modify Dart files
- modify generated files

Verification

After documentation edits:

Report:
- changed markdown files
- major sections added or updated
- confirmation that no Dart code changed
- any architectural terminology clarified
```
