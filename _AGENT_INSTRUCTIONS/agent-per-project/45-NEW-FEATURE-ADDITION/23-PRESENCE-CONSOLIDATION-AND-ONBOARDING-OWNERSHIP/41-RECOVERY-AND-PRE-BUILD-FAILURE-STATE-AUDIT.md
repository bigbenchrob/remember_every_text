---
tier: project
scope: recovery-and-pre-build-failure-state
owner: agent-per-project
last_reviewed: 2026-08-15
source_of_truth: code
links:
  - ./21-INITIAL-IMPORT-GRAPH-BUILD-LIFECYCLE-AUDIT.md
  - ./25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md
  - ./26-PRE-RESET-PREPARATION-PROGRESS-IMPLEMENTATION.md
  - ./27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md
  - ./30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md
  - ./40-AUTOMATIC-RECOVERY-PRESENTATION-AUDIT.md
  - ./38-REMOVE-AUTOMATIC-RECOVERY-DIAGNOSTIC-REASON-IMPLEMENTATION.md
  - ./39-CALM-TRUTHFUL-AUTOMATIC-RECOVERY-COPY-IMPLEMENTATION.md
tests:
  - test/essentials/onboarding/application/onboarding_gate_provider_test.dart
  - test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart
  - test/essentials/onboarding/infrastructure/persistence/filesystem_derived_message_data_file_store_test.dart
---

# Recovery And Pre-Build Failure State Audit

## Executive Answer

There are four distinct pre-build and recovery operational truths:

1. a required prerequisite is blocked, as when Full Disk Access is false;
2. mutation authority is busy, so the requested operation was not admitted;
3. admission fails for a reason other than ordinary contention, so the
   operation could not start; and
4. reset was admitted and then failed, after derived stores may already have
   changed.

The settled controller failure is a fifth, later truth: the build started and
failed inside its existing caught and persisted boundary.

The human-facing gap that matters next is the fourth case. An admitted reset
failure is real operation truth in the current process, but current code
usually discards that truth and presents only whatever the resulting files
later imply. This can make a failed preparation look as though nothing
happened.

The smallest correct state model is a **process-local Onboarding preparation-
failure state** for Onboarding-owned pre-controller failures. It should not be
persisted. Restart should continue to derive durable truth from the files and
probes that remain. Ordinary contention and FDA blocking must stay outside
that failure state.

## 1. Failure-Family Inventory

### Prerequisite blocked

The current FDA guard is a truthful prerequisite branch:

```text
onboarding import admitted
    -> current FDA check is false
    -> no reset
    -> no build
    -> awaitingFda
```

The user must grant or restore source access. This is not a reset failure.

### Mutation busy

`ArchiveMutationCoordinator.run()` throws
`ArchiveMutationDeniedException` when another owner already holds mutation
authority. The requested action is never called. No reset work begins and no
derived file changes on behalf of the denied request.

This means **not admitted yet**, not **started and failed**.

### Other admission failure

Admission can fail before the action for reasons other than contention. For
the current first-run and automatic-recovery operations, the principal code-
grounded example is failure to resolve admitted archive authority. High-risk
operations such as the standalone `messageDataReset` request can also throw
`ArchiveCheckpointRequiredException` when production checkpoint evidence is
missing or invalid.

No reset begins in these cases, but the condition is not ordinary temporary
contention. It should not be described as a reset failure.

### Admitted reset failure

All audited reset callers ultimately invoke
`MessageDataResetService.resetDerivedData()`. After admission, that service
performs several sequential effects. An exception can therefore occur after
one or more derived files have already been removed.

This is the missing operational truth:

```text
preparation was admitted
    -> reset began
    -> reset did not finish normally
    -> derived filesystem state may have changed
```

### Controller failure

Once reset succeeds, `ConversationGraphBuildController.runOnce()` has its own
caught failure boundary. `OnboardingGate` records a coarse graph-projection
failure, returns to `awaitingUserAction`, and exposes the settled stable failure
surface. This audit does not redesign that path.

## 2. Denial Versus Failure

