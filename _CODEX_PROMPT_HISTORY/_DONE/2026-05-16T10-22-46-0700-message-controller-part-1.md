---
created_at: 2026-05-16T10:22:46-07:00
title: "Message controller part 1"
tags: []
source: codex_prompt_history.html
---

# Message controller part 1

## Prompt

```text
Next task: implement MessageImportStageController using the documented StageController pattern.

Context

HandleStageController and ChatStageController now exist and have been routed through SyncStatePollingOrchestrator.

The StageController pattern is now validated for two prerequisite concerns.

Next, apply the pattern to message import only.

Important distinction

Do NOT create a full MessageStageController yet.

Messages currently involve multiple concerns:

* message import
* prerequisite-aware message policy
* migration refresh/execution
* comparative validation

This task should extract ONLY the message import stage.

Leave migration refresh/execution and comparative validation in the current polling orchestrator for now.

Goal

Introduce MessageImportStageController and MessageImportStageReport, then route existing message import refresh/decision/execution sequencing through the stage controller WITHOUT behavior change.

Expected structure

Add:

application/messages/models/message_import_stage_report.dart

application/messages/orchestrators/message_import_stage_controller.dart
application/messages/orchestrators/message_import_stage_controller_provider.dart
application/messages/orchestrators/message_import_stage_controller_provider.g.dart

MessageImportStageController responsibilities

Move the existing message import concern-local sequence out of SyncStatePollingOrchestrator and into MessageImportStageController.

The controller should:

* invalidate message reader snapshot providers
* read message delta
* read MessageSyncState
* read ImportDecision
* read MessageImportPrerequisiteAssessment
* read PrerequisiteAwareMessageImportDecision
* invoke ShadowImportExecutionOrchestrator using the current validated execution path
* re-observe message facts after execution if mutation occurred
* return a MessageImportStageReport
* provide stable diagnostic events equivalent to the current tick-event strings

Important execution boundary

Do NOT wire prerequisite-aware message import decision into execution authority yet.

Current execution behavior must remain unchanged:

ShadowImportExecutionOrchestrator still uses existing ImportDecision.

Prerequisite-aware decision remains diagnostic-only.

Preserve behavior

This should be a refactor only.

Do NOT change:

* polling cadence
* MessageImporter behavior
* ImportDecision semantics
* prerequisite-aware decision semantics
* migration behavior
* comparative validation behavior
* handle behavior
* chat behavior
* endurance log meaning
* dev panel semantics
* production behavior

Do NOT add:

* PipelineOrchestrator
* generic stage interface
* graph orchestration
* topological sorting
* descriptor-driven runtime planning
* join importers
* topology reconstruction
* prerequisite-aware execution authority

MessageImportStageReport should capture enough causal information to explain:

* pre-execution message delta
* pre-execution sync state
* ImportDecision
* MessageImportPrerequisiteAssessment
* PrerequisiteAwareMessageImportDecision
* execution outcome
* importer result if executed
* post-execution delta/state if applicable
* diagnostic events

Preserve current tick-event wording as closely as possible.

Expected diagnostic events should remain equivalent to current messages such as:

* reader refresh started
* import observation boundary invalidated
* import delta observed: …
* import decision observed: …
* prerequisite assessment observed: …
* prerequisite-aware message import decision observed: …
* shadow import executed: …
* shadow import skipped: …

SyncStatePollingOrchestrator should become thinner by delegating message import concern logic to MessageImportStageController and appending report.diagnosticEvents.

Tests

Add focused tests for MessageImportStageController covering:

* doNothing skips execution
* considerIncrementalImport invokes execution exactly once
* ledger-ahead/blocking behavior remains preserved through existing ImportDecision path
* prerequisite-aware blocked decision is reported but does not block execution
* report fields capture pre/post state
* diagnostic tick-event strings remain stable
* reader invalidation remains at the observation boundary

Also rerun affected endurance-log/status tests.

Verification

Run:

* dart analyze on changed files
* focused message import stage controller tests
* existing handle/chat stage controller tests if shared patterns are touched
* affected shadow polling endurance log writer tests

Report back with:

* files added/changed
* where MessageImportStageReport lives
* where MessageImportStageController lives
* whether SyncStatePollingOrchestrator is thinner
* confirmation prerequisite-aware decision remains diagnostic-only
* confirmation behavior/log output remains equivalent
* tests run
```

Implemented `MessageImportStageController` for the message import slice only.

Changed for this task:

- Added [message_import_stage_report.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/models/message_import_stage_report.dart)
- Added [message_import_stage_controller.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/orchestrators/message_import_stage_controller.dart)
- Added [message_import_stage_controller_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/orchestrators/message_import_stage_controller_provider.dart)
- Generated [message_import_stage_controller_provider.g.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/orchestrators/message_import_stage_controller_provider.g.dart)
- Updated [sync_state_polling_orchestrator.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/orchestrators/sync_state_polling_orchestrator.dart) to delegate message import refresh/execution to the stage controller
- Added [message_import_stage_controller_test.dart](/Users/rob/Development/FlutterProjects/remember_every_text/test/essentials/incremental_update/application/messages/orchestrators/message_import_stage_controller_test.dart)

`SyncStatePollingOrchestrator` is thinner now for message import: it calls `messageImportStageControllerProvider`, appends `report.diagnosticEvents`, then continues with migration refresh and comparative validation as before.

Prerequisite-aware message import decision remains diagnostic-only. Execution still goes through `ShadowImportExecutionOrchestrator.runForDecision(decision)` using the existing `ImportDecision`.

Verified:

- `dart analyze` on changed message files: passed
- Focused tests passed:
  - message import stage controller
  - shadow import execution orchestrator
  - handle stage controller
  - chat stage controller
  - shadow polling endurance log writer

Note: the worktree still contains prior uncommitted handle/chat stage-controller and documentation changes from the preceding slices.
