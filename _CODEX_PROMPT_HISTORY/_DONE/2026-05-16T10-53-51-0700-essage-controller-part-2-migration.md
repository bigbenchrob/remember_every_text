---
created_at: 2026-05-16T10:53:51-07:00
title: "<essage controller part 2 migration"
tags: []
source: codex_prompt_history.html
---

# <essage controller part 2 migration

## Prompt

```text
Next task: implement MessageMigrationStageController using the documented StageController pattern.

Context

The shadow incremental-update pipeline now has:

* HandleStageController
* ChatStageController
* MessageImportStageController

These concern-local stage controllers now own their respective refresh/decision/execution cycles and return stage reports.

SyncStatePollingOrchestrator is becoming thinner, but migration refresh/execution still remains embedded as a separate concern.

Goal

Extract ONLY the message migration refresh/execution concern into a MessageMigrationStageController.

Do not create a full PipelineOrchestrator yet.

Do not alter comparative validation yet.

Expected structure

Add:

application/messages/models/message_migration_stage_report.dart

application/messages/orchestrators/message_migration_stage_controller.dart
application/messages/orchestrators/message_migration_stage_controller_provider.dart
application/messages/orchestrators/message_migration_stage_controller_provider.g.dart

MessageMigrationStageController responsibilities

Move the existing migration refresh/execution sequence out of SyncStatePollingOrchestrator and into MessageMigrationStageController while preserving behavior.

The controller should:

* invalidate migration/projection reader snapshot providers
* read migration delta
* read MessageMigrationState
* read MigrationDecision
* invoke ShadowMigrationExecutionOrchestrator only when policy allows
* re-observe migration facts after execution if mutation occurred
* return a MessageMigrationStageReport
* provide stable diagnostic events equivalent to current tick-event strings

Important boundary

This task is only about shadow message migration/projection:

macos_import_shadow.db.messages
→ working_shadow.db.messages

Do NOT add:

* production migration ownership
* full working projection replacement
* handle/chat projection
* attachment projection
* topology projection
* comparative validation refactor
* pipeline orchestrator
* graph orchestration
* topological sorting

Preserve behavior

This should be a refactor only.

Do NOT change:

* polling cadence
* migration decision semantics
* migration executor behavior
* message import behavior
* handle/chat stage behavior
* comparative validation behavior
* endurance log meaning
* dev panel semantics
* production behavior

MessageMigrationStageReport should capture enough causal information to explain:

* pre-execution migration delta
* pre-execution migration state
* MigrationDecision
* execution outcome
* migration result if executed
* post-execution delta/state if applicable
* diagnostic events

Preserve current tick-event wording as closely as possible.

Expected diagnostic events should remain equivalent to current strings such as:

* migration reader refresh started
* migration delta observed: …
* migration decision observed: …
* shadow migration executed: …
* shadow migration skipped: …

SyncStatePollingOrchestrator should become thinner by delegating migration concern logic to MessageMigrationStageController and appending report.diagnosticEvents.

Tests

Add focused tests for MessageMigrationStageController covering:

* doNothing skips execution
* considerShadowMigration invokes execution exactly once
* projection-ahead/blocking behavior skips execution
* report fields capture pre/post state
* diagnostic tick-event strings remain stable
* reader invalidation remains at the observation boundary

Also rerun affected endurance-log/status tests.

Verification

Run:

* dart analyze on changed files
* focused message migration stage controller tests
* existing handle/chat/message import stage controller tests if shared patterns are touched
* affected shadow polling endurance log writer tests

Report back with:

* files added/changed
* where MessageMigrationStageReport lives
* where MessageMigrationStageController lives
* whether SyncStatePollingOrchestrator is thinner
* confirmation behavior/log output remains equivalent
* tests run
```

---

Implemented `MessageMigrationStageController` as the migration/projection-only stage.

Added:

- [message_migration_stage_report.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/models/message_migration_stage_report.dart)
- [message_migration_stage_controller.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/orchestrators/message_migration_stage_controller.dart)
- [message_migration_stage_controller_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/orchestrators/message_migration_stage_controller_provider.dart)
- [message_migration_stage_controller_provider.g.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/orchestrators/message_migration_stage_controller_provider.g.dart)
- [message_migration_stage_controller_test.dart](/Users/rob/Development/FlutterProjects/remember_every_text/test/essentials/incremental_update/application/messages/orchestrators/message_migration_stage_controller_test.dart)

Updated:

- [sync_state_polling_orchestrator.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/orchestrators/sync_state_polling_orchestrator.dart) now delegates migration refresh/execution to `messageMigrationStageControllerProvider`.
- [shadow_incremental_update_status_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/status/shadow_incremental_update_status_provider.dart) now reads migration transition time from the new stage controller.

`SyncStatePollingOrchestrator` is thinner: it now delegates handle, chat, message import, and message migration stages, then still runs comparative validation itself. Comparative validation was not refactored.

Behavior/log output is preserved: migration tick events still use the same wording for reader refresh, delta, decision, executed, and skipped paths. The stage controller also preserves the existing migration transition logging and keep-alive lifecycle.

Verified:

- `dart analyze` on changed migration/status files: passed
- Focused tests passed:
  - `message_migration_stage_controller_test.dart`
  - `shadow_migration_execution_orchestrator_test.dart`
  - `message_import_stage_controller_test.dart`
  - `handle_stage_controller_test.dart`
  - `chat_stage_controller_test.dart`
  - `shadow_polling_endurance_log_writer_test.dart`