| Property | Admission denied | Admitted reset failed |
| --- | --- | --- |
| Requested action called | No | Yes |
| Reset began | No | Yes |
| Derived files may have changed | No | Yes |
| Coordinator authority released | The competing owner retains its authority | The failed owner's authority is released by `finally` |
| Immediate retry safety | Safe after the current owner releases | Mechanically safe, but the underlying I/O problem may recur |
| Durable evidence | None from this request | Remaining and missing files, sidecars, and logs |
| Correct human interpretation | MessageLens could not start this yet | MessageLens started preparation but could not finish it |

Collapsing these cases would either overstate harmless contention or understate
a potentially partial durable mutation.

## 3. First-Run Mutation-Admission Denial

The path is:

```text
Import My Messages
    -> EnvironmentReadinessActions or OnboardingOverlayActions
    -> OnboardingGate.startImportAndGraphBuild()
    -> ArchiveMutationCoordinator.run(onboardingImport)
    -> ArchiveMutationDeniedException
```

`OnboardingGate.startImportAndGraphBuild()` does not catch the exception. The
Gate remains `awaitingUserAction`; `_startImportAndGraphBuild()` was never
called, so no FDA check, preparation overlay, reset, or build occurs.

Current callback behavior is inconsistent but never human-facing:

- `EnvironmentReadinessPanelView` discards the returned Future;
- the production overlay awaits the Future in an async button callback but has
  no local error projection; and
- provider action methods simply relay the Future.

The coordinator records the denied operation, owner, timestamp, and count in
process-local `ArchiveMutationCoordinatorState`. It does not itself log the
denial. No durable failure is written.

The readiness action remains visible and can be tried again. Once the current
owner releases authority, retry is naturally safe because the denied request
performed no mutation.

**Verdict:** ordinary admission denial is not setup failure. It means
MessageLens is busy and could not start this operation yet. A future bounded
busy indication may be useful, but no failure state is justified by denial
alone.

## 4. First-Run FDA Block

The outer `onboardingImport` operation has already been admitted when the
current FDA guard is read. If it is false, the Gate sets `awaitingFda` and
returns. The coordinator releases authority normally.

No reset or graph build begins. The existing FDA presentation supplies the
required human action. This path already has a truthful state and does not
belong in a generic preparation-failure surface.

## 5. First-Run Reset Failure

The current sequence is:

```text
onboardingImport admitted
    -> FDA succeeds
    -> Gate publishes importing
    -> Preparing setup... paints
    -> resetDerivedData()
    -> reset throws
```

The reset service may already have:

- closed the source-scoped import database;
- closed the Conversation Graph database;
- removed some or all active database files and SQLite sidecars;
- removed some retired cleanup files; or
- reached provider invalidation or data-version publication.

Database-close errors are deliberately logged as warnings and do not stop
deletion. File deletion itself is sequential. A later deletion can therefore
throw after an earlier base file or sidecar was removed. If deletion throws,
provider invalidation and the data-version bump have not yet run. This can
leave closed provider instances and partially changed files in the current
process until subsequent reconciliation.

The Gate catches the reset exception only to unwind presentation:

1. clear the `importing` override;
2. invalidate the environment report;
3. set `awaitingUserAction`; and
4. rethrow the original error with its stack trace.

No pipeline failure is persisted. The build does not start. The app-owned
button paths do not turn the rethrown error into human feedback.

After environment re-evaluation, the person may see:

- **Import My Messages** if enough derived files disappeared;
- a stable graph-failure surface if populated incomplete stores remain; or
- another automatic-recovery attempt if the recovery heuristic still holds.

The displayed state describes current files, not the fact that the operation
the person just started failed. The existing test proves the clean fixture
returns to **Import My Messages**, which is mechanically retryable but can feel
like a no-op loop.

**Verdict:** current unwind is operationally safe enough to avoid a stranded
progress overlay, but it is not a complete human state transition.

## 6. Automatic-Recovery Admission Denial

Automatic recovery publishes `recoveringFailedAttempt` before requesting
mutation authority. If another owner holds authority:

1. `ArchiveMutationDeniedException` is caught;
2. in-flight and suppression flags are cleared;
3. the recovery override is cleared;
4. the Gate logs a warning; and
5. the Gate invalidates itself.

