---
created_at: 2026-05-15T08:49:48-07:00
title: "Begin targeted minimal expansion of shadow pipeline"
tags: []
source: codex_prompt_history.html
---

# Begin targeted minimal expansion of shadow pipeline

## Prompt

```text
You are beginning the next architectural phase of the shadow incremental-update system.

IMPORTANT CONTEXT

The current shadow pilot is now validated and functioning:

facts
→ semantic state
→ policy decision
→ execution orchestration
→ narrow executor
→ updated facts
→ comparative validation

The shadow pipeline currently supports:

* shadow incremental import
* shadow migration/projection
* comparative validation
* endurance logging
* dev observability panel
* causal tick-event tracing

The system is intentionally:

* shadow-only
* non-authoritative
* parallel to production
* reversible
* observable

Do NOT move toward production replacement yet.

The goal of this branch is NOT:
“add more features quickly.”

The goal IS:
stabilize the architectural substrate before expanding table coverage.

CORE DIRECTION

We are now transitioning from:
narrow SQL executors

toward:
production-shaped importer architecture.

The immediate priority is:

1. source-scoped identity
2. importer discipline
3. resumable/idempotent continuation
4. explicit dependency ownership

before:

* joins
* attachments
* canonicalization
* archive-source merging
* production adoption

ARCHITECTURAL REQUIREMENTS

The following principles are now considered foundational:

* macos_import_shadow.db is a persistent shadow ledger, NOT disposable scratch state.
* Importers must become resumable and idempotent.
* Source truth must be preserved separately from canonical app truth.
* Raw source rowids are NOT globally meaningful across multiple sources.
* Relationship-bearing tables must preserve source-scoped provenance identity.
* Projection/migration resolves canonical application identity later.

IMPORTANT:

Do NOT design around:
“single live chat.db forever.”

The architecture must anticipate:
multiple archive sources + live sources.

IMMEDIATE OBJECTIVES FOR THIS BRANCH

PHASE 1 — Stabilize importer architecture

1. Refactor:
    ShadowMessageImportExecutor
    →
    ShadowMessageImporter

without changing observable behavior.

2. Introduce a minimal importer abstraction:

ImporterDescriptor:

* importerName
* sourceTables
* targetTables
* prerequisites
* continuationStrategy
* idempotenceStrategy
* validationStrategy

This can initially remain extremely lightweight.

3. Preserve all current behavior:

* polling
* comparative validation
* endurance logging
* convergence tracking
* dev status panel
* tests

4. Add source-scoped relationship preservation to shadow messages.

The shadow ledger should begin preserving source-local relationship identity explicitly.

Examples:

* source_chat_rowid
* source_sender_handle_rowid

Do NOT yet attempt canonical relationship resolution.

Projection remains responsible for canonical app identity later.

IMPORTANT CONSTRAINTS

DO NOT:

* build a generic framework
* build importer graph execution yet
* add topological sorting yet
* introduce production ownership
* collapse responsibilities together
* bypass Readers → Integrators → Orchestrators boundaries

DO:

* preserve causal traceability
* preserve explicit responsibility separation
* preserve narrow mutation ownership
* preserve observability
* preserve testability
* preserve endurance validation semantics

The validated architecture spine and invariants must remain intact.

DESIRED OUTCOME

At the end of this branch, we should have:

* a production-shaped message importer
* explicit importer metadata
* preserved shadow behavior
* preserved behavioral comparison
* source-scoped message relationship identity
* a cleaner substrate for adding:
    handles
    chats
    joins
    attachments

incrementally and safely.

Before coding:
please first inspect the current shadow incremental-update structure and propose the smallest safe architectural refactor sequence.

_________________________

Codex response:

Current shadow structure is clean enough for a small staged refactor.

Current Shape

SyncStatePollingOrchestrator owns polling, invalidates reader providers, invokes import/migration refresh, then comparison.
ShadowImportExecutionOrchestrator owns execution eligibility and overlap protection.
ShadowMessageImportExecutor owns the actual live chat.db.message → macos_import_shadow.db.messages mutation.
The executor is already narrow, resumable by MAX(source_rowid), and idempotent via INSERT ... conflictAlgorithm.ignore.
messages already has source_id and source_kind, but not source-scoped relationship fields like source_chat_rowid or source_sender_handle_rowid.
Smallest Safe Refactor Sequence

Introduce importer metadata only
Add a lightweight ImporterDescriptor model with:
importerName, sourceTables, targetTables, prerequisites, continuationStrategy, idempotenceStrategy, validationStrategy.

Rename/refactor executor to importer
Rename ShadowMessageImportExecutor → ShadowMessageImporter, preserving:

importNewMessages()
result type shape
provider behavior
orchestrator behavior
This is mostly naming and responsibility clarification.
Keep orchestrator boundary unchanged
ShadowImportExecutionOrchestrator should still decide whether execution may run. It should depend on the importer and call importNewMessages(). No graph, no topological ordering, no production ownership.

Attach descriptor to message importer
Add a descriptor getter/static const on ShadowMessageImporter, likely:

source tables: message
target tables: messages, plus schema-support chats / import_batches
prerequisites: empty for now
continuation: MAX(messages.source_rowid)
idempotence: source_rowid/id + conflict ignore
validation: minimal current row-count/cursor convergence
Add source-scoped relationship fields to shadow import ledger messages
Add nullable columns to macos_import.db / shadow schema:

source_chat_rowid INTEGER
source_sender_handle_rowid INTEGER
Keep nullable. Do not resolve canonical relationships yet.

Populate fields in the shadow message importer
Update the live message query to read source-local relationship columns, probably:

chat_id AS source_chat_rowid
handle_id AS source_sender_handle_rowid
Insert them into shadow messages. Continue using placeholder chat_id for schema compatibility until chat import/projection is introduced.

Focused tests
Add/adjust tests for:

schema creation includes new nullable source-scoped relationship columns
upgrade adds them safely
importer descriptor values are stable
shadow message import preserves source_chat_rowid / source_sender_handle_rowid
orchestrator still invokes importer exactly once for considerIncrementalImport
Key Constraints To Preserve

No production DB writes.
No archive import implementation.
No importer graph yet.
No topological sort.
No canonical relationship resolution.
No working DB relationship changes.
No behavioral change to polling, comparison, endurance logging, or dev panel.
The riskiest part is the schema bump, because it affects macos_import.db as well as shadow DB creation. I’d keep that isolated and nullable, with focused sqflite creation/upgrade tests.
```

# Chat GPT correction

The only change I’d make is ordering:

Reason: the schema bump is the riskiest piece. I’d isolate it in its own commit before the naming/architecture refactor.

So the sequence becomes:

Commit 1:
Add nullable source_chat_rowid / source_sender_handle_rowid
schema creation + upgrade tests
no behavior change

Commit 2:
Populate those fields in current shadow message import path
focused import preservation test

Commit 3:
Rename/refactor ShadowMessageImportExecutor → ShadowMessageImporter
preserve behavior

Commit 4:
Add ImporterDescriptor metadata
descriptor tests
