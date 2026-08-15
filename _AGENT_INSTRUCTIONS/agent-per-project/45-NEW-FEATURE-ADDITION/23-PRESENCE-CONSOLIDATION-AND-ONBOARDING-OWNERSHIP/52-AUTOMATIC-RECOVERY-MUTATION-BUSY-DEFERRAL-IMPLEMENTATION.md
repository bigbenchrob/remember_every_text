---
tier: project
scope: automatic-recovery-mutation-busy-deferral
owner: agent-per-project
last_reviewed: 2026-08-15
source_of_truth: code
links:
  - ./51-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-AUDIT.md
  - ./50-PROCESS-LOCAL-ONBOARDING-PREPARATION-FAILURE-IMPLEMENTATION.md
  - ./27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md
tests:
  - test/essentials/onboarding/application/onboarding_gate_provider_test.dart
---

# Automatic Recovery Mutation-Busy Deferral Implementation

## Result

Automatic recovery no longer retries from an unchanged environment report
while another mutation owner remains active. Ordinary mutation contention is
now a silent, process-local deferral:

```text
busy denial
    -> wait for coordinator release
    -> obtain fresh environment truth
    -> recover only if still required
```

The coordinator remains an admission authority. It retains no denied request,
does not queue work, and has no new API.

## Previous Behavior

The Gate previously cleared recovery suppression and invalidated itself after
`ArchiveMutationDeniedException`. Because the cached environment report still
required recovery, the rebuilt Gate could schedule the same admission request
again without any relevant fact changing.

Recovery presentation was also published before mutation admission, so a
denied request could transiently claim that recovery was underway.

## Final Deferral Mechanism

`OnboardingGate` now owns one private enum with three values:

```text
none
waitingForMutationRelease
awaitingFreshEnvironment
```

The values mean:

- `none`: no contention-specific reconciliation is pending;
- `waitingForMutationRelease`: recovery was denied while the coordinator was
  locked; and
- `awaitingFreshEnvironment`: a genuine release occurred and the environment
  provider has been invalidated, but its new result has not yet arrived.

This enum contains no callback, command, report, owner identity, or durable
state. It records only which fact the Gate is waiting to observe.

The existing guards retain narrow meanings:

- `_automaticRecoveryInFlight` means one admission/recovery attempt has been
  scheduled or is executing;
- `_automaticRecoverySuppressed` prevents the current report from becoming
  executable again; and
- the private deferral enum distinguishes waiting for release from waiting for
  a fresh report.

## Coordinator Listener Seam

The Gate uses a lifecycle-bound `ref.listen` selecting only
`ArchiveMutationCoordinatorState.isLocked`. It updates a private current-lock
fact and reacts only to:

```text
previous == true && next == false
```

Denial timestamps, counts, labels, and operation metadata do not rebuild or
retrigger recovery.

## Race-Safe Release Handling

On busy denial the Gate first enters `waitingForMutationRelease`, then checks
the lock fact most recently published by the listener.

- If authority remains locked, the Gate waits for the listener.
- If the owner released before denial handling completed, the current-lock
  fact is already false and the Gate requests fresh environment evaluation
  immediately.

The transition to `awaitingFreshEnvironment` occurs before provider
invalidation, so the denial catch and release listener cannot request duplicate
evaluations.

If another owner wins the later admission race, the new denial returns the Gate
to `waitingForMutationRelease`. It remains contention, not failure.

## Fresh Environment Requirement

Release invalidates `onboardingEnvironmentReportProvider`. The Gate does not
retain or replay the denied report.

Riverpod may expose the previous value while an asynchronous provider is
refreshing. The Gate therefore consumes a report as fresh only when the
provider is no longer loading and has no error. The stale refreshing value
cannot authorize recovery.

When the completed report arrives:

- if reset is no longer required, suppression and deferral clear and ordinary
  environment-derived state wins;
- if reset remains required, exactly one new admission attempt is scheduled.

No asynchronous callback is retained across Gate disposal. A new process has
no deferral to reconstruct and starts from ordinary probes.

## Presentation Admission Boundary

`recoveringFailedAttempt` is now published inside the coordinator-admitted
action. The admitted action waits for that presentation frame before invoking
the unchanged reset service.

The ordering is now:

```text
request authority
    -> admitted
    -> publish existing recovery presentation
    -> reset derived data
```

A denied request never exposes the recovery surface. The Slice 39 wording,
icon, activity indicator, typography, spacing, and lack of controls are
unchanged.

## Failure Distinction

The implementation preserves three separate outcomes:

```text
ordinary busy denial
    -> silent deferral

non-contention admission error
    -> preparationFailed

admitted reset error
    -> preparationFailed
```

No new `OnboardingStatus` or human-visible busy state was added. Slice 50 retry
and support behavior remains unchanged.

## Deliberately Absent Machinery

The implementation adds no:

- timer or `Future.delayed`;
- polling or backoff;
- mutation queue or waiting API;
- persisted pending work;
- retained recovery callback;
- human-facing waiting copy; or
- coordinator scheduling responsibility.

## Riverpod Lifecycle

The coordinator listener belongs to the Gate provider lifecycle. Fresh truth
arrives through the Gate's existing dependency on the environment provider,
not through a detached Future that later publishes state.

This choice also keeps provider disposal mechanical: disposal removes the
listener, and a later coordinator release cannot recreate or execute recovery.

## Unchanged Boundaries

This slice does not change:

- automatic-recovery classification or thresholds;
- Environment Readiness ownership;
- `MessageDataResetService.resetDerivedData()`;
- reset targets, ordering, or exception behavior;
- mutation operations or policy;
- the nested mutation-policy caveat;
- first-run busy feedback;
- Settings reset;
- Presence; or
- attachment archival and preservation.

Deferral changes only **when** automatic recovery may ask to reset. It does not
change **what** admitted reset authority means.

## Verification Coverage

Focused Gate tests prove:

- a busy owner prevents reset and never publishes recovery or
  `preparationFailed`;
- repeated frames do not produce repeated admission attempts;
- release causes one fresh environment evaluation;
- fresh ready-to-import truth performs no reset;
- fresh recovery truth admits once and publishes recovery once;
- a second owner winning the race defers recovery again;
- release before denial handling is not missed;
- non-contention admission and admitted reset failures retain Slice 50;
- disposal cannot trigger orphan recovery; and
- a new Gate reconstructs no deferred job.

Existing coordinator tests continue to cover exclusivity, denial metadata,
nested holds, `finally` release, locked-to-idle publication, and disposal.

## Deviation From Audit 51

Audit 51 described one private Boolean as a possible implementation. The final
code uses one private three-value enum because two different facts must not be
conflated: waiting for authority release and waiting for the refreshed
environment result.

This is not additional workflow state. It is the smallest guard that prevents
Riverpod's retained value during provider refresh from being mistaken for the
new environment report.
