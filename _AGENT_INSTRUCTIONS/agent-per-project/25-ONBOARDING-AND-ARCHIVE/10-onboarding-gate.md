# Onboarding Gate — State Machine and Overlay

## Purpose

The `OnboardingGate` is the top-level bootstrap coordinator. It evaluates
whether the app is ready for normal use and coordinates the readiness,
recovery, import, graph-build, and reimport lifecycle.

> **Safety:** Gate reset/recovery means resetting only enumerated rebuildable
> derived stores. Archived attachment payloads are preservation data and are
> outside every Gate reset. See
> [`ATTACHMENT-PRESERVATION-INVARIANT.md`](ATTACHMENT-PRESERVATION-INVARIANT.md).

Current surface split:

- `awaitingFda` and `awaitingUserAction` mount the production Onboarding
  Presence host. The generic Presence runner presents the active
  required-source Schedule, while Onboarding supplies the explicit FDA
  Settings specialist presentation.
- `recoveringFailedAttempt`, import/graph-build progress, completion, and
  reimport completion use the blocking `OnboardingOverlay`.

This is a staged ownership boundary. Presence owns the required-source
readiness interaction. The gate remains the operational authority for recovery,
import, graph construction, completion, and reimport.

### Messages Source Truthfulness

The required-source Schedule no longer treats every failed Messages read as
evidence of missing Full Disk Access. The Messages/Onboarding specialist
classifies the protected read as `readable`, `accessDenied`, or `unavailable`.
Only explicit filesystem permission denial warrants FDA guidance. Missing,
invalid-schema, query, and ambiguous I/O failures receive bounded
source-unavailable guidance instead.

Onboarding projects that specialist result through generic Boolean TestAgents;
Presence remains unaware of Messages, SQLite, or FDA meaning. Adjacent readable
and access-denied Tests share one process-local observation, while every retry
begins a fresh protected read. The Gate still owns only operational admission
and mounts the same real Onboarding Presence host for prerequisite interaction.

## Ownership

- **Location:** `lib/essentials/onboarding/`
- **Owner:** Essentials layer (not a feature)
- **Rule:** Onboarding coordinates and presents. It never owns source-scoped
  import/projection logic.

## Durable Operation Snapshot

`OnboardingStatus` remains the current presentation/workflow projection. It is
not the durable authority for whether consequential Onboarding work is running,
interrupted, failed, or complete.

`OnboardingOperationSnapshot` is the canonical durable description of admitted
Onboarding operations. It records a typed operation kind, typed stage, unique
operation identity, originating process-session identity, completed stages,
real progress observations, bounded failure evidence, and terminal status. It
is persisted as format-versioned JSON in the existing overlay settings table;
no Onboarding schema or second operation database exists.

The authority chain is strict:

```text
ArchiveMutationCoordinator -> whether work may execute
Onboarding operation snapshot -> what admitted work is doing or last did
import and graph databases -> whether durable work actually completed
```

A snapshot never grants mutation authority and never substitutes for imported
rows or Conversation Graph truth. Initial import and reimport become complete
only after the admitted mutation releases maintenance and fresh canonical
probes prove both derived stores are populated.

On a new process, a persisted `running` snapshot from a different process
session becomes `interrupted`. Environment Readiness then reconciles it as
completed, resumable, inconsistent, or temporarily unavailable. During
maintenance, reconciliation consumes the existing maintenance report and does
not independently open protected stores.

## State Machine

The gate tracks a single `OnboardingStatus` enum with 11 states:

```
┌─────────────────────────────────────────────────────────────┐
│                     OnboardingStatus                        │
├─────────────────────────────────────────────────────────────┤
│ notNeeded               — App databases populated, skip     │
│ recoveringFailedAttempt — Reset incomplete DBs before retry │
│ preparationFailed       — Current preparation attempt failed│
│ awaitingFda             — FDA not granted, show instructions│
│ awaitingUserAction      — FDA OK, databases empty, show UI  │
│ importing               — Import pipeline running           │
│ buildingGraph           — Conversation graph build running  │
│ complete                — First-run pipeline done           │
│ reimporting             — User-triggered re-import running  │
│ reimportBuildingGraph   — Re-import graph build phase       │
│ reimportComplete        — Re-import finished                │
└─────────────────────────────────────────────────────────────┘
```

