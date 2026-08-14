---
tier: project
scope: production-import-progress-presentation
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: code
links:
  - 21-INITIAL-IMPORT-GRAPH-BUILD-LIFECYCLE-AUDIT.md
  - 22-REMOVE-MISLEADING-ABORT-IMPORT-IMPLEMENTATION.md
  - ../../25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md
  - ../../43-PRESENCE/00-PRESENCE.md
tests:
  - test/essentials/onboarding/presentation/onboarding_overlay_progress_test.dart
  - test/essentials/onboarding/application/onboarding_gate_provider_test.dart
---

# Production Import Progress Surface Audit

## Executive Conclusion

Using only facts MessageLens already knows while the build is running, the
best production progress experience is **minimal calm**: one coarse statement
of active work, one indeterminate activity indicator, and one truthful request
to keep MessageLens open. The next smallest implementation is **replace the
current repetitive explanatory paragraph with concise keep-open guidance**.

Live stage telemetry is not yet earned. It would require operation-layer work,
while the current coarse truth is already enough to answer the three questions
that matter during the passive wait:

```text
What is happening?
    MessageLens is building local browsing data.

Is it still working?
    Yes; the active indeterminate indicator is backed by controller state.

What should I do?
    Keep MessageLens open. Using other applications is fine.
```

This conclusion follows the established Presence character: calm, truthful,
attentive, and free of information shown merely because the software happens
to possess it.

## 1. Sources And Scope

The audit used current code as authority, principally:

- `EnvironmentReadinessPanelView` and its surface model;
- `OnboardingOverlay`;
- `OnboardingGate` and `OnboardingStatus`;
- `ConversationGraphBuildController` and `ConversationGraphBuildState`;
- `ConversationGraphBuildReport`;
- `MessageDataResetService`;
- the macOS application-close policy in `AppDelegate`;
- Audits 21 and 22;
- the calm and truthful interaction principles in `43-PRESENCE/00-PRESENCE.md`.

This is a presentation audit. It does not change the Gate, controller,
orchestrator, Presence, persistence, copy in code, or any operation behavior.

## 2. Current Visible Flow

### 2.1 First run

The human begins in the Environment Readiness surface. Its import-readiness
detail presents **Import My Messages**. Pressing it invokes the existing Gate
action.

The progress overlay does **not** appear immediately. Mutation admission, the
FDA recheck, and derived-data reset occur while the Gate still reports
`awaitingUserAction`. The Environment Readiness/Presence surface therefore
remains visible without a new activity indication, and the import button is
not replaced by a local loading state. Only after reset returns does the Gate
enter its progress statuses and show the full-window blocking overlay.

The complete visible sequence is:

1. The existing readiness surface remains visible during admission, FDA
   recheck, and reset, with no new progress copy or indicator.
2. **Preparing setup…**
   - headline;
   - indeterminate linear progress indicator;
   - `MessageLens is building its local browsing data from Messages.`;
   - no button or cancellation control.
3. **Building browsing data…**
   - the same indicator and paragraph;
   - no button or cancellation control.
4. A normally very brief controller-success presentation may render:
   - **Browsing data ready**;
   - a full progress indicator;
   - the same paragraph.
5. The completion surface renders:
   - success icon;
   - **Import Complete!**;
   - when the in-memory report is available, three metric chips:
     **Imported**, **Projected**, and **Text enriched**;
   - **Get Started**.
6. **Get Started** dismisses the workflow overlay and selects the Messages
   sidebar.

The first two Gate statuses are deliberately rendered by the same widget. The
headline changes because the controller moves from `idle` to `running`, not
because `OnboardingStatus.importing` and `buildingGraph` convey two truthful
operational phases.

### 2.2 Caught failure and recovery

When the controller catches an error, its state briefly becomes `failed`. If
Flutter renders that intermediate state before the Gate changes status, the
progress headline can display the raw `lastError` string. The Gate then:

1. persists a coarse graph-projection failure;
2. returns to `awaitingUserAction`;
3. invalidates the environment report;
4. may trigger automatic cleanup when probes find incomplete derived data.

The stable failure/recovery surfaces can include:

- **Import Attempt Failed** or **Messages Could Not Be Prepared**;
- an explanatory paragraph;
- one or more notes, including a persisted timestamp and possibly the raw
  stored error;
- **Try Import Again** or **Retry Import and Graph Build**;
- **Send Report To Developer**;
- during cleanup, **Cleaning Up A Previous Setup Attempt**;
- a cleanup explanation;
- an optional reset-reason panel;
- a circular activity indicator.

There is a possible transient after failure while the invalidated environment
report catches up: `awaitingUserAction` may initially render the prior report
or the null-report welcome presentation before the durable failure-derived
presentation arrives. This is a consequence of the current independent Gate
override and asynchronous environment report. It is not a new failure state.

Retry starts a fresh reset and build. It does not resume the failed stage.

### 2.3 Reimport

Two different mechanisms currently carry the word *reimport* and must not be
conflated.

#### Direct reimport API

`OnboardingGate.startReimport()` has focused test coverage but no production
caller in `lib/`. If invoked, it first resets derived data while the Gate still
reports `notNeeded`; no reimport progress overlay represents that reset. After
reset returns, it shows the shared progress widget with:

1. **Preparing rebuild…**;
2. **Rebuilding browsing data…**;
3. a normally brief **Browsing data rebuilt** state;
4. the same **Import Complete!** surface and metrics;
5. **Done** instead of **Get Started**.

Its paragraph is:

> MessageLens is rebuilding its local browsing data from Messages.

On failure, it returns to the same `awaitingUserAction` failure/retry surface
used by first run. It has no distinct failure presentation.

#### Production Reset Message Data route

The production Settings action currently calls
`confirmResetAndPrepareReimport()`, not `startReimport()`. The human sees:

1. **Reset MessageLens Databases?** with explanatory copy;
2. **Proceed** and **Cancel**;
3. after **Proceed**, the reset runs without a dedicated progress surface;
4. after reset, **MessageLens Databases Cleared**;
5. explanatory copy and **OK**;
6. the refreshed ordinary readiness/import path;
7. after **Import My Messages**, the first-run progress wording and
   **Get Started** completion action.

Therefore the reimport-specific overlay copy is implemented capability, not
the current production reset journey.

### 2.4 Shared presentation

First-run and direct-reimport active work share:

- one blocking card;
- one headline;
- one indeterminate linear activity indicator while work is not complete;
- one explanatory paragraph;
- no interactive control;
- one completion component with optional metrics.

Only the preparing/running/succeeded wording, explanatory verb, and completion
button label differ.

## 3. Copy-To-Truth Mapping

### Active progress

| Displayed wording or element | Operational fact | Assessment |
| --- | --- | --- |
| No new visible state immediately after **Import My Messages** | Mutation admission, FDA recheck, and reset may already be running | Missing activity acknowledgement; no false copy, but not obviously active |
| **Preparing setup…** | Controller is still `idle` during Gate staging after reset | Truthful coarse summary |
| **Preparing rebuild…** | Direct-reimport controller is still `idle` after reset | Truthful coarse summary |
| **Building browsing data…** | Controller is `running` across all source-import and graph-projection stages | Truthful coarse summary |
| **Rebuilding browsing data…** | Direct-reimport controller is `running` after deleting previous derived data | Truthful coarse summary |
| **Browsing data ready** | Controller has succeeded in this process | Literal |
| **Browsing data rebuilt** | Direct-reimport controller has succeeded in this process | Literal |
| `MessageLens is building its local browsing data from Messages.` | One controller run constructs app-local source and graph data from Messages; Contacts are also imported | Truthful coarse summary, but repetitive and incomplete |
| `MessageLens is rebuilding its local browsing data from Messages.` | Same operation after an explicit reset | Truthful coarse summary, but repetitive and incomplete |
| Indeterminate linear indicator | Controller is idle during staging or actively running; no work denominator exists | Truthful coarse summary |
| Full linear indicator | Controller reported success before Gate completion presentation replaced progress | Literal but normally transient |
| Raw `lastError` as progress headline | Controller caught an exception | Literal, but unnecessarily technical and visually over-prominent |
| No active controls | No cancellation contract exists | Literal and truthful |

