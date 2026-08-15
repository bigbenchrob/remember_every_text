The next step should be an **analysis/design audit of automatic recovery presentation only**. We have deliberately finished the stable failure surface; now we should ask what the human needs to see while MessageLens is automatically cleaning up incomplete rebuildable browsing data.

Perform an **analysis/design audit only** of the production automatic-recovery presentation used after MessageLens detects incomplete derived browsing data from a failed or interrupted setup attempt.

**This prompt is authorization to perform the audit. Do not stop to ask for plan confirmation.**

Read first:

- `27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md`
- `30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md`
- `33-FAILURE-DIAGNOSTIC-INFORMATION-HIERARCHY-AUDIT.md`
- `34-REMOVE-WHAT-TO-CHECK-STABLE-FAILURE-IMPLEMENTATION.md`
- `35-REMOVE-ENVIRONMENT-SUMMARY-STABLE-FAILURE-IMPLEMENTATION.md`
- `36-REMOVE-SUPPORT-TRANSPORT-CAPTION-STABLE-FAILURE-IMPLEMENTATION.md`
- current `OnboardingGate` automatic-recovery path
- current `MessageDataResetService`
- current Environment Readiness recovery classification
- current recovery presentation/widget
- current `resetAppDatabasesReason` generation
- current automatic-recovery tests

Use current code as source of truth.

Do not implement code.

Do not change recovery mechanics.

Do not change reset semantics.

Do not change persistence.

Do not change Presence.

The purpose of this audit is to answer:

> **While MessageLens is automatically cleaning up incomplete rebuildable browsing data, what does the human actually need to know, and which recovery diagnostics belong outside ordinary reading order?**

---

## 1. Trace the exact automatic-recovery path

Start from the environment facts that cause automatic recovery to be selected.

Trace:

```text
environment probes
    -> recovery classification
    -> OnboardingGate
    -> recoveringFailedAttempt
    -> mutation admission
    -> MessageDataResetService.resetDerivedData()
    -> recovery completion/failure
    -> environment re-evaluation
    -> next visible state
```

Document:

- exact provider/state transitions;
- when the recovery overlay becomes visible;
- when mutation authority is acquired;
- when reset begins;
- what happens after success;
- what happens after failure;
- what is durable versus process-local.

---

## 2. Define what automatic recovery actually means

In ordinary language first, establish the mechanical truth.

Determine whether the most accurate description is essentially:

> MessageLens found signs that its rebuildable browsing data is incomplete, so it is removing those incomplete derived stores before allowing setup to be tried again.

Verify that against code.

Be explicit that automatic recovery does **not** mean:

```text
repairing Apple Messages
restoring attachments
resuming the failed import
continuing from the failed stage
deleting all MessageLens data
automatically rerunning setup
```

unless code actually proves otherwise.

---

## 3. Inventory everything currently visible

Record the exact current recovery presentation, including:

- heading;
- explanatory paragraph;
- progress indicator;
- `resetAppDatabasesReason`;
- any bordered diagnostic card;
- any buttons or actions;
- any completion transition;
- any failure transition.

Record exact wording where useful.

---

## 4. Audit the heading

Current wording includes:

```text
Cleaning Up A Previous Setup Attempt
```

Assess:

- Is “previous” always truthful?
- Does the code know that the incomplete state came from a prior process/launch?
- Could automatic recovery be triggered during the same launch after a caught failure?
- Does “cleanup” accurately convey the human-level operation?
- Does it sound destructive or alarming?

Evaluate alternatives conceptually, such as:

```text
Preparing MessageLens to try again
Cleaning up incomplete browsing data
Getting MessageLens ready to try again
```

Do not choose wording for aesthetics alone.

---

## 5. Audit the explanatory paragraph

Current wording has included a shape like:

```text
MessageLens detected signs that an earlier setup attempt left incomplete local
data. It is clearing that data now so setup can restart cleanly.
```

Audit every claim:

### “earlier setup attempt”

Is that always supported?

### “incomplete local data”

Is it precise enough, or could it sound like source/preservation data?

### “clearing that data”

Could a human reasonably interpret this as deleting:

- Apple Messages;
- Contacts;
- archived attachment payloads?

### “so setup can restart cleanly”

Does automatic recovery itself restart setup?

Or does it merely clean derived stores and return to a state where the human may start setup again?

Classify each clause:

```text
truthful
overbroad
unsupported
technically true but anxiety-inducing
```

---

## 6. Audit `resetAppDatabasesReason`