### Transition Flow (First Run)

```
App Start
  │
  ├─ environment report → databases populated?
  │   └─ YES → notNeeded (overlay never shown)
  │
  ├─ environment report → FDA blocked?
  │   └─ YES → awaitingFda
  │       └─ Presence resumes the required-source readiness Schedule
  │       └─ explicit Onboarding FDA specialist opens System Settings
  │       └─ restart resumes the current Trip from Step 1
  │           └─ generic TestStep performs a fresh source-readiness check
  │
  ├─ environment report → sources readable, DBs empty?
  │   └─ YES → awaitingUserAction
  │       └─ Presence presents and advances the required-source Schedule
  │       └─ Schedule completion releases the blocking Presence surface
  │       └─ Environment Readiness combines unchanged environment facts with
  │          durable Schedule completion
  │           ├─ sparse + incomplete → Re-check only
  │           └─ sparse + complete → existing import action available
  │       └─ existing import action → startImportAndGraphBuild()
  │           ├─ importing (source-scoped import/projection begins)
  │           ├─ buildingGraph (conversation graph build running)
  │           └─ complete (show summary, "Get Started" button)
  │
  ├─ environment report → incomplete partial app DBs?
  │   └─ request automatic-recovery mutation authority
  │       ├─ busy → defer silently until locked → idle
  │       │   └─ fresh environment report still requires recovery?
  │       │       ├─ NO → ordinary environment-derived state
  │       │       └─ YES → request authority once again
  │       └─ admitted → recoveringFailedAttempt
  │           └─ reset rebuildable source-scoped import/graph DBs
  │               ├─ success → awaitingUserAction
  │               └─ failure → preparationFailed
  │                   └─ Try Again → ordinary first-run entry point
  │
  └─ environment report → import/graph projection previously failed?
      └─ awaitingUserAction (show failure details + retry)
```

### Transition Flow (Re-Import)

```
Settings → "Re-scan & Import"
  │
  ├─ reimporting (skips FDA gate — already granted)
  ├─ reimportBuildingGraph
  └─ reimportComplete → "Done" button
```

## Key Provider

```dart
// lib/essentials/onboarding/application/onboarding_gate_provider.dart
@Riverpod(keepAlive: true)
class OnboardingGate extends _$OnboardingGate {
  @override
  OnboardingStatus build() {
    // Watches environment report provider
    // Classifies into status via resolveBuildStatus()
  }

  void refreshEnvironment() { ... }
  Future<void> startImportAndGraphBuild() async { ... }
  Future<void> startReimport() async { ... }
  Future<void> openFdaSettings() async { ... }
}
```

### Resolution Logic

`resolveBuildStatus()` maps the environment report to a status:

1. If `permissionBlocked` → `awaitingFda`
2. If `ready` (both DBs populated) → `notNeeded`
3. `importFailed`, `graphProjectionFailed`, `sourceUnavailable`,
   `sourceSparseOrUnsynced`, and `readyToImport` → `awaitingUserAction`

Workflow override states are preserved while recovery, import, graph build,
completion, reimport, or process-local preparation failure is in progress. The
environment report can also set
`shouldResetAppDatabasesBeforeImport`, which triggers automatic recovery into
`recoveringFailedAttempt` only after mutation authority is admitted. Ordinary
mutation contention remains process-local and silent. The Gate observes the
coordinator's locked-to-idle transition, invalidates the environment report,
and consumes only the completed fresh result; it never replays the denied
report or persists a pending recovery command.

### Accepted-Readiness Handoff

`OnboardingEnvironmentReport` remains the authority for current machine facts.
It may continue to report `sourceSparseOrUnsynced` after the human has knowingly
chosen to continue. Completion of the canonical required-sources Presence
Schedule is the separate durable acceptance authority.

The Environment Readiness surface composes those facts. Sparse and incomplete
continues to show **Confirm Local Messages History** with **Re-check**. Sparse
and complete shows the existing **Ready To Import** presentation and **Import
My Messages** action. Import and graph-build failures retain their existing
retry behavior and are never overridden by Presence completion.

