### 53 — User-Initiated Setup Mutation-Busy Feedback Audit

Perform an **analysis-only audit** of the production behavior when the human explicitly chooses **Import My Messages** but `ArchiveMutationCoordinator` cannot admit the setup operation because another legitimate mutation owner is active.

**This prompt is authorization to perform the audit. Do not stop to ask for plan confirmation.**

Create:

`53-USER-INITIATED-SETUP-MUTATION-BUSY-FEEDBACK-AUDIT.md`

Continue using the `50-` document-number series.

Read first:

- `41-RECOVERY-AND-PRE-BUILD-FAILURE-STATE-AUDIT.md`
- `50-PROCESS-LOCAL-ONBOARDING-PREPARATION-FAILURE-IMPLEMENTATION.md`
- `51-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-AUDIT.md`
- `52-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-IMPLEMENTATION.md`
- `27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md`
- canonical Onboarding Gate documentation
- current `OnboardingGate`
- current `EnvironmentReadinessPanelView`
- current production Onboarding overlay/action path
- current `ArchiveMutationCoordinator`
- coordinator state/provider
- current tests for first-run setup initiation and mutation denial

Use current code as source of truth.

Do **not** implement application code.

Do **not** automatically replay a denied human command.

Do **not** add mutation queues, timers, polling, or persistence.

Do **not** change automatic-recovery deferral from Slice 52.

The purpose of this audit is to answer:

> **When the human explicitly asks MessageLens to begin setup but mutation authority is already occupied, what is the smallest truthful feedback that tells them their request did not start—without calling contention a setup failure, replaying their command later, or exposing mutation-coordinator machinery?**

---

## 1. Trace the exact production button paths

Trace every current production route by which the human can initiate initial setup/import.

At minimum inspect:

```text
Environment Readiness
    -> Import My Messages
    -> action/provider
    -> OnboardingGate.startImportAndGraphBuild()

Onboarding overlay
    -> corresponding setup action
    -> OnboardingGate.startImportAndGraphBuild()
```

For each path establish:

- exact button callback;
- whether callback awaits the returned Future;
- whether errors are caught;
- whether `ArchiveMutationDeniedException` escapes;
- whether Flutter/framework logging receives it;
- whether the human receives any feedback;
- whether Gate status changes;
- whether any progress presentation appears.

Audit actual production composition, not just test helpers.

---

## 2. Establish the busy-denial truth

Use ordinary language first.

The mechanical truth is expected to be:

> The person asked MessageLens to start setup, but another MessageLens operation already had exclusive permission to change the same rebuildable data. Setup did not start.

Verify that from code.

The following must remain distinct:

```text
USER-INITIATED BUSY DENIAL
    command was explicit
    mutation action never ran
    reset never began
    no setup work started
    request must NOT be replayed automatically

PREPARATION FAILURE
    meaningful/admitted preparation encountered an error
    -> preparationFailed

FDA BLOCK
    required source prerequisite unavailable
    -> existing FDA flow

CONTROLLER FAILURE
    build actually began and failed
    -> existing persisted failure path
```

Busy denial must not become `preparationFailed`.

---

## 3. Compare this with automatic recovery

Slice 52 established:

```text
automatic recovery busy
-> silently defer
-> wait for locked -> idle
-> obtain fresh environment truth
-> reconsider automatic work
```

Explain precisely why that behavior cannot simply be copied for a human button press.

The key distinction should be examined:

```text
automatic intent
    system may reconsider from fresh truth later

human command
    intent occurred at a particular moment
    denial means that command did not execute
    replaying later changes command semantics
```

Answer:

> Is retaining/replaying the denied **Import My Messages** action ever justified?

Expected answer may be no, but prove it from interaction semantics.

---

## 4. Inventory realistic competing owners

Using the current coordinator operation list, determine which real production operations could hold authority when **Import My Messages** is pressed.

For each realistic owner ask:

- could the human already see that operation?
- could it be background work?
- could it last long enough for denial to be perceptible?
- would its completion naturally cause the readiness UI to change?
- could it itself be incompatible with initial setup being offered?

This is not an invitation to redesign those operations.

The purpose is to understand what “busy” may mean to the human.

---

## 5. Determine whether proactive button disabling is possible

Audit whether the UI can already observe:

```text
ArchiveMutationCoordinatorState.isLocked
```

before the person presses **Import My Messages**.

Consider a design such as:

```text
coordinator locked
-> disable Import My Messages
```

