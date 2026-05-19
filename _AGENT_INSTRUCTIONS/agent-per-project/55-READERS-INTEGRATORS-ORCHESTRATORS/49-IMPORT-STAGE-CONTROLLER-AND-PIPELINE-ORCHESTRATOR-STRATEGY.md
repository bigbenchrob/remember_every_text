# 49-IMPORT-STAGE-CONTROLLER-AND-PIPELINE-ORCHESTRATOR-STRATEGY

## Purpose

This document describes the validated execution architecture for the shadow incremental-update import pipeline.

The current pilot has validated:

- independent `HandleImporter`
- independent `ChatImporter`
- `MessageImporter`
- prerequisite-aware message policy semantics
- prerequisite convergence before message import
- observable tick-event and endurance-log traces
- concern-local execution slices
- concern-local `StageController` reports
- manual ordered execution through `PipelineOrchestrator`

The architecture now has a higher-level runtime shape:

```text
PipelineOrchestrator
→ ordered concern execution stages
→ readers / integrators / importers
→ execution reports
→ pipeline run trace
```

This document formalizes the validated pattern and the boundaries that should remain true as future importer coverage expands.

---

# Architectural Clarification

`StageController` is not a fourth peer layer beside:

```text
Readers
Integrators
Orchestrators
```

Instead, a `StageController` is a specialized concern-local orchestrator with a standardized interface.

The distinction is:

```text
Concern-local orchestration
vs
Whole-pipeline orchestration
```

The existing responsibility model remains intact:

```text
facts
→ semantic state
→ policy decision
→ execution orchestration
→ narrow executor/importer
→ updated facts
```

A stage controller packages this pattern for one concern. A pipeline orchestrator sequences multiple stage controllers.

---

# Application-Layer File Placement

Stage-controller work should keep file placement aligned with responsibility, not just proximity.

Recommended concern-local structure:

```text
application/<concern>/readers/
application/<concern>/integrators/
application/<concern>/importers/
application/<concern>/orchestrators/
application/<concern>/models/

domain/models/
domain/sealed_unions/
```

## Domain Models

`domain/models/` should contain durable semantic values and factual value objects that describe the problem space rather than one application execution cycle.

Examples:

- `HandleSnapshot`
- `ChatSnapshotDelta`
- `MessageImportPrerequisiteAssessment`
- provenance models
- source/ledger snapshots

These models may be produced or consumed by application-layer readers and integrators, but they represent reusable semantic data rather than orchestration history.

## Domain Sealed Unions

`domain/sealed_unions/` should contain explicit semantic states and policy decisions.

Examples:

- `HandleSyncState`
- `ChatSyncState`
- `MessageSyncState`
- `ImportDecision`
- `MigrationDecision`
- prerequisite-aware policy decisions

These describe durable meaning such as "source is ahead", "ledger is ahead", "execution may be considered", or "execution is blocked".

## Application Readers

`application/<concern>/readers/` should contain factual observation boundaries and provider-facing read coordination.

Readers answer:

```text
What facts are true right now?
```

They should not own semantic derivation, execution policy, or mutation.

## Application Integrators

`application/<concern>/integrators/` should contain semantic derivation, policy derivation, and prerequisite composition.

Integrators answer:

```text
What do these facts mean?
What policy meaning follows from that semantic state?
```

They should remain side-effect free where practical.

## Application Importers

`application/<concern>/importers/` should contain narrow, resumable mutation tools.

Importers answer:

```text
How do I safely import this concern slice?
```

They should not own prerequisite derivation, readiness assessment, graph planning, or broad orchestration policy.

## Application Orchestrators and Stage Controllers

`application/<concern>/orchestrators/` should contain lifecycle and execution coordination for that concern.

This is where concern-local `StageController` types belong.

Examples:

- `HandleStageController`
- `ChatStageController`
- `MessageStageController`
- concern-local execution orchestrators

`StageController` is orchestration. It owns refresh/execution sequencing for one concern and coordinates readers, integrators, and importers.

## Application Models

`application/<concern>/models/` should contain application-layer reports, execution traces, and other values that describe what happened during one application execution cycle.

Examples:

- `HandleStageReport`
- future `ChatStageReport`
- future `MessageStageReport`
- concern-local stage execution reports
- importer execution reports when they describe application execution rather than durable domain meaning

