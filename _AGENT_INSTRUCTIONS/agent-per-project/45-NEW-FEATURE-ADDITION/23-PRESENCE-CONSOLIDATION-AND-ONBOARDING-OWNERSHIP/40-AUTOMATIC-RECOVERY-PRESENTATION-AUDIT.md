---
tier: project
scope: automatic-recovery-presentation
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: code
links:
  - ./27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md
  - ./30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md
  - ./33-FAILURE-DIAGNOSTIC-INFORMATION-HIERARCHY-AUDIT.md
  - ./34-REMOVE-WHAT-TO-CHECK-STABLE-FAILURE-IMPLEMENTATION.md
  - ./35-REMOVE-ENVIRONMENT-SUMMARY-STABLE-FAILURE-IMPLEMENTATION.md
  - ./36-REMOVE-SUPPORT-TRANSPORT-CAPTION-STABLE-FAILURE-IMPLEMENTATION.md
tests:
  - ../../../../test/essentials/onboarding/application/onboarding_gate_provider_test.dart
---

# Automatic Recovery Presentation Audit

## Decision Summary

While automatic recovery runs, the human needs to know **that MessageLens found
incomplete rebuildable browsing data, is preparing the app for another setup
attempt, and requires no action except waiting**.

The current presentation says more than the operation proves. In particular,
it describes a **previous** or **earlier setup attempt**, displays internal
import-ledger and Conversation-Graph reasoning, and can imply that setup itself
will restart automatically. The code proves neither a prior process boundary
nor an automatic rerun.

The preferred philosophy is **calm recovery**. The ordinary surface should
orient and reassure without exposing the row-count heuristic. Explicitly
listing preserved source and archive categories is truthful but unnecessary
unless evidence shows that people fear data loss; introducing deletion topics
can create the alarm it is trying to resolve.

The diagnostic reason belongs **outside ordinary reading order**. It already
remains available in the environment report, Gate and reset logs, development
diagnostics, database probes, and support-bundle evidence.

The one next implementation slice should therefore be:

> **Remove `resetAppDatabasesReason` from the production automatic-recovery
> surface while preserving the reason everywhere it currently serves
> diagnostics.**

Heading and body corrections are justified, but they are not mechanically
inseparable from reason-card removal and should be reviewed in the next bounded
slice.

## 1. Exact Recovery Lifecycle

### Selection facts

`OnboardingEnvironmentReport` considers automatic reset only when all of the
following are true:

- database maintenance is not active;
- the source-scoped import database contains rows;
- its row count is known and at least 25;
- the import count plausibly tracks the locally available source history;
- the Conversation Graph is empty or contains fewer than half as many messages
  as the import ledger; and
- either a persisted import/graph failure exists, or the non-empty graph itself
  exhibits the severe row-count disparity.

Source access, Contacts availability, and sparse-source blockers are classified
before the inferred recovery state. A maintenance lock suppresses creation of a
reset reason. Recovery is therefore not the response to every onboarding
failure or every partially populated store.

The evaluator can produce exactly two production reasons:

```text
A previous import or graph projection failure left a populated import ledger
but an incomplete conversation graph.
```

```text
The conversation graph contains far fewer messages than the import ledger,
which strongly suggests an incomplete graph projection.
```

When either reason exists, the report sets:

```text
state = graphProjectionFailed
blockerKind = graphProjectionFailed
shouldResetAppDatabasesBeforeImport = true
resetAppDatabasesReason = <reason>
```

### Gate and presentation transition

The runtime path is:

```text
environment probes
    -> OnboardingEnvironmentReport infers incomplete derived stores
    -> OnboardingGate.build() receives the report
    -> _maybeTriggerAutomaticRecovery() marks recovery in flight/suppressed
    -> next post-frame callback publishes recoveringFailedAttempt
    -> production recovery overlay becomes visible
    -> _runAutomaticRecovery() requests archive mutation admission
    -> admitted action calls MessageDataResetService.resetDerivedData()
    -> nested message-data-reset admission inherits the same Zone owner
    -> allow-listed derived stores are closed and deleted
    -> derived providers are invalidated and data version advances
    -> Gate clears the recovery override
    -> environment report and Gate are invalidated
    -> Gate publishes awaitingUserAction while probes run again
    -> the re-evaluated environment selects the next visible state
```

