Yes. The next question is narrowly architectural: ordinary mutation contention is **not failure**; the automatic recovery request simply could not begin because another legitimate owner had the mutation lock. The remaining defect is that clearing suppression can make the unchanged recovery condition immediately eligible again, so repeated recovery flashes/denials are possible. 50\-PROCESS\-LOCAL\-ONBOARDING\-PREPARATION\-FAILURE\-IMPLEMENTATION.md

Perform an **analysis-only audit** of automatic-recovery behavior when `ArchiveMutationCoordinator` denies the recovery request because another legitimate mutation operation currently owns exclusive authority.

**This prompt is authorization to perform the audit. Do not stop to ask for plan confirmation.**

Create:

`51-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-AUDIT.md`

Use the `50-` series for all subsequent documents in this package unless explicitly directed otherwise.

Read first:

- `41-RECOVERY-AND-PRE-BUILD-FAILURE-STATE-AUDIT.md`
- `50-PROCESS-LOCAL-ONBOARDING-PREPARATION-FAILURE-IMPLEMENTATION.md`
- `27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md`
- current `OnboardingGate`
- current `ArchiveMutationCoordinator`
- coordinator provider/state implementation
- current automatic-recovery trigger/rebuild logic
- current environment-report invalidation logic
- all mutation-owner definitions/policies
- focused tests for automatic recovery and mutation coordination

Use current code as source of truth.

Do **not** implement code.

Do **not** add timers, polling, queues, backoff, or persistence.

Do **not** change mutation policy.

Do **not** change reset behavior.

Do **not** modify Presence.

The purpose of this audit is to answer:

> **When automatic recovery wants mutation authority but another legitimate operation already owns it, what is the smallest correct way to defer recovery until contention has genuinely changed—without treating contention as failure, repeatedly flashing recovery UI, polling, or inventing durable workflow state?**

---

## 1. Establish the exact current contention path

Trace the complete current path:

```text
environment report says automatic recovery is needed
    -> OnboardingGate schedules recovery
    -> recoveringFailedAttempt becomes visible
    -> automaticRecovery requests mutation authority
    -> ArchiveMutationDeniedException
    -> recovery flags/override unwind
    -> Gate invalidates/rebuilds
    -> unchanged environment still requests recovery
    -> possible new attempt
```

Document the exact:

- provider rebuild points;
- post-frame callbacks;
- Gate flags;
- suppression flags;
- coordinator state changes;
- invalidations;
- watchers/listeners that can retrigger Gate computation.

Determine whether an actual retry loop exists or merely a code path capable of repeated attempts under repeated provider rebuilds.

Do not assume visible flashing without proving the render/rebuild sequence.

---

## 2. Define the mechanical truth of busy denial

Use ordinary language first.

The truth should be approximately:

> MessageLens determined that automatic recovery would be appropriate, but another MessageLens operation currently has exclusive permission to modify the same rebuildable data, so recovery did not start.

Verify this.

Explicitly distinguish:

```text
BUSY DENIAL
    requested action never executed
    reset never began
    no files changed on behalf of recovery
```

from:

```text
PREPARATION FAILURE
    admitted operation encountered a real error
```

and:

```text
RECOVERY RESET FAILURE
    reset actually began and then failed
```

Busy denial must remain outside `preparationFailed`.

---

## 3. Identify every possible competing mutation owner

Inventory all current `ArchiveMutationCoordinator` operations that can hold authority while automatic recovery wants it.

For each owner, record:

- operation identifier;
- likely duration;
- whether it can coexist with Onboarding UI;
- whether it is user-initiated or automatic;
- whether its completion naturally changes/invalidate providers;
- whether automatic recovery should still be needed afterward.

Do not speculate about future mutation owners.

---

## 4. Audit coordinator observability

Determine exactly what `ArchiveMutationCoordinatorState` exposes.

For example:

```text
current owner
operation type
active/inactive status
denial count
timestamp
policy
```

Record:

- which properties are reactive;
- whether Riverpod consumers can watch owner release;
- whether a completion transition is observable;
- whether state publication occurs in `finally`;
- whether a caller can naturally wait for or react to authority becoming free without polling.

Central question:

> **Does the coordinator already expose a state seam that can tell Onboarding “contention has ended”?**

