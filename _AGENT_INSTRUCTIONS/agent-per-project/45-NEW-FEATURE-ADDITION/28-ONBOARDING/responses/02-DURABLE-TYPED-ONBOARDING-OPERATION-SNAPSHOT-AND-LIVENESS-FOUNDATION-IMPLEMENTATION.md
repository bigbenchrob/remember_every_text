---
tier: project
scope: onboarding
owner: agent-per-project
last_reviewed: 2026-08-23
source_of_truth: implementation-record
---

# Durable Typed Onboarding Operation Snapshot And Liveness Foundation

## Outcome

Onboarding now has one typed, durable description of consequential work that
is independent of the widget currently visible. It distinguishes:

- no admitted operation;
- a current operation with observed progress;
- work left running by an earlier process;
- a typed terminal failure;
- durable completion proved by MessageLens databases.

This is a liveness foundation, not the final watchdog. It records real
observations but does not infer failure from elapsed wall-clock time.

## Previous Authorities

Before this slice, operational state was distributed across:

- process-local `OnboardingStatus` workflow overrides;
- the current Environment Readiness report;
- import and graph progress providers;
- persisted import and graph failure summaries;
- Presence Schedule state;
- source-scoped import and Conversation Graph database truth.

Those authorities remain valid within their scopes. The missing authority was
one durable record of which admitted Onboarding operation was running, where it
had reached, and how it terminated.

## Snapshot Model

`OnboardingOperationSnapshot` persists one format-versioned typed value with:

- `OnboardingOperationKind`:
  `initialImport`, `reimport`, or `automaticRecovery`;
- `OnboardingOperationStatus`:
  `idle`, `running`, `interrupted`, `failed`, or `completed`;
- the current typed stage and completed stages;
- operation and originating process-session identities;
- operation, stage, progress-observation, failure, and finish times;
- optional bounded numerator/denominator evidence;
- a monotonically increasing progress revision;
- typed failure category and recovery disposition.

The stage vocabulary follows the current real orchestration boundary:

1. `environmentPreparation`;
2. `messageDataBuild`;
3. `durableReadinessVerification`;
4. `automaticRecoveryReset`.

Source import and graph projection currently run through one established graph
build orchestration call, so this slice does not pretend they are independently
observable top-level stages.

## Identity And Stale Work

Every operation receives a fresh UUID. Every application process receives a
fresh process-session UUID. Operation identity rejects late progress from a
previous attempt. Process-session identity makes a persisted `running` value
from an earlier process mechanically recognizable.

During controller initialization:

```text
persisted running
    + different process session
    -> interrupted
```

Quitting or crashing is therefore not classified as failure, and an earlier
run cannot remain durably `running` forever after relaunch.

## Persistence

The snapshot is encoded as bounded JSON in the existing overlay settings table
under:

```text
onboarding_operation_snapshot_v1
```

This required no schema or database addition. The overlay database is available
early, survives restart, and remains outside rebuildable import/graph stores.
Snapshot writes are serialized through the controller. The representative
fixture records one write per explicit batch observation, not one write per
source row and not one timer heartbeat.

## Transition API

`OnboardingOperationSnapshotController` exclusively owns publication through:

- `begin`;
- `enterStage`;
- `reportProgress`;
- `runStage`;
- `fail`;
- `reconcile`;
- `complete`.

`runStage` provides the top-level failure boundary. Synchronous exceptions,
failed Futures, and progress-stream errors all replace `running` with a typed
`failed` snapshot before the error continues through existing error handling.

## Mutation Authority Separation

The ownership chain is:

```text
ArchiveMutationCoordinator
    admits or rejects consequential work

OnboardingOperationSnapshotController
    describes admitted work

source-scoped import and Conversation Graph stores
    prove durable results
```

The snapshot controller imports no mutation coordinator and cannot grant a
database capability. It is descriptive, never permissive. Existing Gate work
continues to execute under `ArchiveMutationCoordinator`.

## Durable Completion Rule

Initial import and reimport cannot become `completed` from a callback, progress
denominator, or animation. After the admitted mutation has released its
maintenance lock, the completion verifier freshly probes the canonical
source-scoped import and Conversation Graph databases and requires positive
row counts. That evidence produces `OnboardingInstallationReadyProof`, the only
accepted completion proof for those operation kinds.

Automatic recovery reset has a separate typed reset-completion proof. It does
not claim that installation is complete.

## Restart Reconciliation

The application shell activates a reconciliation provider. It combines an
interrupted snapshot with the already-established Environment Readiness report:

- ready, populated stores -> completed with durable proof;
- permission/source/readiness blockers -> remains interrupted and resumable;
- import or graph failure -> typed inconsistent failure;
- admitted maintenance -> unavailable, with no additional protected database
  reads.

Durable database truth therefore overrides stale operation history. The
snapshot never substitutes its counts for import or graph facts.

## Presence Projection Seam

The snapshot exposes a small typed projection:

```text
idle -> idle
running -> working
interrupted -> interrupted
failed -> needsAttention
completed -> done
```

No Narrator copy is persisted. Presence may later derive interaction from this
feature-owned operational evidence without becoming the owner of Onboarding
work or completion truth.

## Existing Presentation

The current Gate and overlay remain the user-facing workflow. First run,
reimport, and automatic recovery now publish operation truth underneath the
existing presentation. This slice does not redesign the UI or wire the current
Option-launch `Delete MessageLens App Data` no-op.

## Intentionally Deferred

The snapshot cannot yet prove that a coarse underlying call is hung. The next
slice must define bounded stall/watchdog semantics using execution opportunity,
sleep/wake awareness, and actual progress observations. It must not use a timer
heartbeat as evidence of work.

Also deferred:

- record-level anomaly quarantine;
- Start Fresh and abandoned-installation actions;
- richer import and graph progress sources;
- broad Presence or Onboarding presentation redesign.

## Verification Scope

Focused coverage proves serialization, persistence without a schema change,
typed transitions, real progress observations, sync/Future/stream failure
routing, completion-proof enforcement, stale identity rejection, restart
interruption, durable reconciliation, bounded write cadence, Gate integration,
maintenance-safe reconciliation, and the permanent architecture boundaries
required by Prompt 02.

Final verification completed on 2026-08-23:

- complete Flutter suite: 1,991 tests passed;
- architecture suite: 406 tests passed;
- source-scoped import and Conversation Graph suites: 186 tests passed;
- `flutter analyze`: no issues;
- `dart format`: no changes required;
- `git diff --check`: clean;
- macOS debug build: `MessageLens Development.app` built successfully.
