---
created_at: 2026-05-16T08:49:18-07:00
title: "document the emerging StageController / PipelineOrchestrator architecture before implementing it"
tags: []
source: codex_prompt_history.html
---

# document the emerging StageController / PipelineOrchestrator architecture before implementing it

## Prompt

```text
Next task: document the emerging StageController / PipelineOrchestrator architecture before implementing it.

Context

The shadow incremental-update architecture now has:

* independent HandleImporter
* independent ChatImporter
* MessageImporter
* prerequisite-aware policy semantics
* converging prerequisite satisfaction
* observable/endurance-trace execution
* independent concern-local orchestration slices

The architecture is beginning to reveal a higher-level execution shape:

PipelineOrchestrator
→ ordered concern execution stages
→ readers/integrators/importers
→ execution reports
→ run trace

Before implementing this runtime structure, we should formalize it architecturally.

Goal

Add a new architecture document describing the emerging:

* StageController
* PipelineOrchestrator

strategy.

Suggested document

49-IMPORT-STAGE-CONTROLLER-AND-PIPELINE-ORCHESTRATOR-STRATEGY.md

under:

55-READERS-INTEGRATORS-ORCHESTRATORS/

Architectural clarification

IMPORTANT:

StageController is NOT intended to become a fourth peer architecture layer beside:

* readers
* integrators
* orchestrators

Instead:

StageController is a specialized concern-local orchestrator with a standardized interface.

The intent is to distinguish:

* concern-local orchestration
    from
* whole-pipeline orchestration

Core concepts to document

Please describe:

Concern-local orchestration

Examples:

HandleStageController
ChatStageController
MessageStageController

Each stage controller owns:

* invalidation boundaries
* refresh sequencing
* semantic derivation
* prerequisite assessment
* policy derivation
* importer execution
* stage reporting

but only for its concern.

Pipeline orchestration

PipelineOrchestrator owns:

* ordered execution
* stage sequencing
* pipeline-level tracing/reporting
* eventual dependency planning
* eventual graph execution
* eventual retry/recovery policy

It does NOT own concern semantics directly.

Manual ordering first

Document that the immediate intended implementation shape is:

manually ordered stage list

Example:

[
HandleStageController,
ChatStageController,
MessageStageController,
]

No graph execution yet.

No topological sorting yet.

Descriptor-driven planning later

Document that future importer descriptors may eventually support:

* dependency graph construction
* topological planning
* importer DAG execution

But this is intentionally deferred until the simpler ordered-stage architecture is validated.

Execution flow example

Document a likely future execution cycle:

for stage in orderedStages:
report = await stage.refreshAndMaybeExecute()
append report to pipeline trace

Then describe what a stage does internally:

invalidate readers
→ derive delta/state/prerequisites/policy
→ maybe execute importer
→ validate convergence
→ return stage report

Important architectural intent

Document clearly:

Importers should remain narrow mutation tools.

Importers should NOT:

* own prerequisite derivation
* own readiness assessment
* own dependency planning
* own orchestration policy

Those responsibilities belong to:

* readers
* integrators
* stage controllers
* pipeline orchestrator

The importer should only:

* perform narrow import mutation safely
* preserve provenance
* return explicit execution results

Legacy comparison

Document the architectural difference from legacy mutable-state importer chains.

Suggested framing:

Legacy:

* mutable pipeline state passed through importers
* importer-local hidden validation
* implicit orchestration meaning

Emerging architecture:

* explicit semantic derivation
* observable prerequisite assessment
* explicit policy decisions
* explicit stage reports
* concern-local orchestration
* pipeline-level execution trace

No Dart code changes in this task.

This is architecture/documentation only.

Report back with:

* document added
* key architectural boundaries clarified
* any open questions identified
* recommended first implementation slice afterward
```