Because `recoveringFailedAttempt` is published immediately before the mutation
request, the recovery overlay may be visible before admission succeeds. The
outer `automaticRecovery` admission is the first mutation authority. The reset
service's nested `messageDataReset` request re-enters under the same process-
local owner rather than competing for separate authority.

### What reset actually does

`MessageDataResetService.resetDerivedData()`:

1. closes the source-scoped import and Conversation Graph databases;
2. deletes only the active import/graph database families and retired cleanup
   database families, including their narrowly associated SQLite sidecars;
3. invalidates providers for derived message data;
4. increments the message-data version;
5. verifies whether the allow-listed base files remain; and
6. logs completion or rethrows a logged failure.

It does not run source import or graph projection after deletion.

### Success

The Gate does not distinguish successful reset in a durable recovery result.
Its `finally` block always clears the override, invalidates the report and
itself, and sets `awaitingUserAction`. Successful deletion normally causes the
fresh report to classify the empty derived stores as `readyToImport`. The human
is then offered the existing setup/import action.

Automatic recovery therefore makes another setup attempt possible. It does
not start that attempt.

### Failure

The reset service logs and rethrows reset failures. The admitted recovery
method catches them, logs another recovery-specific error, and leaves
`_automaticRecoverySuppressed` true. Its `finally` block still clears the
recovery surface and returns to environment-derived `awaitingUserAction`.

There is no durable automatic-reset failure record and no presentation of the
reset exception. Surviving files and any older pipeline failure determine the
next stable surface. The current Gate instance will not repeat automatic
recovery for the same still-present reason until suppression is cleared. A
manual environment refresh clears it; a later process starts with fresh
process-local flags and may infer recovery again.

This is a missing operational failure distinction, not content that the
running recovery surface can truthfully explain. This audit does not redesign
that state.

### Mutation-admission denial

If another owner holds mutation authority, the coordinator throws
`ArchiveMutationDeniedException`. The Gate:

- performs no reset;
- clears in-flight and suppression flags;
- clears the recovery override;
- logs the denial; and
- invalidates itself.

The recovery surface can therefore appear briefly and then disappear. There is
no explicit timer, queue, or backoff schedule. A later provider rebuild with
the same report is eligible to request recovery again; the code's log calls
this deferral, but no durable deferred job exists.

The catch is specific to busy-authority denial. This audit does not generalize
that behavior to unrelated admission exceptions.

### Abrupt termination

There is no durable recovery job, checkpoint, stage, or resume token. A quit or
crash may leave some allow-listed files deleted and others present because
database closes and file-family deletions are sequential. The next launch
probes the files that remain and derives a new environment state. It does not
resume the interrupted reset.

### Durable versus process-local truth

| Truth | Lifetime |
| --- | --- |
| Source, import, and graph files | Durable filesystem evidence |
| Coarse prior import/graph failure records | Durable overlay evidence |
| `resetAppDatabasesReason` | Re-derived report value |
| Reset deletion side effects | Durable filesystem effects |
| Gate and reset logs | Diagnostic records, not workflow authority |
| `recoveringFailedAttempt` | Process-local presentation override |
| `_automaticRecoveryInFlight` | Process-local guard |
| `_automaticRecoverySuppressed` | Process-local guard |
| Recovery completion/failure result | Not durably represented |
| Recovery resume point | Does not exist |

## 2. What Automatic Recovery Means

The most accurate ordinary-language description is:

> MessageLens found signs that its rebuildable browsing data is incomplete, so
> it is removing those incomplete derived stores before allowing setup to be
> tried again.

It does **not** mean:

- repairing or changing Apple Messages or Contacts;
- restoring or reconciling attachments;
- deleting archived attachment payloads;
- resuming the failed import or graph build;
- continuing from a known failed stage;
- deleting all MessageLens data; or
- automatically rerunning setup.

## 3. Current Visible Inventory

The production recovery widget currently renders:

```text
[cleaning-services icon]

Cleaning Up A Previous Setup Attempt

MessageLens detected signs that an earlier setup attempt left incomplete local
data. It is clearing that data now so setup can restart cleanly.

[bordered resetAppDatabasesReason card, when present]

[indeterminate circular activity indicator]
```

The reason is present for the production classification that triggers this
surface, although the widget accepts a nullable report. There are no buttons,
actions, percentage, stage label, cancel control, retry control, or explicit
completion/failure transition. Completion and failure both replace the
recovery surface through Gate/report state changes.

