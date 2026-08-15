---
tier: project
scope: initial-setup-failure-recovery-surface
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: code
links:
  - ./21-INITIAL-IMPORT-GRAPH-BUILD-LIFECYCLE-AUDIT.md
  - ./23-PRODUCTION-IMPORT-PROGRESS-SURFACE-AUDIT.md
  - ./26-PRE-RESET-PREPARATION-PROGRESS-IMPLEMENTATION.md
  - ./27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md
  - ./28-INITIAL-SETUP-COMPLETION-SURFACE-AUDIT.md
  - ./29-CALM-INITIAL-SETUP-COMPLETION-HANDOFF-IMPLEMENTATION.md
  - ../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
tests: []
---

# Initial Setup Failure And Recovery Surface Audit

## Decision Summary

When setup fails, the human primarily needs to know **that setup did not
finish, whether MessageLens is still working or cleaning up, and what action is
available next**.

The current operation layer already proves enough coarse truth for a calm
primary failure surface. It does not prove which import or projection stage
failed. A richer failure taxonomy is therefore unnecessary for the human
headline and unsupported for stage-specific copy.

The current presentation has two distinct problems:

1. while the Gate is recording and handing off a caught controller failure,
   the active progress headline can display the controller's raw exception;
2. the later stable graph-projection presentation assumes source import
   completed even though every controller-lifecycle error is stored under the
   same graph-projection key.

The single next implementation slice should address the first problem:

> **Raw `lastError` must not become the active-progress headline. Replace it
> with one bounded, phase-neutral failure statement while leaving diagnostics,
> persistence, retry, and recovery unchanged.**

This comes first because the raw value is arbitrary developer-facing text and
can remain visible indefinitely if the failure-record handoff itself fails.
The stable failure hierarchy should be simplified in a later, separately
reviewed slice.

## 1. Operational Authorities

The failure experience is derived from several authorities rather than one
durable setup job:

```text
OnboardingGate
    process-local workflow and presentation status

ConversationGraphBuildController
    process-local running/succeeded/failed outcome and raw error string

OnboardingFailureStore
    durable, coarse import or graph-projection failure records

OnboardingEnvironmentReport
    source readiness, database probes, persisted failure records,
    and inferred incomplete-store classification

MessageDataResetService
    allow-listed deletion of rebuildable derived stores
```

There is no durable operation checkpoint, failed-stage identity, resume point,
or durable recovery state. Restart truth is reconstructed from persisted coarse
failure records and the files that survived.

## 2. Exact Failure Paths

### Path table