The underlying `OnboardingStatus.importing` name is misleading if read as a
real operation. The production UI does not display that word and therefore
does not currently repeat the fiction to the human.

### Completion

| Displayed wording or element | Operational fact | Assessment |
| --- | --- | --- |
| **Import Complete!** | Source import, enrichment, joins, and graph projection completed | Truthful coarse summary, narrower than the complete operation |
| **Imported** count | `insertedMessageCount` from final message import result | Literal, but diagnostic for most humans |
| **Projected** count | Inserted message count from final message projection | Literal, but unnecessarily technical and likely redundant to ordinary users |
| **Text enriched** count | Messages enriched from attributed content | Literal, but diagnostic and unexplained |
| **Get Started** | Dismisses overlay and selects Messages | Literal human handoff; not required for data correctness |
| **Done** | Dismisses a direct-reimport completion overlay | Literal |

### Failure and recovery

| Displayed wording or element | Operational fact | Assessment |
| --- | --- | --- |
| **Import Attempt Failed** | Environment report classified a persisted import failure | Literal at the report's coarse classification |
| **Messages Could Not Be Prepared** | A failure was persisted through the Gate's graph-build failure path | Truthful coarse summary |
| `MessageLens imported source data, but ... could not finish preparing it` | Assumes import completed before projection failure | Potentially misleading: the Gate stores every controller-stage error as graph projection failure, including source-import stage failures |
| Raw persisted error note | Exact caught error string is available | Literal, but unnecessarily technical and anxiety-inducing in primary content |
| **Try Import Again** | Starts the ordinary clean setup path again | Truthful coarse summary |
| **Retry Import and Graph Build** | Starts reset plus the complete import/projection lifecycle | Literal but unnecessarily technical |
| `Retrying will rerun setup.` | No stage resume exists | Literal |
| **Send Report To Developer** | Diagnostic export can be attempted | Literal |
| **Cleaning Up A Previous Setup Attempt** | Automatic recovery is deleting incomplete derived app data | Truthful coarse summary |
| Reset-reason panel | Probe-derived cleanup reason is available | Literal, but diagnostic and potentially too prominent |

## 4. Hidden State Audit

### Gate state versus controller state

| Gate status | Controller state normally observed | Visible interpretation |
| --- | --- | --- |
| `importing` | `idle` | Preparing setup |
| `buildingGraph` before `runOnce()` publishes | `idle` | Preparing setup |
| `buildingGraph` during the operation | `running` | Building browsing data |
| `buildingGraph` immediately after success | `succeeded` | Browsing data ready, normally transient |
| `buildingGraph` immediately after error | `failed` | Raw error, potentially transient |
| `complete` | `succeeded` | Completion summary |
| `reimporting` | `idle` | Preparing rebuild |
| `reimportBuildingGraph` before and during the operation | `idle`, then `running` | Preparing, then rebuilding |
| `reimportComplete` | `succeeded` | Completion summary |

`importing` and `buildingGraph` do not correspond to two real operations and
do not produce two meaningfully distinct presentations. Preserving both buys
only internal staging: two rendered frames before the controller call. It buys
no useful human explanation and must not be treated as stage telemetry.

The same is true of `reimporting` and `reimportBuildingGraph`.

This audit does not remove or refactor the states. It records that future
presentation should derive active wording from controller truth and user
context, not infer operational phases from those Gate names.

## 5. Truthful Live Facts Already Available

