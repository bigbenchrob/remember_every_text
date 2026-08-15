### 52 — Automatic-Recovery Mutation-Busy Deferral Implementation

Implement the single bounded correction recommended by:

- `51-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-AUDIT.md`
- `50-PROCESS-LOCAL-ONBOARDING-PREPARATION-FAILURE-IMPLEMENTATION.md`
- `27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md`

**This prompt is authorization to implement. Do not stop to ask for plan confirmation.**

Create:

`52-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-IMPLEMENTATION.md`

Continue using the `50-` document-number series.

The goal is:

> When automatic recovery is denied because another mutation owner is active, defer silently until the coordinator genuinely becomes idle, obtain fresh environment truth, and attempt recovery only if that fresh truth still requires it.

No denied recovery request should be retained or replayed.

No timer, queue, polling, persistence, new `OnboardingStatus`, or busy UI is required.

---

## 1. Preserve the mechanical distinction

These truths must remain distinct:

```text
BUSY DENIAL
    recovery never obtained mutation authority
    reset never began
    recovery changed no files
    -> defer silently

NON-CONTENTION ADMISSION ERROR
    recovery could not begin for an exceptional reason
    -> preparationFailed

ADMITTED RESET FAILURE
    recovery obtained authority
    reset began
    reset failed
    -> preparationFailed
```

Ordinary `ArchiveMutationDeniedException` must never enter:

```text
OnboardingStatus.preparationFailed
```

Slice 50 behavior for the other two cases must remain unchanged.

---

## 2. Remove the immediate retry cycle

Current busy-denial behavior effectively permits:

```text
denied
-> clear suppression
-> invalidate Gate
-> consume unchanged environment report
-> schedule another recovery attempt
-> denied again
```

Stop that cycle.

After ordinary busy denial:

- do not immediately invalidate/rebuild into another attempt;
- do not clear state in a way that makes the same cached environment report executable again;
- do not schedule another post-frame retry;
- do not use `Future.delayed`, timers, frame callbacks, or backoff.

The Gate should instead enter a private deferred condition whose meaning is only:

```text
automatic recovery was denied because mutation authority was occupied;
fresh environment truth is required after occupancy changes.
```

This is not a queued job.

---

## 3. Add one private Gate-local deferral guard

Add the smallest private process-local guard required by Audit 51.

A concept such as:

```text
_automaticRecoveryDeferredForMutation
```

or equivalent is acceptable.

It must:

- exist only inside the live `OnboardingGate`;
- not appear in `OnboardingStatus`;
- not be persisted;
- not be reconstructed after restart;
- not contain an executable callback/request;
- not preserve the denied environment report as authority.

Its meaning is **“re-evaluate later”**, not **“run this job later.”**

---

## 4. Observe only the coordinator lock fact

Use the existing reactive coordinator seam.

Prefer listening to the smallest relevant fact:

```text
ArchiveMutationCoordinatorState.isLocked
```

rather than watching denial timestamps, counts, owner labels, or the whole coordinator state if avoidable.

The relevant transition is:

```text
previous.isLocked == true
&& next.isLocked == false
```

Install the listener as part of the Gate lifecycle so there is no subscribe-after-denial race.

Do not add a new coordinator API.

Do not modify coordinator ownership semantics.

---

## 5. On busy denial, defer rather than fail

When `ArchiveMutationDeniedException` is caught during automatic recovery:

1. mark automatic recovery as deferred for mutation contention;
2. ensure no visible recovery operation remains active;
3. ensure the same stale environment report cannot immediately trigger another attempt;
4. preserve ordinary coordinator denial diagnostics;
5. do not enter `preparationFailed`;
6. do not run reset;
7. do not invalidate the Gate merely to retry.

Then inspect current coordinator lock state.

This check is necessary because the competing owner may have released authority between the original denial and denial handling.

---

## 6. Close the missed-release race

Audit 51 identified this race:

```text
owner releases
-> coordinator publishes idle
-> busy-denial catch has not yet marked deferral
```

The implementation must not miss that release.

Use the lifecycle-bound listener plus a current-state check in denial handling.

Required behavior:

```text
busy denial
-> mark deferred

if coordinator is still locked:
    wait for locked -> idle listener

if coordinator is already idle:
    begin fresh environment re-evaluation now
```