No reset occurs. The recovery overlay may therefore appear briefly and then
disappear.

Because suppression is cleared and the unchanged environment report still
requests recovery, the invalidated, still-watched Gate can schedule another
attempt without a timer or backoff. Repeated denial and presentation flashes
are mechanically possible while another owner remains active; the exact visual
cadence is frame-dependent.

**Verdict:** this is a deferred automatic operation, not a recovery failure.
It needs correct deferral/backoff behavior before it needs a failure message.

## 7. Automatic-Recovery Other Admission Failure

`_runAutomaticRecovery()` catches only `ArchiveMutationDeniedException`.
Another exception from admission escapes an unawaited Future. In that path:

- `_automaticRecoveryInFlight` remains true;
- `_automaticRecoverySuppressed` remains true;
- the recovery override remains active; and
- no `finally` restores an environment-derived state.

The non-interactive recovery surface can therefore remain indefinitely even
though no reset began. This is an error-handling hole, not evidence that a
durable reset-failure record is needed.

The eventual implementation must always unwind automatic-recovery process
state. It must still distinguish a busy denial from a non-contention error.

## 8. Automatic-Recovery Reset Failure

Once automatic recovery is admitted, the same reset specialist runs. Its
exception is caught inside `_runAdmittedAutomaticRecovery()` and logged as an
automatic reset failure. The error is not rethrown or persisted.

The `finally` block:

- clears the in-flight flag;
- keeps automatic recovery suppressed for the current Gate instance;
- clears the recovery override;
- invalidates the environment report and Gate; and
- publishes `awaitingUserAction`.

The old pipeline failure record, if one existed, remains. The UI that replaces
recovery depends entirely on surviving files and existing coarse evidence. It
does not identify the reset failure.

Manual retry invokes the ordinary first-run action and runs reset again. A
manual environment refresh clears suppression. A new process also begins with
fresh suppression flags and may infer automatic recovery again.

**Verdict:** the recovery operation really failed and partial deletion is
possible. A calm process-local failure orientation is justified. Persisting a
new reset-failure record is not yet justified.

## 9. Direct-Reimport Reset Failure

`startReimport()` requests outer `onboardingImport` authority and then calls
reset before publishing `reimporting` or `reimportBuildingGraph`.

There is no catch around reset. Failure therefore:

- leaves Gate status `notNeeded`;
- shows no progress or failure surface;
- skips the build;
- propagates through the returned Future; and
- does not invalidate the environment report.

No current `lib/` caller invokes `startReimport()`. The path remains covered by
Gate tests but is dormant in production composition. It demonstrates the same
missing reset-failure truth, but it should not determine the priority or scope
of the next production correction.

## 10. Explicit Reset Message Data Failure

The production Settings flow is:

```text
Reset message data...
    -> non-dismissible confirmation dialog
    -> Proceed
    -> confirmResetAndPrepareReimport()
    -> resetDerivedData()
    -> messageDataReset mutation admission
    -> reset
    -> completion dialog
    -> refresh onboarding environment
```

Standalone `messageDataReset` requires a verified production checkpoint. Its
admission can therefore fail through ordinary contention or
`ArchiveCheckpointRequiredException` before deletion.

If reset throws after admission, the service logs and rethrows. The completion
dialog and environment refresh are skipped. The Settings action chain awaits
the Future but provides no catch or human-facing error. The person remains in
Settings after the confirmation dialog has disappeared.

Partial derived-store deletion is possible. The next launch probes the files
that remain and may enter ready-to-import, stable failure, or automatic
recovery. The current launch does not deliberately reconcile the environment
after this failure.

This is a second production example of the same admitted reset-failure truth,
but presentation ownership is contextual: Settings owns the explicit reset
interaction, while Onboarding owns first-run and automatic-recovery
presentation.

## 11. Shared Mechanical Properties