The development panel has a separate recovery presentation with the report
reason and a linear indicator. This audit's ordinary-reading-order verdict is
about the production recovery widget, not the deliberate developer diagnostic
surface.

## 4. Heading Audit

Current:

```text
Cleaning Up A Previous Setup Attempt
```

| Claim | Verdict | Reason |
| --- | --- | --- |
| **Cleaning Up** | Technically true but potentially alarming | The operation removes incomplete rebuildable stores, but “cleanup” alone does not define the preservation boundary. |
| **Previous** | Unsupported as a process/launch claim | The Gate has no prior-process identity. A persisted failure may have been written earlier in the same launch, and disparity-based recovery may have no persisted failure at all. |
| **Setup Attempt** | Over-specific | One reason is inferred from store disparity without proof of a recorded attempt or exact lifecycle stage. |

Conceptually, **Preparing MessageLens to try again** best reflects the human
outcome and avoids unsupported history. **Cleaning up incomplete browsing
data** is mechanically precise but puts deletion mechanics in the headline.
**Getting MessageLens ready to try again** is also supportable, but the final
wording should be settled in its own bounded copy slice.

The current heading is not sufficiently truthful.

## 5. Body-Copy Audit

Current:

```text
MessageLens detected signs that an earlier setup attempt left incomplete local
data. It is clearing that data now so setup can restart cleanly.
```

| Clause | Classification | Assessment |
| --- | --- | --- |
| **detected signs** | Truthful | Recovery is inferred from current probes, row-count thresholds, and sometimes a persisted coarse failure. |
| **an earlier setup attempt** | Unsupported | No process boundary is recorded, and disparity-only recovery does not prove a particular attempt. |
| **left incomplete local data** | Technically true but anxiety-inducing and overbroad | The incomplete records are rebuildable MessageLens browsing stores. “Local data” can reasonably sound like source Messages, Contacts, archives, preferences, or user intent. |
| **clearing that data now** | Technically true but anxiety-inducing and overbroad | Deletion is occurring, but only against an explicit allow-list of rebuildable derived stores. |
| **so setup can restart cleanly** | Ambiguous and partly unsupported | Cleanup can permit another attempt; the recovery path does not itself restart setup. It also does not resume the interrupted operation. |

The smallest truthful replacement concept for a later copy slice is:

```text
MessageLens found incomplete browsing data and is preparing the app for
another setup attempt. Please wait.
```

This is a concept, not approved final copy in this audit.

## 6. `resetAppDatabasesReason` Audit

The reason is a technical classification explanation, not a user decision.
Both production values:

- expose internal terms such as **import ledger**, **Conversation Graph**, and
  **graph projection**;
- explain a threshold-based diagnosis that the user cannot act upon;
- lead to the same automatic deletion and the same instruction to wait;
- can make the recovery surface sound more destructive or more certain than
  the evidence permits; and
- do not clarify attachment preservation.

The first reason says **previous failure**, but a durable failure record proves
only that a coarse failure was recorded, not that it came from a previous
launch or that graph projection was the actual failed stage. The second reason
correctly calls its conclusion a strong suggestion, but the row disparity is
still implementation reasoning rather than human-facing orientation.

**Verdict:** `resetAppDatabasesReason` should move out of ordinary recovery UI
but remain diagnostic. No simplified reason taxonomy is needed because the
current reasons do not produce different human actions.

## 7. Information Hierarchy

The settled rule remains:

> **Ordinary reading order should contain only information that changes the
> human's understanding or next action.**

| Visible item | Classification | Verdict |
| --- | --- | --- |
| Recovery heading | ORIENTATION | Required, but current wording needs later correction. |
| Explanatory paragraph | REASSURANCE | Required in a shorter, browsing-data-specific form; current wording is overbroad. |
| Instruction to wait | ACTION-CRITICAL | The current spinner implies waiting, but explicit copy would be truthful. |
| Indeterminate activity indicator | ORIENTATION / REASSURANCE | Retain. It truthfully shows an active operation without inventing progress. |
| `resetAppDatabasesReason` card | DIAGNOSTIC / IMPLEMENTATION DETAIL | Remove from ordinary reading order. |
| Controls | REDUNDANT / UNSUPPORTED | None should be added. There is no supported interaction during reset. |