Do not create a second listener after denial.

---

## 7. On locked → idle, obtain fresh environment truth

When coordinator ownership genuinely transitions to idle while automatic recovery is deferred:

Do **not** replay the denied request.

Do **not** reuse the environment report captured before denial.

Instead:

```text
locked -> idle
-> invalidate/re-evaluate onboarding environment
-> await/observe a fresh result
-> ask whether automatic recovery is still warranted
```

Only fresh environment facts may authorize another recovery attempt.

---

## 8. Fresh report no longer requires recovery

If fresh environment truth says:

```text
shouldResetAppDatabasesBeforeImport == false
```

then:

- clear the deferral guard;
- perform no reset;
- remain in or return to the ordinary environment-derived Onboarding state;
- do not show recovery UI.

This must work regardless of _why_ the competing mutation made recovery unnecessary.

Onboarding does not need to understand the competing operation's semantics.

---

## 9. Fresh report still requires recovery

If fresh environment truth still requires automatic recovery:

- clear/transition the deferral guard appropriately;
- make exactly one new mutation-admission attempt.

Do not assume that authority remains idle merely because it was idle when the report refresh started.

Another owner may win the race.

If the new attempt is again ordinarily denied:

```text
busy
-> defer again
-> wait for next genuine locked -> idle transition
```

This remains contention, not failure.

---

## 10. Publish recovery UI only after admission

Move:

```text
recoveringFailedAttempt
```

presentation inside the successfully admitted automatic-recovery action.

The desired ordering is:

```text
environment says recovery needed
-> request mutation authority
-> authority admitted
-> publish recoveringFailedAttempt
-> allow recovery presentation to become active
-> resetDerivedData()
```

Do not publish:

```text
Preparing MessageLens to try again
```

for an operation that never obtained authority.

This is part of the same bounded admission/deferral correction, not a new UX feature.

---

## 11. Preserve the calm recovery presentation

Once authority has actually been admitted, retain the existing Slice 39 surface unchanged:

```text
Preparing MessageLens to try again

MessageLens found incomplete browsing data and is preparing for another setup attempt. Please wait.

[indeterminate activity]
```

Do not alter:

- wording;
- icon;
- spinner;
- typography;
- spacing;
- controls.

No new busy presentation is added.

---

## 12. Preserve Slice 50 failure behavior

If the later admission attempt throws a **non-contention** admission exception:

```text
-> preparationFailed
```

If admission succeeds but `resetDerivedData()` throws:

```text
-> preparationFailed
```

The stable failure surface remains:

```text
MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data.
You can try again.

[Try Again]
[Send Report To Developer]
```

Do not weaken or bypass Slice 50.

---

## 13. Keep suppression semantics deterministic

Review `_automaticRecoveryInFlight`, `_automaticRecoverySuppressed`, the new deferral guard, and the workflow override together.

After implementation, there should be no combination in which:

- the Gate repeatedly attempts while the same owner remains locked;
- recovery remains permanently suppressed after contention has ended and fresh truth still requires it;
- recovery UI remains active while no admitted recovery operation exists;
- a non-contention error leaves recovery flags stranded.

Keep the state machinery as small as possible.

Document the final meanings/invariants of these private guards.

---

## 14. No human-visible busy state

Do not add:

```text
Waiting…
Another operation is running…
Recovery paused…
Queued…
```

or any similar presentation.

Automatic recovery contention requires no human decision.

If another visible mutation is running, extra Onboarding messaging would compete with it.

If the competing mutation is background work, there is still nothing the human needs to do.

Silent deferral is intentional.

---

## 15. Do not queue recovery

The coordinator must remain an admission authority, not a scheduler.

Do not add:

- pending operations;
- callback queues;
- fairness rules;
- automatic command replay;
- `runWhenAvailable`;
- `waitUntilIdle` job APIs.

The architecture remains:

```text
ArchiveMutationCoordinator
    owns whether mutation authority is occupied

OnboardingGate
    owns whether automatic recovery still makes sense
```

The coordinator publishes facts.

The caller decides what those facts mean.

---

## 16. Do not poll or back off

Explicitly do not introduce:

```text
Timer
Future.delayed
periodic polling
exponential backoff
frame retries
```

The exact fact change is already observable.

Use it.