| Existing fact | Availability | Presentation classification | Reason |
| --- | --- | --- | --- |
| Controller `idle/running/succeeded/failed` | Live, process-local | Useful to human | Supports preparing, active work, success, and failure |
| `startedAt` | Live after controller starts | Potentially useful, but not yet presentation-worthy | Supports truthful process-local elapsed time only |
| `finishedAt` | Terminal, process-local | Diagnostic only | Adds little to a calm completion screen |
| Controller `owner` | Live, process-local | Diagnostic only | Values such as `onboarding-first-run` are implementation labels |
| First-run versus direct-reimport context | Live from Gate status | Useful to human | Initial preparation and rebuilding have different meaning |
| Gate status | Live, process-local | Partly useful | Determines overlay lifecycle; `importing/buildingGraph` are not truthful stage facts |
| Required-sources Schedule completion | Durable stream | Useful before start, not during progress | Proves the human accepted the readiness workflow, not operation progress |
| Environment/source readiness report | Probe-derived | Useful before start and after failure | Establishes prerequisites; does not describe current build position |
| `lastError` | Terminal, process-local | Diagnostic and potentially anxiety-inducing | Useful for support, too technical as the progress headline |
| Persisted failure evidence | Durable overlay fact | Useful for recovery, detail diagnostic | Supports retry/recovery classification across launch |
| `lastReport` | Terminal, process-local | Mostly diagnostic | Supplies final counts and timings but not live progress |
| Final import/projection/enrichment counts | Completion-only | Diagnostic for most humans | Technically truthful, weak orientation value |
| Current stage | Not exposed | Unavailable | Exists only inside orchestrator execution |
| Percentage or remaining work | Does not exist | Unavailable | No truthful denominator |

## 6. Elapsed-Time Verdict

`startedAt` makes process-local elapsed time truthful once the controller is
running. It does not cover:

- archive mutation admission;
- the FDA recheck;
- derived-data reset;
- the Gate's pre-controller staging frames;
- time spent in a previous process before quit or crash.

A presentation timer could update `Working for 2m 14s` without changing the
operation layer. The number would be equally truthful during first run and
direct reimport once their controllers start.

Nevertheless, elapsed time is **not recommended now**:

- it reports duration, not progress;
- it may focus attention on slowness during a passive wait;
- it visually invites an unavailable ETA;
- it adds moving detail without helping the human make a decision;
- it omits reset time and resets to zero after a new process starts.

Elapsed time should be reconsidered only if real use shows that people cannot
distinguish a healthy long operation from a stalled one. That would be an
observed reassurance problem, not a reason to display every available fact.

## 7. Keep-Open Guidance Verdict

The current surface does not tell the human what to do while work runs.

The narrow truthful contract is:

> **Keep MessageLens open while it prepares your messages. You can use other
> apps in the meantime.**

This is supported because:

- the operation is process-local and has no durable resume checkpoint;
- quitting terminates it;
- closing the last MessageLens window also terminates the application because
  `applicationShouldTerminateAfterLastWindowClosed` returns `true`;
- switching to another application does not itself terminate MessageLens or
  request cancellation.

The UI should not promise uninterrupted behavior across quitting, closing the
window, restarting, logging out, or restarting the Mac. Sleep normally
suspends rather than deliberately cancels the process, but no explicit
sleep/wake guarantee belongs to this operation contract, so the progress copy
should say nothing about it.

## 8. Visual-Density Findings

The active surface is already restrained after removal of **Abort Import**. It
contains no stage list, percentage, ETA, log, metric counter, or competing
control.

The remaining issues are small:

- admission, FDA recheck, and reset can run before the progress overlay appears;
- the headline and paragraph repeat the same browsing-data statement;
- the paragraph tells the human what the app is doing but not what the human
  should do;
- `lastError` can briefly replace the calm headline with unbounded technical
  text;
- completion shows three implementation-shaped metrics that do not help most
  people decide what to do next;
