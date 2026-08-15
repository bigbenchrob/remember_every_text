Yes. I’d keep this one analysis-only again, because the gap sits across several boundaries and we should not “fix” it by simply throwing up a spinner too early.

Perform an **analysis/design audit only** of the production gap between the human pressing **Import My Messages** and the existing blocking progress overlay becoming visible.

Read first:

- `21-INITIAL-IMPORT-GRAPH-BUILD-LIFECYCLE-AUDIT.md`
- `23-PRODUCTION-IMPORT-PROGRESS-SURFACE-AUDIT.md`
- `24-TRUTHFUL-KEEP-OPEN-PROGRESS-GUIDANCE-IMPLEMENTATION.md`
- current `EnvironmentReadinessPanelView`
- `EnvironmentReadinessActions.startImportAndGraphBuild()`
- `OnboardingGate.startImportAndGraphBuild()`
- `ArchiveMutationCoordinator`
- `MessageDataResetService`
- current Onboarding overlay / progress presentation
- current FDA re-check path

Use current code as source of truth.

Do not implement code.

Do not change the Gate.

Do not change reset behavior.

Do not change the build controller.

Do not add telemetry.

Do not change Presence.

The purpose of this audit is to answer:

> **What is the smallest truthful way to acknowledge immediately that Import My Messages has been accepted and setup preparation has begun, before the controller build itself starts?**

---

# 1. Trace the exact visible gap

Start at:

```text
human presses:
    Import My Messages
```

Trace the exact sequence until the first existing progress overlay frame appears.

Document:

- button callback;
- provider/action call;
- Gate entry;
- mutation admission;
- FDA recheck;
- reset;
- Gate status changes;
- first overlay render.

For each step, identify whether the human currently receives any visible acknowledgement.

Measure the logical gap, not necessarily wall-clock duration.

The key question is:

> During which real operations can the UI still look as though nothing happened?

---

# 2. Identify what is actually true immediately after the click

List the facts that become true as soon as the action is accepted.

Possible examples:

```text
the command was received
setup preparation has begun
mutation admission is being requested
FDA is being rechecked
derived data may be reset
the controller build has NOT started yet
```

Verify each from code.

Separate:

```text
safe to tell the human
too internal
not yet true
```

---

# 3. Audit the current button behavior

Inspect the **Import My Messages** control itself.

Answer:

- Is it disabled immediately after press?
- Can it be pressed twice?
- Does the callback await the full Gate action?
- Does the UI get an in-flight state?
- Could repeated clicks race or be ignored by Gate state?
- Is there any visual pressed/loading feedback beyond ordinary button behavior?
- What happens if mutation admission is denied?
- What happens if FDA recheck fails?
- What happens if reset throws?

Do not fix these yet.

---

# 4. Distinguish three periods

Evaluate the operation as three user-facing periods:

```text
A. action accepted / preparation begins
B. controller build is actively running
C. terminal success or failure
```

We already have a good experience for B.

The audit should focus on A.

Determine whether A itself contains meaningful subphases that the user needs to know about, or whether one generic state such as:

```text
Preparing MessageLens…
```

is sufficient.

Do not manufacture separate UI for:

```text
checking permission
acquiring mutation lock
deleting databases
```

unless a real user need requires it.

---

# 5. Audit failure boundaries before the overlay

This is critical.

The previous lifecycle audit found that some failures happen before the controller build catch.

Inspect:

### Mutation admission failure

- where it throws;
- who catches it;
- what the user sees;
- whether the readiness surface remains visible;
- whether the action can be retried.

### FDA recheck fails

- what Gate state becomes;
- what presentation takes over;
- whether an immediate “Preparing…” state would conflict with the FDA surface.

### Reset failure

- where it throws;
- whether any failure state is persisted;
- what UI remains;
- whether the existing action Future rejects visibly or silently.

For each, ask:

> If we show an immediate preparation state, how must it unwind truthfully on this failure?

Do not let a new loading surface hide an actionable FDA or failure state.

---

# 6. Identify the correct ownership layer for acknowledgement

Evaluate possible owners:

### Environment Readiness button-local state

```text
button pressed
-> local in-flight state
```

Pros/cons:

- immediate;
- presentation-local;
- may not know Gate outcome;
- may disappear on provider rebuild.

### OnboardingGate state

Add/use a state meaning preparation has begun before reset.

Pros/cons:

- authoritative operation coordination;
- risks expanding transitional Gate workflow state.

### Existing Gate status earlier

Move existing progress-state transition before reset.

Pros/cons:

- may solve the gap with no new state;
- must remain truthful if admission/FDA/reset fail.

### Separate application-level command state

Evaluate only if existing layers cannot represent the truth cleanly.

Do not invent a new authority unless necessary.

Recommend the smallest owner.

---

# 7. Evaluate moving the progress overlay earlier

Audit whether the existing progress surface could appear before reset.

For example:

```text
human presses Import
-> show Preparing MessageLens
-> admission
-> FDA recheck
-> reset
-> controller starts
-> Building browsing data
```

Assess:

- truthfulness;
- interaction with FDA failure;
- interaction with reset failure;
- whether current overlay depends on controller state;
- whether it can safely render while controller is idle;
- whether existing `Preparing setup…` wording already fits this period.

The current progress audit established that **Preparing setup…** is truthful coarse wording while the controller is idle. Determine whether it remains truthful even earlier, during admission/FDA/reset.

---

# 8. Check whether the current “preparing” state is artificially late

Audit why `OnboardingStatus.importing` is currently set only after reset.

Is that ordering required for correctness, or merely historical presentation sequencing?

Trace comments/tests/history if useful.

Do not change it.

Answer:

> Is there any architectural reason the Gate cannot expose “preparing” before reset begins?

If yes, document it.

If no, say so.

---

# 9. Repeated-click / double-start safety

Prove what currently prevents:

```text
Import My Messages
Import My Messages
```

from launching two operations.

Identify whether correctness depends on:

- Gate status guard;
- mutation coordinator exclusion;
- button state;
- provider action serialization;
- some combination.

If the visual acknowledgement moves earlier, preserve that correctness model.

Do not add another lock unless needed.

---

# 10. Evaluate the smallest truthful presentation

Compare these possibilities:

## A. Disable button + inline activity

```text
Import My Messages [spinner]
```

while the existing readiness panel remains visible.

## B. Immediately transition to existing full progress overlay

```text
Preparing MessageLens…
[indeterminate progress]
Keep MessageLens open...
```

## C. Immediate acknowledgement message, then overlay later

```text
Getting things ready…
```

followed by existing overlay.

For each assess:

- truthfulness;
- visual continuity;
- implementation complexity;
- failure unwind;
- duplicate interaction protection;
- architectural ownership.

Recommend one.

---

# 11. Consider the keep-open guidance timing

The current active guidance says:

> Keep MessageLens open while it prepares your messages. You can use other apps in the meantime.

Would that also be truthful during admission/FDA/reset?

If yes, the same progress surface may naturally cover the whole admitted operation.

If no, identify the exact narrower wording needed for the preparation period.

Avoid copy proliferation unless necessary.

---

# 12. Reimport/reset path comparison

Audit whether the same pre-overlay gap exists for:

- direct `startReimport()`;
- production **Reset Message Data** flow;
- automatic recovery.

Do not broaden the recommended slice automatically.

The main target is first-run **Import My Messages**.

But identify whether the same underlying ordering problem appears elsewhere, so we do not accidentally create inconsistent behavior.

---

# 13. Persistence and restart implications

Confirm whether earlier visual acknowledgement requires any durable state.

Expected answer:

```text
No.
```

If the app quits during admission/reset, startup already reconstructs from durable files and environment facts.

Do not add a persisted “preparing” state.

Explain why ephemeral progress is sufficient.

---

# 14. Recommend exactly one next implementation slice

Use:

```text
Next concern:
Why it comes next:
Current defect:
Smallest implementation:
Owner:
Gate changes:
Operation-layer changes:
Persistence impact:
Failure-unwind behavior:
Presentation impact:
Test seam:
```

Choose one bounded change.

Do not bundle reset failure redesign, reimport cleanup, or telemetry into it.

---

# 15. Produce a compact transition diagram

Show:

```text
Import My Messages
    -> preparation acknowledgement
    -> admission
    -> FDA recheck
    -> reset
    -> controller running
    -> completion/failure
```

Mark:

- current visible state;
- proposed visible state;
- owner of each transition.

---

# 16. Documentation output

Create:

`25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md`

Include:

1. exact current gap;
2. immediate truthful facts;
3. button/in-flight audit;
4. pre-controller failure boundaries;
5. ownership analysis;
6. earlier-overlay feasibility;
7. double-start safety;
8. three presentation options;
9. keep-open guidance timing;
10. reimport/reset comparison;
11. persistence/restart conclusion;
12. exactly one recommended slice;
13. transition diagram.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

Do not alter application code.

---

# Hard constraints

Do not:

- implement UI changes;
- change Gate status ordering;
- add new Gate states;
- change reset;
- change mutation policy;
- change FDA behavior;
- add telemetry;
- add cancellation;
- add persistence;
- change Presence;
- redesign completion/failure;
- solve the nested mutation-policy caveat in this pass.

This is analysis/design only.

---

# Success criterion

At the end of the audit, we should be able to answer:

> **Immediately after Import My Messages is pressed, the truthful visible response should be **\_\_\_\_**, owned by **\_\_\_\_**, and it can appear before **\_\_\_\_** without misrepresenting the operation.**

Stop after the audit and report back before implementation.

This one should tell us whether the existing **Preparing MessageLens** surface can simply start earlier—which would be the nicest outcome—or whether the admission/FDA/reset boundaries require something more careful.
