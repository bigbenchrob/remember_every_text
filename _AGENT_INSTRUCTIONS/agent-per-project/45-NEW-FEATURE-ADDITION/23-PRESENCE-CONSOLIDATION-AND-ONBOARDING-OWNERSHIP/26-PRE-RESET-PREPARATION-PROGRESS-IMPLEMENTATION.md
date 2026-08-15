---
tier: project
scope: onboarding-pre-reset-progress
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: code-and-doc
links:
  - ./25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md
  - ../../25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md
tests:
  - test/essentials/onboarding/application/onboarding_gate_provider_test.dart
  - test/essentials/onboarding/presentation/onboarding_overlay_progress_test.dart
---

# Pre-Reset Preparation Progress Implementation

## Result

The active first-run setup path now displays the existing **Preparing setup…**
overlay while derived-data reset is underway. The human no longer remains on
an apparently idle readiness surface after MessageLens has accepted the setup
request and begun work.

No new Gate status, progress component, provider, persistence, or operation was
introduced.

## Old Ordering

```text
Gate status guard
    -> mutation admission
    -> current FDA-readiness guard
    -> reset derived data
    -> Gate: importing
    -> paint progress overlay
    -> Gate: buildingGraph
    -> controller run
```

Reset was real work but remained invisible.

## New Ordering

```text
Gate status guard
    -> mutation admission
    -> current FDA-readiness guard
    -> Gate: importing
    -> paint progress overlay
    -> reset derived data
    -> Gate: buildingGraph
    -> controller run
```

Only presentation-state ordering changed. Reset and graph-build operations are
unchanged.

## Admission And FDA Boundaries

Preparation begins only after both existing boundaries have succeeded:

1. `ArchiveMutationCoordinator` has admitted the first-run operation.
2. The existing current FDA-readiness guard is true.

An admission denial therefore leaves the readiness surface in place. A false
FDA guard still moves directly to `awaitingFda`; reset is not called and no
preparation frame appears.

The FDA provider's computation and caching behavior were not changed.

## Preparation Presentation Precedence

`ConversationGraphBuildController` is keep-alive and may retain a terminal
state from an earlier attempt. During the newly admitted preparation period,
the Gate's `importing` status is authoritative for presentation:

```text
Gate: importing
    -> Preparing setup…
    -> indeterminate activity

otherwise
    -> derive progress presentation from controller state
```

This prevents stale `succeeded` or `failed` controller state from showing
**Browsing data ready**, a completed progress indicator, or an old error while
a new reset is active. The controller itself is not reset or otherwise changed
for presentation convenience.

## Reset-Failure Unwind

If first-run reset throws after preparation has become visible, the Gate:

1. clears the ephemeral `importing` workflow override;
2. invalidates the environment report;
3. restores `awaitingUserAction` presentation;
4. rethrows the original error.

The failure is not swallowed, persisted as a pipeline failure, translated into
controller failure, or given a new recovery surface.

## Successful Continuation

After reset succeeds, the existing sequence continues unchanged:

```text
Gate: buildingGraph
    -> ConversationGraphBuildController.runOnce()
    -> source import
    -> graph projection
    -> existing completion or failure handoff
```

The same blocking overlay therefore progresses continuously from **Preparing
setup…** to **Building browsing data…** without introducing another screen.

## Scope Preserved

This slice changes only `startImportAndGraphBuild()` and its first-run progress
presentation. It does not change:

- direct reimport;
- Reset Message Data;
- automatic recovery;
- mutation admission or nested mutation policy;
- reset allow-lists or attachment preservation;
- controller lifecycle or telemetry;
- source import or graph projection;
- failure persistence;
- Presence;
- cancellation or restart semantics.

## Tests

Focused coverage proves:

- preparation is visible while a controllable reset remains pending;
- the progress indicator remains indeterminate;
- the controller has not started during pending reset;
- a repeated start does not duplicate reset or build work;
- FDA false never enters preparation or reset;
- reset failure restores readiness and preserves the thrown error;
- stale controller success and failure cannot replace preparation copy;
- successful reset continues through the ordinary build lifecycle.

## Deviations From Audit 25

None. The implementation follows the single bounded slice recommended by
[Audit 25](25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md).

## Verification

- 20 focused Gate and progress-presentation tests passed.
- All 121 Onboarding, Environment Readiness, and graph-controller tests passed.
- All 373 architecture tripwires passed.
- `flutter analyze` reported no issues.
- Targeted Dart formatting and `git diff --check` passed.
- A debug macOS build completed successfully without launching the app or
  accessing the production archive.