| Failure boundary | Origin and catch | Persisted evidence | Gate and environment result | Human presentation | Retry behavior |
| --- | --- | --- | --- | --- | --- |
| Mutation admission | `ArchiveMutationCoordinator.run()` denies a competing owner or another admission prerequisite throws. `OnboardingGate.startImportAndGraphBuild()` does not catch it. | None from Onboarding | Gate remains `awaitingUserAction`; environment facts are unchanged | Existing readiness/import surface remains. No stable failure explanation is shown. | The same action may be tried again when mutation authority is available. No work began and nothing resumes. |
| FDA recheck before reset | Gate finds `onboardingFullDiskAccessProvider == false`. This is a guarded return, not an exception. | None | Gate becomes `awaitingFda` | FDA guidance and Settings action | Import cannot begin until readiness is re-established. No derived data was reset. |
| First-run derived-data reset | Database close, allow-listed deletion, invalidation, or post-cleanup probing throws in `MessageDataResetService`. The service logs and rethrows; the first-run Gate clears preparation, invalidates the report, returns to `awaitingUserAction`, and rethrows. | No failure record | Usually the ordinary import/readiness presentation returns; residual file facts can cause another derived classification | No stable reset-failure message. In the covered clean case the human sees **Import My Messages** again, which can feel as if the button did nothing. | A new press runs reset again, then starts the build only if reset succeeds. |
| Direct-reimport reset | `_startReimport()` calls reset before publishing a reimport status and has no reset catch. | No failure record | Existing Gate state can remain `notNeeded` while the error escapes | No Onboarding failure surface is guaranteed | The direct-reimport caller must initiate another operation. |
| Controller service resolution | Resolving `ConversationGraphBuildService` throws inside the controller `try`. Controller records `failed`; Gate catches the rethrow. | Gate attempts one graph-projection record containing `Conversation graph build failed: <error>` | Gate returns to `awaitingUserAction`; probes decide whether failure, recovery, or ready-to-import content follows | Raw error can appear transiently first. Stable content depends on surviving files. | A visible retry invokes the full first-run reset and rebuild path. |
| Source import stages | Any of `import_chats`, `import_handles`, `import_contacts`, `import_messages`, or `import_attachments` throws. Controller and Gate catch as above. | Graph-projection record, despite import origin | Partial import rows or attachment archive effects may survive. Probe ratios may trigger automatic recovery; otherwise stable failure or ready-to-import content appears. | Current stable copy may incorrectly imply that import completed. | Retry resets derived import and graph stores, preserves archived payloads, and reruns all stages. |
| Text enrichment | `enrich_missing_text` throws after message import has returned. | Graph-projection record | Populated import data commonly makes incomplete-state recovery or graph-failure classification possible | Same transient raw and stable graph-failure surfaces | Clean rebuild, not resume |
| Import join stages | Any chat-message, chat-handle, or message-attachment join import throws. | Graph-projection record | Same probe-derived behavior as other partial import failures | Same current graph-failure presentation | Clean rebuild, not resume |
| Graph projection stages | Any handle, contact, chat, message, attachment, or edge projection throws. | Graph-projection record | Partial graph rows may survive; automatic recovery can be inferred from import-to-graph evidence | Same transient raw and stable graph-failure surfaces | Clean rebuild, not resume |
| Post-build version publication | The orchestrator returns, but `messageDataVersionProvider.bump()` throws inside the controller `try`. | Graph-projection record | Stores may already be fully ready. Environment classification gives ready stores precedence, while the Gate's `awaitingUserAction` override remains. | The overlay can show **Environment Ready** and only **Re-check Environment**, despite a caught operation failure. | Re-check can clear the override; no stage resume exists. |
| Clearing an old graph failure after controller success | `clearGraphProjectionFailure()` throws after the controller has published `succeeded`. Gate treats the exception as build failure and attempts to save a new graph failure. | A new graph record if that second write succeeds | Stores and controller can be successful while Gate returns to `awaitingUserAction` | As above, the report can truthfully classify the environment as ready while the blocking overlay remains until re-check | Re-check derives normal readiness; no rebuild is mechanically required. |
| Persisting the caught failure | `saveGraphProjectionFailure()` itself throws. The Gate catch has no secondary catch around this write. | None or an older record | `_finishFirstRunWithFailure()` is never reached; Gate can remain `buildingGraph` while controller remains `failed` | Raw controller error can remain the progress headline indefinitely | Relaunch discards process state and relies on probes; no in-process stable retry contract is reached. |
| Abrupt quit or crash | Process ends during reset or any build stage. No catch is guaranteed to run. | No new caught-failure record | Next launch classifies surviving files. A sufficiently populated import ledger plus clearly incomplete graph may trigger automatic recovery; other partial shapes become ready-to-import or graph-failure states. Fully ready stores may open normally. | The human sees inferred recovery or a probe-derived readiness/failure surface, not proof of a recorded exception. | There is no resume. Recovery or the next import action resets derived stores and rebuilds. |
| Automatic-recovery mutation denial | Another mutation owner blocks recovery. Gate catches only `ArchiveMutationDeniedException`, clears the recovery override, and re-evaluates later. | None | No recovery mutation occurs | Recovery may disappear while the environment is re-evaluated | Recovery can be attempted again after authority becomes available. |
| Automatic-recovery reset failure | Reset service logs and rethrows; `_runAdmittedAutomaticRecovery()` catches it, suppresses another automatic attempt in the current Gate instance, then returns to `awaitingUserAction`. | No reset-failure record | Incomplete stores and any older pipeline record remain | Stable presentation is derived from those old facts; the reset exception itself is absent | A human retry invokes reset again. A later process launch may attempt automatic recovery again. |

### Mechanically different failures must remain distinct

The controller catch boundary covers service resolution, all 17 orchestrator
stages, and the message-data-version bump. It does not cover initial mutation
admission, FDA rejection, reset, or a failure to persist the caught error.

The current UI often collapses these paths into the same awaiting-action
surface, but the operation does not provide one uniform failure result.

## 3. Current Failure And Recovery Surfaces

### Transient active-progress failure

While Gate status remains `buildingGraph` or `reimportBuildingGraph`,
`_ProgressContent` watches controller state. When the controller changes to
`failed`, the headline becomes:

```text
<ConversationGraphBuildState.lastError>
```

or, only when that value is null:

```text
MessageLens could not prepare browsing data
```

The indeterminate progress bar and existing keep-open paragraph remain below
the error headline until the Gate completes its failure handoff.

### Stable import-failure surface

Current exact primary content:

```text
Import Attempt Failed

MessageLens could reach your local sources, but the last import attempt did
not finish successfully. You can retry now or send a report to the developer.

[Environment summary]
[What to check]

Try Import Again
Send Report To Developer
```

`What to check` can contain:

- a persisted-failure timestamp described as coming from a previous launch;
- the raw persisted error message;
- source-availability advice;
- report-export advice;
- a clean-pass statement when no imported rows remain.

There is no active production writer of `saveImportFailure()` in current code.
This state is currently reachable through development simulation, historical
persisted import records, and probe classification associated with those
records rather than the active Gate catch.

### Stable graph-projection-failure surface

Current exact primary content:

```text
Messages Could Not Be Prepared

MessageLens imported source data, but the app could not finish preparing it
for use. You can retry now or send a report to the developer.

[Environment summary]
[What to check]

Retry Import and Graph Build
Send Report To Developer
```

`What to check` can contain:

- a persisted-failure timestamp described as coming from a previous launch;
- the raw persisted error message;
- a statement that imported data exists and the failure therefore happened
  while preparing it for browsing;
- a statement that browsing data is empty or incomplete;
- report-export advice.

### Automatic-recovery surface

Current exact content:

```text
Cleaning Up A Previous Setup Attempt

MessageLens detected signs that an earlier setup attempt left incomplete local
data. It is clearing that data now so setup can restart cleanly.

[resetAppDatabasesReason]

[activity indicator]
```

The displayed reason can expose terms such as **import ledger**,
**conversation graph**, **graph projection**, row-count disparity, and
**failure**. There is no action while recovery is running.

After successful cleanup, the Gate returns to `awaitingUserAction`; the empty
derived stores normally classify as `readyToImport`. Setup does not
automatically restart. After cleanup failure, the Gate also returns to
`awaitingUserAction`, but the reset exception is not shown.

### Report-export feedback

The support action reports one of:

```text
MessageLens could not prepare a diagnostic report right now.
Email draft prepared with the support bundle attached.
Support bundle prepared. It was opened in Finder so it can be attached manually.
```

The failure surface also explains that MessageLens will try to prepare an email
to `messagelens@gmail.com` and otherwise reveal the bundle in Finder.

## 4. Raw-Error Headline Audit

### Can an ordinary human see it?

Yes. The controller publishes `failed` before rethrowing to the Gate. Riverpod
can rebuild `_ProgressContent` while the Gate is still awaiting the durable
failure write and failure-state handoff.

### How long can it remain?

In the normal path it can remain for the duration of the overlay failure-store
write, environment invalidation, and resulting frame scheduling. This may be
brief but is not assigned a fixed upper bound.

If `saveGraphProjectionFailure()` hangs, the headline can remain for the
duration of that hang. If the write throws, the Gate never calls its normal
failure-finishing method, so the raw headline can remain until another state
change or process restart.

### What can it contain?

The controller uses `error.toString()` without sanitization or length
restriction. It can therefore contain:

- SQLite exception text and SQL statements;
- database and attachment paths;
- provider or service-resolution terminology;
- filesystem errors;
- internal class and stage language;
- arbitrarily long third-party exception descriptions.

The controller does not intentionally append a stack trace, although an
exception's own string representation could contain stack-like detail.

### Human value

The raw string does not determine any user action. The action remains to wait
for handoff, retry from a clean rebuild when offered, or provide diagnostics.
It therefore has diagnostic value but no headline value.

**Verdict:** raw error text does not belong at headline level.

## 5. Persisted Failure Classification

### Current recording behavior

Every error caught around `_runConversationGraphBuild()` is written through:

```text
saveGraphProjectionFailure(
    message: "Conversation graph build failed: <error>"
)
```

The current production Gate never calls `saveImportFailure()`.

| Actual origin | Durable category |
| --- | --- |
| Controller service resolution | graph projection |
| Chats, handles, contacts, messages, or attachments import | graph projection |
| Rich-text enrichment | graph projection |
| Import joins | graph projection |
| Graph entity or edge projection | graph projection |
| Message-data-version publication | graph projection |
| Clearing the prior graph failure after controller success | graph projection, if the replacement write succeeds |

