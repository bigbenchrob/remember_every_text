Ready. This should be the **failure/recovery presentation audit**, and I’d make one thing explicit at the top so Codex doesn’t ask you for another ceremonial sign-off:

> **This prompt is authorization to perform the audit. Do not stop to ask for plan confirmation.**

Perform an **analysis/design audit only** of the production failure and recovery experience for initial MessageLens setup.

**This prompt is authorization to perform the audit. Do not stop to ask for plan confirmation.**

Read first:

- `21-INITIAL-IMPORT-GRAPH-BUILD-LIFECYCLE-AUDIT.md`
- `23-PRODUCTION-IMPORT-PROGRESS-SURFACE-AUDIT.md`
- `26-PRE-RESET-PREPARATION-PROGRESS-IMPLEMENTATION.md`
- `27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md`
- `28-INITIAL-SETUP-COMPLETION-SURFACE-AUDIT.md`
- `29-CALM-INITIAL-SETUP-COMPLETION-HANDOFF-IMPLEMENTATION.md`
- current `OnboardingGate`
- current Environment Readiness failure/recovery presentation
- current `OnboardingFailureStore`
- current automatic-recovery logic
- current `ConversationGraphBuildController` failure behavior
- current `MessageDataResetService` failure behavior
- current report-to-developer / diagnostic export behavior

Use current code as source of truth.

Do not implement code.

Do not change failure mechanics.

Do not change recovery policy.

Do not change import/build behavior.

Do not change Presence.

The purpose of this audit is to answer:

> **When initial setup fails, what does the human actually need to know and do, and how much of the current technical failure information belongs in the primary UI?**

---

## 1. Trace every real failure path

Start from:

```text
Import My Messages
```

and identify every materially different failure boundary through setup and recovery.

At minimum inspect:

```text
mutation admission failure
FDA readiness failure before reset
derived-data reset failure
controller/service-resolution failure
source-import-stage failure
text-enrichment failure
join/import failure
graph-projection-stage failure
abrupt quit/crash
automatic-recovery reset failure
```

For each, record:

```text
where failure originates
where it is caught
what gets persisted
what Gate state results
what environment facts result
what the human sees
whether retry is possible
whether retry resumes or rebuilds
```

Do not collapse mechanically different failures merely because the current UI does.

---

## 2. Inventory every current failure/recovery surface

Record the exact current visible content for stable production states, including where applicable:

- heading;
- explanatory paragraph;
- diagnostic notes;
- raw error text;
- timestamp;
- reset/recovery reason;
- retry button;
- report-to-developer action;
- recovery progress presentation.

Identify actual wording from code.

Also identify any transient failure presentation that may appear briefly before the stable failure surface.

---

## 3. Audit the transient raw-error headline

Prior audits found that when `ConversationGraphBuildController` briefly enters `failed`, the active progress widget may display raw `lastError` as the headline before `OnboardingGate` completes its failure handoff.

Verify this precisely.

Answer:

- Can an ordinary user actually see it?
- For how long / under what rebuild timing?
- Is it bounded or potentially arbitrarily technical?
- Can it contain filenames, SQLite messages, stack-like implementation terminology, or other developer-facing detail?
- Does it help the human make any decision?

Conclude whether raw error text belongs at headline level.

Do not change it in this audit.

---

## 4. Audit persisted failure classification

The earlier lifecycle audit found that all errors caught around the controller lifecycle are persisted through a coarse **graph projection failure** mechanism, even when the originating exception occurred during a source-import stage.

Verify current behavior.

For each orchestrator stage category:

```text
source import
text enrichment
joins
graph projection
post-build/controller work
```

determine what durable failure classification is recorded.

Answer:

> What does the persistent failure record actually prove?

and:

> What does it not prove?

Do not invent a richer taxonomy yet.

---

## 5. Audit potentially false explanatory copy

Inspect wording equivalent to:

```text
MessageLens imported source data, but could not finish preparing it...
```

or any other copy that assumes a particular phase completed before failure.

Compare that wording against actual catch semantics.

If a failure can occur during the source-import stages themselves, determine whether this wording is always truthful.

Classify each failure explanation as:

```text
always truthful
truthful only for some failures
technically accurate but too detailed
unsupported
```

Flag any copy that asserts more than the persisted evidence proves.

---

## 6. Separate human truth from diagnostic truth

For every currently displayed failure detail, classify it as:

```text
HUMAN ORIENTATION
    tells the person what happened at a useful level

HUMAN ACTION
    tells them what they can do now

REASSURANCE
    explains what is safe / what will happen next

DIAGNOSTIC
    useful to support/development

IMPLEMENTATION DETAIL
    exposes internal machinery without helping a decision
```

Pay particular attention to:

- raw exception strings;
- timestamps;
- reset-reason descriptions;
- database terminology;
- import/graph distinctions;
- retry explanation.

---

## 7. Define the minimum truthful failure contract

Determine the smallest set of things an ordinary user needs to know after a caught setup failure.

Candidate questions:

```text
Did setup finish?
    No.

Is MessageLens still doing work?
    No / recovery may now be occurring.

Did this damage my Apple Messages data?
    Only say something if current architecture supports that commitment.

What will retry do?
    Start setup again from a clean rebuild, not resume.

What should I do?
    Retry when offered / allow recovery to finish / resolve a blocker.
```

Do not add reassurance simply because it sounds comforting.

Every statement must be grounded in current operational behavior.

---

## 8. Audit retry semantics

Trace exactly what the current retry actions do.

Inspect labels such as:

```text
Try Import Again
Retry Import and Graph Build
```

For each:

- what method is called;
- whether reset occurs first;
- whether the failed operation resumes;
- whether prior partial stores are retained;
- whether automatic recovery happens before retry;
- whether another FDA/readiness guard occurs.

Then answer:

> What is the simplest truthful human description of retry?

For example, perhaps:

```text
Try Again
```

with supporting copy that setup will be rebuilt from a clean starting point.

But do not choose wording until grounded.

---

## 9. Audit automatic recovery presentation

Trace the stable experience when startup or post-failure probes determine that partial derived stores require cleanup.

Record:

- Gate state;
- visible heading;
- visible explanation;
- activity indicator;
- any detailed recovery reason;
- what happens after cleanup succeeds;
- what happens if cleanup fails.

Ask:

> Does the human need to understand why individual files are being reset, or merely that MessageLens is cleaning up an incomplete setup attempt before trying again?

Do not redesign recovery policy.

---

## 10. Audit reset-reason prominence

If the recovery surface currently displays a reset reason or probe explanation, determine:

- how technical it is;
- whether it changes what the human should do;
- whether it provides reassurance;
- whether it is primarily diagnostic;
- whether it can create unnecessary concern about source data.

Remember the attachment-preservation hard invariant.

Recovery/reset presentation must not suggest that MessageLens is deleting preserved attachment payloads or original Apple Messages data.

---

## 11. Audit “Send Report To Developer”

Determine:

- when this action appears;
- what data/report it sends or prepares;
- whether it is reliable/useful;
- whether it belongs as a primary action or a secondary support action;
- whether exposing it makes the failure screen feel more severe than necessary.

Do not remove it.

The question is placement and hierarchy, not capability.

---

## 12. Consider the attachment-preservation invariant

Review failure/recovery wording for implications such as:

```text
we'll delete everything and try again
your data will be rebuilt
nothing can be lost
all messages and attachments remain recoverable
```

These may be dangerously overbroad.

Maintain the distinction:

```text
rebuildable MessageLens derived stores
    may be reset

archived attachment payloads
    preservation data
    outside reset semantics

Apple source stores
    external authoritative sources
    never MessageLens deletion targets
```

Flag any current wording that muddies these categories.

---

## 13. Audit abrupt termination separately

A quit/crash is not the same as a caught controller error.

Trace what the human sees on next launch after partial work survives without a persisted caught-failure record.

Determine:

- which environment probes infer incomplete state;
- when automatic recovery occurs;
- whether the user sees a failure explanation;
- whether current UI falsely implies that an explicit previous error was recorded.

Do not add durable job state.

The goal is simply to make sure presentation does not claim knowledge it lacks.

---

## 14. Compare three failure philosophies

Evaluate:

### A. Diagnostic-first failure

```text
Import Attempt Failed

SQLiteException...
graph projection...
reset reason...

Retry Import and Graph Build
Send Report To Developer
```

### B. Calm human failure

```text
MessageLens couldn’t finish setup.

Your browsing data wasn’t completed.
You can try setup again.

Try Again

[secondary diagnostics/report action]
```

### C. Detailed but progressive disclosure

```text
MessageLens couldn’t finish setup.

Try Again

Technical details ▸
Send Report To Developer
```

For each assess:

- truthfulness;
- human comprehension;
- reassurance;
- diagnostic usefulness;
- cognitive load;
- implementation complexity;
- whether current evidence supports it.

Recommend one philosophy.

Do not implement disclosure UI.

---

