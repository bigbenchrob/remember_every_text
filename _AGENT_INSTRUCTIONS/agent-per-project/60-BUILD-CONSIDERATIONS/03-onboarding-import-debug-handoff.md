---
tier: project
scope: handoff
owner: agent-per-project
status: superseded-historical
last_reviewed: 2026-06-06
source_of_truth: historical-record
links:
  - ../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
  - ../20-DATA-IMPORT-MIGRATION/11-rust-message-extractor.md
  - ../42-SPEC-SYSTEM/README.md
  - ../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md
  - ./02-macos-fda-grant-continuity.md
tests: []
---

# Onboarding / Import Debug Handoff

> **Superseded historical record.** This document describes a March 2026
> legacy import-panel debugging incident. It is retained to preserve project
> history, but it is not current graph-era onboarding, import, or lifecycle
> guidance.
>
> Current ordinary app setup and live update flow is source-scoped:
> `chat.db` -> `macos_import_ss.db` -> `working_ss.db`, coordinated by the
> onboarding/readiness surfaces, `ConversationGraphBuildController`, and
> `ChatDbChangeMonitor`. Retained historical import/projection code exists only
> for explicit archive/recovery compatibility or diagnostics.

Use this file only to understand the historical incident. For current work,
start with:

- `../25-ONBOARDING-AND-ARCHIVE/README.md`
- `../20-DATA-IMPORT-MIGRATION/01-overview.md`
- `../55-READERS-INTEGRATORS-ORCHESTRATORS/73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md`

The original handoff follows below and should not be treated as an active
debugging brief.

## Current Objective

The current user goal is to get the first-run path working end-to-end for a new user:

1. Environmental readiness should accurately evaluate whether the app can proceed.
2. The user should be able to reach and use the legacy developer import and migration panel.
3. Import should actually start when the Import button is pressed.
4. Once import works again, migration and downstream content fidelity can be re-checked.

## Short Status Summary

- Environmental readiness flow for new users was implemented and is active.
- The app can reach the import stage.
- Import has been incomplete or unreliable in recent testing.
- The legacy import developer panel had been short-circuited by the readiness flow.
- That panel-routing regression was partially fixed so the panel is no longer immediately replaced by readiness.
- The newest blocker is functional: the Import button now does not start import.

## Architecture Summary

The relevant systems are split across three cooperating layers:

### 1. Onboarding / readiness state

- `lib/essentials/onboarding/application/onboarding_gate_provider.dart`
  - Owns the high-level onboarding status machine.
  - Drives states like `awaitingFda`, `awaitingUserAction`, `importing`, `migrating`, and `complete`.
- `lib/essentials/onboarding/application/onboarding_environment_report_provider.dart`
  - Evaluates the environment and classifies the current readiness state.
- `lib/features/environment_readiness/`
  - Owns the readiness surface feature, view model mapping, and panel UI.

### 2. Cross-surface navigation

- `lib/essentials/navigation/presentation/widgets/onboarding_center_panel_sync_observer.dart`
  - Auto-opens the readiness panel when onboarding blocks progress.
- `lib/essentials/navigation/application/panel_widget_providers.dart`
  - Reconciles sidebar-driven message flow with the center panel.
  - This layer can overwrite center-panel content if it decides the current panel is incompatible with sidebar flow.
- `lib/essentials/navigation/presentation/view/macos_app_shell.dart`
  - Toolbar Import button routes to `ViewSpec.import(ImportSpec.forImport())`.

### 3. Import and migration execution

- `lib/essentials/db_importers/presentation/view/db_import_control_panel.dart`
  - Legacy developer import/migration panel.
  - Exposes `Start Import`, `Clear Import DB`, and migration controls.
- `lib/essentials/db_importers/presentation/view_model/db_import_control_provider.dart`
  - View model used by the dev panel.
  - Owns `startImport()`, `startMigration()`, `clearImportDatabase()`, and `resetAllDatabases()`.
- `lib/essentials/db_importers/application/services/orchestrated_ledger_import_service.dart`
  - Runs the import pipeline.

## What Was Implemented Earlier In This Effort

### Environmental readiness flow

The first-run onboarding was redesigned from simple dialogs into a richer readiness flow.

It now evaluates:

- Full Disk Access
- Messages database availability
- Contacts availability
- import plausibility and blockers
- stale versus live import or migration failures

The readiness system is feature-owned and routed via `ViewSpec.environmentReadiness(...)`.

This work introduced or heavily changed:

- `OnboardingEnvironmentReport`
- `onboardingEnvironmentReportProvider`
- `OnboardingGate`
- `EnvironmentReadinessSpec`
- `environmentReadinessSurfaceProvider`
- `EnvironmentReadinessPanelView`

### Readiness and onboarding fixes that already landed

The following issues were already debugged and patched before the current blocker:

- explicit onboarding workflow states were preserved during provider rebuilds
- stale persisted import failures no longer force a misleading retry UI when the app DBs are empty
- readiness re-check now invalidates the cached FDA probe
- the readiness center panel gained clickable steps and better simulation messaging

### Legacy import dev panel restoration

The readiness flow accidentally hijacked the old import developer panel.

Observed failure mode:

1. Click toolbar download icon.
2. Open import developer panel.
3. Clear Import DB.
4. Center panel flashes or is replaced by the readiness panel.

Two fixes were then applied:

1. `onboarding_center_panel_sync_observer.dart`
   - If the center panel is already showing the import spec, the observer should not replace it with readiness.
2. `panel_widget_providers.dart`
   - Sidebar reconciliation should not reset sidebar-independent center panels like import, onboarding, or readiness.

Focused tests were added and passed for those navigation behaviors.

## Current Blocker

The current user-reported blocker is:

> The Import button does not start import.