### What the record proves

It proves only that:

- the Gate caught an exception from the controller lifecycle or its immediate
  post-controller failure-clear step;
- MessageLens recorded an error string and UTC timestamp;
- the operation did not reach the Gate's normal success handoff.

### What it does not prove

It does not prove:

- source import completed;
- graph projection began;
- a graph-specific stage failed;
- any particular stage was current;
- no derived rows were written;
- derived stores are incomplete;
- attachment archival is complete or incomplete;
- the failure happened on a previous launch;
- retry can resume from the failed point.

The `graphProjection` phase is currently a coarse storage bucket, not reliable
failed-stage evidence.

## 6. Explanatory-Copy Truth Audit

| Current statement | Classification | Evidence assessment |
| --- | --- | --- |
| **Import Attempt Failed** | Always truthful only when backed by a genuine import failure record | Current active Gate does not create that record; the state mainly serves historical/simulated evidence. |
| **MessageLens could reach your local sources...** | Truthful for the currently classified surface, but not proof about the complete prior attempt | Environment classification checks current source access before surfacing the failure. |
| **Messages Could Not Be Prepared** | Always truthful at a coarse outcome level | The Gate did not reach ordinary completion. |
| **MessageLens imported source data, but...** | Truthful only for some failures | Service resolution and early import stages can fail before a completed source import. Partial rows do not prove completed import. |
| **The imported message data exists, so the failure happened while preparing it for browsing.** | Unsupported | A source importer can write rows before a later source-import or join failure. Existence does not locate the failed phase. |
| **The conversation browsing data is still empty or incomplete.** | Truthful when guarded by `!conversationGraph.hasData`, but the word incomplete is broader than the probe | The guard proves no positive message row count, not why. |
| **This ... failure was recorded ... during a previous launch.** | Unsupported | Persistence proves that a record was read from overlay, not that it originated in a different process. A just-caught current-launch failure is immediately re-read through the same path. |
| **No usable imported message data was left behind...** | Always truthful under its row/file guard | The guard verifies absence or no positive imported message count. |
| **The next retry will start from a clean import pass.** | Truthful when reset succeeds | Every first-run retry invokes derived-data reset before all build stages. |
| **Cleaning Up A Previous Setup Attempt** | Truthful as probe-derived orientation | Recovery is triggered by evidence of incomplete derived stores, not necessarily a caught error. |
| **It is clearing that data now...** | Technically accurate but too ambiguous | Only allow-listed derived stores are reset, but “that data” can sound like Apple source or preserved attachments. |
| **...so setup can restart cleanly.** | Truthful as capability, not automatic behavior | Recovery returns to awaiting action; it does not itself restart setup. |

## 7. Human Truth Versus Diagnostic Truth

| Current detail | Classification | Primary-surface verdict |
| --- | --- | --- |
| Setup/import did not finish | HUMAN ORIENTATION | Keep, using phase-neutral language supported by the operation boundary |
| Recovery is currently cleaning incomplete derived stores | HUMAN ORIENTATION | Keep, but avoid internal store names |
| Try again / re-check action | HUMAN ACTION | Keep and simplify where a future slice permits |
| Retry starts a fresh rebuild | HUMAN ACTION / REASSURANCE | Useful supporting truth |
| Apple source stores are not MessageLens deletion targets | REASSURANCE | Architecturally supportable, but use only if the failure surface needs it |
| Archived payloads are outside reset | REASSURANCE / ARCHITECTURAL SAFETY | Important invariant, but not proof that every attachment was archived |
| Raw exception string | DIAGNOSTIC | Remove from headline; retain in report/log evidence |
| Failure timestamp | DIAGNOSTIC | Secondary or report-only; persistence does not prove previous launch |
| Reset reason | DIAGNOSTIC / IMPLEMENTATION DETAIL | Do not foreground; it does not change the human action |
| Import versus graph labels | IMPLEMENTATION DETAIL under current evidence | Do not use as primary failure classification |
| Environment source and derived-store rows | DIAGNOSTIC | Useful in report/development surfaces, not primary orientation |
| Report-export instructions | HUMAN ACTION with diagnostic purpose | Retain as secondary support guidance |

## 8. Retry Semantics

Both **Try Import Again** and **Retry Import and Graph Build** invoke the same
method:

```text
OnboardingOverlayActions.startImportAndGraphBuild()
    -> OnboardingGate.startImportAndGraphBuild()
```