`StageReport` is not domain semantic state. It is an application execution report: a record of what a stage observed, decided, executed, and returned during one run.

Therefore, stage reports should generally live in:

```text
application/<concern>/models/
```

not:

```text
application/<concern>/orchestrators/
domain/models/
```

This keeps orchestration code separate from execution-report data while avoiding the mistake of treating one-run application trace data as durable domain truth.

## Shared Pipeline Reports

If future pipeline traces become shared across concerns, prefer a clearly named shared application location rather than `domain/models/`.

Candidate:

```text
application/pipeline/models/
```

Use a shared location only when reports are genuinely cross-concern. Keep concern-local reports inside the concern until duplication proves a shared model is useful.

---

# Concern-Local Stage Controllers

Examples:

- `HandleStageController`
- `ChatStageController`
- `MessageImportStageController`
- `MessageMigrationStageController`
- `ComparativeValidationStageController`

Each stage controller owns orchestration for exactly one concern.

For its concern, a stage controller may coordinate:

- reader invalidation boundaries
- refresh sequencing
- delta observation
- semantic state derivation
- prerequisite assessment
- policy decision derivation
- importer execution
- post-execution re-observation
- convergence validation
- stage reporting

It should not own unrelated concern semantics.

Example boundary:

```text
HandleStageController
→ observes live handle facts and shadow ledger handle facts
→ derives handle sync state
→ derives handle import decision
→ invokes HandleImporter only if policy allows
→ returns a handle stage report
```

It should not decide whether messages are importable except by producing handle readiness facts that other semantic layers may consume.

The stage-controller pattern has now been validated in the shadow pilot. The current concern-local stages:

- invalidate only their factual observation providers
- read derived semantic and policy providers
- invoke a narrow importer or execution orchestrator only when policy allows
- re-observe after mutation when needed
- return an application-layer stage report
- expose stable diagnostic events for tick traces and endurance logs

This is the preferred pattern for adding the next concern-local import slices. A new concern should first prove its own factual readers, integrators, policy decision, importer, stage report, and stage controller before being folded into broader pipeline planning.

---

# Pipeline Orchestrator

The `PipelineOrchestrator` owns whole-pipeline sequencing.

In the validated shadow pilot it coordinates:

- ordered stage execution
- stage sequencing
- pipeline-level tracing
- pipeline-level reporting

In later phases it may coordinate:

- eventual dependency planning
- eventual graph execution
- eventual retry/recovery policy

It does not own concern semantics directly.

The pipeline orchestrator should ask each stage controller to run its concern-local cycle and then record the result.

It should not embed:

- handle sync-state logic
- chat sync-state logic
- message prerequisite logic
- importer SQL
- concern-specific validation details

Those remain inside readers, integrators, stage controllers, and importers.

The `PipelineOrchestrator` pattern is now validated for manual ordered stage execution. The polling orchestrator owns timer lifecycle and delegates the tick body to the pipeline. The pipeline owns the ordered stage loop and returns a `PipelineRunReport` containing stage reports and aggregated diagnostic events.

---

# Manual Ordering First

The immediate intended implementation shape is a manually ordered stage list.

Current validated order:

```dart
final stages = [
  handleStageController,
  chatStageController,
  messageImportStageController,
  messageMigrationStageController,
  comparativeValidationStageController,
];
```

Conceptual execution:

```dart
for (final stage in orderedStages) {
  final report = await stage.refreshAndMaybeExecute();
  trace.add(report);
}
```

This currently avoids:

- generic graph execution
- topological sorting
- dynamic dependency planning
- descriptor-driven scheduling

Manual ordering is sufficient for the next validation step because the currently known prerequisite topology is small and explicit:

```text
handles
chats
→ messages
```

The point of this phase was to validate the orchestration interface and reporting model before building graph machinery. That validation has succeeded for the current shadow import, migration, and comparison loop.

---

# Stage Execution Flow

A stage controller should follow the already validated architecture grammar.

Likely stage cycle:

```text
invalidate reader providers
→ readers re-observe source / ledger facts
→ derive delta
→ derive semantic state
→ derive prerequisite assessment if applicable
→ derive policy decision
→ maybe execute importer
→ re-observe facts after execution if mutation occurred
→ validate convergence
→ return stage report
```

The stage report should be explicit enough to explain:

