---
created_at: 2026-05-18T12:42:20-07:00
title: "Fix semantic import distinction"
tags: []
source: codex_prompt_history.html
---

# Fix semantic import distinction

## Prompt

```text
The shadow incremental-update pipeline is now operationally healthy and behaviorally stable.

Recent endurance testing confirmed:

* handle import converges
* chat import converges
* message import converges
* migration converges
* comparative validation returns MATCH/MATCH

However, the logs now consistently show an important semantic distinction:

MessageSyncState.sourceAndLedgerCursorsMatch
rowIdDelta: 0
messageCountDelta: -4

Investigation confirmed:

* no non-source/shim rows exist in shadow messages
* source and ledger max row IDs match correctly
* import continuation semantics are functioning correctly
* migration is fully converged
* the count divergence likely reflects persistent-ledger vs live-source population semantics rather than import failure

Architectural clarification

Current MessageSyncState semantics are intentionally cursor-driven.

That is correct for incremental continuation semantics:

if max source row IDs match,
there are no newer source-local rows to import.

Count divergence is still useful,
but should remain diagnostic/observational unless stronger reconciliation semantics are intentionally introduced later.

Goal

Clarify and formalize the distinction between:

* cursor convergence semantics
    and
* diagnostic count divergence semantics

WITHOUT changing import behavior.

Desired direction

Keep current import continuation behavior fully cursor-driven.

Do NOT:

* gate ImportDecision on count equality
* change MessageSyncState derivation
* introduce new blocking states
* weaken or hide count divergence diagnostics
* change importer continuation behavior

Instead:

* make the distinction explicit in logs/status/docs.

Suggested implementation

Status/dev panel wording

Clarify that MessageSyncState represents cursor continuation state.

Example direction:

Message cursor state: current
Message count divergence: ledger ahead by 4

or equivalent wording.

Endurance log clarification

Preserve:

MessageSyncState.sourceAndLedgerCursorsMatch

but explicitly present:
messageCountDelta
as diagnostic reconciliation information rather than implied sync-state contradiction.

Architecture documentation

Add/update a small invariant/clarification explaining:

Cursor convergence determines incremental continuation semantics.

Count divergence is currently diagnostic only and may reflect:

* persistent import ledger behavior
* live-source deletions/pruning
* differing semantic populations
* future reconciliation concerns

without implying import failure.

Possible documentation locations:

* 30-INVARIANTS.md
* 50-INCREMENTAL-UPDATE-PILOT.md
* stage-controller or snapshot semantics docs if more appropriate

Tests

Add/update focused tests verifying:

* cursor convergence still derives sourceAndLedgerCursorsMatch even with count divergence
* count divergence remains observable
* wording/log presentation reflects the distinction clearly
* ImportDecision behavior remains unchanged

Verification

Run:

* dart analyze on changed files
* focused sync-state/integrator tests
* affected endurance-log/status tests

Report back with:

* wording/docs clarified
* any renamed fields/messages
* whether UI/log presentation changed
* tests run
* whether any open reconciliation questions remain
```

---

This is already implemented from the previous task.

What changed:

Dev panel now separates cursor continuation from count diagnostics:

Message cursor state

Cursor rowIdDelta

Count divergence

Endurance log now separates:

MessageSyncState

Message cursor state

cursor_rowIdDelta

diagnostic_messageCountDelta

count divergence

Docs updated:

30-INVARIANTS.md

50-INCREMENTAL-UPDATE-PILOT.md

Behavior unchanged:

MessageSyncState remains cursor-driven.

ImportDecision remains unchanged.

Count divergence is diagnostic only.

No importer, migration, polling, or comparison behavior changed.

Tests added/updated:

message_sync_assessment_integrator_test.dart

verifies rowIdDelta=0, messageCountDelta=-4 still produces MessageSyncState.sourceAndLedgerCursorsMatch.

shadow_polling_endurance_log_writer_test.dart

verifies count divergence is labeled diagnostic in the endurance log.

Existing import_decision_integrator_test.dart was rerun to confirm policy behavior remains unchanged.

Verification already passed:

dart analyze on changed files

flutter test for sync-state, import-decision, and endurance-log tests

Open question remains: whether count divergence should later become its own reconciliation policy. For now, it is explicitly observational.