Assess:

- truthfulness;
- whether disabled state explains itself;
- accessibility;
- whether the lock may belong to the same/nested owner;
- whether normal race conditions still permit denial after the button was enabled;
- whether watching coordinator state would unnecessarily couple presentation to mutation machinery.

Important:

> A proactive disabled button cannot eliminate the race between rendering “enabled” and admission.

Therefore even if disabling is useful, determine what still happens on an actual denial.

Do not implement.

---

## 6. Audit possible feedback philosophies

Compare at least these models.

### A. Silent no-op

```text
press Import My Messages
-> busy denial
-> screen stays unchanged
```

Assess whether the human can reasonably infer that nothing started.

### B. Stable failure surface

```text
MessageLens couldn't finish setup
```

Assess whether this is false because setup never began.

### C. Transient busy acknowledgement

Conceptually:

```text
MessageLens is busy with another task. Please try again in a moment.
```

or equivalent.

Assess whether this accurately communicates:

- request did not start;
- nothing failed;
- human may try again.

### D. Disabled action while known busy + denial fallback

```text
known busy
-> button unavailable

race-time denial
-> brief truthful acknowledgement
```

Assess whether combining proactive prevention with a race-safe fallback is justified.

### E. Automatically retry when coordinator becomes idle

Evaluate and likely reject unless code/interaction semantics provide compelling evidence.

For each philosophy assess:

- truthfulness;
- cognitive load;
- action clarity;
- race safety;
- architecture leakage;
- implementation burden.

Recommend one philosophy.

---

## 7. Determine the correct duration of feedback

If transient feedback is recommended, determine conceptually whether it should be:

```text
snackbar
inline ephemeral message
temporary button state
modal alert
stable Gate status
```

Do not choose based on aesthetics alone.

Ask:

- Does the human need to make a new decision?
- Is the underlying condition expected to change independently?
- Must the message survive navigation?
- Does retry require another explicit button press?
- Would a modal interrupt another legitimate operation unnecessarily?

Determine whether a new `OnboardingStatus` is earned.

Strong presumption:

```text
busy contention is a transient command outcome,
not durable workflow state
```

but verify.

---

## 8. Audit existing project feedback conventions

Search current application code for existing handling of:

- mutation-busy denial;
- operation already in progress;
- temporarily unavailable actions;
- snackbars/toasts;
- disabled destructive actions;
- retry-after-busy messaging.

Prefer an established application convention if one exists and is semantically appropriate.

Do not force reuse merely for visual consistency if its semantics differ.

Document any useful precedent.

---

## 9. Determine whether coordinator owner labels belong in human UI

Coordinator state may expose human-oriented owner labels.

Assess whether busy feedback should say:

```text
MessageLens is busy with another task.
```

versus something specific like:

```text
MessageLens is currently updating attachments.
```

Ask:

- are owner labels stable product vocabulary?
- are all labels suitable for production users?
- would specificity change what the person does?
- would exposing owner identity leak architecture?

Unless specificity changes the human action, prefer phase-neutral wording.

Do not create a translation taxonomy for coordinator owners.

---

## 10. Audit race behavior

The solution must handle these cases.

### Lock becomes active after rendering

```text
button appears enabled
-> another owner acquires mutation authority
-> human clicks
-> admission denied
```

Feedback must still work.

### Owner releases immediately after denial

The message must not claim MessageLens remains busy indefinitely.

If the human immediately retries, admission may succeed.

### Another owner acquires after first release

A second human retry may also be denied.

No automatic command replay.

### Gate/UI disposed after click

No orphan feedback should be projected into unrelated UI.

### Environment changes while busy

A later manual retry must use the ordinary setup entry point and current prerequisites, not stale readiness assumptions.

---

## 11. Retry semantics

Establish the desired semantics after busy feedback.

Likely:

```text
busy denial
-> tell human request did not start
-> human chooses Import My Messages again later
-> ordinary startImportAndGraphBuild()
-> fresh coordinator admission
-> fresh FDA guard
-> ordinary preparation lifecycle
```

No retry callback should be retained.

No automatic click should occur when the coordinator becomes idle.

No “pending setup” Boolean.

---

## 12. Determine whether Environment Readiness should remain unchanged

After busy denial, durable environment truth has not changed on behalf of the denied request.

Ask whether the correct underlying screen therefore remains:

```text
readyToImport
```

with **Import My Messages** still available once the transient acknowledgement passes.

