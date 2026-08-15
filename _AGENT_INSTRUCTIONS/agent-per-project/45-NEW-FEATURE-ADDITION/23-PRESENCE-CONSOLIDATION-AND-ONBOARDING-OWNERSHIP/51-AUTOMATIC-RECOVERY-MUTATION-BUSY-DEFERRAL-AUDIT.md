---
tier: project
scope: automatic-recovery-mutation-busy-deferral
owner: agent-per-project
last_reviewed: 2026-08-15
source_of_truth: code
links:
  - ./41-RECOVERY-AND-PRE-BUILD-FAILURE-STATE-AUDIT.md
  - ./50-PROCESS-LOCAL-ONBOARDING-PREPARATION-FAILURE-IMPLEMENTATION.md
  - ./27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md
tests:
  - test/essentials/onboarding/application/onboarding_gate_provider_test.dart
  - test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart
---

# Automatic Recovery Mutation-Busy Deferral Audit

## Executive Answer

When automatic recovery is denied because mutation authority is busy,
MessageLens should **defer silently and retain no executable request**. It
should try again only when **the coordinator publishes a genuine transition
from locked to idle**, and before doing so it should **run a fresh environment
evaluation and confirm that recovery is still warranted**. No new **timer,
queue, durable state, or human-visible status** is required.

The current coordinator already exposes the required fact-change seam. Its
reactive state identifies whether authority is locked, and `_release()`
publishes the transition to idle from `finally`. The live Messages monitor
already uses this seam successfully: it remembers only that a fresh probe is
needed, listens for release, and re-probes rather than replaying stale work.

The smallest correction belongs in `OnboardingGate`. It should add one private,
process-local deferral guard, observe only the coordinator's lock transition,
invalidate and await fresh environment truth on release, and attempt recovery
only if that truth still requires it. The coordinator should not remember or
schedule denied work.

Recovery presentation should also move inside the admitted action. This is not
a second feature: it is the presentation consequence of the same admission
boundary. A human-visible recovery operation should correspond to work that
actually obtained authority.

## 1. Exact Current Denial And Retrigger Lifecycle

### Initial trigger

`OnboardingGate.build()` watches `onboardingEnvironmentReportProvider`. Every
build calls:

```text
reportAsync.whenData(_maybeTriggerAutomaticRecovery)
```

When the report says `shouldResetAppDatabasesBeforeImport == true` and neither
automatic-recovery flag is set, `_maybeTriggerAutomaticRecovery()`:

1. sets `_automaticRecoveryInFlight = true`;
2. sets `_automaticRecoverySuppressed = true`; and
3. registers a post-frame callback.

The callback publishes `recoveringFailedAttempt`, then starts the unawaited
`_runAutomaticRecovery()` Future.

### Coordinator denial

`ArchiveMutationCoordinator.run()` calls `_tryAcquire()`. If another owner is
active, `_tryAcquire()`:

- retains the current owner and hold count;
- records the denied operation, denied owner, UTC timestamp, and incremented
  denial count in coordinator state; and
- returns false.

`run()` then throws `ArchiveMutationDeniedException`. The recovery action is
never invoked.

### Gate unwind

The current busy catch:

1. clears `_automaticRecoveryInFlight`;
2. clears `_automaticRecoverySuppressed`;
3. clears the recovery workflow override;
4. logs a deferral warning; and
5. invalidates `OnboardingGate` itself.

It does not invalidate the environment report and does not watch coordinator
release.

### Retrigger

The Gate remains watched by application-shell/navigation composition. Its
self-invalidation therefore rebuilds it. The unchanged environment report is
still available as data, so `whenData()` calls the trigger again. Because both
flags were cleared, another post-frame callback is scheduled.

This forms a real provider-level retry cycle while the owner remains active:

```text
deny
    -> clear suppression
    -> invalidate Gate
    -> same report
    -> schedule again next frame
```

No timer is necessary for the cycle; Gate invalidation and post-frame
scheduling provide its cadence. Each denied attempt also republishes
coordinator denial metadata.

### Is visible flashing proven?

Repeated attempts are mechanically possible and, while the Gate stays watched,
expected. Repeated painted recovery overlays are not guaranteed.