If yes, identify it precisely.

If no, identify the smallest missing seam conceptually, but do not implement it.

---

## 5. Determine whether retry should be event-driven

Compare:

### A. Immediate re-evaluation

```text
denied
-> invalidate Gate
-> same environment report still says recover
-> try again
```

### B. Timer/backoff

```text
denied
-> sleep
-> retry
```

### C. Coordinator-release-driven deferral

```text
denied
-> stop trying
-> observe current mutation owner
-> when authority becomes free
-> re-evaluate environment
-> attempt recovery if still needed
```

### D. User-driven retry only

```text
denied
-> stop automatic recovery
-> wait for human refresh/relaunch
```

Evaluate each for:

- truthfulness;
- CPU/UI churn;
- architectural coupling;
- determinism;
- race behavior;
- testing complexity;
- durable-state burden;
- human involvement.

Prefer no timer if an event-driven ownership transition already exists.

---

## 6. Audit whether recovery UI should appear before admission

Current ordering allows:

```text
recoveringFailedAttempt published
-> then mutation admission requested
```

which means the human may see:

```text
Preparing MessageLens to try again
```

even though recovery never obtains authority.

Audit whether that ordering remains desirable.

Compare:

### A. Current order

```text
publish recovery
-> request authority
```

Pros:

- immediate acknowledgement.

Cons:

- possible flash for an operation that never started.

### B. Admit first, then publish recovery

```text
request authority
-> once admitted publish recovery
-> reset
```

Pros:

- every visible recovery corresponds to admitted work.

Cons:

- there may be a short pre-paint interval before the operation becomes visible.

### C. Keep current order but suppress visible recovery on known-busy state

Assess whether coordinator state makes that possible.

Do not change ordering in this audit.

Conclude whether **presentation-before-admission** is part of the actual defect or merely a harmless transient.

---

## 7. Account for the preparation-failure state

Slice 50 added:

```text
OnboardingStatus.preparationFailed
```

Busy denial must never enter it.

Verify that any proposed deferral mechanism preserves:

```text
busy denial
    -> deferred, not failed

non-contention admission error
    -> preparationFailed

admitted reset error
    -> preparationFailed
```

Do not weaken that distinction.

---

## 8. Determine what happens when the competing operation finishes

For every realistic competing owner, trace its `finally`/completion behavior.

Ask:

- does it invalidate Environment Readiness?
- does it bump data version?
- does it close/reopen database providers?
- does it alter files enough that the old recovery reason may disappear?
- does coordinator state publication itself trigger listeners?

The ideal design should re-evaluate recovery from **fresh environment truth**, not blindly replay the previously denied request.

Desired conceptual sequence:

```text
busy denial
-> wait for contention to end
-> fresh environment probe
-> still needs recovery?
      yes -> request recovery
      no  -> do nothing
```

Assess whether existing architecture naturally supports this.

---

## 9. Race-condition audit

Consider at least:

### Owner releases just before denial handling runs

Could recovery miss the release event?

### Owner releases between checking coordinator state and subscribing

Could the Gate become indefinitely deferred?

### Another owner acquires authority immediately after the first releases

Should recovery simply be denied again and continue waiting?

### Environment becomes ready while waiting

Recovery must not run merely because an old reason was cached.

### Gate/provider is disposed while waiting

No orphan listener or callback should survive.

### App terminates while deferred

No durable deferral state should be needed; next launch re-probes.

Document how each candidate approach behaves.

---

## 10. Audit Riverpod lifecycle implications

Determine whether a solution based on watching coordinator state would:

- create a permanent dependency from OnboardingGate to coordinator state;
- cause excessive Gate rebuilds;
- trigger recovery during irrelevant owner-state changes;
- need `ref.listen`;
- need provider invalidation;
- fit naturally within the current notifier lifecycle.

Do not implement.

Prefer the smallest lifecycle-compatible mechanism.

---

## 11. Determine whether a new “waiting for mutation” Gate status is earned

Evaluate whether we need something like:

```text
waitingForMutationAuthority
```

Possible reasons to reject it:

- no human action exists;
- contention may be milliseconds;
- coordinator already owns busy truth;
- this would duplicate another subsystem's state;
- recovery can simply remain environment-derived until authority frees.