This is now more important than the earlier panel-routing issue.

The current debugging target is no longer just panel visibility. It is the execution path from the legacy import panel into the import orchestrator.

## Most Relevant Files To Read First

Read these in roughly this order when resuming debugging:

1. `lib/essentials/db_importers/presentation/view/db_import_control_panel.dart`
2. `lib/essentials/db_importers/presentation/view_model/db_import_control_provider.dart`
3. `lib/essentials/onboarding/application/onboarding_gate_provider.dart`
4. `lib/essentials/navigation/presentation/widgets/onboarding_center_panel_sync_observer.dart`
5. `lib/essentials/navigation/application/panel_widget_providers.dart`
6. `lib/essentials/db_importers/application/services/orchestrated_ledger_import_service.dart`
7. `lib/essentials/db_importers/application/monitor/chat_db_change_monitor_provider.dart`
8. `lib/essentials/db_importers/application/import_execution_gate_provider.dart`

Read these tests as the current safety net:

1. `test/essentials/navigation/presentation/widgets/onboarding_center_panel_sync_observer_test.dart`
2. `test/essentials/navigation/application/panel_widget_providers_test.dart`
3. `test/essentials/onboarding/application/onboarding_gate_provider_test.dart`
4. `test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart`

## Likely Failure Zones For The Non-Starting Import Button

The most plausible causes are:

### 1. UI action is disabled or returns early

Check whether `DbImportControlState.isProcessing` or another guard prevents `startImport()` from running.

### 2. `startImport()` is invoked but exits early

Inspect all early returns in `db_import_control_provider.dart`, including:

- maintenance lock checks
- path or DB precondition checks
- state machine guards
- interactions with onboarding-specific flow states

### 3. Import is being blocked by another coordinator or monitor

There has already been evidence of cross-talk between first-run onboarding import and always-on import monitoring.

Relevant background:

- `chatDbChangeMonitorProvider` polls `chat.db` every 15 seconds
- there was a prior `database_closed` issue suggesting lifecycle overlap or concurrency problems
- `importExecutionGateProvider` exists and may be relevant, but it has not yet been confirmed as the root fix

### 4. Import starts but the UI does not reflect it

Check whether the orchestrator runs while the panel state or onboarding state fails to update.

Possible symptom pattern:

- button press appears inert
- no visible progress stages appear
- logger may still show import activity even though UI does not

## Known Good / Known Bad State

### Known good

- direct Finder-launched FDA testing previously worked correctly
- the environmental readiness system can reach the import stage
- focused navigation tests for import-panel preservation passed
- a fresh `flutter build macos --debug` succeeded on 2026-03-29 after the earlier build-lock investigation

### Known bad or unresolved

- import is not currently starting from the legacy import panel
- there is still historical evidence of incomplete or unreliable import behavior
- blank-message fidelity remains a separate concern once import works again

## Important Prior Debugging Findings

### Build lock

There was an earlier `build.db` lock concern under `build/macos/Build/Intermediates.noindex/XCBuildData/build.db`.

As of the latest check on 2026-03-29:

- no active xcodebuild or xcbuild process was holding the repo-local `build.db`
- a fresh debug macOS build succeeded
- the current main blocker is not the build lock

### Rich text / blank messages

This was diagnosed separately and should be revisited after import execution is working again.

Key points already established:

- blank messages with some images still rendering strongly suggest rich-text extraction failure
- `target/release/extract_messages_limited` exists locally
- `MessageRichTextImporter` sets `messages.richTextApplied = 0` on several failure paths

This is not the first issue to attack if the Import button itself does nothing.

## Suggested Next Debugging Plan

When resuming, the next agent should not start with more UI rewrites.

The correct plan is:

1. Reproduce the exact sequence from the dev panel.
2. Trace the button handler in `db_import_control_panel.dart` into `db_import_control_provider.dart`.
3. Add logging or tests only at the exact early-return point once found.
4. Confirm whether onboarding gate state, maintenance locks, or auto-sync monitoring are blocking execution.
5. Fix the root cause with the smallest possible diff.
6. Re-verify:
   - Start Import from the dev panel
   - Clear Import DB
   - migration from the same panel
   - onboarding readiness path for a new user

## Invariants To Preserve

The next agent must preserve these invariants while debugging:

- Do not remove or bypass the readiness feature wholesale.
- Do not reintroduce panel hijacking from the readiness sync observer.
- Do not let sidebar reconciliation overwrite sidebar-independent panels.
- Do not instantiate databases directly; use the centralized providers.
- Do not violate overlay versus working database separation.
- Do not suppress anomalous records.
- Do not break the production bundle id or signing continuity documented in `02-macos-fda-grant-continuity.md`.

## Manual Repro Sequence

Use this sequence unless the user gives a newer one:

1. Launch the app.
2. Click the toolbar download icon.
3. Confirm the import developer panel appears and stays visible.
4. Click `Clear Import DB`.
5. Confirm the panel remains visible.
6. Click `Start Import`.
7. Observe whether:
   - progress stages appear
   - logs show import work
   - onboarding state changes
   - import DB is recreated and populated

## Resume Prompt For A Fresh Agent

Use the following as the working brief:

> Read `_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md`, `_AGENT_INSTRUCTIONS/agent-per-project/README.md`, and `_AGENT_INSTRUCTIONS/agent-per-project/60-BUILD-CONSIDERATIONS/03-onboarding-import-debug-handoff.md`. Then debug why the legacy import developer panel's `Start Import` button does not start import. Preserve the environmental readiness flow and the recent import-panel routing fixes. Focus first on `db_import_control_panel.dart`, `db_import_control_provider.dart`, onboarding gate interactions, and any import execution locks or auto-sync interference. Propose a minimal plan before editing files.
