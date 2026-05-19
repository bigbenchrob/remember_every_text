---
created_at: 2026-05-13T08:21:10-07:00
title: "Shadow incremental update tests"
tags: []
source: codex_prompt_history.html
---

# Shadow incremental update tests

## Prompt

```text
Task: Add focused tests for the shadow incremental-update semantic and execution pipeline

Context

The shadow incremental-update pilot now successfully performs a full closed loop:

facts
→ semantic meaning
→ policy meaning
→ shadow execution
→ updated facts
→ resolved semantic state

Before expanding functionality further, we need focused tests validating:
- semantic derivation
- policy derivation
- execution safety behavior
- especially ledger-ahead failure handling

IMPORTANT

Do not add broad integration tests yet.
Do not test legacy import/migration systems.
Do not touch production DBs.

Prefer:
- narrow
- deterministic
- architectural
- causal
tests.

Primary goals

Validate:

1. Snapshot delta → semantic sync state
2. Semantic sync state → import decision
3. Execution orchestrator safety behavior
4. Ledger-ahead blocking behavior

Suggested test files

Likely locations:

test/essentials/incremental_update/application/messages/integrators/
  message_sync_assessment_integrator_test.dart
  import_decision_integrator_test.dart

test/essentials/incremental_update/application/messages/orchestrators/
  shadow_import_execution_orchestrator_test.dart

Use existing naming conventions if nearby tests suggest better names.

Required tests

1. Message sync-state derivation tests

Validate:

SnapshotDelta(rowIdDelta: 0)
→ MessageSyncState.sourceAndLedgerCursorsMatch()

SnapshotDelta(rowIdDelta: positive)
→ MessageSyncState.sourceAheadOfLedger()

SnapshotDelta(rowIdDelta: negative)
→ MessageSyncState.ledgerAheadOfSource()

Use both rowIdDelta and messageCountDelta where appropriate.

2. Import decision derivation tests

Validate:

MessageSyncState.sourceAndLedgerCursorsMatch()
→ ImportDecision.doNothing()

MessageSyncState.sourceAheadOfLedger()
→ ImportDecision.considerIncrementalImport()

MessageSyncState.ledgerAheadOfSource()
→ ImportDecision.blockAndReportLedgerAhead()

Ensure exhaustive sealed-union handling remains covered.

3. Shadow execution orchestrator safety tests

Validate:

If decision == doNothing:
- executor is NOT invoked

If decision == blockAndReportLedgerAhead:
- executor is NOT invoked

If decision == considerIncrementalImport:
- executor IS invoked exactly once

Prefer mock/fake executor injection rather than real DB execution.

4. Explicit ledger-ahead scenario

Add a dedicated test describing:

live max rowid = 100
ledger max source_rowid = 105

Expected:

rowIdDelta = -5
→ MessageSyncState.ledgerAheadOfSource()
→ ImportDecision.blockAndReportLedgerAhead()
→ execution blocked

Architectural intent

These tests should validate the architecture’s causal safety rules:

facts
→ meaning
→ policy
→ execution eligibility

Execution must not occur directly from raw numeric facts.

Execution must remain blocked for ledger-ahead conditions.

Guardrails

Do not:
- add full integration tests
- use production DBs
- invoke legacy MessagesImporter
- invoke legacy migration
- invoke production execution gates
- add attachment logic
- add working_shadow.db logic
- broaden scope into startup reconciliation

Verification

Run:
- dart analyze on changed files
- relevant flutter test targets

Report:
- added test files
- covered scenarios
- how executor invocation was mocked/faked
- confirmation that ledger-ahead blocks execution
```