## 15. Determine whether failure classes need richer operational data

Ask whether a calmer truthful primary UI can be built **without** changing the operation layer.

Expected possibility:

```text
caught setup operation failed
```

may be sufficient for primary presentation even if the exact stage is unknown.

If primary UI truly requires knowing import versus projection failure, identify the missing seam.

Do not add it.

Conclude one of:

```text
Existing coarse failure truth is sufficient for a calm user-facing failure surface.
```

or:

```text
A richer typed failure observation is required before the UI can become truthful.
```

Explain why.

---

## 16. Audit reset failures separately

Reset failures currently occur outside the controller catch boundary.

Determine what the user sees today after:

```text
Preparing setup…
-> reset throws
```

given the recently implemented preparation-state unwind.

Answer:

- does the readiness screen simply return?
- is the error visible anywhere?
- is retry available?
- could this feel like the button did nothing?
- is this important enough to become the next concern, or should caught controller failures be cleaned up first?

Do not redesign reset failure reporting.

---

## 17. Determine whether failure timestamps help

If persisted failure presentation shows a timestamp, assess whether it helps an ordinary user.

Possible uses:

```text
distinguish old versus current failure
support diagnostics
```

Possible costs:

```text
visual noise
suggests error log rather than guided recovery
```

Recommend primary/secondary/hidden placement.

Do not remove it yet.

---

## 18. First-run versus reimport failure

Determine whether the same primary failure language can serve both:

```text
first-run setup
direct reimport/rebuild
```

The operation is mechanically similar, but user context differs.

Assess whether the distinction needs:

```text
different heading
different supporting sentence
different retry label
```

or merely contextual copy within one shared system.

Do not create separate failure architectures.

---

## 19. Produce a failure truth budget

Create a table:

```text
We may truthfully say
We should not claim
```

Examples to evaluate:

### May say

```text
MessageLens couldn't finish preparing local browsing data.
Setup can be tried again.
Retry starts a fresh rebuild rather than resuming.
Recovery may clean up incomplete derived stores.
```

### Must not claim unless proven

```text
Import completed before failure.
The graph alone failed.
No partial derived data exists.
All attachments are preserved by this operation.
The operation will resume where it stopped.
Nothing needs cleanup.
The exact failed stage is known.
```

Ground each in actual code.

---

## 20. Recommend exactly one next implementation slice

Choose the single highest-value bounded correction.

Possible candidates include:

```text
replace misleading failure copy with phase-neutral setup failure wording
stop raw lastError from becoming the active-progress headline
demote raw diagnostic detail from primary failure content
simplify retry language
simplify recovery explanation
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
Recovery impact:
Presentation impact:
Test seam:
```

Do not bundle several failure improvements.

---

## 21. Explicitly assess Presence

Answer:

> Does this next failure-presentation slice require any Presence change?

Expected answer unless evidence says otherwise:

```text
No.
```

Presence should not become an error-processing or archive-recovery engine.

---

## 22. Documentation output

Create:

`30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md`

If document 30 is already occupied, use the next free number and report the adjustment without asking for confirmation.

Include:

1. exact failure paths;
2. current failure/recovery UI inventory;
3. raw-error headline audit;
4. persisted failure-classification audit;
5. explanatory-copy truth audit;
6. human-vs-diagnostic classification;
7. retry semantics;
8. automatic recovery audit;
9. reset-reason audit;
10. report-to-developer audit;
11. attachment-preservation implications;
12. abrupt-termination distinction;
13. three philosophy comparison;
14. richer-failure-data verdict;
15. reset-failure assessment;
16. timestamp assessment;
17. first-run/reimport comparison;
18. failure truth budget;
19. exactly one recommended next slice.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

Do not alter application code.

---

# Hard constraints

Do not:

- implement UI changes;
- change controller errors;
- add failure telemetry;
- add stage identity;
- add durable job state;
- change retry mechanics;
- change automatic recovery;
- change reset;
- change mutation coordination;
- change attachment archival;
- modify Presence;
- introduce ActionStep;
- create a new error taxonomy;
- change schema.

This is analysis/design only.

---

# Success criterion

At the end of the audit, we should be able to answer:

> **When setup fails, the human primarily needs to know **\_\_\_\_**, and the smallest next correction is **\_\_\_\_**.**

The ordinary failure experience should eventually communicate what happened, what MessageLens is doing about it, and what the human can do next—without making them diagnose MessageLens’s internal import and graph pipeline.

That should give us a clean counterpart to the success-path work: **failure first as a human event, diagnostics second as engineering evidence**.