---

## 17. Fresh environment truth is mandatory

The old denied report must never be treated as a deferred command.

After release:

```text
NOT:
    "we wanted recovery earlier, so run it now"

YES:
    "contention changed; what is true now?"
```

This distinction is a hard invariant.

Tests should make stale replay difficult to introduce later.

---

## 18. Riverpod lifecycle

Use a lifecycle-bound mechanism such as the existing appropriate `ref.listen` pattern.

Avoid:

- orphan subscriptions;
- detached callbacks surviving Gate disposal;
- full coordinator-state watches that rebuild on denial bookkeeping;
- listener installation only after contention occurs.

If asynchronous fresh-report evaluation can outlive Gate disposal, preserve normal Riverpod lifecycle safety before publishing new state.

Do not invent a custom lifecycle manager.

---

## 19. Preserve restart semantics

The deferral guard is process-local only.

If the app quits while recovery is deferred:

```text
process exits
-> deferral disappears
-> next launch probes filesystem/environment
-> current truth decides whether recovery is needed
```

There is no queued recovery job to resume.

Do not persist:

- “waiting for mutation”;
- denied owner;
- pending recovery;
- next attempt.

---

## 20. Preserve environment ownership

Do not alter:

- automatic-recovery classification;
- row thresholds;
- `resetAppDatabasesReason`;
- FDA/source blockers;
- database health semantics.

The only environment change in this slice should be the explicit fresh re-evaluation required after coordinator release.

Do not make coordinator state part of durable Environment Readiness truth.

---

## 21. Preserve reset behavior

After successful admission, automatic recovery must invoke the same existing:

```text
MessageDataResetService.resetDerivedData()
```

Do not change:

- reset ordering;
- provider-closing behavior;
- file families;
- exception semantics;
- data-version semantics.

Deferral changes **when a reset may be attempted**, not **what reset does**.

---

## 22. Preserve attachment safety

No waiting/deferral path performs file work.

The hard reset boundary remains unchanged.

Do not inspect, move, delete, or otherwise mutate:

- Apple Messages;
- Apple Contacts;
- locally available source attachment payloads;
- archived attachment payloads;
- overlays/user intent;
- preferences.

Attachment preservation remains mechanically unaffected.

---

## 23. Leave the nested mutation-policy caveat alone

Do not address the existing caveat that outer:

```text
onboardingImport / automaticRecovery
```

authority may not be a strict policy superset of nested:

```text
messageDataReset
```

Keep the concepts separate:

```text
this slice:
    WHEN ownership becomes available

policy caveat:
    WHAT admitted authority permits
```

No policy elevation or nested-admission redesign.

---

## 24. Leave first-run busy feedback alone

User-initiated:

```text
Import My Messages
-> ordinary mutation busy denial
```

still deserves later consideration.

Do not include it here.

Automatic replay of an explicit button action has different semantics from automatic recovery.

This slice concerns **automatic recovery only**.

---

## 25. Focused tests

Add deterministic tests covering at least the following.

### A. Busy owner prevents recovery work

Arrange:

```text
environment requires automatic recovery
coordinator already locked by another owner
```

Prove:

```text
reset count == 0
preparationFailed is never reached
recoveringFailedAttempt is never visibly/published as the admitted recovery state
```

and recovery becomes deferred.

### B. No repeated admission attempts while same owner remains

Keep the same competing owner locked.

Cause ordinary Gate/provider rebuild activity and coordinator denial bookkeeping as needed.

Prove automatic recovery does **not** repeatedly call admission while that owner remains active.

No timer-based assertions.

### C. Locked → idle triggers fresh environment evaluation

Release the competing owner.

Prove exactly one fresh environment evaluation/reconciliation occurs.

### D. Fresh environment still requires recovery

After release, provide a fresh report that still requires recovery.

Prove exactly one new admission attempt occurs.

If admitted:

```text
recoveringFailedAttempt
-> reset once
```

### E. Fresh environment no longer requires recovery

After release, provide fresh environment truth that does not require recovery.

Prove:

```text
no reset
no recovery presentation
deferral clears
ordinary environment state wins
```

### F. Second owner wins the race

After first owner releases, allow another owner to acquire mutation authority before recovery admission.

Prove:

```text
new recovery request denied
-> deferred again
-> no preparationFailed
```

