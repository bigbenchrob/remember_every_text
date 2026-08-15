Good. I’d make the next Codex pass **analysis/design only**, focused entirely on the progress surface we already have. No orchestrator changes yet.

Perform an **analysis/design audit only** of the production first-run and reimport progress experience.

Read first:

- `21-INITIAL-IMPORT-GRAPH-BUILD-LIFECYCLE-AUDIT.md`
- `22-REMOVE-MISLEADING-ABORT-IMPORT-IMPLEMENTATION.md`
- current production onboarding progress widgets
- current `OnboardingGate` progress/status model
- current `ConversationGraphBuildState`
- current completion and failure presentation
- any current design docs describing the desired calm / reassuring onboarding experience

Use current code as source of truth.

Do not implement code.

Do not change the orchestrator.

Do not add progress telemetry.

Do not add cancellation.

Do not change Presence.

The purpose of this audit is to answer:

> **How good can the production import experience become using only operational facts that already exist today?**

---

# 1. Inventory the current visible progress experience

Trace exactly what the user currently sees from the moment they press:

```text
Import My Messages
```

until:

```text
success
or
failure/recovery
```

Document:

- every visible heading;
- status line;
- progress indicator;
- explanatory paragraph;
- button/control;
- transition between screens;
- completion copy;
- failure copy.

Do the same for reimport if the surface differs.

Distinguish:

```text
first-run
reimport
shared presentation
```

---

# 2. Map visible copy to actual operational truth

For every piece of visible copy, record:

```text
displayed wording
actual operational fact supporting it
truth assessment
```

Use:

```text
literal
truthful coarse summary
unnecessarily technical
misleading
unsupported
```

Examples:

```text
"Building browsing data…"
    -> controller running
    -> truthful coarse summary

"Importing…"
    -> if no importer is yet running
    -> misleading
```

Do not rewrite anything yet.

---

# 3. Audit the hidden state model

Inspect how the presentation reacts to:

```text
OnboardingStatus.importing
OnboardingStatus.buildingGraph
ConversationGraphBuildState.running
succeeded
failed
```

Determine whether the UI currently has multiple internal states that are visually or semantically indistinguishable.

Specifically revisit the Audit 21 finding that:

```text
importing
buildingGraph
```

do not correspond to two real operations.

Answer:

> Does preserving both states still buy anything useful in presentation?

Do not refactor them in this pass.

---

# 4. Identify all truthful facts already available live

List every live fact the UI can obtain without operation-layer changes.

At minimum inspect:

- controller running/not running;
- startedAt;
- owner if exposed;
- first-run vs reimport context;
- current Gate state;
- whether required-source readiness was accepted;
- whether this is initial setup or rebuild;
- whether an error has occurred;
- whether final report exists;
- elapsed time calculable from `startedAt`;
- any existing safe human-facing metadata.

Classify each as:

```text
useful to human
diagnostic only
potentially anxiety-inducing
not presentation-worthy
```

---

# 5. Evaluate elapsed time

The controller exposes `startedAt`.

Assess whether showing elapsed time would improve the calm experience.

For example:

```text
Working for 2m 14s
```

Questions:

- Is elapsed time always truthful?
- Does it remain valid through the Gate's pre-build staging frames?
- Would it reassure or instead make long jobs feel slower?
- Does reimport differ?
- Would exposing elapsed time imply a missing estimate?
- Is it worth adding now?

Do not implement it.

Give a recommendation.

---

# 6. Evaluate “keep MessageLens open” guidance

Audit whether current UI tells the human what they should do while the operation runs.

Given current restart semantics, determine whether it is truthful and useful to say something like:

```text
Keep MessageLens open while this finishes.
```

or:

```text
You can use other apps while MessageLens works.
```

Assess:

- quitting;
- closing the window;
- app backgrounding;
- sleeping the Mac;
- user switching apps;
- what the code actually guarantees.

Do not overpromise.

Recommend the narrowest truthful reassurance.

---

# 7. Evaluate visual density

Without redesigning widgets, assess whether the current surface has unnecessary visual noise.

Look for:

- multiple headings saying essentially the same thing;
- technical labels;
- progress indicator plus redundant status text;
- stale controls;
- overly detailed explanation;
- large blocks of text during a passive wait;
- diagnostic detail shown to ordinary users.

The target character is:

> calm, low-noise, reassuring, and obviously active.

Do not interpret that as “minimal at all costs.”

The user should still know:

```text
what is happening
that the app is still working
what they should do
```

---

# 8. Evaluate stage-detail temptation

Audit whether any current UI attempts to imply stage detail from:

```text
importing
buildingGraph
```

or other coarse states.

Conclude whether the production experience should:

```text
stay intentionally coarse
```

or whether:

```text
live stage telemetry is now genuinely worth earning
```

Be strict.

A stage seam should be justified only if it materially improves:

- reassurance;
- diagnosis;
- trust;
- long-running perceived progress.

Not merely because stage names exist internally.