The human does not need to understand why a 50-percent row-count threshold was
crossed. They need to understand that MessageLens is handling incomplete
rebuildable browsing data and that waiting is the correct action.

## 8. Attachment-Preservation Check

The reset allow-list contains:

- the active source-scoped import database;
- the active Conversation Graph database;
- retired import/working cleanup files; and
- each listed database's narrowly associated SQLite sidecars.

It does not include:

- Apple Messages `chat.db`;
- Apple Contacts databases;
- locally available Messages attachment payloads;
- MessageLens archived attachment payloads;
- overlay/user intent; or
- preferences.

The current broad phrases **local data** and **clearing that data** fail to
communicate that boundary and can reasonably be read as including preservation
data. Future copy should use **incomplete browsing data** or **rebuildable
browsing data**.

The UI should not add a long preservation inventory now. Option C below risks
introducing concern by naming deletion targets that the human had not
considered. The mechanical invariant and focused terminology are the first
line of protection.

## 9. Progress Truth And Actions

The presentation knows only:

```text
the Gate has entered recovery and a reset request is in flight
```

It does not know or expose:

- a percentage;
- an independently modeled stage;
- estimated time remaining;
- cancellation semantics;
- a resume point; or
- durable completion state.

The current indeterminate indicator is sufficient. Adding percentage or stage
copy would be invented telemetry. The human should not receive **Cancel**,
**Retry**, **Continue**, or **Dismiss** while reset runs because none maps to a
supported recovery operation.

## 10. Successful-Recovery Transition

After reset, the Gate always leaves `recoveringFailedAttempt`, invalidates the
environment report, and returns to `awaitingUserAction`. With the derived
stores removed, a fresh report normally becomes `readyToImport`, and the
existing **Import My Messages** action appears.

Therefore:

```text
truthful: recovery is making another setup attempt possible
misleading: recovery is restarting setup automatically
```

The current **so setup can restart cleanly** wording is ambiguous enough to
suggest the latter and should be corrected in a later copy slice.

## 11. Recovery-Failure Behavior

The running recovery surface does not have sufficient state to explain reset
failure. The reset service logs the exception and rethrows it; the Gate logs
it, suppresses another automatic attempt in the current Gate instance, clears
the recovery presentation, and returns to environment-derived
`awaitingUserAction`.

The specific reset error is not persisted or shown. A human may see the old
stable failure/readiness state again. Another launch may infer and retry
automatic recovery because suppression is process-local.

This deserves later operational-state analysis, but it is separate from what
the active recovery surface should say. Adding speculative failure copy to the
in-progress surface would not repair the missing state.

## 12. Mutation-Admission Denial

The current order permits a short recovery flash before mutation admission.
Busy-authority denial clears the override and performs no reset. The Gate can
become eligible again after invalidation, but there is no explicit durable or
timed retry schedule.

The recovery copy should therefore not claim that deletion has definitely
begun at the first rendered frame. A calm phrase such as **preparing
MessageLens to try again** remains true across the brief admission boundary.
The current **It is clearing that data now** can be premature.

## 13. Abrupt-Termination Behavior

The reset is not resumable. On restart, MessageLens reconstructs truth from the
remaining files and persisted coarse failure evidence. Copy must not promise:

- that recovery will resume;
- that MessageLens remembers a recovery stage; or
- that the prior operation will continue.

## 14. Presentation Philosophy Comparison

| Philosophy | Truthfulness | Cognitive load | Reassurance | Architectural leakage | Verdict |
| --- | --- | --- | --- | --- | --- |
| **A. Diagnostic recovery** | Technical facts are partly true, but can overstate exact failure history/stage | High | Low; disparity and deletion language can alarm | High | Reject for ordinary UI. Preserve diagnostics elsewhere. |
| **B. Calm recovery** | Strong when phrased around incomplete rebuildable browsing data and another possible attempt | Low | High without introducing new fears | Low | **Recommend.** It matches the supported action: wait. |
| **C. Calm + explicit preservation reassurance** | The allow-list makes a bounded reassurance truthful | Medium | Can reassure an already-concerned user, but can also introduce fear that Messages or attachments were at risk | Medium | Do not use without evidence of a real concern. Prefer precise nouns first. |

