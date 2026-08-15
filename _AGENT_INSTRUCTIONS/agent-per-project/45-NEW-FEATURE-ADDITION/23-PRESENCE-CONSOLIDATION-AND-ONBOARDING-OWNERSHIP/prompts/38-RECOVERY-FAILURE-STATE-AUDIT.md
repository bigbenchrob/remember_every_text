Yes. The next task should be an **analysis-only audit of failures around recovery itself**—especially reset failure and mutation-admission failure—because those are no longer presentation-polish questions. They are missing operational outcomes.

The active recovery surface is now intentionally simple and truthful, while reset failure and admission denial still retain their old behavior. 39\-CALM\-TRUTHFUL\-AUTOMATIC\-RECOVERY\-COPY\-IMPLEMENTATION.md

Perform an **analysis-only audit** of the operational failure states that occur outside the successfully handled Conversation Graph controller failure path.

**This prompt is authorization to perform the audit. Do not stop to ask for plan confirmation.**

Read first:

- `21-INITIAL-IMPORT-GRAPH-BUILD-LIFECYCLE-AUDIT.md`
- `25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md`
- `26-PRE-RESET-PREPARATION-PROGRESS-IMPLEMENTATION.md`
- `27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md`
- `30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md`
- `37-AUTOMATIC-RECOVERY-PRESENTATION-AUDIT.md`
- `38-REMOVE-AUTOMATIC-RECOVERY-DIAGNOSTIC-REASON-IMPLEMENTATION.md`
- `39-CALM-TRUTHFUL-AUTOMATIC-RECOVERY-COPY-IMPLEMENTATION.md`
- current `OnboardingGate`
- current `ArchiveMutationCoordinator`
- current `MessageDataResetService`
- current Environment Readiness classification
- current failure persistence
- current relevant Onboarding tests

Use current code as source of truth.

Do not implement code.

Do not add Gate states.

Do not add failure persistence.

Do not change reset.

Do not change mutation coordination.

Do not change Presence.

The purpose of this audit is to answer:

> **When setup preparation or automatic recovery cannot complete before the main build even begins, what distinct operational truths exist, and what is the smallest correct human-facing state model for them?**

---

## 1. Scope the failure family precisely

Audit failures that occur **outside** the normal caught controller/build failure path.

At minimum include:

```text
first-run mutation admission denied
first-run mutation admission throws for another reason
FDA guard blocks setup
first-run reset throws

automatic-recovery mutation admission denied
automatic-recovery admission throws for another reason
automatic-recovery reset throws

direct-reimport reset throws
Reset Message Data operation fails
```

Do not assume these are one failure class.

For each, determine whether:

- work actually began;
- derived data may already have changed;
- the failure is transient or durable;
- retry is immediately safe;
- recovery can be reattempted;
- a user action is required.

---

## 2. Separate denial from failure

Establish a clear distinction between:

```text
operation was NOT admitted
```

and:

```text
operation WAS admitted but failed
```

For example:

```text
mutation denied
    -> no reset happened

reset throws after admission
    -> some provider closes/deletions may already have occurred
```

These are mechanically different and must not be collapsed merely because both currently end up back at `awaitingUserAction`.

Document the human consequence of each.

---

## 3. Audit first-run mutation-admission denial

Trace:

```text
Import My Messages
-> OnboardingGate.startImportAndGraphBuild()
-> ArchiveMutationCoordinator.run()
-> admission denied
```

Determine:

- exact exception;
- who catches it;
- whether the button callback observes it;
- whether Gate state changes;
- whether any overlay appears;
- whether the existing readiness surface remains active;
- whether retry is naturally possible later;
- whether any human-facing message exists.

Answer:

> Is this actually a setup failure, or merely “MessageLens is busy and could not start this operation yet”?

Do not invent a message.

---

## 4. Audit first-run reset failure

Trace the now-current sequence:

```text
admission succeeds
-> FDA guard succeeds
-> Preparing setup… appears
-> resetDerivedData()
-> reset throws
```

Document:

- what reset may already have completed before throwing;
- which files/providers may have changed;
- what the Gate does now;
- what environment invalidation occurs;
- what the user sees afterward;
- whether the original error remains only in logs/Future failure;
- whether a retry button is naturally available.

The recent implementation deliberately restores readiness and rethrows rather than inventing a failure state. Verify whether that is sufficient or whether it creates a misleading “nothing happened” loop.

---

## 5. Audit automatic-recovery admission denial

Trace:

```text
recoveringFailedAttempt presentation appears
-> mutation admission denied
```

Determine:

- whether the user can briefly see recovery before no reset happens;
- whether the recovery overlay disappears;
- what state is shown next;
- whether the Gate immediately retries later;
- whether repeated presentation flashes are possible;
- what the coordinator logs.

Answer:

> Is this a failure requiring explanation, or simply a deferred automatic operation?

---

## 6. Audit automatic-recovery reset failure

Trace:

```text
automatic recovery admitted
-> resetDerivedData()
-> reset throws
```

Determine:

