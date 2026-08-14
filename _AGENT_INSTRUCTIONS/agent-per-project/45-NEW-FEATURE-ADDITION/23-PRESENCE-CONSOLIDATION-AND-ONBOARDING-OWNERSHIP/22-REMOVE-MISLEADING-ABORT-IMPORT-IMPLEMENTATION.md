---
tier: project
scope: onboarding-progress-truthfulness
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: code
links:
  - 21-INITIAL-IMPORT-GRAPH-BUILD-LIFECYCLE-AUDIT.md
  - ../../25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md
tests:
  - test/essentials/onboarding/presentation/onboarding_overlay_progress_test.dart
  - test/essentials/onboarding/application/onboarding_gate_provider_test.dart
  - test/essentials/conversation_graph/application/conversation_graph_build_controller_provider_test.dart
---

# Remove Misleading Abort Import Implementation

## Correction

The first-run progress surface no longer displays **Abort Import**.

Audit 21 established that the control was mechanically false. It called a
derived-data reset but did not:

- signal `ConversationGraphBuildController`;
- interrupt `ConversationGraphBuildOrchestrator`;
- stop an active specialist;
- wait for a safe stage boundary;
- persist cancellation intent.

While the build held archive mutation authority, the reset requested by the
control was normally denied. The build continued.

The progress surface now communicates only capabilities the application owns:
coarse, indeterminate preparation/build activity followed by the existing
success or failure/recovery outcome.

## Dead Plumbing Removed

Reference search found no caller outside the progress presentation. The slice
therefore removed:

```text
OnboardingOverlayActions.abortImport()
OnboardingGate.abortImport()
```

These were the fake cancellation API. They were not retained as compatibility
shims.

`MessageDataResetService.resetDerivedData()` remains unchanged. It continues to
serve legitimate first-run preparation, reimport preparation, automatic
recovery, and explicit reset workflows.

## Operation Lifecycle Preserved

The following remain unchanged:

- `ArchiveMutationCoordinator` admission and exclusion;
- the pre-build Full Disk Access check;
- derived-data reset before first build and reimport;
- `ConversationGraphBuildController.runOnce()`;
- all 17 orchestrator stages;
- source import and Conversation Graph projection;
- failure persistence;
- automatic recovery;
- restart reconciliation;
- success completion and dismissal.

No cancellation mechanism, progress event, stage identity, percentage, durable
job state, schema, Presence Step, or replacement stop control was introduced.

## Explicitly Non-Cancellable Progress

Both active progress variants continue to show their existing truthful coarse
messages:

```text
Building browsing data…
Rebuilding browsing data…
```

Neither now offers **Abort Import**, Cancel, Stop, Quit Setup, Clean Up, Return,
or Try Later. Failure retry remains available only through the existing
post-failure/recovery path after the operation has actually ended or startup
has reconciled durable state.

## Tests

`onboarding_overlay_progress_test.dart` renders the real production overlay
with a running graph-build controller and proves:

- first-run progress remains visible and contains no cancellation control;
- reimport progress remains visible and contains no cancellation control;
- no replacement false stop/cleanup label was introduced.

Existing Gate and controller tests remain the behavioral protection that:

- successful builds still reach completion;
- caught failures still reach `awaitingUserAction` and existing recovery;
- the controller still runs its service once and publishes terminal state.

Verification completed with:

- 28 focused progress, Gate, controller, Environment Readiness, and durable
  handoff tests;
- 113 complete Onboarding and Environment Readiness tests;
- 372 architecture tripwires;
- clean `flutter analyze`;
- clean formatting and `git diff --check`;
- successful debug macOS build of `MessageLens Development.app` without
  launching it or accessing the production archive.

## Deviations From Audit 21

None.

The audit recommended exactly this bounded correction: remove the false Abort
affordance without redesigning the operation or substituting another command.
