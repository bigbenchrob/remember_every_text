---
created_at: 2026-05-13T07:35:47-07:00
title: "implement shadow message import"
tags: []
source: codex_prompt_history.html
---

# implement shadow message import

## Prompt

```text
Task: Implement a minimal shadow message import execution path for the incremental_update pilot

Context

The shadow incremental-update architecture is now fully validating:

facts
→ semantic meaning
→ policy meaning

using:

live chat.db
→ macos_import_shadow.db

The shadow pipeline currently detects that the shadow ledger is empty and emits:

ImportDecision.considerIncrementalImport

The next step is to validate a full closed-loop execution cycle:

decision
→ execution
→ ledger catches up
→ decision resolves to doNothing

IMPORTANT

This task is intentionally NOT a production importer replacement.

This is an architectural validation slice only.

The implementation must remain:
- tiny
- isolated
- shadow-only
- non-authoritative
- understandable

Absolutely avoid importing legacy responsibility-compressed behavior into this pilot.

Critical guardrail

DO NOT reuse the existing MessagesImporter.

Do not call into:
- legacy import orchestration
- legacy migration orchestration
- attachment orchestration
- startup reconciliation
- execution gates
- debounce/retry systems
- search indexing
- projection logic
- working.db logic
- overlay logic

The purpose of this slice is specifically to avoid inheriting the compressed legacy orchestration model.

Goal

Implement the smallest possible shadow message import execution path:

live chat.db.messages
→ macos_import_shadow.db.messages

ONLY.

Required behavior

1. Read current shadow ledger max imported source_rowid

Use the existing shadow import ledger repository/provider path already wired to:

macos_import_shadow.db

2. Read new rows from live chat.db.messages

Read rows where:

ROWID > shadow ledger max source_rowid

3. Insert those rows into:

macos_import_shadow.db.messages

4. Preserve existing message table schema compatibility

The shadow import should insert enough fields for:
- rowid tracking
- source_rowid tracking
- message counting
- future incremental continuation

Do not attempt full production-equivalent field coverage if unnecessary for this slice.

5. Trigger mechanism

Create a shadow execution orchestrator that:

- observes ImportDecision
- if decision == considerIncrementalImport:
    perform shadow import
- otherwise:
    do nothing

6. Safety

All writes must go ONLY to:

macos_import_shadow.db

Do not touch:
- macos_import.db
- working.db
- working_shadow.db

Architectural intent

This slice validates:

ImportDecision.considerIncrementalImport
→ execution occurs
→ factual ledger state changes
→ semantic state resolves naturally

Desired causal flow

poll tick
→ readers observe drift
→ semantic meaning derived
→ import decision derived
→ shadow import executes
→ readers observe ledger catch-up
→ semantic meaning resolves
→ decision becomes doNothing

Suggested structure

Prefer introducing a tiny, explicit execution component such as:

application/messages/executors/
  shadow_message_import_executor.dart

and:

application/messages/orchestrators/
  shadow_import_execution_orchestrator.dart

Suggested responsibility split

Executor:
- performs narrow message-row import work only

Execution orchestrator:
- observes ImportDecision
- decides whether execution should occur
- invokes executor

Readers:
- factual observation only

Integrators:
- meaning derivation only

Do not collapse these responsibilities together.

Strong simplification preference

Prefer:
- clarity
- explicitness
- tiny slices
- obvious causal flow

over:
- abstraction
- reuse
- feature completeness

Verification

After implementation:

1. Delete macos_import_shadow.db if needed.
2. Start app.
3. Start shadow polling.
4. Observe:
   - ImportDecision.considerIncrementalImport
5. Allow shadow import execution to run.
6. Confirm:
   - rows appear in macos_import_shadow.db.messages
   - shadow ledger catches up
   - MessageSyncState resolves
   - ImportDecision becomes doNothing

Run:
- dart analyze on changed files

Report:
- changed files
- final execution flow
- which fields are imported
- how shadow execution is triggered
- confirmation that no production DBs were modified
- confirmation that legacy MessagesImporter was not used
```