Possible reasons to accept it:

- UI otherwise oscillates;
- Gate needs an explicit internal guard;
- it materially clarifies lifecycle.

Separate:

```text
internal deferral guard
```

from:

```text
human-visible OnboardingStatus
```

They need not be the same thing.

Conclude whether either is earned.

---

## 12. Determine whether the human needs busy feedback

Ask:

> If automatic recovery is delayed because some other MessageLens mutation is already running, does the person need to be told?

Possible situations:

```text
another visible operation is already running
```

In that case, extra recovery messaging may be actively confusing.

Possible answer:

> No new human-facing copy is required; automatic recovery should simply defer silently until mutation authority is available and environment truth still warrants it.

But verify from production composition.

Do not design new busy UI unless evidence demands it.

---

## 13. Audit user-initiated first-run contention separately

Audit 41 also found first-run:

```text
Import My Messages
-> mutation busy denial
-> no human feedback
```

This audit is primarily about **automatic recovery**, but determine whether the same coordinator-release seam could later help a user-initiated operation.

Do **not** expand implementation recommendation to first-run busy feedback unless mechanically inseparable.

Record it as a related future concern if appropriate.

---

## 14. Determine whether coordinator should own waiting

Compare ownership models:

### Coordinator-owned waiting API

Conceptually:

```text
await runWhenAvailable(...)
```

or:

```text
await waitUntilIdle()
```

### Caller-owned deferral

Onboarding observes coordinator state and retries/re-evaluates later.

### Provider-derived scheduling

A provider combines:

```text
environment needs recovery
AND
mutation coordinator idle
```

and only then triggers automatic recovery.

Assess each against single responsibility.

Ask:

> Should `ArchiveMutationCoordinator` merely answer “yes/no and who owns mutation,” or should it become a scheduler/queue?

Strongly resist turning a mutex-like authority into a workflow queue unless required.

---

## 15. Preserve the coordinator's role

Current conceptual responsibility is:

> one destructive archive-derived-data mutation owner at a time.

Do not casually expand that into:

> remember denied jobs and execute them later.

Assess whether queueing would introduce:

- stale requested work;
- ordering semantics;
- cancellation semantics;
- durable-vs-process-local ambiguity;
- fairness questions;
- hidden work occurring after user context changes.

If so, reject queueing.

---

## 16. Determine whether polling/backoff is justified

Explicitly assess:

```text
Timer
Future.delayed
periodic poll
exponential backoff
frame retry
```

If coordinator state already changes reactively, these should probably be rejected.

State why.

Do not implement.

---

## 17. Interaction with mutation-policy caveat

Recall the existing architectural caveat:

```text
outer onboardingImport / automaticRecovery authority
    may not be a strict policy superset of nested messageDataReset
```

Do not solve that here.

But verify that the proposed deferral seam does not accidentally depend on policy elevation or alter nested admission behavior.

State explicitly:

```text
deferral concerns WHEN ownership is available
policy caveat concerns WHAT authority means once admitted
```

Keep them separate.

---

## 18. Attachment-preservation check

No proposed deferral design may change reset targets.

Reconfirm automatic recovery still eventually invokes the same allow-listed reset only after admission.

No candidate may:

- clean files while waiting;
- inspect/delete archived attachments;
- move preservation data;
- broaden reset paths.

If any architecture suggestion would touch archived attachment payloads, reject it.

---

## 19. Define the ideal state machine

Produce the smallest conceptual state machine for automatic recovery around contention.

For example:

```text
environment says recovery needed
        |
        v
is mutation authority currently obtainable?
        |
      yes ----------------> admit recovery -> show recovery -> reset
        |
       no
        v
deferred because busy
        |
        v
observe owner release
        |
        v
fresh environment evaluation
        |
    still needs recovery?
       / \
     yes  no
      |    |
      |    -> ordinary environment state
      v
attempt admission again
```

Adapt it to actual architecture.

Avoid adding conceptual states that code does not need.

---

## 20. Establish a deferral truth budget

Create:

### WE MAY TRUTHFULLY SAY INTERNALLY

Examples to verify:

```text
automatic recovery is warranted by current environment facts
mutation authority is currently held elsewhere
the recovery action did not begin
we may re-evaluate after ownership changes
```