| Property | First-run reset | Automatic recovery | Direct reimport | Explicit Reset Message Data |
| --- | --- | --- | --- | --- |
| Reset specialist | `MessageDataResetService` | Same | Same | Same |
| Outer mutation operation | `onboardingImport` | `automaticRecovery` | `onboardingImport` | `messageDataReset` |
| Reset request re-enters outer owner | Yes | Yes | Yes | No outer owner |
| Production checkpoint enforced for nested reset | No; outer policy remains authoritative | No; outer policy remains authoritative | No; outer policy remains authoritative | Yes |
| Deletion allow-list | Same four database families and sidecars | Same | Same | Same |
| Partial durable mutation possible | Yes | Yes | Yes | Yes |
| Reset error persisted | No | No | No | No |
| Environment invalidated on failure | Yes | Yes | No | No |
| Human failure feedback | None | Later environment-derived surface only | None; no production caller | None |
| Retry | Ordinary first-run retry | Ordinary first-run retry | No production action | Repeat Settings reset or next onboarding action |

These are genuinely instances of one mechanical truth: **an admitted derived-
store reset did not finish**. They do not require one universal UI owner.
Shared operation truth and shared presentation are different questions.

## 12. Attachment-Preservation Verification

No audited failure path can broaden deletion into preservation data.

The reset service passes only private `AppDatabaseFile` base-name allow-lists
to `DerivedMessageDataFileStore`. The filesystem adapter:

- accepts filenames, not paths;
- rejects absolute, parent-relative, and path-like values;
- deletes only each base file plus `-wal` and `-shm`;
- does not enumerate the archive root;
- does not follow a symlinked database file; and
- has no attachment-archive path authority.

Therefore partial failure remains bounded to:

```text
macos_import_ss.db
working_ss.db
macos_import.db
working.db
and their SQLite sidecars
```

The following remain outside every reset target set:

- Apple Messages;
- Apple Contacts;
- locally available Messages attachment payloads;
- archived attachment payloads;
- overlay and user intent;
- Presence state; and
- preferences.

No attachment-preservation safety issue was found, so this audit may continue.

## 13. Durable Evidence After Reset Failure

| Evidence | What it proves | What it cannot prove |
| --- | --- | --- |
| Missing/present derived base files | Current physical state of a named store | Why it is missing or whether reset completed |
| Remaining SQLite sidecars | A companion file remains | Whether its base store is logically usable |
| Database readability and row-count probes | Current readable shape and approximate content | Exact failed reset action or chronology |
| Conversation Graph readiness probe | Whether the minimum graph shape is usable | Whether all build stages completed |
| Existing import/graph failure record | A prior controller failure was recorded | That the later reset failed |
| Reset and Gate logs | Technical exception and operation trace for diagnosis | Durable workflow authority or retry state |
| Mutation coordinator state | Current owner and process-local denial history | A durable operation result after restart |

The filesystem is the correct durable authority after restart. It supports
fresh classification and safe reset/rebuild. It does not preserve the current-
launch fact that an operation visibly started and then failed.

## 14. Error-Propagation Audit

| Case | Catch behavior | Persistence | Human projection |
| --- | --- | --- | --- |
| First-run busy denial | Not caught by Gate | None | None; readiness remains |
| First-run other admission error | Not caught by Gate | None | None; Future error |
| FDA false | Handled as `awaitingFda` | OS/source fact only | Existing FDA flow |
| First-run reset error | Caught for unwind, then rethrown | Logs only | None; environment-derived readiness returns |
| Automatic busy denial | Caught, logged, and immediately made eligible again | Coordinator state and logs only | Possible brief/repeated recovery flash |
| Automatic other admission error | Not caught; unawaited Future | None beyond framework/log handling | Recovery can remain stuck |
| Automatic reset error | Caught and logged only | Existing older failure may remain | Recovery disappears into environment-derived state |
| Direct-reimport reset error | Not caught | Logs only | None; ordinary app remains |
| Explicit reset admission/reset error | Not caught by caller | Coordinator/reset logs only | None after confirmation closes |
| Controller error | Caught, logged, and coarsely persisted | Overlay graph-failure bucket | Settled stable retry/support surface |

Several real failures are effectively invisible to the human. Awaiting a Future
through a Flutter callback does not itself create an application error state.

## 15. Operation Failure Versus Environment Result

Two truths can coexist:

```text
operation truth
    reset did not finish normally

environment truth
    these particular files and rows exist now
```

After partial failure, Environment Readiness may truthfully classify the files
as:

- `readyToImport` if the import store is absent or empty;
- `graphProjectionFailed` if populated import and incomplete graph evidence
  remains;
- eligible for automatic recovery when the conservative threshold still
  holds; or
- `ready` if the remaining graph passes its minimum readiness checks.

None of those facts negates the process-local operation failure. During the
same launch, the human benefits from both: first acknowledge that preparation
stopped, then use current environment facts to determine which action is safe.
After restart, only environment truth needs to survive.

## 16. Minimum Human Contract

For an admitted reset failure, the person needs to know only:

- MessageLens did not finish preparing;
- MessageLens is no longer working on that attempt;
- another attempt is available; and
- support evidence can be sent if the problem repeats.

The person does not need to know which file deletion failed, which sidecar
remains, or whether the error occurred before provider invalidation.

Final copy is outside this audit. The settled stable statement
**MessageLens couldn't finish preparing your browsing data. You can try
again.** is semantically compatible with reset failure, but sharing that
presentation must not reuse the graph-failure persistence bucket.

## 17. State-Model Options

### A. Environment-only

After failure, invalidate probes and show whatever the files imply.

This is sufficient after restart. It is insufficient during the current
launch because it can erase the visible operation outcome and create a
misleading no-op loop.

### B. Process-local preparation failure

Record a narrow current-process failure state after a non-contention
preparation error. Render calm retry/support presentation while retaining
environment facts for action eligibility and diagnostics.

This accurately acknowledges the failed attempt without creating stale durable
workflow truth. Restart naturally forgets the process event and probes files.

### C. Durable reset failure

Persist a new reset-failure record and reconcile it with later files.

This is not earned. Reset has no resume semantics, retry runs reset again, logs
retain technical evidence, and current files determine the safe next action.
Persistence would add clearing and reconciliation obligations without changing
recovery correctness.

**Recommendation:** Option B for Onboarding-owned reset failures. Contextual
Settings feedback should later consume the same operation truth without making
Settings presentation a Gate responsibility.

## 18. Persistence Verdict

> **Durable reset-failure persistence is not earned.**

The durable authority is current filesystem and probe truth. A reset-failure
record would not support resume, would become stale when files change, and
would need new precedence rules against environment classification. The
current process needs a truthful presentation state; the next process needs a
fresh probe.

## 19. Generic Failure-Surface Fit

The settled stable build-failure copy is truthful for preparation failure:

```text
MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data. You can try again.
```

The available actions also fit an Onboarding reset failure:

- **Try Again** performs a new reset and complete build;
- **Send Report To Developer** can include reset logs and current probes.

What must not be shared is the false storage claim that a graph-projection
failure occurred. Shared human presentation does not require shared persisted
classification.

For explicit Settings reset, the same calm language may be reusable, but its
retry and placement remain Settings-owned.

## 20. Admission-Denial Verdict

Ordinary busy denial deserves no setup-failure surface because no destructive
work began. The current no-feedback behavior is incomplete, but the correct
future concern is bounded busy/deferred feedback and non-thrashing retry, not a
preparation-failure state.

A non-contention admission exception is different. It should unwind any active
presentation and become a process-local inability-to-prepare outcome. It still
must remain diagnostically distinguishable from admitted reset failure.

## 21. Automatic-Recovery-Failure Verdict

When reset itself fails, the person does not need to diagnose that automatic
cleanup failed. The supported action is the same: recovery has stopped, setup
is not ready, and another attempt or support report is available.

Automatic recovery therefore may share the calm Onboarding preparation-
failure presentation. It should not share controller-failure persistence.

Automatic busy denial remains deferral. Automatic non-contention admission
errors must always unwind the spinner and flags before any failure projection
is selected.

## 22. ActionStep Verdict

None of these cases earns `ActionStep`, `OperationStep`, or `RecoveryStep`.

Reset, admission, retry, and failure reconciliation remain Onboarding and
Settings operational coordination. Presence neither owns the mutation nor has
the durable evidence required to adjudicate its result. Presence may render
accepted workflow interactions elsewhere, but it must not become the archive-
recovery engine.