The method:

1. requires Gate state `awaitingUserAction`;
2. requests `onboardingImport` mutation authority;
3. rechecks FDA;
4. shows first-run preparation;
5. resets all allow-listed derived import and graph stores;
6. runs every controller/orchestrator stage from the beginning;
7. clears the graph-failure record only after successful controller return;
8. enters first-run `complete` on success.

Retry does not resume. It does not preserve partial import or graph stores once
reset succeeds. It does preserve overlay intent, preferences, and the archived
attachment payload directory.

Automatic recovery may already have reset partial stores before the retry
button appears. Even then, the explicit retry performs the same reset call
again before rebuilding.

The simplest truthful human description is:

```text
Try Again

MessageLens will prepare its local browsing data again from a clean starting point.
```

This audit does not adopt that copy or alter either label.

### Reimport context loss

A failed direct reimport also returns to the shared `awaitingUserAction`
surface. Its retry button calls the first-run method, uses the first-run owner,
and reaches first-run `complete`, whose action is **Get Started** rather than
**Done**. The operation remains a clean reset and rebuild, but the presentation
no longer retains the maintenance context that originated it.

## 9. Automatic Recovery Audit

Automatic recovery is triggered when the environment evaluator finds a
sufficiently populated import ledger that tracks the source and a clearly
incomplete graph, with either a recorded failure or a strong graph-row
shortfall.

The Gate:

1. schedules `recoveringFailedAttempt` after the current frame;
2. requests `automaticRecovery` mutation authority;
3. invokes the same allow-listed `resetDerivedData()` service;
4. clears its process-local recovery override;
5. invalidates the environment report and itself;
6. returns to `awaitingUserAction`.

There is no recovery percentage, stage detail, cancellation, or durable
recovery checkpoint. Successful cleanup normally leads to the ordinary import
action. It does not automatically retry the build.

If cleanup fails, the error is logged but not persisted as a reset failure.
Automatic recovery is suppressed for that Gate instance, the prior file and
failure evidence remains, and the stable surface is re-derived. A process
restart creates another opportunity to infer and attempt recovery.

## 10. Reset-Reason Prominence

The reset reason is displayed in its own bordered card during recovery. Current
possible values explain:

- that a previous import or graph-projection failure left a populated import
  ledger and incomplete graph; or
- that the graph has far fewer messages than the import ledger.

This detail does not change what the human can do. It is primarily diagnostic.
Terms such as ledger, graph, projection, and row disparity increase cognitive
load and may imply broader data deletion than the allow-listed reset performs.

**Recommendation:** keep the reason in diagnostics, not as prominent recovery
copy. This is not the next implementation slice.

## 11. Send Report To Developer Audit

The action appears on stable `importFailed` and `graphProjectionFailed`
surfaces when an environment report is available. It is presented as an
outlined peer beside the filled retry action, followed by a caption explaining
email-draft and Finder fallback behavior.

The action builds a privacy-bounded support bundle containing:

- current and previous application logs;
- available pipeline audit logs;
- a generated database-health report or a bounded health-generation error;
- failure report headers with environment state, blocker, source and derived
  probe paths/status/counts, persisted failure strings, and timestamp.

It does not intentionally include raw database files or row-level samples. It
attempts to open a mail draft with the bundle attached; otherwise it reveals
the bundle in Finder. Both fallback and export failure have explicit feedback.

The capability is useful and reasonably reliable as a secondary support
action. Presenting it beside retry and explaining its transport mechanics on
the primary surface makes the incident feel more severe and technical than
necessary. A future calm failure hierarchy should retain it as secondary
support, not remove it.

## 12. Attachment-Preservation Implications

The reset implementation deletes only enumerated rebuildable MessageLens
derived database files and sidecars. It does not target:

- Apple Messages `chat.db`;
- Apple Contacts databases;
- locally available Messages attachment source payloads;
- the MessageLens archived attachment payload directory;
- overlay intent or preferences.

Failure and recovery copy may therefore truthfully distinguish derived-store
cleanup from Apple source data. It must not claim:

- that every attachment was archived before failure;
- that every cloud-evicted payload is recoverable;
- that nothing could be lost outside this reset operation;
- that “all data” is rebuilt or deleted.

The recovery phrase **clearing that data** currently muddies this distinction
because its antecedent is only **incomplete local data**, not specifically
rebuildable browsing stores.

## 13. Abrupt Termination

