Yes. This should be analysis-only, with one job: **find the next real boundary after Presence completes required-source readiness.**

Perform an **analysis-only audit** of the production handoff from the completed required-source Presence Schedule into the remaining legacy Onboarding flow.

Do not implement code.

Do not change schema.

Do not add Step types.

Do not refactor `OnboardingGate`.

Do not change import behavior.

The purpose of this audit is to identify the **next real onboarding concern** after required-source readiness and determine whether it can be expressed with existing Presence grammar or whether reality finally earns another generic mechanism.

Read first:

- `18-PRODUCTION-GENERIC-PRESENCE-RUNNER-INTEGRATION.md`
- `17-ONBOARDING-MESSAGES-HISTORY-CHOICE-WORKFLOW-IMPLEMENTATION.md`
- current `OnboardingGate` implementation
- current production onboarding/import orchestration code
- current import/recovery/graph-build documentation
- any current docs describing production onboarding states or import phases

Use current production code as source of truth where documentation is stale.

---

## 1. Start at the exact Presence completion boundary

Trace the production path beginning at:

```text
required_sources_confirmation
```

through:

```text
Presence Schedule completion
-> OnboardingPresenceHost disappears / completes
-> OnboardingGate resumes control
```

Document exactly:

- what event/state marks the required-source Schedule complete;
- what `OnboardingGate` observes next;
- what production state replaces the Presence surface;
- what code path executes immediately afterward.

Do not summarize vaguely as “then import starts.”

Name the actual states/classes/providers/methods involved.

---

## 2. Trace all remaining production onboarding phases

Follow the real path from that handoff through the point where the user reaches ordinary MessageLens use.

Inventory the phases in actual execution order.

For each phase, identify whether it is primarily:

```text
FACT
    establish something about the world

INFORM
    explain something to the human

CHOICE
    human selects among finite routes

OPERATION
    perform potentially meaningful work

WAIT / PROGRESS
    operation is underway and UI reports status

RECOVERY
    work failed and user/system determines what to do

COMPLETION
    onboarding is considered finished
```

Use these as descriptive categories only.

Do not turn them into Step classes.

---

## 3. Identify the first concern after readiness

Answer very specifically:

> What is the first semantically meaningful thing that happens after required sources are accepted?

Examples of possible answers might be:

```text
determine whether import is already complete
start an import
prepare databases
copy source data
build graph
recover an interrupted import
```

but do not assume any of these.

Trace the actual code.

This first concern is the leading candidate for the next Presence slice.

---

## 4. Separate decisions from operations

For every remaining onboarding phase, ask:

### Is this a factual question?

If yes, identify:

- what fact is established;
- who currently establishes it;
- whether a generic `TestStep` could express the routing.

### Is this merely explanatory copy?

If yes, identify whether generic `TellStep` is sufficient.

### Is this a finite human decision?

If yes, identify:

- available choices;
- whether durable-value/mutable-label `ChoiceStep` already fits.

### Is this an operation?

If yes, identify:

- what work is performed;
- who owns that expertise;
- whether execution changes external/local durable state;
- whether progress must be reported;
- whether cancellation/retry exists;
- whether the operation survives app restart;
- what success/failure result is currently returned.

Do not invent `ActionStep` merely because something is an operation.

Collect evidence first.

---

## 5. Pay special attention to long-running work

The original production-readiness concern included user reassurance during major data events.

Trace where these operations occur:

- source import;
- attachment import if distinct;
- working-database construction;
- Conversation Graph construction;
- any migration/reconciliation phase;
- archival ingestion if it currently participates in onboarding.

For each, identify:

```text
who starts it
who owns progress
what progress data exists
what durable checkpoint exists
what happens on quit/restart
what happens on failure
what UI currently displays
```

Do not redesign the progress UI yet.

The question is ownership and execution semantics.

---

## 6. Determine what `OnboardingGate` still owns

Produce a concise responsibility inventory for `OnboardingGate` after the Presence production cutover.

For each responsibility, classify it as:

```text
still correctly owned by OnboardingGate

candidate to become a Presence workflow concern

candidate to move to a specialist

transitional debt
```

Explain why.

Do not assume the goal is to eliminate `OnboardingGate`.

If it has a coherent remaining responsibility, say so.

---

## 7. Look for duplicated workflow state

Inspect whether the post-Presence onboarding path contains state such as:

```text
enum onboardingPhase
booleans like importStarted / importComplete
retry flags
special recovery states
manual next-screen routing
```