The recovery override is published from a post-frame callback. Coordinator
denial completes asynchronously, and its catch can clear the override before
the next frame paints. Flutter may coalesce those state changes. Provider
listeners can still observe transitions, but the current tests do not prove a
visible flash on every denial.

The defect is therefore stronger than a visual claim: the Gate repeatedly
requests authority without waiting for contention to change, and its visible
state can oscillate even if some transitions never reach paint.

## 2. Busy-Denial Mechanical Truth

In ordinary language:

> MessageLens determined that automatic recovery would be appropriate, but
> another MessageLens operation currently had exclusive permission to modify
> the same archive-derived data. Recovery did not start.

The distinctions are mechanical:

```text
BUSY DENIAL
    requested recovery action was never invoked
    reset never began
    recovery changed no files

NON-CONTENTION ADMISSION ERROR
    requested action did not begin
    admission failed for an exceptional reason
    Slice 50 -> preparationFailed

ADMITTED RESET FAILURE
    recovery obtained authority
    reset began
    reset did not finish
    Slice 50 -> preparationFailed
```

Busy denial must remain outside `preparationFailed`.

## 3. Current Competing Mutation Owners

The coordinator is process-wide, so every active caller below can deny
Onboarding automatic recovery. A blocking Onboarding overlay may prevent a new
user action from being initiated, but it does not make an already-running or
background operation disappear.

| Operation | Current owner/caller | Duration from current code | Initiation | Completion effects relevant to re-evaluation |
| --- | --- | --- | --- | --- |
| `liveGraphUpdate` | `chat-db-monitor` | Variable; import, graph projection, and attachment archival | Automatic | Graph-controller and monitor states change; environment report watches both |
| `localAccountIdentityReconciliation` | `chat-db-monitor` | Usually bounded by handle reconciliation, but data-dependent | Automatic at monitor startup | May bump message-data version; environment report does not watch that version directly |
| `graphBuild` | graph-build controller using its supplied owner label | Potentially long full/incremental graph construction | User workflow or automatic subsystem | Controller publishes running/succeeded/failed and bumps message-data version; environment report watches controller state |
| `onboardingImport` | `onboarding-first-run` or `settings-reimport` | Potentially long reset plus graph build | User-initiated | Gate, reset, and graph-controller state change; reset invalidates derived DB providers |
| `automaticRecovery` | `onboarding-automatic-recovery` or `deterministic-attachment-recovery` | Reset-sized for Onboarding; potentially long for attachment recovery | Automatic or user-invoked recovery | Onboarding recovery changes Gate/environment; attachment recovery changes only its own state |
| `messageDataReset` | `message-data-reset` | File/database dependent, usually bounded but destructive | Nested or explicit Settings action | Invalidates derived DB providers and bumps message-data version; explicit Settings flow later refreshes Onboarding |
| `historicalArchiveImport` | `historical-archives-import` | Potentially long source import and projection | User-initiated | Bumps message-data version and feature state; no direct environment-report invalidation |
| `historicalArchiveRemoval` | Historical Archives testing owner | Potentially long removal and reprojection | User-initiated | Bumps message-data version and feature state; no direct environment-report invalidation |
| `attachmentReconciliation` | single, prioritized, live-range, graph-sweep, burst, or archive-all attachment owners | From one file to a long archive sweep | Both automatic and user-initiated | Invalidates attachment settings; no direct environment-report invalidation |
| `attachmentClearing` | `attachment-archive-clear` | Archive-size dependent | User-initiated | Invalidates attachment settings; no direct environment-report invalidation |

`historicalArchiveDryRun` and `destructiveMaintenance` exist in the enum but
have no current `lib/` caller. They are not current competing owners and are not
used to justify this design.

Nested operations inherit the async-zone owner and increase `holdCount` rather
than competing with their outer operation. The coordinator continues to expose
the outer admitted operation while nested work runs.

Completion side effects are inconsistent by design because features own their
work. Some owners naturally rebuild the environment report; others do not.
Coordinator release is the only universal completion fact. This is why release
should trigger an explicit fresh environment evaluation rather than relying on
feature-specific invalidations.

## 4. Coordinator Observability