The completion query reads the latest Schedule run checkpoint
(`currentTripOccurrenceId == null`). It does not inspect trace or recover a
Choice value, and it adds no second acceptance flag. The import action still
delegates to `OnboardingGate.startImportAndGraphBuild()`.

## Overlay Rendering

`OnboardingOverlay` is a full-window widget rendered above the main app shell
for blocking workflow phases. It switches content based on the current status:

| Status | Overlay Content |
|--------|-----------------|
| `recoveringFailedAttempt` | Recovery/reset progress |
| `preparationFailed` | Calm setup failure with **Try Again** and support actions |
| `importing` | Progress view with row counts and duration per table |
| `buildingGraph` | Progress view continuing from import |
| `complete` | Summary (total counts, warnings, archive size), "Get Started" button |
| `reimporting` | Progress view (no welcome preamble) |
| `reimportBuildingGraph` | Progress view |
| `reimportComplete` | Summary, "Done" button |
| `notNeeded` | Not rendered — overlay is absent |

Legacy note: `OnboardingOverlay` still contains branches for `awaitingFda` and
`awaitingUserAction`, but the current app shell normally presents those states
through `OnboardingPresenceHost` instead of mounting the overlay. The extracted
`OnboardingFdaContent` presentation is shared with the explicit specialist Step
without moving platform authority into generic Presence.

### Overlay Blocking

The overlay renders a `ModalBarrier` that prevents interaction with the main
app during blocking workflow states. When the shell does not mount the overlay,
FDA and user-action states are handled by panel content and sidebar parking.

## Failure Persistence

Import and graph-projection failures are persisted as JSON in the overlay database's
`OverlaySettings` table via `OverlayOnboardingFailureStorage`. This allows:

- Showing the last failure on next launch without re-running the pipeline
- Distinguishing "never tried" from "tried and failed"
- Clearing on successful completion

The legacy import and graph failure buckets remain inputs to Environment
Readiness. In addition, the operation snapshot persists a bounded typed failure
for the current admitted operation. A top-level synchronous, Future, or stream
failure therefore cannot leave canonical operation state saying that work is
still running. Current filesystem and database probes remain the restart
reconciliation authority.

## File Inventory

| File | Role |
|------|------|
| `application/onboarding_gate_provider.dart` | State machine and orchestration |
| `application/onboarding_operation_snapshot_controller.dart` | Typed operation transitions, progress observations, terminal failure, and reconciliation |
| `application/onboarding_operation_snapshot_provider.dart` | Process-session identity and durable snapshot providers |
| `application/onboarding_operation_reconciliation_provider.dart` | Reconciles interrupted operation history with Environment Readiness evidence |
| `application/onboarding_durable_completion_verifier_provider.dart` | Proves post-mutation import and graph readiness before completion |
| `application/onboarding_environment_report_provider.dart` | Environment evaluation |
| `application/database_existence_checker.dart` | Filesystem DB presence check |
| `application/fda_checker.dart` | Full Disk Access probe |
| `domain/onboarding_status.dart` | Presentation status enum (11 states) |
| `domain/onboarding_environment_report.dart` | Typed environment snapshot |
| `domain/onboarding_operation_snapshot.dart` | Operation identity, typed stages/status, progress, and failure evidence |
| `domain/import_spec.dart` | Retired import-control route tagging for diagnostics/compatibility |
| `domain/spec_classes/onboarding_view_spec.dart` | Onboarding panel spec for dev/debug surfaces |
| `infrastructure/overlay_onboarding_failure_storage.dart` | Failure persistence |
| `infrastructure/persistence/overlay_onboarding_operation_snapshot_store.dart` | Snapshot persistence in existing overlay settings |
| `application/required_sources_readiness_scheduler_provider.dart` | Production composition root for real Onboarding agents, Schedule installation, and Scheduler initialization |
| `presentation/onboarding_presence_host.dart` | Production shell around the generic Presence runner and explicit FDA specialist |
| `presentation/onboarding_overlay.dart` | Full-window operational overlay and shared FDA presentation |
| `presentation/onboarding_dev_panel.dart` | Debug/simulation overrides |
| `navigation/presentation/widgets/onboarding_center_panel_sync_observer.dart` | Syncs onboarding gate states into `ViewSpec.environmentReadiness` |