Option B best fits current facts and implementation complexity. It requires no
new state, telemetry, recovery mechanics, or preservation behavior.

## 15. Recovery Truth Budget

### WE MAY TRUTHFULLY SAY

- MessageLens found signs of incomplete rebuildable browsing data.
- MessageLens is preparing the app for another setup attempt.
- The operation removes only allow-listed derived browsing stores.
- The operation is active and the human should wait.
- Another setup attempt can be offered after recovery and re-evaluation.

### WE MUST NOT IMPLY

- Apple Messages or Contacts is being altered.
- Locally available source attachments are being deleted.
- Archived attachment payloads, overlay intent, or preferences are being
  deleted.
- Every attachment is preserved by this operation; reset does not establish
  that broader claim.
- All MessageLens data is being cleared.
- The exact failed stage is known.
- The incomplete state necessarily came from a previous process or launch.
- Recovery resumes the interrupted import or graph build.
- Recovery itself automatically starts another setup attempt.
- Recovery can resume after abrupt termination.

## 16. Diagnostic Retention

Removing the reason card from ordinary UI would not remove the underlying
evidence:

- `OnboardingEnvironmentReport` retains `resetAppDatabasesReason`, the source,
  import, graph, overlay, and attachment-archive probes, row counts, persisted
  failure evidence, and current operation health;
- `OnboardingGate` logs the resolved state and reset reason;
- automatic recovery logs the reason before reset;
- fresh-start preparation logs the reason when relevant;
- `MessageDataResetService` logs requested reset, closed stores, deleted file
  families, post-reset existence checks, preservation categories, and errors;
- `ArchiveMutationCoordinatorState` retains process-local admission and denial
  diagnostics;
- the development Onboarding panel displays the reason deliberately; and
- support reports preserve database-health probes and persisted raw failure
  evidence, while exported logs preserve the recovery-specific reason and
  reset trace.

The structured onboarding failure-report header does not currently repeat
`resetAppDatabasesReason` verbatim. It does preserve the state, blocker, source
and derived database paths/readability/row counts, persisted pipeline failures,
and timestamps. Together with logs, this is sufficient to reconstruct why the
heuristic fired. Ordinary UI is not the sole diagnostic store.

## 17. Exactly One Next Implementation Slice

```text
Next concern:
Remove resetAppDatabasesReason from ordinary automatic-recovery presentation.

Why it comes next:
It is pure diagnostic and implementation detail, changes no human action, adds
the greatest architectural leakage, and is mechanically separable from the
heading/body wording correction.

Current defect:
The production recovery surface displays import-ledger, Conversation-Graph,
projection, persisted-failure, and row-disparity reasoning in ordinary reading
order.

Smallest implementation:
Stop rendering the bordered reset-reason card in the production
_RecoveryContent widget. Leave the report field, reason generation, Gate/reset
logging, development panel, environment classification, and diagnostics
unchanged. Do not alter the current heading/body in this slice.

Owner:
Onboarding presentation.

Operation-layer changes:
None.

Persistence impact:
None.

Recovery-mechanics impact:
None.

Attachment-preservation impact:
None.

Presentation impact:
The variable technical card disappears; heading, body, icon, indicator, and
non-interactive behavior remain unchanged pending the next copy review.

Test seam:
A focused production recovery widget test should prove that a report carrying
a reset reason still shows the recovery surface and activity indicator but not
the reason text. Existing Gate tests should continue proving one reset and the
return to awaitingUserAction.
```

## 18. Layout Verdict

No current code-grounded overflow defect is established for the recovery
surface. The bordered reason card adds variable-height, unbounded technical
text and unnecessary visual density. Removing it will naturally simplify and
shorten the surface without changing card geometry, typography, scrolling, or
spacing policy.

No geometry correction is recommended in this audit.

## 19. Presence Verdict

No Presence change is required. Automatic derived-store recovery remains
Onboarding/bootstrap operational behavior. Presence does not own the reset,
its classification, its admission, or its presentation state.

## Final Answer

> **While automatic recovery runs, the human needs to know that MessageLens is
> preparing incomplete rebuildable browsing data for another setup attempt and
> that they should wait. The diagnostic reason for recovery belongs outside
> ordinary reading order. The next smallest correction is removing the
> `resetAppDatabasesReason` card from the production recovery surface while
> retaining all diagnostic evidence and recovery mechanics.**