- stable failure surfaces can elevate raw errors and cleanup reasons into
  ordinary reading order.

The active progress indicator and status are not redundant. One communicates
motion; the other gives the motion meaning. The explanatory paragraph is the
best candidate for later simplification because it currently repeats meaning
instead of supplying guidance.

The pre-overlay reset gap is also real, but it is not merely a copy defect. A
correction must deliberately order Gate presentation around reset and preserve
truthful handling if admission, FDA recheck, or reset fails. It should not be
smuggled into the next presentation-only slice.

## 9. Stage-Detail Verdict

No current production UI truthfully names the live stage. The Gate's
`importing/buildingGraph` distinction must not be used to manufacture that
detail:

- `importing` contains no import work;
- `buildingGraph` contains all nine import/enrichment/join stages and all eight
  graph-projection stages.

**Live stage telemetry is NOT yet earned.**

It would become worth considering only if observed users or support evidence
show a material need to:

- distinguish healthy long work from a stalled operation;
- identify a repeatedly slow or failing phase while the operation is still
  running;
- restore trust that cannot be achieved with truthful activity and guidance.

Even then, the operation layer would need to publish a typed live observation
with a stable stage identity and a deliberately human-safe label policy.
Presentation must not parse logs or infer a stage from time. A stage count
would still not justify a percentage because stage costs are highly unequal.

## 10. Presentation Philosophy Comparison

| Philosophy | Current API support | Truthfulness | Reassurance | Complexity | Operation changes |
| --- | --- | --- | --- | --- | --- |
| **A. Minimal calm** | Complete | High | High: says work is active and what to do | Low | None |
| **B. Calm + elapsed time** | Supported after controller start | Accurate but incomplete across reset/restart | Uncertain; may emphasize waiting and imply a missing ETA | Moderate presentation timer/state | None |
| **C. Richer staged progress** | Absent | Unsupported today | Unproven; detail may reassure or may add noise | High | Required live observation seam |

### Recommendation

Choose **A. Minimal calm**.

Its ideal information hierarchy is:

```text
Preparing MessageLens

[ indeterminate activity ]

Building local browsing data…
Keep MessageLens open while this finishes. You can use other apps.
```

This is a philosophy comparison, not an instruction to implement every line in
one pass. The one next slice below is narrower.

## 11. Completion Audit

### What is shown

The completion presentation shows an icon, **Import Complete!**, up to three
final counts, and either **Get Started** or **Done**.

### Usefulness and truth

- **Import Complete!** is understandable but understates that MessageLens also
  enriched content and built the Conversation Graph.
- **Imported**, **Projected**, and **Text enriched** are literal report facts.
  They are closer to diagnostics than human reassurance. Imported and
  projected message counts will often look duplicative without explaining the
  architecture.
- A completion acknowledgement is useful as a deliberate transition from a
  blocking setup operation into ordinary browsing.
- The build's durable result does not depend on pressing **Get Started**. Once
  the databases are ready, a fresh launch derives `notNeeded` from probes and
  can open ordinary MessageLens safely.

### Durability

The successful databases are durable. `OnboardingStatus.complete`, the final
report, and the completion overlay are process-local. If the app closes on the
completion screen, the screen and metrics are not restored; the next launch
probes ready data and proceeds normally.

No completion change is recommended in the next slice. A later focused pass
may decide whether a quieter human-facing completion should replace the three
diagnostic chips, but that question is independent of active progress truth.

## 12. Failure Audit

### Current human result

A caught controller failure eventually returns the human to an actionable
failure/retry presentation and may first perform automatic cleanup. Retry and
diagnostic export are available only after active work has ended.

### Presentation mismatches

- The progress widget can briefly promote raw `lastError` to headline level.
- The durable failure is always stored through the graph-projection failure
  API, so wording that asserts source import finished is not reliable for every
  possible failed stage.
- Raw exception text and reset reasons may be useful for support but are too
  prominent for a calm ordinary-user path.