A quit or crash does not create a caught-failure record. On next launch:

- process-local Gate and controller state is gone;
- no operation resumes;
- source access and derived files are probed anew;
- populated import plus clearly incomplete graph evidence can trigger automatic
  cleanup;
- smaller or different partial shapes can surface ready-to-import or
  graph-failure content without an explicit recorded exception;
- stores that satisfy readiness can open normally even if the completion
  handoff was never shown.

The recovery heading refers to detected **signs** of an incomplete attempt,
which is compatible with inferred evidence. Stable graph-failure notes become
less reliable: they can describe a “failure” and its phase even when the app
only knows that current stores are incomplete.

Presentation must not imply that MessageLens recorded an explicit prior error
unless a persisted record actually exists. Even with such a record, the
current model cannot prove that it came from a previous launch.

## 14. Failure Philosophy Comparison

### A. Diagnostic-first failure

```text
Import Attempt Failed

SQLiteException...
graph projection...
reset reason...

Retry Import and Graph Build
Send Report To Developer
```

| Criterion | Assessment |
| --- | --- |
| Truthfulness | Individual raw facts may be literal, but the phase classification can be false |
| Human comprehension | Low |
| Reassurance | Low; technical detail can amplify concern |
| Diagnostic usefulness | High |
| Cognitive load | Highest |
| Implementation complexity | Already largely present |
| Evidence support | Does not support failed-stage claims |

### B. Calm human failure

```text
MessageLens couldn't complete this attempt.

You can try again from a clean starting point.

Try Again
```

| Criterion | Assessment |
| --- | --- |
| Truthfulness | Strong across caught controller phases |
| Human comprehension | High |
| Reassurance | Good if it avoids unearned preservation promises |
| Diagnostic usefulness | Low in the primary surface |
| Cognitive load | Lowest |
| Implementation complexity | Low |
| Evidence support | Existing coarse failure truth is sufficient |

### C. Calm failure with progressive diagnostics

```text
MessageLens couldn't complete this attempt.

Try Again

Technical details
Send Report To Developer
```

| Criterion | Assessment |
| --- | --- |
| Truthfulness | Strong when primary copy stays phase-neutral |
| Human comprehension | High |
| Reassurance | Strongest balance |
| Diagnostic usefulness | Preserved on demand |
| Cognitive load | Low initially |
| Implementation complexity | Higher because disclosure behavior does not yet exist |
| Evidence support | Current report data supports secondary diagnostics, not precise primary classification |

### Recommendation

Adopt **C as the long-term information hierarchy**: calm human truth first,
diagnostic evidence second. Do not introduce a disclosure component merely to
reach that hierarchy. The existing report action can remain the secondary
diagnostic route while bounded corrections simplify the primary surface.

## 15. Richer Failure Data Verdict

> **Existing coarse failure truth is sufficient for a calm user-facing failure
> surface.**

The primary UI needs to know only that the current setup/rebuild operation did
not reach completion and whether cleanup or retry is available. The Gate and
controller already establish those facts in the caught controller path.

A richer typed failure observation would be required only if product copy must
name the exact failed phase or offer phase-specific remediation. Current code
does not justify that requirement. No new taxonomy should be created merely to
support a calmer headline.

## 16. Reset-Failure Assessment

After first-run **Preparing setup...**, a reset exception:

1. clears the preparation override;
2. invalidates the environment report;
3. sets the Gate to `awaitingUserAction`;
4. rethrows the original error with its stack trace.

The reset service logs the exception and a bounded stack excerpt, but the
ordinary UI receives no stable failure fact. In the covered clean case the
readiness screen returns with **Import My Messages**. The interaction can feel
like the button did nothing.

This is a real missing state transition, and direct reimport has an even weaker
reset-failure presentation. It deserves a dedicated operational audit because
the current coarse controller failure record cannot truthfully represent it.
It should not be folded into the next presentation-only slice.

## 17. Timestamp Assessment

The timestamp can help support distinguish an older persisted record from a
new report, but the current record has no launch identity. The UI therefore
cannot truthfully say **during a previous launch** merely because the record is
loaded from persistence.

For an ordinary human, the date and minute do not change the action. They make
the screen resemble an error log.

**Recommendation:** timestamp belongs in diagnostic/report output, not primary
failure guidance. If later retained through disclosure, display the recorded
time without inferring which launch created it.

## 18. First Run Versus Reimport