### WE MUST NOT IMPLY

```text
recovery failed
reset failed
recovery is queued
recovery will definitely run next
current recovery reason will still be valid later
the competing operation caused the incomplete state
```

---

## 21. Testing strategy for eventual implementation

Identify focused deterministic tests needed for the recommended solution.

At minimum consider:

### Busy owner prevents reset

```text
environment needs recovery
coordinator busy
-> reset count = 0
-> no preparationFailed
```

### No repeated attempt while same owner remains

Prove the Gate does not repeatedly request mutation authority merely because it rebuilds.

### Owner release triggers fresh evaluation

After contention ends:

```text
fresh environment still needs recovery
-> exactly one recovery attempt
```

### Environment changes while deferred

After contention ends:

```text
fresh environment no longer needs recovery
-> no reset
```

### Second owner wins race

Recovery remains deferred correctly and does not fail.

### Non-contention admission error remains preparationFailed

Slice 50 behavior preserved.

### Restart

No deferred job is persisted or replayed; new process starts from probes.

Do not write tests in this audit.

---

## 22. Decide whether the solution belongs in Gate, coordinator, or derived provider

Choose the most appropriate owner.

Use:

```text
Coordinator
    owns exclusive mutation authority

Environment report
    owns durable/environment classification

OnboardingGate
    owns automatic-recovery orchestration and process-local lifecycle
```

Recommend which layer should perform the deferral and why.

Avoid making one layer understand another layer's semantic meaning unnecessarily.

---

## 23. Recommend exactly one next implementation slice

Choose one bounded correction only.

Possible result:

```text
defer automatic recovery after busy denial until coordinator returns idle,
then invalidate/re-evaluate environment before making a new recovery request
```

But derive it from code.

Use:

```text
Next concern:
Why it comes next:
Current defect:
Smallest implementation:
Owner:
New state required:
Coordinator changes:
Gate changes:
Environment changes:
Persistence impact:
Presentation impact:
Recovery mechanics impact:
Attachment-preservation impact:
Race handling:
Test seam:
```

Do not bundle first-run busy feedback, policy-superset work, Settings behavior, or reset changes.

---

## 24. Documentation output

Create:

`51-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-AUDIT.md`

Include:

1. exact current denial/retrigger lifecycle;
2. busy-denial mechanical truth;
3. competing mutation owners;
4. coordinator observability;
5. event-driven retry analysis;
6. recovery-presentation ordering;
7. Slice 50 interaction;
8. owner-release behavior;
9. race analysis;
10. Riverpod lifecycle analysis;
11. state-model verdict;
12. human-feedback verdict;
13. first-run related concern;
14. ownership comparison;
15. queue/polling verdict;
16. policy-caveat separation;
17. attachment-preservation verification;
18. ideal state machine;
19. deferral truth budget;
20. test strategy;
21. exactly one next implementation slice.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

No application code changes.

---

# Hard constraints

Do not:

- implement deferral;
- add timers;
- add polling;
- add backoff;
- add a mutation queue;
- add durable pending-work state;
- create a recovery-failure state for busy denial;
- change `preparationFailed`;
- change reset semantics;
- change mutation policy;
- fix the nested policy-superset caveat;
- change FDA behavior;
- change first-run busy UI;
- change Settings reset;
- modify Presence;
- touch attachment archival.

If the existing coordinator already provides an adequate reactive owner-release seam, prefer consuming that seam rather than inventing another scheduling mechanism.

# Success criterion

At the end of the audit, we should be able to complete this sentence:

> **When automatic recovery is denied because mutation authority is busy, MessageLens should **\_\_\_\_**. It should try again only when **\_\_\_\_**, and before doing so it should **\_\_\_\_**. No new **\_\_\_\_** is required.**

The desired architecture should make contention boring:

```text
someone else is using the mutation lane
        ↓
automatic recovery quietly waits/defer
        ↓
lane becomes free
        ↓
look at reality again
        ↓
recover only if reality still says recovery is needed
```

No flashing, no spinning retry loop, no fake failure, and no new durable workflow machinery.

This is exactly the sort of problem where **“wait for the fact to change, then look at reality again”** is likely to beat retry machinery—but the audit should prove whether the coordinator already gives us that fact-change seam.
