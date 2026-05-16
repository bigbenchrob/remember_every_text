# 49-IMPORT-STAGE-CONTROLLER-AND-PIPELINE-ORCHESTRATOR-STRATEGY

## Purpose

This document describes the emerging execution architecture for the shadow incremental-update import pipeline before it is implemented as a runtime structure.

The current pilot has validated:

- independent `HandleImporter`
- independent `ChatImporter`
- `MessageImporter`
- prerequisite-aware message policy semantics
- prerequisite convergence before message import
- observable tick-event and endurance-log traces
- concern-local execution slices

The architecture is now revealing a higher-level shape:

```text
PipelineOrchestrator
→ ordered concern execution stages
→ readers / integrators / importers
→ execution reports
→ pipeline run trace
```

This document formalizes that direction without adding implementation requirements yet.

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
- `MessageStageController`

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

---

# Pipeline Orchestrator

The `PipelineOrchestrator` owns whole-pipeline sequencing.

It may coordinate:

- ordered stage execution
- stage sequencing
- pipeline-level tracing
- pipeline-level reporting
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

---

# Manual Ordering First

The immediate intended implementation shape is a manually ordered stage list.

Example:

```dart
final stages = [
  handleStageController,
  chatStageController,
  messageStageController,
];
```

Conceptual execution:

```dart
for (final stage in orderedStages) {
  final report = await stage.refreshAndMaybeExecute();
  trace.add(report);
}
```

This intentionally avoids:

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

The point of this phase is to validate the orchestration interface and reporting model before building graph machinery.

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

These should remain open until the first implementation slice proves or disproves the design:

- Should each stage report include both pre-execution and post-execution state?
- Should stage controllers return typed concern-specific reports or a shared report envelope with concern-specific payloads?
- Should pipeline traces be persisted, logged only, or exposed through the dev status panel first?
- Should stage controllers be invoked by the existing polling orchestrator initially, or should a new pipeline orchestrator own the polling tick body?
- How much convergence validation belongs inside a stage controller versus inside a separate validator?

None of these questions require graph execution yet.

---

# Recommended First Implementation Slice

The smallest safe first implementation slice should be:

1. Introduce a concern-local `HandleStageController`.
2. Move existing handle refresh / decision / execution sequencing into it without behavior change.
3. Return an explicit handle stage report.
4. Keep the current polling orchestrator as the caller.
5. Add focused tests proving:
   - reader invalidation remains at the observation boundary
   - `doNothing` skips execution
   - blocked states skip execution
   - `considerIncrementalImport` invokes the importer
   - report fields preserve the causal path

After that is stable, repeat for `ChatStageController`, then `MessageStageController`.

Only after all three concern-local stage controllers produce consistent reports should a `PipelineOrchestrator` replace the hand-written sequencing currently embedded in the polling orchestrator.