that effectively duplicates workflow geometry already representable by Presence.

If such state exists, document:

- what it controls;
- whether it is durable;
- whether it can disagree with Presence state;
- whether replacing it would simplify ownership.

Do not refactor it.

---

## 8. Inspect restart/recovery semantics

For every remaining long-running onboarding operation, determine what happens if the app quits:

```text
before operation starts
during operation
after operation succeeds
after operation fails
during graph construction
during recovery
```

Identify the current durable authority for resumption.

Do not assume Presence should own operation checkpoints.

We need to know whether the next concern is:

```text
workflow routing
```

or:

```text
durable job orchestration
```

or both.

This distinction matters.

---

## 9. Look for a second operation-shaped case

`OpenFdaSettingsStep` remains the one explicit domain-specific operation exception.

Search the remaining onboarding path for another mechanically similar case:

> a Step whose essential behavior is “invoke some opaque specialist operation, await a result, then route or continue.”

Candidate examples might be import startup, graph construction, archive preparation, or opening another system surface.

If you find a second genuine case, compare it directly with `OpenFdaSettingsStep`.

Ask:

- what mechanical properties do they share?
- what properties differ?
- is there now enough evidence for a generic operation abstraction?
- would such an abstraction actually reduce special cases?

Do not implement or name `ActionStep` unless the evidence supports it.

If the cases are materially different, say so.

---

## 10. Test existing Presence grammar first

For the first few post-readiness concerns, explicitly test whether each can already be expressed as composition of:

```text
TellStep
TestStep
ChoiceStep
FixedDestinationStep
```

For example:

```text
Test
-> Tell
-> Choice
```

may be sufficient even if the legacy code currently uses one large enum/state handler.

Prefer composition over inventing a new Step.

---

## 11. Identify the next smallest implementation slice

At the end of the audit, recommend exactly **one** next slice.

It should be the smallest real production concern that:

- occurs immediately after the current Presence boundary;
- improves production onboarding;
- has clear ownership;
- can be implemented and manually/testably proven in isolation;
- does not require speculative architecture.

State:

```text
Next concern:
Why it comes next:
Existing Presence grammar sufficient? yes/no
If yes: exact composition
If no: exact missing mechanical capability
Owner(s):
Persistence implications:
Restart implications:
Presentation implications:
Suggested test seam:
```

Do not produce a multi-month roadmap.

---

## 12. Explicitly assess whether ActionStep is now earned

Conclude with one of:

```text
ActionStep is still NOT earned.
```

or:

```text
A generic operation Step is now earned by these two or more concrete cases:
...
```

If recommending a generic operation Step, define only the minimum common mechanical contract supported by current evidence.

Do not generalize beyond the observed cases.

---

## 13. Produce a handoff diagram

Include a compact diagram of the actual production flow beginning at:

```text
required_sources_confirmation
```

and ending at ordinary MessageLens readiness.

Mark the ownership boundaries:

```text
Presence
OnboardingGate
specialists
database/import infrastructure
```

Use actual current phases and names.

---

## 14. Documentation output

Create:

`19-POST-READINESS-ONBOARDING-HANDOFF-AUDIT.md`

The document should contain:

1. exact current handoff;
2. ordered post-readiness phase inventory;
3. first real concern after readiness;
4. factual/choice/operation classification;
5. `OnboardingGate` responsibility audit;
6. long-running operation/restart analysis;
7. duplicated workflow-state findings;
8. comparison with `OpenFdaSettingsStep`;
9. existing Presence grammar fit;
10. one recommended next implementation slice;
11. ActionStep verdict;
12. compact ownership/handoff diagram.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

Do not alter implementation code.

---

## Hard constraints

Do not:

- implement anything;
- add new Step classes;
- add schema;
- modify workflow definitions;
- refactor `OnboardingGate`;
- alter import/recovery behavior;
- change production run state;
- change FDA behavior;
- change presentation;
- propose speculative future features unrelated to the immediate handoff.

This is an evidence-gathering pass.

---

## Success criterion

At the end of the audit, we should be able to answer in one sentence:

> **The next real onboarding concern after required-source readiness is **\_\_\_\_**, and the smallest correct Presence treatment is **\_\_\_\_**.**

If the answer requires more than one major architectural invention, the audit has probably gone too broad.

Stop after the audit and report back before implementation.

This should tell us whether the next move is another pleasantly ordinary composition of existing Steps—or whether the code finally produces enough evidence for a genuinely new operation-shaped abstraction.