`ArchiveMutationCoordinatorState` currently exposes:

- current operation;
- owner ID and human-oriented owner label;
- admitted environment and archive instance identity;
- nested hold count;
- acquisition timestamp;
- last release timestamp;
- last denied operation and owner;
- last denial timestamp;
- cumulative denial count;
- derived `isLocked`; and
- derived `blocksDatabaseReopen`.

All fields are process-local Riverpod state. Consumers may watch the full state
or select only `isLocked`. `_release()` runs from `finally`, decrements nested
holds, and publishes an unlocked state only after the final hold is released.
Action exceptions and checkpoint-admission exceptions therefore release
authority normally.

The coordinator has no queue, waiting API, pending-job collection, fairness
policy, or durable state. None is needed here.

The required seam already exists:

```text
previous.isLocked == true
    && next.isLocked == false
```

`ChatDbChangeMonitor` already listens for exactly this transition and schedules
a fresh source probe when deferred live work exists.

## 5. Event-Driven Deferral Analysis

### A. Immediate re-evaluation

This is the current behavior. It is truthful only about the environment reason,
not about authority availability. It causes repeated coordinator calls,
denial-state churn, and possible UI oscillation. It is deterministic in the
wrong way: the same unchanged facts produce the same denial indefinitely.

**Reject.**

### B. Timer or backoff

A timer reduces frequency but does not identify the fact that matters. It may
retry while the owner is still active, wait after the owner is gone, complicate
tests and disposal, and introduce arbitrary timing policy.

**Reject.**

### C. Coordinator-release-driven deferral

The denial is remembered only as a process-local need to re-evaluate. The Gate
observes the coordinator becoming idle, obtains a fresh environment report,
and requests recovery only if current truth still warrants it.

This has no polling, no durable burden, no stale queued command, and no human
involvement. It matches an established repository pattern.

**Recommend.**

### D. User-driven retry only

This avoids churn but makes an automatic reconciliation depend on a refresh or
relaunch even though the process already observes owner release. It is safe but
unnecessarily inert.

**Reject as the primary behavior.** Relaunch remains a valid reconciliation
fallback because no deferral state is durable.

## 6. Recovery Presentation Ordering

Current ordering is:

```text
publish recoveringFailedAttempt
    -> request mutation authority
```

That presentation overstates the known truth during contention. The Gate knows
only that recovery is desirable, not that recovery has started.

Suppressing presentation when the coordinator is already known busy removes
the common flash, but cannot close the race in which another owner acquires
authority after the check and before `run()` acquires it.

The mechanically truthful ordering is:

```text
request mutation authority
    -> admitted action begins
    -> publish recoveringFailedAttempt
    -> allow the recovery surface to paint
    -> reset
```

The short pre-admission interval does not need its own presentation. This is
not a new workflow state. It ensures every visible recovery corresponds to
admitted work and belongs in the same bounded deferral correction.

## 7. Interaction With Slice 50

The required mapping remains:

```text
busy denial
    -> deferred, not failed

non-contention admission error
    -> preparationFailed

admitted reset error
    -> preparationFailed
```

No proposed deferral flag may replace, persist, or reconstruct
`preparationFailed`. A successful later admission clears deferral through the
ordinary recovery lifecycle. An exceptional later admission still reaches the
Slice 50 failure surface.

## 8. What Happens When The Owner Finishes

Feature-specific completion effects are not reliable as a universal signal.
The coordinator's final release is reliable.

The desired sequence is:

```text
busy denial
    -> retain private deferral guard
    -> keep automatic recovery suppressed
    -> coordinator publishes locked -> idle
    -> invalidate and complete a fresh environment probe
    -> environment still requires recovery?
         yes -> make one new admission attempt
         no  -> clear deferral and remain in ordinary environment state
```

The old denied request is never replayed. Its captured report is discarded.

## 9. Race Analysis

### Owner releases before denial handling

A permanent coordinator listener may observe release before the busy catch has
set its deferral guard. The catch must therefore set the guard and then inspect
current coordinator state. If authority is already idle, it should request the
same fresh re-evaluation immediately.

### Owner releases between state check and subscription

