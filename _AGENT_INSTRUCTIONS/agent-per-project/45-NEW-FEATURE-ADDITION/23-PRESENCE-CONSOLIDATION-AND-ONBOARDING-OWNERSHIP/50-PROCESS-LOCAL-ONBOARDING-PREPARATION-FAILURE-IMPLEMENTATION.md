---
tier: project
scope: process-local-onboarding-preparation-failure
owner: agent-per-project
last_reviewed: 2026-08-15
source_of_truth: code
links:
  - ./41-RECOVERY-AND-PRE-BUILD-FAILURE-STATE-AUDIT.md
  - ./30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md
  - ./27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md
tests:
  - test/essentials/onboarding/application/onboarding_gate_provider_test.dart
  - test/essentials/onboarding/presentation/onboarding_overlay_failure_test.dart
---

# Process-Local Onboarding Preparation Failure Implementation

## Scope

This bounded slice implements Audit 41's single recommendation: preserve the
current-process truth that Onboarding-owned preparation could not finish before
the Conversation Graph controller lifecycle began.

It does not add durable failure state. Environment and filesystem probes remain
the only restart authority.

## Final Status And API

`OnboardingStatus.preparationFailed` represents:

```text
Onboarding preparation could not be completed in this process.
```

`OnboardingGate` owns the status as a workflow override. The existing
`startImportAndGraphBuild()` method now accepts both:

- `awaitingUserAction`; and
- `preparationFailed`.

No second retry API was added.

## Cases Entering The State

Exactly three paths enter `preparationFailed`:

1. admitted first-run reset failure;
2. admitted automatic-recovery reset failure; and
3. non-contention automatic-recovery admission failure.

All three retain the technical error and stack trace in the application log.
The ordinary surface does not expose either.

## Cases Explicitly Excluded

The following remain distinct:

- FDA false continues to `awaitingFda`;
- `ArchiveMutationDeniedException` remains ordinary mutation contention;
- Conversation Graph controller failure continues through its existing
  persisted graph-failure path;
- Settings-owned **Reset Message Data** remains outside `OnboardingGate`;
- dormant direct reimport reset behavior is unchanged.

No busy state, waiting UI, timer, queue, or backoff was added.

## First-Run Reset-Failure Transition

The implemented transition is:

```text
startImportAndGraphBuild()
    -> onboardingImport admitted
    -> FDA true
    -> importing / Preparing setup...
    -> resetDerivedData() throws
    -> log original error and stack trace
    -> preparationFailed
    -> controller does not start
```

The Gate no longer rethrows the reset exception into the button callback. The
stable process-local outcome is now the human-visible result.

## Automatic-Recovery Reset-Failure Transition

The implemented transition is:

```text
recoveringFailedAttempt
    -> automaticRecovery admitted
    -> resetDerivedData() throws
    -> clear in-flight state
    -> retain current-process suppression
    -> log original error and stack trace
    -> preparationFailed
```

The recovery spinner therefore ends at a stable failure surface rather than
disappearing behind newly projected environment state.

## Automatic Admission-Error Unwind

A non-`ArchiveMutationDeniedException` admission error now:

1. clears `_automaticRecoveryInFlight`;
2. retains suppression for the current Gate instance;
3. replaces the recovery override with `preparationFailed`; and
4. logs the original error and stack trace.

No reset is described or inferred because the admitted action did not run.

Ordinary mutation denial retains the previous deferral behavior and does not
enter `preparationFailed`. Audit 41's possible repeated-denial behavior remains
out of scope.

## Presentation

The new status uses the existing blocking Onboarding overlay and settled calm
failure hierarchy:

```text
MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data. You can try again.

[Try Again] [Send Report To Developer]
```

The implementation reuses `_WelcomeContent` with one fixed presentation
projection. Environment Summary is explicitly suppressed for this state.

The surface does not show:

- raw exceptions;
- reset filenames;
- mutation details;
- import-ledger or graph-projection terminology;
- **What to check**;
- **Environment Summary**; or
- **Technical Details**.

## Retry Semantics

**Try Again** invokes the existing `startImportAndGraphBuild()` entry point.
The previous failure remains visible while mutation admission is attempted.
Once admitted, the ordinary lifecycle replaces it:

```text
preparationFailed
    -> admitted retry
    -> FDA check
    -> importing / Preparing setup...
    -> complete reset
    -> complete graph build
```

This is a fresh attempt, not resume behavior.

## Refresh And Clearing

Entering `preparationFailed` does not itself request a new environment probe.
The current operation outcome remains stable until an existing deliberate seam
reopens evaluation.

The existing `refreshEnvironment()` method clears the workflow override,
invalidates current FDA and environment probes, and reprojects current durable
truth. No new refresh interaction was added.

## Restart Semantics

`preparationFailed` exists only in the live `OnboardingGate` notifier. A new
provider container or process has no record of it and resolves status from the
current environment report and filesystem probes.

Logs are not consulted to recreate the status.

## Persistence Not Added

This slice adds no:

- overlay setting;
- `presence.db` row;
- schema field;
- reset-failure record; or
- reconstruction rule.

## Controller-Failure Persistence Not Reused

Preparation failure never calls `saveGraphProjectionFailure()` or
`saveImportFailure()`. Those stores remain evidence that their respective
controller-owned phases began and failed.

Focused coverage confirms a real graph-controller failure still saves the
existing graph-projection record and returns to `awaitingUserAction`, not
`preparationFailed`.

## Attachment-Preservation Invariant

`MessageDataResetService`, its deletion order, filename-only allow-list, and
filesystem adapter are unchanged. The reset boundary remains limited to the
four rebuildable derived database names and SQLite sidecars documented by the
attachment-preservation invariant.

No source or archived attachment payload is touched by this state change.

## Tests

Focused coverage proves:

- first-run reset failure reaches `preparationFailed` and never starts the
  controller;
- the stable failure copy, **Try Again**, and support action are visible while
  the raw exception is absent;
- retry starts a new reset/build through the ordinary entry point;
- deliberate refresh returns control to environment truth;
- a new Gate does not reconstruct the process-local status;
- automatic reset failure ends recovery at `preparationFailed`;
- non-contention automatic admission error unwinds and can be re-evaluated;
- ordinary mutation denial and FDA false never enter the status;
- controller failure retains its existing persisted path; and
- existing reset-preservation tests remain the attachment safety authority.

## Remaining Busy-Denial Issue

Automatic recovery still clears suppression after ordinary mutation denial.
An unchanged recovery report may therefore request recovery again while another
owner remains active. This is the separate deferral/backoff concern identified
by Audit 41 and was intentionally not changed.

## Deviations From Audit 41

None.

The implementation uses application logging as the current-process diagnostic
record rather than introducing a separate preparation-failure detail object.
This is the smallest mechanism that preserves the original error and stack
trace for support evidence without creating another failure model.

## Verification

Completed on 2026-08-15:

- focused Gate and stable-failure presentation tests: 30 passed;
- focused Gate, environment-readiness, recovery presentation, mutation
  coordinator, and reset-preservation tests: 61 passed;
- complete Onboarding test directory: 128 passed;
- architecture tripwires: passed;
- `flutter analyze`: no issues;
- touched Dart formatting: clean;
- `git diff --check`: clean; and
- debug macOS build: succeeded at
  `build/macos/Build/Products/Debug/MessageLens Development.app`.

The build emitted the existing Xcode build-version notices and the existing
`volume_controller` `PrivacyInfo.xcprivacy` processing warning. Neither blocked
the build. The application was not launched against the production archive.
