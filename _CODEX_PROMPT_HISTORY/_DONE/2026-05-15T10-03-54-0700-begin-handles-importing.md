---
created_at: 2026-05-15T10:03:54-07:00
title: "Begin handles importing"
tags: []
source: codex_prompt_history.html
---

# Begin handles importing

## Prompt

```text
Next architectural slice: begin the first prerequisite-bearing importer concern using handles, but ONLY through observation and semantic reconciliation initially.

Context

The shadow incremental-update system now has:

- validated shadow import + migration loop
- comparative validation
- endurance logging
- tick-event tracing
- importer abstraction
- importer descriptors
- source-scoped relationship preservation

The architecture is intentionally evolving incrementally and cautiously.

The next milestone is NOT:
“implement full handle import.”

The next milestone IS:
prove the Readers → Integrators → policy-decision chain for the first prerequisite-bearing table.

Goal

Add a handles observation/reconciliation slice WITHOUT mutation.

This slice should stop before actual handle import execution.

The purpose is to establish:

facts
→ semantic state
→ policy meaning

for handles, before introducing a real ShadowHandleImporter.

Desired shape

live chat.db.handle facts
→ shadow ledger handles facts
→ handle delta
→ handle sync state
→ handle import decision

No writes yet.

No importer execution yet.

No graph orchestration yet.

Suggested structure

Follow the same architectural grammar already validated for messages.

Suggested folders:

application/handles/readers/
application/handles/integrators/

Infrastructure additions only if needed.

Suggested providers/models

Readers:
- liveChatDbHandleSnapshotProvider
- importLedgerHandleSnapshotProvider

Models:
- HandleSnapshot
- HandleSnapshotDelta

Integrators:
- handleSnapshotDeltaIntegratorProvider
- handleSyncStateProvider
- handleImportDecisionProvider

Suggested semantics

Possible semantic states:

HandleSyncState:
- sourceAndLedgerCursorsMatch
- sourceAheadOfLedger
- ledgerAheadOfSource

Possible policy decisions:

HandleImportDecision:
- doNothing
- considerIncrementalImport
- blockAndReportLedgerAhead

Keep this intentionally parallel to the message grammar.

Observation details

Initially keep handle observation minimal.

Examples:
- MAX(ROWID)
- row counts

Do NOT attempt:
- canonicalization
- dedupe
- joins
- relationship resolution
- migration/projection
- source merging

No handle writes yet.

No shadow handle importer yet.

No orchestration execution yet.

Architectural constraints

DO NOT:
- add handle mutation
- add topological sorting
- add importer graph orchestration
- add production ownership
- add handle projection logic
- add relationship resolution
- couple handles to messages yet

DO:
- preserve architecture symmetry
- preserve explicit semantic meaning
- preserve clear causal flow
- preserve observability
- preserve testability

The important thing being validated is:

Can prerequisite-bearing concerns follow the same architecture spine cleanly before execution exists?

Tests

Add focused tests for:
- handle delta interpretation
- semantic state derivation
- policy decision derivation
- ledger-ahead blocking behavior
- stable provider behavior

No endurance logging changes required yet.
No dev panel changes required yet.

Report back with:
- files added
- semantic states introduced
- policy decisions introduced
- whether the handle slice remained mutation-free
- whether any premature coupling/abstraction temptations were intentionally avoided
```

---

Implemented the read-only handle observation/reconciliation slice.

Added:

Handle models:
HandleSnapshot
HandleSnapshotDelta
Handle semantic states:
HandleSyncState.sourceAndLedgerCursorsMatch
HandleSyncState.sourceAheadOfLedger
HandleSyncState.ledgerAheadOfSource
Handle policy decisions:
HandleImportDecision.doNothing
HandleImportDecision.considerIncrementalImport
HandleImportDecision.blockAndReportLedgerAhead
Read-only repositories/readers/providers for:
live chat.db.handle
shadow import ledger macos_import_shadow.db.handles
Pure integrators/providers for:
handle delta
handle sync state
handle import decision
Tests added:

delta interpretation
semantic state derivation
policy decision derivation
ledger-ahead blocking
provider-chain behavior
live handle snapshot repository
import-ledger handle snapshot repository
Verification passed:

dart analyze on the new handle slice
focused flutter test for the new handle tests
This slice is mutation-free: no handle importer, no execution orchestrator, no graph orchestration, no polling changes, and no production behavior changes.