If yes, this supports treating busy as command feedback rather than Gate workflow state.

Do not invalidate environment merely to manufacture UI change.

---

## 13. Audit the production overlay path separately

If **Import My Messages** or equivalent can be invoked from both:

- Environment Readiness panel; and
- blocking Onboarding overlay,

determine whether the same feedback mechanism naturally reaches both.

Avoid two independent busy-message implementations if one action layer can own the result.

But do not move general presentation responsibilities into `OnboardingGate` merely for reuse.

Identify the cleanest seam:

```text
Gate returns/throws typed outcome
action wrapper translates it
presentation shows transient feedback
```

or whatever current architecture actually supports.

---

## 14. Audit exception ownership

Current busy outcome is represented by:

```text
ArchiveMutationDeniedException
```

Determine whether callers should:

- catch this exact coordinator exception;
- receive a narrower Onboarding action outcome;
- have `OnboardingGate` swallow and project something;
- use existing coordinator-state knowledge instead.

Assess coupling carefully.

Question:

> Should an ordinary UI callback need to understand `ArchiveMutationCoordinator` terminology?

Prefer semantic boundaries over convenient exception catching if a small existing application seam already supports them.

Do not create a large result hierarchy.

---

## 15. Determine whether a typed start outcome is earned

Consider whether:

```text
Future<void> startImportAndGraphBuild()
```

is still the right contract if “busy/not started” is an expected operational result rather than an exceptional bug.

Possible conceptual alternative:

```text
StartSetupResult.started
StartSetupResult.busy
```

But assess whether such a type would be over-architecture.

Ask:

- Does the caller genuinely need to distinguish an expected contention outcome?
- Are there multiple production callers that need the same handling?
- Would catching `ArchiveMutationDeniedException` leak coordinator mechanics?
- Would a two-case result make the contract more truthful?

Do not implement a result type in this audit.

---

## 16. Keep `preparationFailed` narrow

Slice 50 must remain:

```text
admitted reset failure
or exceptional non-contention admission failure
-> preparationFailed
```

Do not route busy contention there simply to obtain an existing UI.

The settled failure copy:

```text
MessageLens couldn't finish setup
```

is not truthful when setup never started.

Record this explicitly.

---

## 17. FDA behavior remains separate

If FDA is false after successful mutation admission:

```text
-> awaitingFda
```

That existing path remains correct.

Busy feedback should not mention permissions.

Do not alter the cached-FDA concern in this slice.

---

## 18. Attachment-preservation check

Busy denial performs no reset and no file mutation.

Any eventual manual retry continues through the same existing setup/reset path.

Do not change:

- reset allow-list;
- attachment archival;
- source databases;
- preservation-data handling.

No attachment-specific UI is needed for a request that never started.

---

## 19. Human truth budget

Produce:

### WE MAY TRUTHFULLY SAY

Concepts to verify:

```text
MessageLens could not start setup because another operation is using the data right now.
Nothing from this setup request started.
The person can try again.
```

Do **not** necessarily use all of these in final UI.

### WE MUST NOT IMPLY

```text
setup failed
preparation failed
data was changed
reset failed
the request is queued
setup will begin automatically later
the user must restart MessageLens
the competing operation caused a problem
```

---

## 20. Decide the minimum ordinary message

Recommend the smallest human-facing concept.

Potential shape:

```text
MessageLens is busy with another task. Please try again in a moment.
```

But inspect project tone and current UI before settling wording.

Ask whether “in a moment” is supportable for potentially long operations.

A safer concept may be:

```text
MessageLens is busy with another task. Please try again when it finishes.
```

But that assumes the human knows when “it” finishes.

Perhaps simply:

```text
MessageLens is busy with another task. Please try again.
```

Derive the recommendation rather than accepting these examples.

---

## 21. Determine whether button disabling adds value

Conclude one of:

```text
disable Import My Messages while coordinator is known locked,
plus retain denial feedback for races
```

or:

```text
leave button enabled and handle actual contention only
```

or another evidence-based result.

Consider whether a disabled primary action with no explanation is worse than an enabled action that gives a precise transient response.

Do not implement.

---

## 22. Determine the correct owner

Choose among:

```text
OnboardingGate
    owns setup orchestration

Onboarding action/provider layer
    owns translation of command outcome

Presentation
    owns transient human feedback

ArchiveMutationCoordinator
    owns only mutation authority
```

