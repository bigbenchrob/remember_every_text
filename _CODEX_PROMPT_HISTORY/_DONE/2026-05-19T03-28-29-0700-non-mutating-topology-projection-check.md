---
created_at: 2026-05-19T03:28:29-07:00
title: "Non-mutating topology projection check"
tags: []
source: codex_prompt_history.html
---

# Non-mutating topology projection check

## Prompt

```text
Next task: implement a read-only topology projection preview.

Context

The architecture now successfully preserves source-scoped topology:

* chat.db.chat_message_join observation exists
* chat_message_joins source-scoped ledger table exists
* topology import is resumable/idempotent
* topology stage participates in PipelineOrchestrator
* topology preservation occurs before migration/projection
* canonical relationship projection remains intentionally deferred

A design document now exists:

60-CANONICAL-TOPOLOGY-PROJECTION-DESIGN.md

The recommended next slice from that document is:

read-only topology projection preview

Goal

Build a mutation-free projection-preview layer that attempts to resolve source topology endpoints into existing ledger/working entities.

This slice should:

* validate endpoint resolution semantics
* expose unresolved/ambiguous topology conditions
* preserve the existing safety model
* avoid mutating working_shadow.db

This is still a semantic/diagnostic layer, not canonical topology projection.

Core idea

Take preserved source topology rows:

source_id
source_chat_rowid
source_message_rowid

and attempt to resolve them through:

ledger message/chat rows
→ working message/chat rows

without yet creating working relationship rows.

Important constraints

Do NOT:

* mutate working_shadow.db
* create projected topology tables
* remove placeholder chat behavior
* alter migration logic
* alter MessageImporter
* alter topology importer
* alter PipelineOrchestrator ordering
* introduce canonical conflict resolution
* alter UI/search behavior
* add graph orchestration
* add dependency planners

Do:

* preserve source truth vs app truth separation
* preserve source provenance
* expose endpoint-resolution semantics explicitly
* keep this slice read-only
* follow the existing readers/integrators/orchestrators pattern

Suggested structure

New concern area:

application/topology_projection_preview/

Suggested components:

Readers:

* topology projection preview reader(s)

Integrators:

* endpoint resolution integrators
* projection-preview semantic derivation

Models:

* topology projection preview models

Sealed unions:

* topology projection preview states/results

Potential model direction

A preview result should likely represent something like:

source topology row
→ ledger message resolved?
→ ledger chat resolved?
→ working message resolved?
→ working chat resolved?
→ projection status

Suggested projection statuses

From the design doc, likely variants such as:

* projectable
* missingLedgerMessage
* missingLedgerChat
* missingWorkingMessage
* missingWorkingChat
* ambiguousWorkingChat
* alreadyProjected
* notYetSupported

Use whatever names fit existing conventions best.

Endpoint resolution rules

Message endpoint resolution should likely follow:

source_id + source_message_rowid
→ ledger message
→ working message

Chat endpoint resolution should likely follow:

source_id + source_chat_rowid
→ ledger chat
→ working chat

Do not assume source row IDs are canonical app IDs.

Important architecture goal

This slice should validate:

Can source topology endpoints be deterministically resolved?

before introducing any topology mutation/projection into working_shadow.db.

This keeps the architecture sequence intact:

facts
→ semantic projection readiness
→ diagnostic meaning
→ mutation later

Suggested outputs

It is acceptable for this slice to produce:

* aggregated preview summaries
* counts by projection status
* sample unresolved rows
* diagnostic stage/report information

without full UI integration.

StageController?

Do NOT add a dedicated StageController yet unless the slice naturally needs one.

A narrow read-only preview orchestrator/integrator is sufficient for now.

Tests

Add focused tests covering:

* successful message endpoint resolution
* successful chat endpoint resolution
* missing ledger message
* missing ledger chat
* missing working message
* missing working chat
* ambiguous working chat
* fake archive source isolation
* source provenance preserved in preview results
* no working DB mutation occurs

Verification

Run:

* dart analyze on changed files
* focused topology projection preview tests
* existing topology importer/stage tests if affected

Report back with:

* files/models added
* exact preview statuses introduced
* endpoint resolution strategy implemented
* whether aggregated summaries were added
* whether any ambiguities/unresolved states appeared in current data
* confirmation the slice remains mutation-free
* tests run
```