## 23. Operational Failure Matrix

| Case | Work admitted? | Durable mutation may have started? | Current human feedback | Retry | Needs distinct state? |
| --- | ---: | ---: | --- | --- | --- |
| First-run busy denial | No | No | None; import action remains | Safe after owner releases | No failure state; future busy feedback only |
| FDA blocked | Outer request admitted, prerequisite fails | No | Existing FDA flow | After permission/recheck | Existing state is sufficient |
| Other admission failure | No useful action began | No | None; Future error | When cause is corrected | Yes, if user-visible; not reset failure |
| First-run reset failure | Yes | Yes | Readiness/failure derived from resulting files | New clean attempt | Yes, process-local preparation failure |
| Automatic busy denial | No | No | Recovery may flash and retry | Automatic after authority is free | No failure state; deferral policy needed |
| Automatic reset failure | Yes | Yes | Recovery disappears into file-derived state | Manual retry; later launch may recover again | Yes, process-local preparation failure |
| Direct-reimport reset failure | Yes | Yes | None; no production caller | No current production action | Same truth, low current priority |
| Explicit Reset Message Data failure | Yes | Yes | None after confirmation closes | Repeat reset or next-launch onboarding | Contextual process-local failure feedback |
| Controller failure | Yes | Yes | Settled stable failure UI | Clean rebuild | Existing caught/persisted path |

## 24. Exactly One Next Implementation Slice

```text
Next concern:
    Represent Onboarding-owned preparation failure in process memory.

Why it comes next:
    First-run and automatic-recovery reset failures can follow a visible active
    operation, may leave partially changed derived stores, and currently lose
    that operation outcome before the human receives feedback. Environment
    probes remain necessary but cannot explain that the current attempt stopped.

Current defect:
    First-run reset failure rethrows after restoring awaitingUserAction;
    automatic-recovery reset failure logs and returns to awaitingUserAction;
    both let later file classification replace the failed-operation truth.
    Non-contention automatic-admission errors can also strand the recovery
    surface because their process flags are not unwound.

Smallest implementation:
    Add one narrow process-local Onboarding preparation-failure status and use
    it for first-run reset failure, automatic-recovery reset failure, and
    non-contention automatic-recovery admission failure. Always unwind recovery
    flags and overrides. Reuse the settled calm failure presentation and its
    retry/support actions without writing a pipeline failure record. Exclude
    ordinary ArchiveMutationDeniedException and FDA blocking. Do not include
    Settings Reset Message Data or dormant direct reimport in this first slice.

Owner:
    OnboardingGate owns current-process operation outcome. Onboarding
    presentation owns its human projection. Reset remains owned by
    MessageDataResetService.

Gate changes:
    One process-local status, deterministic unwind, retry entry from that
    status, and clearing on retry/refresh. No new operation authority.

Persistence impact:
    None. Restart discards the status and re-probes files.

Reset impact:
    None. Same service, order, allow-list, and exception behavior.

Recovery impact:
    Busy denial remains deferral. Reset and non-contention admission failures
    stop at a stable process-local failure instead of disappearing or spinning.

Attachment-preservation impact:
    None. The filename-only allow-list remains unchanged.

Presentation impact:
    A calm existing-style setup failure surface replaces silent return to a
    readiness surface. Final copy is reviewed in the implementation slice.

Test seam:
    Prove first-run reset failure, automatic reset failure, and generic
    automatic admission failure reach the process-local failure surface; retry
    invokes a new reset/build; refresh clears process-local failure; busy denial
    and FDA false never enter the state; restart reconstruction uses environment
    facts; diagnostics retain the original errors; no failure persistence or
    reset-target changes occur.
```

## Final Answer

> **There are four distinct pre-build/recovery operational truths: prerequisite
> blocking, busy denial, other pre-action admission failure, and admitted reset
> failure. The human-facing gap that matters next is admitted Onboarding reset
> failure. The smallest correct treatment is one process-local preparation-
> failure state with calm retry/support presentation, while filesystem probes
> remain the sole durable restart authority.**
