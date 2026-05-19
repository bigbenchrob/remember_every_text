---
created_at: 2026-05-17T08:44:55-07:00
title: "ComparativeValidationStageController"
tags: []
source: codex_prompt_history.html
---

# ComparativeValidationStageController

## Prompt

```text
Next task: implement ComparativeValidationStageController using the documented StageController pattern.

Context

The shadow incremental-update pipeline now has:

* HandleStageController
* ChatStageController
* MessageImportStageController
* MessageMigrationStageController

SyncStatePollingOrchestrator now delegates handle, chat, message import, and message migration stages, then still runs comparative validation itself.

Goal

Extract ONLY comparative validation into a ComparativeValidationStageController.

Do not create PipelineOrchestrator yet.

Expected structure

Add:

application/messages/models/comparative_validation_stage_report.dart

application/messages/orchestrators/comparative_validation_stage_controller.dart
application/messages/orchestrators/comparative_validation_stage_controller_provider.dart
application/messages/orchestrators/comparative_validation_stage_controller_provider.g.dart

ComparativeValidationStageController responsibilities

Move the existing comparative validation sequence out of SyncStatePollingOrchestrator and into ComparativeValidationStageController while preserving behavior.

The controller should:

* run the existing ComparativeValidationOrchestrator / comparison flow
* capture comparison outcome details
* return a ComparativeValidationStageReport
* provide stable diagnostic events equivalent to current comparison tick-event strings

Important boundary

This stage is diagnostic/observational only.

It must not:

* trigger import
* trigger migration
* alter execution policy
* mutate production databases
* mutate shadow databases
* become a control plane

Preserve behavior

This should be a refactor only.

Do NOT change:

* polling cadence
* comparison semantics
* comparison wording
* import behavior
* migration behavior
* handle/chat behavior
* endurance log meaning
* dev panel semantics
* production behavior

Do NOT add:

* PipelineOrchestrator
* generic stage interface
* graph orchestration
* topological sorting
* descriptor-driven runtime planning
* production ownership

ComparativeValidationStageReport should capture enough causal information to explain:

* import comparison outcome
* migration comparison outcome
* reason text if present
* execution outcome, likely observational/noMutation
* diagnostic events

Preserve current tick-event wording as closely as possible.

Expected diagnostic event should remain equivalent to the current string:

* comparison observed: import=… migration=…

SyncStatePollingOrchestrator should become thinner by delegating comparative validation to ComparativeValidationStageController and appending report.diagnosticEvents.

Tests

Add focused tests for ComparativeValidationStageController covering:

* comparison report captures import comparison
* comparison report captures migration comparison
* diagnostic event string remains stable
* no mutation/execution behavior is introduced
* existing ComparativeValidationOrchestrator behavior remains unchanged

Also rerun affected endurance-log/status tests.

Verification

Run:

* dart analyze on changed files
* focused comparative validation stage controller tests
* existing stage controller tests if shared patterns are touched
* affected shadow polling endurance log writer tests

Report back with:

* files added/changed
* where ComparativeValidationStageReport lives
* where ComparativeValidationStageController lives
* whether SyncStatePollingOrchestrator is thinner
* confirmation comparative validation remains diagnostic-only
* confirmation behavior/log output remains equivalent
* tests run
```

---

Implemented `ComparativeValidationStageController` as a diagnostic-only stage.

Added:

- [comparative_validation_stage_report.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/models/comparative_validation_stage_report.dart)
- [comparative_validation_stage_controller.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/orchestrators/comparative_validation_stage_controller.dart)
- [comparative_validation_stage_controller_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/orchestrators/comparative_validation_stage_controller_provider.dart)
- [comparative_validation_stage_controller_provider.g.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/orchestrators/comparative_validation_stage_controller_provider.g.dart)
- [comparative_validation_stage_controller_test.dart](/Users/rob/Development/FlutterProjects/remember_every_text/test/essentials/incremental_update/application/messages/orchestrators/comparative_validation_stage_controller_test.dart)

Updated:

- [sync_state_polling_orchestrator.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/orchestrators/sync_state_polling_orchestrator.dart) now delegates comparison to `comparativeValidationStageControllerProvider`.
- [shadow_incremental_update_status_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/status/shadow_incremental_update_status_provider.dart) now reads comparison transition time through the stage controller.

`SyncStatePollingOrchestrator` is thinner again: it delegates handle, chat, message import, message migration, and comparative validation stages.

Comparative validation remains diagnostic-only. The new stage only calls the existing `ComparativeValidationOrchestrator.refreshOnce()`, captures the outcomes, and emits the same tick-event wording: `comparison observed: import=… migration=…`.

Verified:

- `dart analyze` on changed comparative/status/polling files: passed
- Focused tests passed:
  - `comparative_validation_stage_controller_test.dart`
  - `message_migration_stage_controller_test.dart`
  - `message_import_stage_controller_test.dart`
  - `handle_stage_controller_test.dart`
  - `chat_stage_controller_test.dart`
  - `shadow_polling_endurance_log_writer_test.dart`