Trace where `resetAppDatabasesReason` comes from and every kind of value it can contain.

Likely examples may mention:

```text
import ledger
Conversation Graph
graph projection
message-row disparity
persisted failure
```

For each possible reason, ask:

- does it change what the human should do?
- is it necessary for reassurance?
- is it useful primarily for support?
- does it expose internal architecture?
- can it imply a false failed stage?
- can it muddy the attachment-preservation boundary?

Determine whether it deserves ordinary display.

---

## 7. Apply the same hierarchy rule used for stable failures

Use the settled principle:

> **Ordinary reading order should contain only information that changes the human's understanding or next action.**

For recovery, identify what the human actually needs.

Possible minimum:

```text
MessageLens noticed incomplete browsing data.
It is preparing a clean retry.
Please wait.
```

But derive the actual contract from code.

Classify each current visible item as:

```text
ORIENTATION
REASSURANCE
ACTION-CRITICAL
DIAGNOSTIC
IMPLEMENTATION DETAIL
REDUNDANT
```

---

## 8. Respect the attachment-preservation invariant

This section is mandatory.

Recovery/reset deletes only explicitly allowed **rebuildable MessageLens derived stores**.

It must not imply deletion of:

```text
Apple Messages chat.db
Apple Contacts databases
locally available source attachments
MessageLens archived attachment payloads
overlay/user intent
preferences
```

Review all current recovery wording against that distinction.

Prefer precise concepts such as:

```text
incomplete browsing data
rebuildable browsing data
local browsing stores
```

over broad phrases such as:

```text
your data
all local data
everything
starting from scratch
clearing MessageLens
```

Do not add a long preservation explanation to the UI unless the human actually needs it.

---

## 9. Audit recovery progress truth

Determine what the UI really knows while recovery is running.

Does it know only:

```text
recovery reset is in progress
```

or anything finer?

Confirm whether:

- percentage is unavailable;
- stage detail is unavailable;
- cancellation is unavailable;
- resume is unavailable.

Assess whether the current activity indicator is sufficient.

Do not add telemetry.

---

## 10. Audit what happens after successful recovery

Trace the exact next state after reset succeeds.

Does recovery:

```text
automatically restart setup
```

or:

```text
return to awaitingUserAction
-> environment re-evaluates
-> Import My Messages appears
```

Document this precisely.

Then assess whether current copy saying setup will “restart” is misleading.

The human-facing language must distinguish:

```text
MessageLens is making another setup attempt possible
```

from:

```text
MessageLens is automatically starting another setup attempt
```

---

## 11. Audit recovery failure

Trace what happens if automatic recovery reset itself throws.

Determine:

- who catches it;
- whether an error is persisted;
- what Gate state follows;
- whether automatic recovery is suppressed in the current process;
- what presentation appears next;
- whether the human ever sees the reset error;
- whether another launch may try recovery again.

Ask:

> Does the recovery surface need to explain failure, or is that a separate missing operational state?

Do not redesign it.

---

## 12. Audit mutation-admission denial

If automatic recovery cannot acquire mutation authority:

- what happens;
- what the user sees;
- whether recovery presentation briefly appears;
- whether it clears cleanly;
- whether another attempt is scheduled.

Do not change coordination.

---

## 13. Abrupt termination during recovery

If MessageLens quits/crashes while recovery reset is running:

- no durable recovery job state exists;
- partial deletion may remain;
- next launch reprobes.

Verify this.

Determine whether any current copy falsely implies recovery will resume.

Do not add durable recovery state.

---

## 14. Compare three recovery presentation philosophies

Evaluate:

### A. Diagnostic recovery

```text
Cleaning Up A Previous Setup Attempt

MessageLens detected a graph/import disparity...

Import ledger: ...
Conversation Graph: ...
[technical reset reason]
```

### B. Calm recovery

```text
Preparing MessageLens to try again

MessageLens found incomplete browsing data and is cleaning it up.

[indeterminate activity]
```

### C. Calm recovery + explicit preservation reassurance

```text
Preparing MessageLens to try again

MessageLens is removing incomplete browsing data.
Your original Messages and saved attachment archive are not part of this cleanup.

[indeterminate activity]
```

For each assess:

- truthfulness;
- cognitive load;
- reassurance;
- whether reassurance introduces unnecessary alarm;
- architectural leakage;
- implementation complexity.

Recommend one philosophy.

Be especially strict about whether option C solves a real human concern or merely introduces one by mentioning deletion.

---

## 15. Determine whether the diagnostic reason should remain visible

Conclude one of:

```text
resetAppDatabasesReason should remain in ordinary recovery UI
```

```text
resetAppDatabasesReason should move out of ordinary UI but remain diagnostic
```

or:

```text
a simplified human-safe recovery reason is worth retaining
```

If recommending a simplified reason, identify the exact useful distinction it communicates.

Do not invent a new reason taxonomy.

---

## 16. Determine whether the current heading/body need correction

Conclude whether:

```text
Cleaning Up A Previous Setup Attempt
```

and the current body are sufficiently truthful.

If not, identify the smallest truthful replacement concept.

Do not implement it.

---

## 17. Determine whether recovery needs any action

Ask whether the human should have:

```text
Cancel
Retry
Continue
Dismiss
```

while automatic recovery runs.

Given the current mechanics, expected answer may be:

```text
No; recovery is non-interactive.
```

But verify from code.

Do not introduce controls.

---

## 18. Produce the recovery truth budget

Create:

```text
WE MAY TRUTHFULLY SAY
```

and:

```text
WE MUST NOT IMPLY
```

Potential examples to verify:

### May say

```text
MessageLens found incomplete rebuildable browsing data.
MessageLens is cleaning up those derived stores.
The user should wait.
Another setup attempt can be offered afterward.
```

### Must not imply

```text
Apple Messages is being altered.
Archived attachments are being deleted.
Every attachment is preserved.
Setup is automatically restarting.
Recovery resumes the interrupted operation.
The exact failed stage is known.
All MessageLens data is being cleared.
```

---

## 19. Determine whether support diagnostics already preserve recovery evidence

Identify where recovery/probe reasoning exists outside UI:

- logs;
- environment report;
- database health;
- support bundle;
- reset reason;
- mutation diagnostics.

Ask:

> If `resetAppDatabasesReason` disappeared from ordinary UI, would useful diagnostic evidence be lost?

If not, say so.

---

## 20. Recommend exactly one next implementation slice

Choose one bounded correction.

Candidates may include:

```text
remove resetAppDatabasesReason from ordinary recovery UI

replace broad recovery heading/body with calm browsing-data wording

remove unsupported previous-attempt language

something else discovered from code
```

Choose **one only**.

Use:

```text
Next concern:
Why it comes next:
Current defect:
Smallest implementation:
Owner:
Operation-layer changes:
Persistence impact:
Recovery-mechanics impact:
Attachment-preservation impact:
Presentation impact:
Test seam:
```

Do not bundle reason removal and copy redesign unless they are mechanically inseparable.

---

## 21. Layout assessment

Determine whether recovery currently has any overflow or density problem.

Do not solve geometry.

If removing diagnostic material would naturally simplify the surface, record that.

---

## 22. Presence assessment

Confirm whether Presence needs any change.

Expected:

```text
No.
```

Automatic derived-store recovery remains Onboarding/bootstrap operational behavior.

---

## 23. Documentation output

Create:

`37-AUTOMATIC-RECOVERY-PRESENTATION-AUDIT.md`

If document 37 is occupied, use the next free number and proceed without asking for confirmation.

Include:

1. exact recovery lifecycle;
2. current visible inventory;
3. heading audit;
4. body-copy audit;
5. reset-reason audit;
6. hierarchy classification;
7. attachment-preservation check;
8. progress truth;
9. success transition;
10. recovery-failure behavior;
11. admission-denial behavior;
12. abrupt-termination behavior;
13. three philosophy comparison;
14. diagnostic-reason verdict;
15. recovery truth budget;
16. diagnostic-retention analysis;
17. exactly one next slice;
18. layout verdict.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

Do not alter application code.

---

# Hard constraints

Do not:

- implement UI changes;
- change reset;
- change automatic-recovery policy;
- change mutation admission;
- add cancellation;
- add progress telemetry;
- add durable recovery state;
- change environment classification;
- change attachment archive behavior;
- modify Presence;
- create a new recovery taxonomy;
- redesign failure screens.

This is analysis/design only.

---

# Success criterion

At the end of the audit, we should be able to answer:

> **While automatic recovery runs, the human needs to know **\_\_\_\_**. The diagnostic reason for recovery belongs **\_\_\_\_**. The next smallest correction is **\_\_\_\_**.**

The recovery surface should eventually explain a safe, non-interactive cleanup of **rebuildable browsing data** without making the human understand import ledgers, graph projection, row-count heuristics, or the internal reset machinery.

That should let us simplify recovery with the same discipline we used for failure: human truth first, diagnostic evidence elsewhere.
