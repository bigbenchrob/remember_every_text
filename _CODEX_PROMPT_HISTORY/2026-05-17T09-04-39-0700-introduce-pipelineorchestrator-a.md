---
created_at: 2026-05-17T09:04:39-07:00
title: "introduce PipelineOrchestrator a"
tags: []
source: codex_prompt_history.html
---

# introduce PipelineOrchestrator a

## Prompt

```text
Next task: introduce PipelineOrchestrator as the owner of the ordered stage execution loop.

Context

The shadow incremental-update architecture now has fully extracted concern-local stages:

* HandleStageController
* ChatStageController
* MessageImportStageController
* MessageMigrationStageController
* ComparativeValidationStageController

Each stage now:

* owns its concern-local refresh/decision/execution flow
* returns a stage report
* emits stable diagnostic events
* preserves existing runtime behavior

SyncStatePollingOrchestrator has effectively become:

run ordered stages
→ append diagnostic events

The StageController pattern has now been validated before introducing PipelineOrchestrator.

Goal

Introduce PipelineOrchestrator as the owner of the ordered stage execution loop.

This should remain:

* manual ordered execution only
* no graph execution
* no topological sorting
* no generic runtime planner

Expected structure

Add:

application/pipeline/models/pipeline_run_report.dart

application/pipeline/orchestrators/pipeline_orchestrator.dart
application/pipeline/orchestrators/pipeline_orchestrator_provider.dart
application/pipeline/orchestrators/pipeline_orchestrator_provider.g.dart

PipelineOrchestrator responsibilities

PipelineOrchestrator should:

* own the ordered stage list
* invoke each stage sequentially
* collect stage reports
* aggregate diagnostic events
* return a PipelineRunReport

Initial manual order should remain explicit and hardcoded:

[
handleStageController,
chatStageController,
messageImportStageController,
messageMigrationStageController,
comparativeValidationStageController,
]

Do NOT introduce dynamic ordering.

Do NOT use importer descriptors for runtime planning yet.

PipelineRunReport

PipelineRunReport should likely contain:

* startedAt
* finishedAt
* ordered stage reports
* aggregated diagnostic events

Keep it narrow and observational.

Do NOT introduce broad analytics/reporting frameworks.

Important boundary

PipelineOrchestrator is still not a graph planner.

It should NOT own:

* dependency graph construction
* topological sorting
* retry policy
* recovery policy
* dynamic scheduling
* prerequisite semantics
* importer semantics

Those remain inside:

* readers
* integrators
* stage controllers
* importers

Preserve behavior

This should be a refactor only.

Do NOT change:

* polling cadence
* stage ordering
* import behavior
* migration behavior
* comparison behavior
* prerequisite-aware semantics
* endurance log meaning
* dev panel semantics
* production behavior

SyncStatePollingOrchestrator responsibilities after refactor

SyncStatePollingOrchestrator should become thinner.

It should:

* own polling lifecycle/timing only
* invoke PipelineOrchestrator.runOnce()
* append/report pipeline diagnostic events
* preserve existing polling activation/deactivation semantics

It should no longer directly coordinate individual concern stages.

Important

Preserve all current diagnostic event wording and ordering as closely as possible.

The resulting runtime/log output should remain behaviorally equivalent.

Tests

Add focused tests for PipelineOrchestrator covering:

* stages execute in the intended order
* stage reports are aggregated
* diagnostic events preserve ordering
* no stage is skipped
* no new behavior/control semantics are introduced

Also rerun:

* existing stage controller tests
* affected endurance-log/status tests

Verification

Run:

* dart analyze on changed files
* focused pipeline orchestrator tests
* existing stage controller tests if touched
* affected shadow polling endurance log writer tests

Report back with:

* files added/changed
* where PipelineRunReport lives
* where PipelineOrchestrator lives
* how ordered stages are represented
* how SyncStatePollingOrchestrator became thinner
* confirmation behavior/log output remains equivalent
* tests run
```

---

Implemented `PipelineOrchestrator` as the owner of the ordered stage execution loop.

Added:

- [pipeline_run_report.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/pipeline/models/pipeline_run_report.dart)
- [pipeline_orchestrator.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/pipeline/orchestrators/pipeline_orchestrator.dart)
- [pipeline_orchestrator_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/pipeline/orchestrators/pipeline_orchestrator_provider.dart)
- [pipeline_orchestrator_provider.g.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/pipeline/orchestrators/pipeline_orchestrator_provider.g.dart)
- [pipeline_orchestrator_test.dart](/Users/rob/Development/FlutterProjects/remember_every_text/test/essentials/incremental_update/application/pipeline/orchestrators/pipeline_orchestrator_test.dart)

Updated:

- [sync_state_polling_orchestrator.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/orchestrators/sync_state_polling_orchestrator.dart)

The ordered stages are hardcoded manually in `pipeline_orchestrator_provider.dart`:

`handle → chat → message import → message migration → comparative validation`

`SyncStatePollingOrchestrator` is now thinner: it owns polling lifecycle/timing, calls `pipelineOrchestrator.runOnce()`, appends `pipelineReport.diagnosticEvents`, and uses `pipelineReport.importDecisionAfterRun` for transition logging.

`PipelineRunReport` contains typed reports for each stage, an `orderedStageReports` list, aggregated `diagnosticEvents`, and `importDecisionAfterRun`.

Verification passed:

- `dart analyze` on changed pipeline/polling files
- `flutter test` for:
  - pipeline orchestrator
  - comparative validation stage
  - message migration stage
  - message import stage
  - handle stage
  - chat stage
  - endurance log writer

No graph execution, topological sorting, descriptor planning, retry policy, or production ownership was added.
