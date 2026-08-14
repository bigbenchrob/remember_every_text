---
tier: project
scope: production-import-progress-guidance
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: code
links:
  - 23-PRODUCTION-IMPORT-PROGRESS-SURFACE-AUDIT.md
  - 22-REMOVE-MISLEADING-ABORT-IMPORT-IMPLEMENTATION.md
  - ../../25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md
tests:
  - test/essentials/onboarding/presentation/onboarding_overlay_progress_test.dart
---

# Truthful Keep-Open Progress Guidance Implementation

## Correction

The active import/rebuild progress surface now answers what the human should do
while MessageLens works.

The previous paragraph was:

```text
MessageLens is building its local browsing data from Messages.
```

or, for the direct-reimport context:

```text
MessageLens is rebuilding its local browsing data from Messages.
```

Those statements were broadly truthful but repeated the existing
**Building browsing data…** or **Rebuilding browsing data…** headline.

Both contexts now share:

```text
Keep MessageLens open while it prepares your messages. You can use other apps
in the meantime.
```

## Supporting Operational Facts

The guidance states only facts already established by Audit 23:

- the build lifecycle and its in-flight state are process-local;
- quitting MessageLens terminates that operation;
- closing the final MessageLens window terminates the macOS application;
- switching to another application does not terminate MessageLens or request
  cancellation.

The copy does not claim that the operation survives quit, close, relaunch,
restart, sleep, or any other interruption. It does not promise resume.

## Shared First-Run And Reimport Presentation

One shared string is used for both active contexts. The existing controller-
derived headlines continue to express the only context difference needed:

```text
first run:
    Building browsing data…

direct reimport:
    Rebuilding browsing data…
```

No separate prose system, context branch, layout, or presentation abstraction
was introduced.

## Preserved Behavior

The slice changed only active-progress copy and its focused tests. It did not
change:

- `OnboardingGate` or its statuses;
- archive mutation admission;
- derived-data reset;
- `ConversationGraphBuildController` or the orchestrator;
- source import or graph projection;
- completion or failure/recovery presentation;
- restart reconciliation or persistence;
- Presence;
- schema;
- progress geometry or visual hierarchy.

The existing headline and indeterminate linear activity indicator remain. The
surface remains explicitly non-cancellable.

## Tests

The production-overlay widget tests now prove for both first-run and direct
reimport progress:

- the context-appropriate coarse headline remains visible;
- the shared keep-open and use-other-apps guidance is visible;
- the linear progress indicator remains indeterminate;
- the previous repetitive paragraphs are absent;
- no live stage, percentage, ETA, or resume/relaunch promise appears;
- Abort, Cancel, Stop, Quit Setup, Clean Up, Return, and Try Later remain
  absent.

Verification completed with:

- both focused production-overlay progress cases passing;
- all 113 Onboarding and Environment Readiness tests passing;
- all 372 architecture tripwires passing;
- clean Flutter analysis;
- clean targeted formatting and `git diff --check`;
- a successful debug macOS build without launching the app.

The build retained the existing Xcode build-number diagnostic and
`volume_controller` privacy-manifest processing warning. Neither warning was
introduced by this presentation-only slice.

## Deviations From Audit 23

None.

Audit 23 recommended exactly this bounded presentation correction. No elapsed
time, telemetry, operation change, or additional progress-surface refinement
was included.
