---
created_at: 2026-05-14T07:45:53-07:00
title: "Shadow/legacy pipeline dev panel"
tags: []
source: codex_prompt_history.html
---

# Shadow/legacy pipeline dev panel

## Prompt

```text
Task: Add a dev-only shadow incremental-update status panel

Context

The shadow incremental-update pilot now has:

- shadow import execution
- shadow migration execution
- comparative validation against production
- MATCH / PHASE SKEW / MISMATCH / NOT COMPARABLE semantics
- focused tests for comparison behavior

Console logs are useful, but we now need a small developer visibility surface so the current shadow state can be inspected without reading logs.

Goal

Add a dev-only status panel or toolbar popover showing the current shadow incremental-update status.

Scope

This is visibility only.

Do not change:
- production behavior
- shadow execution behavior
- polling cadence
- import/migration logic
- comparison semantics

Suggested UI contents

Show:

1. Polling status
- polling active/inactive if available
- last refresh time if available

2. Shadow import state
- ImportDecision
- MessageSyncState
- rowIdDelta
- messageCountDelta

3. Shadow migration state
- MigrationDecision
- MessageMigrationState
- messageIdDelta
- messageCountDelta

4. Comparative validation
- incremental import comparison outcome
- migration projection comparison outcome
- reason text for phase skew/mismatch/not comparable

5. Optional controls
- Start polling
- Stop polling
- Refresh once

Use existing dev toolbar/panel conventions if present.

Architecture requirements

Prefer a read-only presentation provider/view-model that watches existing providers:

- importDecisionProvider
- messageSyncStateProvider
- snapshotDeltaIntegratorProvider
- migrationDecisionProvider
- messageMigrationStateProvider
- migration delta provider
- incrementalUpdateComparisonProvider

Do not make the UI compute semantic meaning itself.

The UI should display already-derived facts and meanings.

Guardrails

Do not:
- add new business logic to the widget
- trigger production import/migration
- write to production databases
- write to shadow databases except through existing Start/Refresh behavior
- introduce new polling logic in the widget
- duplicate integrator logic
- modify legacy chatDbChangeMonitorProvider

Implementation preference

Keep this small and developer-only.

Acceptable forms:
- toolbar popover
- collapsible dev panel
- temporary dev-only section in existing toolbar shell

Prefer clarity over polish.

Testing

If practical, add a simple widget/view-model test for formatting or state mapping.

At minimum run:
- dart analyze on changed files

Manual verification

1. Launch app.
2. Open dev status panel.
3. Confirm initial state shows doNothing / projectionCaughtUp / MATCH.
4. Start polling.
5. Send one Messages.app message.
6. Confirm panel reflects:
   - import decision transition
   - migration decision transition
   - comparison outcome, including PHASE SKEW if sampled mid-transition
7. Confirm final state returns to doNothing / projectionCaughtUp / MATCH.

Report:
- changed files
- where the panel is exposed
- which providers the panel watches
- confirmation that it does not compute business logic itself
- confirmation that production behavior is unchanged
```