### G. Release-before-catch race

Construct the race where the owner releases before busy-denial handling finishes.

Prove recovery is not indefinitely stranded.

The current-state check after marking deferral must cause fresh re-evaluation.

### H. Non-contention admission error

Prove existing Slice 50 behavior remains:

```text
-> preparationFailed
```

with no reset.

### I. Admitted reset error

Prove existing Slice 50 behavior remains:

```text
admitted
-> recovery presentation
-> reset throws
-> preparationFailed
```

### J. Presentation admission boundary

Prove a denied automatic-recovery request never exposes the production recovery surface.

Prove an admitted request does.

### K. Disposal

Dispose the Gate while deferred.

Then release coordinator authority.

Prove there is no orphan recovery attempt or state publication.

### L. Restart/process reconstruction

Create a new provider container/process-equivalent fixture after deferral.

Prove no deferred job/status is reconstructed.

Fresh environment truth alone determines behavior.

---

## 26. Existing coordinator tests

Preserve existing tests proving:

- exclusive mutation authority;
- denied request metadata;
- release in `finally`;
- nested hold count;
- final locked → idle publication;
- disposal behavior.

Add coordinator tests only if the existing seam itself lacks coverage required by this implementation.

Do not change coordinator behavior merely to simplify Gate tests.

---

## 27. Architecture tripwires

Add or retain focused tripwires where appropriate proving:

```text
no Timer/Future.delayed retry in automatic recovery
no queued recovery callback in coordinator
no persistent deferred-recovery field
no new OnboardingStatus for contention
busy denial != preparationFailed
recovery presentation occurs only after admission
Presence has no mutation-deferral dependency
```

Do not create brittle source-string tests unless that is already the project convention.

---

## 28. Documentation

Create:

`52-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-IMPLEMENTATION.md`

Record:

1. previous retry-cycle behavior;
2. final deferral mechanism;
3. private guard semantics;
4. coordinator listener seam;
5. race-safe release handling;
6. fresh-environment requirement;
7. recovery-presentation admission boundary;
8. busy vs preparation-failure distinction;
9. no new status/UI;
10. no timer/queue/persistence;
11. Riverpod lifecycle;
12. restart behavior;
13. mutation-policy caveat explicitly unchanged;
14. attachment-preservation boundary;
15. first-run busy feedback explicitly deferred;
16. tests;
17. deviations from Audit 51.

Update:

- package `00-START-HERE.md`
- Feature Addition `INDEX.md`
- `DOCUMENTATION_PASS_LOG.md`
- changelog/version if current convention requires it.

---

## 29. Verification

Run:

- focused automatic-recovery deferral tests;
- Slice 50 preparation-failure tests;
- OnboardingGate tests;
- Environment Readiness tests;
- ArchiveMutationCoordinator tests;
- recovery presentation tests;
- reset-preservation tests;
- complete Onboarding test suite;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- debug macOS build.

Do not launch against the production archive.

# Hard constraints

Do not:

- add timers;
- add polling;
- add backoff;
- add a mutation queue;
- persist deferred recovery;
- add a human-visible busy status;
- add an `OnboardingStatus`;
- replay stale denied recovery work;
- change `preparationFailed`;
- change recovery classification;
- change reset behavior;
- change mutation policy;
- address nested-policy elevation;
- change first-run busy feedback;
- change Settings reset;
- modify Presence;
- touch attachment archival.

If the implementation cannot reliably obtain **fresh** environment truth after coordinator release without a broader provider/lifecycle redesign, stop and report the obstacle rather than falling back to timed retry.

# Success criterion

Contention should become mechanically boring:

```text
environment says recovery may be needed
        ↓
mutation lane occupied
        ↓
defer silently
        ↓
no repeated attempts while lane remains occupied
        ↓
lane becomes idle
        ↓
obtain fresh environment truth
        ↓
still needs recovery?
    /             \
  yes              no
   ↓                ↓
attempt admission   ordinary environment state
   ↓
admitted?
 /       \
yes       busy again
 ↓          ↓
show       defer again
recovery
 ↓
unchanged reset
```

A recovery operation should become visible **only after it actually obtains mutation authority**.

No stale command should survive contention. No timer should guess when the lane is free. No new durable workflow state should exist.