Recommend where the busy semantic should be translated and where it should be rendered.

Do not make the coordinator produce onboarding copy.

---

## 23. Testing strategy for eventual implementation

Identify focused tests for the recommended design.

At minimum cover:

### Explicit request while busy

```text
coordinator locked
-> user presses Import My Messages
-> reset count == 0
-> controller count == 0
-> no preparationFailed
-> truthful busy feedback appears
```

### No replay

Release coordinator.

Prove setup does not start automatically.

### Explicit second attempt

Press Import My Messages again after release.

Prove the ordinary setup lifecycle starts exactly once.

### Race

Button is initially usable, another owner acquires before admission.

Prove busy feedback still appears.

### Non-contention admission exception

Must retain Slice 50 behavior if that path is currently classified as `preparationFailed`, or document any caller-specific distinction discovered.

### FDA false

Still reaches existing FDA presentation, not busy feedback.

### Controller failure

Still reaches settled stable setup failure.

### No persistence

Busy outcome is not reconstructed after restart.

Do not write tests in this audit.

---

## 24. Determine whether Settings or other explicit mutation actions belong here

Other user-triggered operations may also suffer busy denial.

Do not broaden this audit automatically.

Record whether the eventual mechanism could be reusable, but keep the next implementation slice scoped to initial setup unless sharing is mechanically unavoidable.

No general “operation busy framework.”

---

## 25. Presence verdict

Explicitly determine whether any of this belongs in Presence.

Expected:

```text
No.
```

This is the result of an Onboarding operational command trying to acquire archive mutation authority.

Presence should remain blissfully ignorant.

---

## 26. Recommend exactly one next implementation slice

Choose one bounded correction.

Possible result:

> Translate ordinary mutation contention from `startImportAndGraphBuild()` into a non-persisted, human-readable busy outcome at the Onboarding action/presentation seam; leave the readiness state intact and require a fresh explicit click to retry.

But derive it from code.

Use:

```text
Next concern:
Why it comes next:
Current defect:
Smallest implementation:
Owner:
Gate/API changes:
Presentation changes:
New state required:
Persistence impact:
Automatic replay:
Coordinator changes:
Reset impact:
Attachment-preservation impact:
Race handling:
Test seam:
```

Do not bundle unrelated busy handling for Settings, automatic recovery, or other features.

---

## 27. Documentation output

Create:

`53-USER-INITIATED-SETUP-MUTATION-BUSY-FEEDBACK-AUDIT.md`

Include:

1. exact production initiation paths;
2. busy-denial truth;
3. automatic-vs-human intent distinction;
4. competing owners;
5. proactive-disable analysis;
6. feedback philosophy comparison;
7. feedback-duration/state verdict;
8. existing UI convention audit;
9. owner-label verdict;
10. race analysis;
11. retry semantics;
12. Environment Readiness behavior;
13. overlay/panel comparison;
14. exception/API ownership;
15. typed-outcome verdict;
16. `preparationFailed` separation;
17. FDA separation;
18. attachment-preservation verification;
19. truth budget;
20. recommended copy concept;
21. button-disable verdict;
22. ownership verdict;
23. test strategy;
24. exactly one next implementation slice.

Update:

- package `00-START-HERE.md`
- Feature Addition `INDEX.md`
- `DOCUMENTATION_PASS_LOG.md`

Do not modify application code.

---

# Hard constraints

Do not:

- implement busy feedback;
- automatically replay **Import My Messages**;
- add timers or polling;
- add a mutation queue;
- add persistent pending setup state;
- route busy denial to `preparationFailed`;
- change automatic-recovery deferral;
- change mutation policy;
- change reset behavior;
- change FDA behavior;
- address the cached-FDA concern;
- build a generic busy-notification framework;
- change Settings behavior;
- modify Presence;
- touch attachment archival.

# Success criterion

At the end of the audit we should be able to complete:

> **When the user presses Import My Messages while mutation authority is busy, MessageLens should **\_\_\_\_**. The denied command should **\_\_\_\_**. The underlying readiness state should **\_\_\_\_**. Retry should occur only when **\_\_\_\_**.**

The ideal behavior should make the distinction obvious:

```text
human presses Import My Messages
        ↓
mutation lane occupied
        ↓
setup did NOT start
        ↓
acknowledge that fact calmly
        ↓
retain no command
        ↓
human chooses whether/when to press again
```

No fake failure. No invisible no-op. No delayed surprise import.