Caught controller failures from first run and direct reimport ultimately share
the same `awaitingUserAction` presentation. The operation-level truth is
similar: browsing data was not completed and another attempt starts from a
clean derived-store state.

One primary failure system is appropriate. The context may justify small copy
differences:

| Context | Useful distinction |
| --- | --- |
| First run | Setup did not finish; ordinary browsing is not ready |
| Reimport | Rebuilding did not finish; the maintenance operation failed |

The current Gate does not preserve this context after failure. A shared calm
statement about preparing browsing data is truthful for both. Different
headings, retry architecture, or failure taxonomies are not justified now.

The loss of **Done** versus **Get Started** context on a failed-reimport retry
is a separate lifecycle observation, not a reason to split the failure system.

## 19. Failure Truth Budget

| We may truthfully say | Grounding |
| --- | --- |
| This setup or rebuild attempt did not complete normally. | The Gate did not reach its normal operation handoff. |
| The current attempt has stopped after a caught controller failure. | Controller is terminal `failed`; no stage continues in that lifecycle. |
| MessageLens is cleaning up an incomplete setup attempt. | Gate status is `recoveringFailedAttempt` and reset is in flight. |
| Setup can be tried again when the action is offered. | Stable failure action invokes a new admitted operation. |
| Retry starts again from a clean derived-data starting point when reset succeeds. | Every first-run retry resets allow-listed derived stores before all stages. |
| MessageLens reset does not target Apple Messages or Contacts source stores. | Reset uses a fixed internal derived-file allow-list. |
| Archived attachment payloads are outside ordinary reset. | Permanent attachment-preservation invariant and file-store boundary. |

| We should not claim | Why unsupported |
| --- | --- |
| Source import completed before failure. | Service resolution or an import stage may have failed. |
| The graph alone failed. | All caught controller errors use the graph-projection key. |
| The exact failed stage is known. | No failed-stage identity leaves the orchestrator. |
| A persisted record came from a previous launch. | Persistence has timestamp but no launch identity. |
| No partial derived data exists. | Stages commit independently and abrupt termination can leave files. |
| The operation will resume where it stopped. | No checkpoint or resume contract exists. |
| Automatic recovery will restart setup. | Recovery only resets and returns to awaiting action. |
| Every attachment is preserved or recoverable. | Build success/failure does not prove payload availability or archival completeness. |
| “Everything” will be deleted and rebuilt. | Apple sources, overlay data, preferences, and archived payloads are outside reset. |
| A reset failure was recorded for later diagnosis. | Reset errors are logged but not persisted as Onboarding failure records. |

## 20. Exactly One Next Implementation Slice

```text
Next concern:
    Remove the transient raw-error headline from active setup progress.

Why it comes next:
    It is the only ordinary production headline whose content is an arbitrary
    exception string. Its lifetime is unbounded when failure persistence or
    handoff fails, and it never changes the human action.

Current defect:
    ConversationGraphBuildController publishes error.toString(), and
    _progressStatusMessage returns it verbatim while the Gate still owns a
    building/rebuilding status.

Smallest implementation:
    For ConversationGraphBuildStatus.failed inside the existing progress
    presentation, return one fixed, phase-neutral human statement. Preserve
    lastError in controller state, logs, persisted failure evidence, stable
    diagnostics, and support-bundle export.

Owner:
    Onboarding presentation.

Operation-layer changes:
    None.

Persistence impact:
    None.

Recovery impact:
    None.

Presentation impact:
    During the controller-to-Gate failure handoff, the progress headline is
    bounded human orientation rather than raw diagnostic text. Stable failure
    and recovery surfaces remain unchanged for a later review.

Test seam:
    A focused progress widget test supplies a failed controller state with a
    deliberately technical error and proves that the bounded headline is
    shown while the raw string is absent. Existing Gate failure, persistence,
    retry, recovery, and diagnostic-report tests remain unchanged.
```

## 21. Presence Assessment

No Presence change is required.

Presence renders the accepted readiness workflow before the Gate-owned import
operation begins. It does not own import errors, reset, automatic recovery,
diagnostic export, or retry. Making the Gate-owned failure presentation calmer
must not turn Presence into an error-processing or archive-recovery engine.

## Final Answer

> **When setup fails, the human primarily needs to know that setup did not
> finish, whether MessageLens is still working or cleaning up, and what they
> can do next. The smallest next correction is to stop raw controller errors
> from becoming the active-progress headline.**
