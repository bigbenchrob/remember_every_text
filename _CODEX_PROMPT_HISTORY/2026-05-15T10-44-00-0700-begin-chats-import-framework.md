---
created_at: 2026-05-15T10:44:00-07:00
title: "Begin chats import framework"
tags: []
source: codex_prompt_history.html
---

# Begin chats import framework

## Prompt

```text
Next architectural slice: add read-only chat observation/reconciliation, without mutation.

Context

The shadow incremental-update architecture now has:

* validated message import/migration loop
* portable MessageImporter naming
* ImporterDescriptor metadata
* source-scoped message relationship fields
* read-only handle observation/reconciliation slice
* handle semantic state and handle policy decision
* focused tests for handle delta/state/decision/provider behavior

The next step is to add the corresponding read-only chat slice so the future dependency topology becomes visible before adding mutation.

Goal

Add a chats observation/reconciliation slice WITHOUT mutation.

This slice should stop before actual chat import execution.

The purpose is to establish:

facts
→ semantic state
→ policy meaning

for chats.

Desired shape

live chat.db.chat facts
→ shadow ledger chats facts
→ chat delta
→ chat sync state
→ chat import decision

No writes yet.

No ChatImporter yet.

No graph orchestration yet.

Suggested structure

Follow the same architecture grammar already used for messages and handles.

Suggested folders:

application/chats/readers/
application/chats/integrators/

Infrastructure additions only if needed.

Suggested models/providers

Models:

* ChatSnapshot
* ChatSnapshotDelta

Readers:

* liveChatDbChatSnapshotProvider
* importLedgerChatSnapshotProvider

Integrators:

* chatSnapshotDeltaIntegratorProvider
* chatSyncStateProvider
* chatImportDecisionProvider

Semantic state:

* ChatSyncState.sourceAndLedgerCursorsMatch
* ChatSyncState.sourceAheadOfLedger
* ChatSyncState.ledgerAheadOfSource

Policy decision:

* ChatImportDecision.doNothing
* ChatImportDecision.considerIncrementalImport
* ChatImportDecision.blockAndReportLedgerAhead

Observation details

Keep observation minimal.

Examples:

* MAX(ROWID)
* row count

Do NOT attempt:

* chat canonicalization
* participant resolution
* chat-handle joins
* dedupe
* relationship projection
* migration/projection
* source merging

Architectural constraints

DO NOT:

* add chat mutation
* add ChatImporter yet
* add topological sorting
* add importer graph orchestration
* add production ownership
* alter message import behavior
* alter handle behavior
* couple chats to messages yet
* couple chats to handles yet
* add relationship resolution

DO:

* preserve architectural symmetry
* preserve source-scoped thinking
* preserve explicit semantic meaning
* preserve testability
* keep this mutation-free

Tests

Add focused tests for:

* chat delta interpretation
* semantic state derivation
* policy decision derivation
* ledger-ahead blocking
* provider-chain behavior
* live chat snapshot repository
* import-ledger chat snapshot repository

No endurance logging changes required yet.
No dev panel changes required yet.
No execution orchestrator required yet.

Report back with:

* files added
* semantic states introduced
* policy decisions introduced
* what chat facts are observed
* confirmation this slice is mutation-free
* confirmation no premature coupling/graph abstraction was added
```