- Retry wording says setup will rerun, which is truthful, but the surface does
  not consistently make explicit that it rebuilds from a clean start rather
  than resuming.
- Reset exceptions occur outside the Gate's controller catch and therefore do
  not share this deliberate failure presentation.

Partial derived state is appropriately hidden behind recovery and retry. The
human does not need row-level cleanup detail to understand that setup can be
tried again.

These findings justify a future failure-presentation audit, not a redesign in
this progress slice.

## 13. First Run Versus Reimport

The active operation is mechanically similar enough that first run and
reimport should use the same visual system.

The minimum meaningful wording distinction is:

```text
first run:
    preparing MessageLens / building local browsing data

reimport:
    rebuilding MessageLens browsing data
```

First run establishes the initial app-local representation. Reimport replaces
an existing derived representation. That difference deserves a verb, not a
separate progress design.

The production reset journey currently falls back through the first-run
wording. Whether it should call the direct reimport API is an operational and
journey-integration question outside this presentation audit.

## 14. Truth Budget

| We may truthfully show now | We cannot truthfully show now |
| --- | --- |
| Preparing before the controller starts | Current import/projection stage |
| Active local browsing-data construction | Percentage complete |
| Initial setup versus direct rebuild context | Rows or work units remaining |
| Indeterminate continued activity | Estimated time remaining |
| Process-local elapsed time after `startedAt` | Durable elapsed time across launch |
| Keep MessageLens open | Resume from the interrupted stage |
| Other apps may be used while MessageLens stays open | Safe completion after quitting or closing the window |
| Controller success | Safe cancellation |
| Final in-memory report counts | Exact failed stage through the shared failure API |
| Caught failure and clean retry | Import-versus-projection failure in every case |
| Probe-based recovery after interruption | A durable operation checkpoint |

This table is the guardrail for future progress UI work. Presentation may omit
available facts for calmness; it must never promote unavailable facts into
copy.

## 15. Exactly One Next Implementation Slice

```text
Next concern:
Give the human truthful keep-open guidance during active progress.

Why it comes next:
The surface already says what MessageLens is doing and proves that it remains
active, but it does not say what the human should do. The current explanatory
paragraph repeats the headline instead of resolving that uncertainty.

Current defect:
"MessageLens is building/rebuilding its local browsing data from Messages"
adds little beyond the status heading and omits the important fact that the
process must remain open because there is no durable resume checkpoint.

Smallest implementation:
Replace that one active-progress paragraph with concise first-run/reimport-safe
guidance: keep MessageLens open while it prepares the data, and make clear that
using other apps is fine. Preserve the existing headline, indeterminate
indicator, status derivation, completion, and failure surfaces.

Owner:
Onboarding progress presentation.

Operation-layer changes:
None.

Persistence impact:
None.

Restart impact:
None. The copy explains the existing process-local limitation; it does not
claim resume.

Presentation impact:
One repetitive paragraph becomes one actionable reassurance. No new control,
counter, timer, stage, or visual system.

Test seam:
Render first-run and direct-reimport active progress. Assert the keep-open and
use-other-apps guidance is present, the existing truthful coarse headings and
indeterminate indicator remain, and no cancellation or unsupported progress
claim appears.
```

## 16. Ownership And Change Verdict

| Component | Change needed for the recommended slice? | Reason |
| --- | --- | --- |
| Presence | No | Presence does not own the destructive operation or this legacy blocking progress projection |
| `ConversationGraphBuildOrchestrator` | No | No stage telemetry is requested |
| `ConversationGraphBuildController` | No | Existing running state is sufficient |
| `OnboardingGate` | No | Existing lifecycle and context are sufficient |
| Onboarding progress presentation | Yes, later bounded slice | Owns the repetitive paragraph and human guidance |

No operation-layer change is required because coarse truth remains sufficient.
The tempting seventeen-stage narrative would add machinery before a human need
has earned it.