---

# 9. Compare three candidate presentation philosophies

Evaluate these three concepts using only current facts.

## A. Minimal calm

```text
Preparing MessageLens

[ indeterminate progress ]

Building local browsing data…
Keep MessageLens open while this finishes.
```

## B. Calm + elapsed time

```text
Preparing MessageLens

[ indeterminate progress ]

Building local browsing data…
Working for 3m 12s
Keep MessageLens open while this finishes.
```

## C. Richer staged progress

```text
Importing messages…
Building conversations…
Indexing attachments…
```

For each, state:

- support from current APIs;
- truthfulness;
- reassurance value;
- complexity;
- whether operation-layer changes are required.

Recommend one.

---

# 10. Audit completion presentation

Inspect the current success screen.

Determine:

- what final report facts are shown;
- whether they are useful to the human;
- whether they are too diagnostic;
- whether completion wording accurately describes import + graph projection;
- whether requiring a separate **Get Started** click is still useful;
- whether ordinary MessageLens can already safely open without it;
- whether completion is durable or merely in-memory.

Do not change anything.

This is important because the progress experience should lead naturally into completion.

---

# 11. Audit failure presentation

Inspect the current caught-failure path.

Determine:

- what the human sees;
- how technical the error is;
- whether retry meaning is truthful;
- whether the UI explains that retry rebuilds from scratch rather than resumes;
- whether partial-state recovery is hidden appropriately;
- whether diagnostic details should remain accessible but secondary.

Do not redesign failure handling yet.

Identify only obvious presentation mismatches.

---

# 12. First-run versus reimport

Compare the two experiences.

Ask:

> Should they intentionally look nearly identical while work runs?

The operation is mechanically similar, but user context differs:

```text
first run:
    building MessageLens for the first time

reimport:
    rebuilding derived browsing data
```

Identify the minimum wording difference justified by meaning.

Do not create separate visual systems unless evidence requires it.

---

# 13. Determine whether live stage telemetry is earned

Conclude one of:

```text
Live stage telemetry is NOT yet earned.
```

or:

```text
Live stage telemetry is now earned because...
```

If not earned, state what user need would have to emerge to justify it.

If earned, define only the minimum observation contract, for example:

```text
currentStageId
humanSafeLabel?
```

But do not implement it.

Do not propose percentages unless independently justified.

---

# 14. Recommend exactly one next implementation slice

Choose the smallest implementation that most improves truthfulness and calmness using existing operation facts.

Possible examples:

```text
simplify active progress presentation
add truthful keep-open reassurance
remove redundant importing/building distinction from visible UI
add elapsed time
simplify completion presentation
```

Choose **one**.

Use:

```text
Next concern:
Why it comes next:
Current defect:
Smallest implementation:
Owner:
Operation-layer changes:
Persistence impact:
Restart impact:
Presentation impact:
Test seam:
```

Do not recommend a bundle of UI improvements.

---

# 15. Preserve architectural boundaries

Explicitly confirm whether:

```text
Presence
```

needs any change for this next slice.

The expected answer is probably:

```text
No.
```

Likewise assess:

```text
ConversationGraphBuildController
ConversationGraphBuildOrchestrator
OnboardingGate
```

Only recommend changes where evidence requires them.

---

# 16. Produce a compact “truth budget”

Create a concise table:

```text
We may truthfully show now
We cannot truthfully show now
```

Examples:

```text
working
elapsed time
keep app open
success
retry

vs.

current stage
percentage
ETA
resume
cancel safely
```

This should become the guardrail for future progress UI work.

---

# 17. Documentation output

Create:

`23-PRODUCTION-IMPORT-PROGRESS-SURFACE-AUDIT.md`

Include:

1. current visible flow;
2. copy-to-truth mapping;
3. hidden state audit;
4. currently available live facts;
5. elapsed-time verdict;
6. keep-open guidance verdict;
7. visual-density findings;
8. stage-detail verdict;
9. three philosophy comparison;
10. completion audit;
11. failure audit;
12. first-run/reimport comparison;
13. stage-telemetry verdict;
14. truth budget;
15. one recommended next slice.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

Do not alter application code.

---

# Hard constraints

Do not:

- implement UI changes;
- change copy in code;
- change Gate state model;
- add telemetry;
- add percentages;
- add stage names;
- add cancellation;
- add durable job state;
- modify Presence;
- modify operation lifecycle;
- redesign failure/recovery;
- refactor completion.

This is analysis/design only.

---

# Success criterion

At the end of the audit, we should be able to answer:

> **Using only facts MessageLens already knows while the build is running, the best production progress experience is **\_\_\_\_**, and the next smallest implementation is **\_\_\_\_**.**

If the recommendation requires orchestrator changes, it must explain why the current coarse truth is no longer sufficient.

Stop after the audit and report back before implementation.

I think this is the right point to resist the seductive urge to show seventeen little blinking stage names. The question is whether they would actually make the experience better, not whether we can technically expose them.