- whether partial deletion may have occurred;
- what Gate flags are set;
- whether automatic recovery is suppressed;
- what UI replaces recovery;
- whether the reset error is persisted;
- whether the old pipeline failure remains;
- whether another launch may trigger recovery again;
- whether manual retry will run reset again.

This is one of the central cases.

---

## 7. Audit direct-reimport reset failure

Trace `startReimport()` separately.

Determine:

- whether it has the same protection as first-run;
- whether its reset runs before any progress state;
- who catches failure;
- what the user sees;
- whether its current lack of production callers affects priority.

Do not propose fixing dormant/development-only behavior unless it affects production architecture.

---

## 8. Audit Reset Message Data failure

Trace the production Settings journey that explicitly resets derived data.

Determine:

- confirmation flow;
- mutation admission;
- reset call;
- failure behavior;
- whether a human-facing error exists;
- whether the operation may leave partially deleted derived stores;
- what happens on next launch.

Compare it to first-run reset failure.

This may provide a second concrete case that helps define a generic reset-failure outcome.

---

## 9. Identify shared mechanical properties

Build a comparison table for:

```text
first-run reset failure
automatic-recovery reset failure
explicit Reset Message Data failure
direct-reimport reset failure
```

Compare:

- same specialist (`MessageDataResetService`)?
- same destructive allow-list?
- mutation owner/admission?
- possibility of partial durable mutation?
- exception shape?
- persistence?
- retry semantics?
- next environment probe?
- human action afterward?

Then answer:

> Are these genuinely instances of one missing “derived-store reset failed” operational truth?

or:

> Are they different enough that they must remain contextual?

Do not generalize without evidence.

---

## 10. Keep attachment preservation central

For every reset-failure path, verify that even partial failure cannot broaden deletion beyond the explicit allow-list.

Reconfirm:

```text
Apple Messages
Apple Contacts
locally available source attachment payloads
archived attachment payloads
overlay/user intent
preferences
```

remain outside the reset target set.

If any failure path can inadvertently touch the attachment archive, **stop immediately and report before continuing the audit**.

---

## 11. Determine what durable evidence exists after reset failure

Inventory what survives:

```text
filesystem state
missing/present derived DBs
remaining SQLite sidecars
environment report probes
existing pipeline failure record
logs
mutation-coordinator diagnostics
```

For each, state what it can prove.

Ask:

> Does MessageLens need a new persisted reset-failure record for correctness?

or:

> Can existing file/probe truth remain the durable authority while a human-facing process-local failure state handles the current launch?

Do not add persistence.

---

## 12. Audit current error propagation

For each audited operation, document whether errors are:

```text
caught and presented
caught and logged only
re-thrown
lost through unawaited UI Future
persisted
used only to change environment state
```

Pay special attention to button callbacks that discard returned Futures.

Identify any cases where a real failure becomes effectively invisible to the human.

---

## 13. Distinguish operation failure from environment result

A reset operation may fail, yet the resulting filesystem state may later classify as:

```text
readyToImport
graph failure
recovery needed
ready
```

depending on what was deleted before failure.

Document this distinction.

The operational truth:

```text
reset operation failed
```

is not necessarily identical to the later environmental truth:

```text
these files currently exist / do not exist
```

Ask whether the UI needs both.

---

## 14. Define the minimum human contract

For each genuinely user-visible operational failure, determine what the person needs to know.

Possible generic questions:

```text
Did MessageLens finish preparing?
Can I try again?
Is MessageLens still doing something?
Do I need to quit/restart?
Do I need to change permissions?
```

Avoid implementation language.

Possible conceptual message:

```text
MessageLens couldn't finish preparing for setup.
You can try again.
```

But do not choose final wording yet.

---

## 15. Determine whether a new Gate state is actually necessary

Evaluate whether current states can represent reset failure truthfully.

Options might include:

### A. Return to awaitingUserAction with derived presentation

Current behavior.

### B. Reuse existing stable setup-failure surface

Could be tempting, but current persistence semantics refer to caught controller failure, not reset failure.

### C. Add a narrow process-local reset/preparation failure status

Would explicitly preserve the operation outcome in the current process.

### D. Let Environment Readiness derive a distinct surface from durable file facts only

No process-local operation-failure identity.

Evaluate truthfulness and reconciliation costs.

Do not implement any.

Conclude which shape is smallest and correct.

---

## 16. Assess whether failure persistence is earned

Ask:

> Does a reset failure need to survive restart as “reset failed”?

Consider:

- restart probes the resulting files;
- retry always performs reset again;
- logs retain technical error evidence;
- no resume semantics exist.

Conclude one of:

```text
Durable reset-failure persistence is NOT earned.
```

or:

```text
Durable reset-failure persistence is required because...
```

Do not create it.

---

## 17. Evaluate whether one generic failure surface can serve reset failure

Compare the settled stable build-failure surface:

```text
MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data.
You can try again.
```

against reset-failure truth.

Would that wording be truthful if preparation failed before the build started?

Probably perhaps yes, but test carefully.

Ask:

- would retry action semantics be correct?
- would support reporting contain the right evidence?
- would existing failure persistence incorrectly claim graph failure?
- can the UI show the same copy without reusing the wrong persistence bucket?

Separate **shared presentation** from **shared storage classification**.

---

## 18. Mutation-admission denial may deserve no failure UI

Evaluate admission denial separately.

If no destructive operation began and another operation simply owns the resource, perhaps the truthful behavior is:

```text
remain on current screen
allow later retry
optionally indicate temporarily busy
```

rather than a failure screen.

Assess based on current product behavior and likelihood.

Do not conflate “couldn't start yet” with “started and failed.”

---

## 19. Automatic-recovery failure may deserve different handling

Because automatic recovery is non-interactive, a reset failure there could produce:

```text
recovery stopped
-> return to stable failure
-> allow manual Try Again
```

or perhaps a specific human-visible failure.

Determine what current mechanics support.

Ask whether the user needs to know:

> automatic cleanup itself failed

or merely:

> setup still isn't ready; Try Again / Send Report.

Do not invent a new surface unless it changes the supported action.

---

## 20. Compare three state-model philosophies

### A. Environment-only

No explicit reset-failure state.

After failure:

```text
invalidate
-> probe files
-> show whatever environment says
```

Pros:

- minimal state.

Cons:

- operation failure may disappear from human experience.

### B. Process-local preparation failure

Record in Gate only:

```text
preparationFailed
```

for current process, with calm retry UI.

Pros:

- acknowledges real operation failure;
- no new durable state.

Cons:

- another Gate status;
- restart forgets it.

### C. Durable reset failure

Persist reset failure and classify it later.

Pros:

- survives restart.

Cons:

- new persistence authority/reconciliation burden.

Assess each against actual evidence.

Recommend one, but do not implement.

---

## 21. Revisit `ActionStep` only if evidence demands it

These failures are still inside Onboarding operational coordination.

Do not use this audit as a pretext for moving reset into Presence.

Explicitly conclude whether any of this earns:

```text
ActionStep
OperationStep
RecoveryStep
```

Expected answer may remain no.

Explain why.

---

## 22. Produce an operational failure matrix

Create a compact matrix:

| Case                    | Work admitted? | Durable mutation may have started? | Current human feedback    | Retry         | Needs distinct state? |
| ----------------------- | -------------: | ---------------------------------: | ------------------------- | ------------- | --------------------- |
| Admission denied        |                |                                    |                           |               |                       |
| FDA blocked             |                |                                    |                           |               |                       |
| First-run reset failure |                |                                    |                           |               |                       |
| Recovery reset failure  |                |                                    |                           |               |                       |
| Explicit reset failure  |                |                                    |                           |               |                       |
| Controller failure      |            yes |                                yes | settled stable failure UI | clean rebuild | existing              |

This should make the missing state obvious if there is one.

---

## 23. Recommend exactly one next implementation slice

Choose the single highest-value bounded correction.

Potential outcomes:

```text
add a process-local preparation/reset-failure Gate state

surface unhandled reset error through existing awaitingUserAction presentation

handle the Import My Messages Future so reset/admission failure is visible

something smaller discovered in code
```

Choose one only.

Use:

```text
Next concern:
Why it comes next:
Current defect:
Smallest implementation:
Owner:
Gate changes:
Persistence impact:
Reset impact:
Recovery impact:
Attachment-preservation impact:
Presentation impact:
Test seam:
```

---

## 24. Documentation output

Create:

`40-RECOVERY-AND-PRE-BUILD-FAILURE-STATE-AUDIT.md`

If document 40 is occupied, use the next free number and proceed without asking for confirmation.

Include:

1. failure-family inventory;
2. denial-vs-failure distinction;
3. first-run admission audit;
4. first-run reset failure;
5. automatic-recovery denial;
6. automatic-recovery reset failure;
7. direct-reimport failure;
8. explicit Reset Message Data failure;
9. shared mechanical properties;
10. attachment-preservation verification;
11. durable evidence;
12. error-propagation audit;
13. environment-vs-operation truth;
14. minimum human contract;
15. state-model options;
16. persistence verdict;
17. generic-surface fit;
18. admission-denial verdict;
19. automatic-recovery-failure verdict;
20. ActionStep verdict;
21. operational failure matrix;
22. exactly one next slice.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

Do not alter application code.

---

# Hard constraints

Do not:

- implement UI changes;
- add Gate states;
- add persisted failure records;
- change reset behavior;
- change mutation coordination;
- change recovery policy;
- modify environment heuristics;
- change support reporting;
- modify Presence;
- add ActionStep;
- change attachment archival;
- run destructive work against production data.

This is analysis only.

If any current production path appears capable of deleting the attachment preservation archive, **stop immediately and report that safety issue before proceeding further.**

---

# Success criterion

At the end of the audit, we should be able to answer:

> **There are **\_\_** distinct pre-build/recovery failure truths. The human-facing gap that matters next is **\_\_**. The smallest correct state/presentation treatment is **\_\_**.**

The audit should tell us whether we truly have a missing operational state—or merely an error-handling hole that can be fixed without adding one.
