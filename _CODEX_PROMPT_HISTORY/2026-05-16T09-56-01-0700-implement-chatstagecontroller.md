---
created_at: 2026-05-16T09:56:01-07:00
title: "Implement ChatStageController"
tags: []
source: codex_prompt_history.html
---

# Implement ChatStageController

## Prompt

```text
Yes, that looks good. It locks in the key placement rule:

StageController → application/<concern>/orchestrators/
StageReport → application/<concern>/models/

and clearly keeps domain/models reserved for durable semantic/factual values, not one-run execution trace data.  ￼


Next task: implement ChatStageController using the documented StageController pattern.

Context

The StageController / PipelineOrchestrator strategy has now been documented in:

49-IMPORT-STAGE-CONTROLLER-AND-PIPELINE-ORCHESTRATOR-STRATEGY.md

Important conventions from that doc:

* StageController is a specialized concern-local orchestrator, not a fourth peer layer.
* StageController files belong under:
    application//orchestrators/
* StageReport files belong under:
    application//models/
* Importers remain narrow mutation tools.
* The current polling orchestrator should remain the caller for now.
* No PipelineOrchestrator yet.
* No graph execution yet.
* No topological sorting yet.

Current implementation state

HandleStageController has already been implemented and routed through SyncStatePollingOrchestrator.

Now repeat the same pattern for chats.

Goal

Introduce ChatStageController and ChatStageReport, then route existing chat refresh/decision/execution sequencing through the stage controller WITHOUT behavior change.

Expected structure

Add:

application/chats/models/chat_stage_report.dart

application/chats/orchestrators/chat_stage_controller.dart
application/chats/orchestrators/chat_stage_controller_provider.dart
application/chats/orchestrators/chat_stage_controller_provider.g.dart

ChatStageController responsibilities

Move the existing chat concern-local sequence out of SyncStatePollingOrchestrator and into ChatStageController.

The controller should:

* invalidate chat reader snapshot providers
* read chat delta
* read chat sync state
* read chat import decision
* invoke ChatImportExecutionOrchestrator only when policy allows
* re-observe chat facts after execution if mutation occurred
* return a ChatStageReport
* provide stable diagnostic events equivalent to the current tick-event strings

ChatStageReport should capture enough causal information to explain:

* pre-execution delta
* pre-execution sync state
* decision
* execution outcome
* importer result if executed
* post-execution delta/state if applicable
* diagnostic events

Preserve behavior

This should be a refactor only.

Do NOT change:

* polling cadence
* chat importer behavior
* chat decision semantics
* message import behavior
* handle behavior
* prerequisite-aware policy semantics
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

Important

Preserve the current visible tick-event output as closely as possible.

The polling orchestrator should become thinner by delegating chat concern logic to ChatStageController and appending report.diagnosticEvents, analogous to the handle stage refactor.

Tests

Add focused tests for ChatStageController covering:

* doNothing skips execution
* blockAndReportLedgerAhead blocks execution
* considerIncrementalImport invokes execution exactly once
* report fields capture pre/post state
* diagnostic tick-event strings remain stable
* reader invalidation remains at the observation boundary

Also rerun any affected endurance-log/status tests if imports change.

Verification

Run:

* dart analyze on changed files
* focused chat stage controller tests
* affected polling/endurance tests
* existing handle stage controller tests if shared patterns are touched

Report back with:

* files added/changed
* where ChatStageReport lives
* where ChatStageController lives
* whether SyncStatePollingOrchestrator is thinner
* confirmation behavior/log output remains equivalent
* tests run
```

---

mplemented ChatStageController using the documented pattern.

Files added:

chat_stage_report.dart
chat_stage_controller.dart
chat_stage_controller_provider.dart
chat_stage_controller_provider.g.dart
chat_stage_controller_test.dart
Files changed:

sync_state_polling_orchestrator.dart
Placement:

ChatStageReport lives in application/chats/models/.
ChatStageController lives in application/chats/orchestrators/.
SyncStatePollingOrchestrator is thinner now. \_refreshChats() delegates to:

final report = await \_ref
.read(chatStageControllerProvider)
.refreshAndMaybeExecute();
tickEvents?.addAll(report.diagnosticEvents);
Behavior/log output is intended to remain equivalent. The stage controller emits the same existing chat tick-event strings:

chat observation boundary invalidated
chat delta observed: ...
chat import decision observed: ...
shadow chat import executed/skipped: ...
Tests added for:

doNothing skips execution
blockAndReportLedgerAhead blocks execution
considerIncrementalImport executes once
pre/post state and delta reporting
stable diagnostic tick-event strings
Verification passed:

dart analyze lib/essentials/incremental_update/application/chats/models/chat_stage_report.dart lib/essentials/incremental_update/application/chats/orchestrators/chat_stage_controller.dart lib/essentials/incremental_update/application/chats/orchestrators/chat_stage_controller_provider.dart lib/essentials/incremental_update/application/messages/orchestrators/sync_state_polling_orchestrator.dart test/essentials/incremental_update/application/chats/orchestrators/chat_stage_controller_test.dart

flutter test test/essentials/incremental_update/application/chats/orchestrators/chat_stage_controller_test.dart test/essentials/incremental_update/application/chats/orchestrators/chat_import_execution_orchestrator_test.dart test/essentials/incremental_update/application/handles/orchestrators/handle_stage_controller_test.dart test/essentials/incremental_update/application/messages/status/shadow_polling_endurance_log_writer_test.dart
No PipelineOrchestrator, graph execution, topological sorting, importer behavior changes, or topology reconstruction were added.

5 files changed
+355
-58
Undo

Review

lib/essentials/incremental_update/application/chats/models/chat_stage_report.dart
lib/essentials/incremental_update/application/chats/orchestrators/chat_stage_controller.dart
lib/essentials/incremental_update/application/chats/orchestrators/chat_stage_controller_provider.dart
lib/essentials/incremental_update/application/messages/orchestrators/sync_state_polling_orchestrator.dart
test/essentials/incremental_update/application/chats/orchestrators/chat_stage_controller_test.dart