The listener should be installed for the Gate lifecycle, not created after
denial. This removes the subscription gap. If the catch sees locked, the
existing listener catches release; if it sees idle, it initiates re-evaluation.

### Another owner acquires immediately after release

Recovery may lose the next admission race. That remains ordinary busy denial:
retain deferral and wait for the next genuine release. Do not count it as
failure.

### Environment becomes ready while deferred

Release triggers a fresh probe. A report that no longer requires reset clears
deferral without running recovery. The cached denied reason has no authority.

### Gate is disposed

A Riverpod `ref.listen` registered in `build()` shares the Gate lifecycle. No
timer, detached subscription, or orphan callback is needed. Any async
re-evaluation must still check provider lifecycle before publishing state.

### Process exits

The private deferral guard disappears. Relaunch derives everything from
environment and filesystem probes, exactly as required.

## 10. Riverpod Lifecycle Verdict

The Gate should listen to a selected coordinator fact, ideally `isLocked`, not
watch the complete state. Watching denial timestamps/counts would rebuild the
Gate on irrelevant denial bookkeeping and could reproduce churn.

One lifecycle-bound listener does create a direct dependency from automatic
recovery orchestration to mutation availability. That dependency is correct:

```text
OnboardingGate owns when to request recovery
ArchiveMutationCoordinator owns whether mutation authority is occupied
```

On release, the Gate must not clear suppression and immediately consume the
old report. It should keep a fresh-evaluation guard until the invalidated
environment provider has produced a current result. The implementation may use
the existing async provider lifecycle; it does not need a new provider or
scheduler.

## 11. State-Model Verdict

No human-visible `waitingForMutationAuthority` status is earned:

- there is no human action;
- another legitimate operation is already active;
- the wait may be brief;
- the coordinator already owns busy truth; and
- another status would duplicate that truth in Onboarding.

One private process-local boolean or equivalent small guard is earned. Its only
meaning is:

```text
automatic recovery was denied because authority was occupied;
re-evaluate after occupancy changes.
```

It is not a queued job and does not promise that recovery will run.

## 12. Human-Feedback Verdict

No new busy copy or UI is justified. A competing visible operation may already
explain what MessageLens is doing; a background operation may finish without
requiring attention. Adding recovery messaging would imply that another task
is queued or that something failed.

Automatic recovery should defer silently. The recovery surface should appear
only after admission.

## 13. Related First-Run Concern

User-initiated **Import My Messages** can also receive ordinary busy denial and
currently supplies no human feedback. The coordinator-release seam could inform
a later design, but automatic replay is not obviously correct for an explicit
button action.

That concern is mechanically separable and must not be included in the next
automatic-recovery slice.

## 14. Ownership Comparison

### Coordinator-owned waiting or queueing

Reject. It would turn exclusive admission authority into a scheduler and force
it to own stale-work validation, cancellation, fairness, ordering, and process
lifetime semantics.

### Caller-owned deferral

Recommend. Onboarding owns whether recovery still makes sense, so it should
remember only that fresh evaluation is needed and consume coordinator release
as a fact.

### Derived scheduling provider

Not currently earned. Combining environment and coordinator state in a new
provider would obscure the existing Gate orchestration and still need an
explicit fresh-probe boundary after release.

## 15. Queue, Polling, And Backoff Verdict

Reject all of the following:

- `Timer`;
- `Future.delayed`;
- periodic polling;
- exponential backoff;
- frame retry; and
- coordinator-held pending work.

They either guess when contention changed or retain stale executable intent.
The coordinator already publishes the exact ownership transition.

## 16. Mutation-Policy Caveat Remains Separate

The existing nested-policy caveat is unchanged:

```text
deferral asks WHEN mutation ownership is available
policy asks WHAT the admitted authority permits
```

The outer `onboardingImport` / `automaticRecovery` operation may still not be a
strict policy superset of nested `messageDataReset`. This audit neither relies
on policy elevation nor changes re-entrant admission.

## 17. Attachment-Preservation Verification

Deferred recovery performs no file work. If fresh truth still requires
recovery and admission later succeeds, it invokes the same
`MessageDataResetService` and the same filename-only allow-list.

No candidate in this audit:

