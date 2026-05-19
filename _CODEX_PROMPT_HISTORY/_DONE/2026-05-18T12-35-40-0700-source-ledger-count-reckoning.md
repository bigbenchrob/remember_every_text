---
created_at: 2026-05-18T12:35:40-07:00
title: "Source/ledger count reckoning"
tags: []
source: codex_prompt_history.html
---

# Source/ledger count reckoning

## Prompt

```text
We should clarify and formalize the distinction between:

* cursor-based import continuation semantics
    and
* diagnostic count divergence semantics

Current situation

The shadow incremental-update pipeline is operationally healthy:

* source and ledger max row IDs converge
* imports stop correctly
* migration converges
* comparative validation returns MATCH/MATCH

However, the endurance log currently shows:

messageCountDelta: -4

while simultaneously reporting:

MessageSyncState.sourceAndLedgerCursorsMatch

Investigation confirmed:

* no non-source/shim rows exist in shadow messages
* max source row IDs are equal
* import continuation semantics are functioning correctly
* the count divergence likely reflects persistent-ledger vs live-source population semantics rather than import failure

Important architectural clarification

Current MessageSyncState is intentionally cursor-driven.

That is correct for incremental continuation semantics:

* if max source row IDs match,
* there are no newer source-local rows to import.

Count divergence is still useful,
but should remain diagnostic/observational unless we later define stronger reconciliation semantics.

Goal

Clarify this distinction in:

* naming
* status presentation
* endurance logs
* architecture documentation

WITHOUT changing import execution behavior.

Desired direction

Keep current import continuation semantics cursor-driven.

Do NOT:

* gate import execution on count equality
* convert count divergence into blocking state
* introduce new execution policy
* weaken or hide the diagnostic

Instead:

* explicitly surface count divergence as diagnostic reconciliation information.

Suggested implementation

Possible refinements include:

Status/dev panel wording

Instead of implying:
MessageSyncState fully represents reconciliation,

clarify separation such as:

Message cursor state: current
Message count divergence: ledger ahead by 4

or equivalent wording.

Endurance log wording

Keep:
MessageSyncState.sourceAndLedgerCursorsMatch

but separately surface:
messageCountDelta as a diagnostic reconciliation value.

Architecture documentation

Add a small invariant/clarification explaining:

Cursor convergence determines incremental continuation semantics.

Count divergence is currently diagnostic only and may reflect:

* persistent import ledger behavior
* live-source deletions/pruning
* differing semantic populations
* future reconciliation concerns

without implying import failure.

Important constraints

Do NOT:

* change ImportDecision semantics
* change MessageSyncState derivation semantics
* introduce new sync states unless truly necessary
* alter importer behavior
* alter migration behavior
* alter polling cadence
* alter comparison semantics

This is a semantic clarification / observability refinement only.

Tests

Add/update focused tests verifying:

* cursor convergence still derives sourceAndLedgerCursorsMatch even with count divergence
* count divergence remains observable
* status/log wording reflects the distinction clearly
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

Clarified cursor-vs-count semantics without changing execution behavior.

Changed:

- Dev panel now separates:
  - `Message cursor state`
  - `Cursor rowIdDelta`
  - `Count divergence`
- Endurance log now separates:
  - `Message cursor state`
  - `cursor_rowIdDelta`
  - `diagnostic_messageCountDelta`
  - `count divergence`
- Docs updated:
  - [30-INVARIANTS.md](/Users/rob/Development/FlutterProjects/remember_every_text/_AGENT_INSTRUCTIONS/agent-per-project/55-READERS-INTEGRATORS-ORCHESTRATORS/30-INVARIANTS.md)
  - [50-INCREMENTAL-UPDATE-PILOT.md](/Users/rob/Development/FlutterProjects/remember_every_text/_AGENT_INSTRUCTIONS/agent-per-project/55-READERS-INTEGRATORS-ORCHESTRATORS/50-INCREMENTAL-UPDATE-PILOT.md)

Semantics remain unchanged:

- `MessageSyncState` is still cursor-driven.
- `ImportDecision` still follows `MessageSyncState`.
- Count divergence is visible but diagnostic only.
- No importer, migration, polling cadence, or comparison behavior changed.

Tests added/updated:

- `MessageSyncAssessmentIntegrator` now verifies `rowIdDelta=0` with `messageCountDelta=-4` still returns `sourceAndLedgerCursorsMatch`.
- Endurance log writer now verifies count divergence is labeled diagnostic.

Verification passed:

- `dart analyze` on changed files
- `flutter test` for sync-state, import-decision, and endurance-log tests

Open reconciliation question remains: whether we eventually want a separate reconciliation policy for count divergence. For now, it is intentionally observational.
OO