- what facts were observed
- what semantic state was derived
- what policy decision was reached
- whether execution occurred
- what importer result was returned
- whether the stage converged
- what diagnostic events were emitted

The report is not only for code. It is the human-readable causal record for endurance logs, dev panels, and comparative validation.

---

# Importer Responsibility

Importers should remain narrow mutation tools.

An importer should only:

- perform scoped import mutation safely
- preserve source provenance
- preserve source-scoped relationship identity where applicable
- remain resumable
- remain idempotent
- return explicit execution results

An importer should not own:

- prerequisite derivation
- readiness assessment
- dependency planning
- polling cadence
- stage sequencing
- retry policy
- graph traversal
- broad orchestration policy

Those responsibilities belong to:

- readers
- integrators
- stage controllers
- pipeline orchestrator

This keeps mutation mechanics separate from semantic and policy meaning.

---

# Descriptor-Driven Planning Later

Importer descriptors may eventually support dependency-aware planning.

Future uses may include:

- dependency graph construction
- topological planning
- importer DAG execution
- prerequisite validation across importer families
- richer recovery and retry policy

That future should be deferred until the simpler ordered-stage architecture is validated.

Current descriptors are useful as metadata and documentation, but they should not prematurely become runtime graph machinery.

The intended progression is:

```text
manual ordered stages
→ standardized stage reports
→ validated pipeline trace
→ descriptor-assisted planning
→ graph execution only if justified
```

---

# Legacy Comparison

Legacy importer chains tend toward:

- mutable pipeline state passed through importers
- importer-local hidden validation
- implicit prerequisite meaning
- implicit orchestration meaning
- broad responsibility compression

The emerging architecture prefers:

- explicit factual readers
- explicit semantic derivation
- observable prerequisite assessment
- explicit policy decisions
- concern-local stage controllers
- narrow importers
- whole-pipeline run trace

The difference is not only structural. It changes how failures are understood.

In the emerging model, humans should be able to inspect a run trace and answer:

```text
Which stage ran?
What did it observe?
What meaning did it derive?
What policy decision did it reach?
Did it execute?
What changed?
Did downstream stages become eligible?
```

---

# Suggested Stage Report Shape

The exact model should be designed during implementation, but a useful report should likely include:

- `stageName`
- `startedAt`
- `finishedAt`
- observed delta
- semantic state
- prerequisite assessment if applicable
- policy decision
- execution skipped/executed/blocked
- importer result if executed
- convergence status
- diagnostic events

Example conceptual report:

```text
stage=chats
delta=rowIdDelta=12, chatCountDelta=12
state=sourceAheadOfLedger
decision=considerIncrementalImport
execution=executed
insertedCount=12
postState=sourceAndLedgerCursorsMatch
```

The report should preserve causal visibility without becoming a new source of business logic.

---

# Open Questions

The first implementation slices have answered several earlier questions:

- stage reports should include pre-execution and post-execution state when mutation can occur
- concern-specific reports are useful because each stage has different semantic payloads
- pipeline traces are useful in endurance logs and dev observability before any production promotion
- the existing polling orchestrator should own timing while `PipelineOrchestrator` owns the tick body

Remaining open questions:

- Should pipeline traces be persisted, logged only, or exposed through the dev status panel first?
- How much convergence validation belongs inside a stage controller versus inside a separate validator?
- When, if ever, should importer descriptors become runtime planning inputs?
- What promotion criteria must be satisfied before any stage can receive production authority?

None of these remaining questions require graph execution yet.

---

# Validated Implementation Sequence

The staged implementation sequence validated the pattern without behavior changes:

1. Introduce concern-local stage reports.
2. Extract `HandleStageController`.
3. Extract `ChatStageController`.
4. Extract `MessageImportStageController`.
5. Extract `MessageMigrationStageController`.
6. Extract `ComparativeValidationStageController`.
7. Introduce `PipelineOrchestrator` as the owner of the manual ordered stage loop.

The result is:

```text
SyncStatePollingOrchestrator
→ owns timer lifecycle and polling start/stop
→ calls PipelineOrchestrator.runOnce()

PipelineOrchestrator
→ owns ordered stage execution
→ returns PipelineRunReport

StageControllers
→ own concern-local observation / meaning / policy / execution
→ return concern-specific StageReports
```

This is now the preferred substrate for future shadow importer expansion.