- cleans while waiting;
- receives attachment archive path authority;
- inspects, moves, or deletes archived payloads;
- broadens reset targets; or
- changes reset ordering.

## 18. Ideal State Machine

```text
fresh environment says recovery is needed
        |
        v
mutation coordinator idle?
      /   \
    yes    no
     |      |
     |      -> mark process-local deferral
     |         keep recovery presentation absent
     |         observe locked -> idle
     |                    |
     |                    v
     |              fresh environment probe
     |                    |
     |          still needs recovery?
     |               /          \
     |             yes           no
     |              |             |
     |              |             -> ordinary environment state
     |              v
     +-------> request mutation admission
                       |
                 admitted?
                  /       \
                yes        busy
                 |          |
                 |          -> defer again
                 v
          publish recovery presentation
                 |
                 v
          run unchanged reset
```

Exceptional admission and admitted reset errors retain Slice 50 behavior.

## 19. Deferral Truth Budget

### We may truthfully say internally

- Current environment facts warrant considering automatic recovery.
- Mutation authority is held by another owner.
- This recovery action did not begin.
- Recovery may be reconsidered after ownership changes.
- Fresh environment truth, not the denied request, decides the next action.

### We must not imply

- Recovery failed.
- Reset failed.
- Recovery is queued.
- Recovery will run next.
- The old recovery reason will still be valid later.
- The competing operation caused the incomplete state.

## 20. Eventual Test Strategy

The next implementation should add deterministic coverage proving:

1. a busy owner prevents reset and never reaches `preparationFailed`;
2. Gate rebuilds and denial bookkeeping do not cause another admission request
   while the same owner remains;
3. locked-to-idle release causes one fresh environment evaluation;
4. recovery is attempted exactly once when the fresh report still requires it;
5. no reset occurs when the fresh report is ready;
6. a second owner winning the race returns recovery to deferred state;
7. a release occurring before denial handling is not missed;
8. non-contention admission error still reaches `preparationFailed`;
9. admitted reset error still reaches `preparationFailed`;
10. recovery presentation is never published for a denied request;
11. provider disposal leaves no listener or callback; and
12. a new process reconstructs no deferred job.

The existing coordinator tests already prove exclusive ownership, denial
metadata, release in `finally`, nested hold semantics, and disposal safety.

## 21. Exactly One Next Implementation Slice

**Next concern:** automatic-recovery deferral under ordinary mutation
contention.

**Why it comes next:** Slice 50 now handles real preparation failures. Busy
denial is the remaining pre-controller path that can repeatedly churn without
waiting for its governing fact to change.

**Current defect:** denial clears suppression and invalidates the Gate, so the
same unchanged report can schedule another attempt immediately.

**Smallest implementation:** add one Gate-local deferral guard; observe the
coordinator's locked-to-idle transition; on release obtain fresh environment
truth; attempt recovery only if still required; and publish recovery
presentation only from inside the admitted action.

**Owner:** `OnboardingGate`.

**New state required:** one private process-local deferral/re-evaluation guard;
no `OnboardingStatus`.

**Coordinator changes:** none. Consume its existing reactive `isLocked`
transition.

**Gate changes:** event-driven deferral, race-safe release reconciliation,
fresh-report gating, and admitted-only recovery presentation.

**Environment changes:** no classifier or schema changes; only explicit
invalidation/re-evaluation after release.

**Persistence impact:** none.

**Presentation impact:** no new UI or copy. The existing recovery surface no
longer represents denied work.

**Recovery mechanics impact:** none after admission; the same reset executes.

**Attachment-preservation impact:** none.

**Race handling:** permanent lifecycle-bound release observation plus an idle
state check in denial handling closes the missed-release window; subsequent
owners simply defer recovery again.

**Test seam:** real coordinator state with controlled owner `Completer`s and a
mutable environment-report fixture. No timers are needed.

## Conclusion

The coordinator already provides the fact MessageLens needs. The Gate should
wait for that fact to change, then look at reality again. It should not retry
because time passed, remember executable work, or tell the human that recovery
failed.

Contention becomes ordinary:

```text
mutation lane occupied
    -> defer silently
    -> lane released
    -> fresh environment truth
    -> recover only if still necessary
```
