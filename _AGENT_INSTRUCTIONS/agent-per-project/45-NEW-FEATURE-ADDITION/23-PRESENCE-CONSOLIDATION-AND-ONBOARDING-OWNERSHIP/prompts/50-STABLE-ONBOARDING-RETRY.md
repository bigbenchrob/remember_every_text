Audit 41 gives us a strong implementation target: there are four different pre-build truths, and only admitted reset failure needs the new human-facing failure state. Busy mutation denial remains “couldn’t start yet,” FDA remains its own prerequisite flow, and controller failure already has its established handling. 41-RECOVERY-AND-PRE-BUILD-FAILURE-STATE-AUDIT.md

The important architectural point is that this new state should be process-local only. The current process should remember “the preparation operation you just watched failed”; after relaunch, the filesystem and environment probes go back to being the durable authority. 41-RECOVERY-AND-PRE-BUILD-FAILURE-STATE-AUDIT.md

Implement the single bounded operational-state slice recommended by:

41-RECOVERY-AND-PRE-BUILD-FAILURE-STATE-AUDIT.md

This prompt is authorization to implement. Do not stop to ask for plan confirmation.

For this and subsequent work in this package, use the 50- document-number range to avoid collisions with already-existing numbered documents.

Create the implementation record as:

50-PROCESS-LOCAL-ONBOARDING-PREPARATION-FAILURE-IMPLEMENTATION.md

The goal is:

Preserve, for the current process only, the truthful fact that an Onboarding-owned preparation operation started or was meaningfully attempted and then failed before the Conversation Graph controller lifecycle began.

This state should give the human a stable calm retry/support surface instead of allowing the failed operation to disappear immediately behind whatever filesystem probes happen to report next.

Do not persist this state.

Do not change reset mechanics.

Do not change mutation coordination.

Do not change Presence.

⸻

1. Governing distinctions

Preserve these as mechanically different truths:

PREREQUISITE BLOCKED
e.g. FDA false
-> existing prerequisite flow
MUTATION BUSY
ordinary ArchiveMutationDeniedException
-> requested work was not admitted
-> NOT preparation failure
OTHER PRE-ACTION ADMISSION FAILURE
operation could not begin for a non-contention reason
-> process-local preparation failure where in scope below
ADMITTED RESET FAILURE
reset began
-> reset did not finish normally
-> derived filesystem state may already have changed
-> process-local preparation failure
CONTROLLER FAILURE
reset succeeded
-> controller/build began
-> existing caught/persisted failure path

Do not collapse these into one generic error state.

⸻

2. Add one narrow process-local Onboarding status

Add one process-local OnboardingGate status representing:

Onboarding preparation could not be completed in this process.

A name conceptually like:

preparationFailed

is appropriate if consistent with current enum conventions.

This is not:

resetFailed
graphFailed
importFailed
recoveryFailed

because the human-facing state is intentionally broader than the internal cause.

The state is:

- process-local;
- owned by OnboardingGate;
- not written to overlay;
- not written to presence.db;
- not inferred from trace;
- not restored after restart.

⸻

3. First-run reset failure must enter this state

Current first-run sequence:

operation admitted
-> FDA guard succeeds
-> Preparing setup…
-> resetDerivedData()
-> reset throws

Today the Gate:

clears preparation
-> awaitingUserAction
-> rethrows

and the visible failed-operation truth disappears.

Change that bounded behavior so an admitted first-run reset failure:

1. ends the active preparation presentation;
2. records the process-local preparation-failure outcome;
3. presents the preparation-failure surface;
4. preserves the original error diagnostically;
5. does not start the controller.

Do not persist a pipeline/graph failure.

Do not pretend the Conversation Graph controller failed.

⸻

4. Automatic-recovery reset failure must enter the same state

Current automatic recovery:

recoveringFailedAttempt
-> admitted reset
-> reset throws
-> log
-> clear recovery
-> awaitingUserAction

Change the human outcome so an admitted reset failure reaches the same process-local preparation-failure status.

Preserve:

- existing reset logging;
- automatic-recovery suppression semantics unless a small adjustment is strictly needed for deterministic state;
- environment invalidation as appropriate;
- no persisted reset-failure record.

The important result is:

recovery operation really failed
-> recovery spinner ends
-> calm preparation-failure surface appears

instead of the failure disappearing behind newly derived environment state.

⸻

5. Handle non-contention automatic-recovery admission failure

Audit 41 found a separate hole:

automatic recovery presentation begins
-> mutation admission throws something other than ArchiveMutationDeniedException
-> unawaited Future escapes
-> in-flight/suppression/override may remain stranded

Fix this within the bounded slice.

For a non-contention admission error:

1. deterministically unwind automatic-recovery in-flight state;
2. clear the active recovery override;
3. retain/log the original error diagnostically;
4. enter the process-local preparation-failure surface.

No reset occurred, so do not describe it diagnostically as a reset failure.

The human-facing state may be shared because their supported next action is the same.

⸻

6. Ordinary mutation busy denial must NOT enter failure

Preserve ordinary:

ArchiveMutationDeniedException

as a deferral/contention case.

It means:

requested operation did not start
another mutation owner is active

It does not mean:

preparation started and failed

Do not route ordinary busy denial into preparationFailed.

Preserve existing deferral behavior in this slice unless deterministic flag unwind is necessary for correctness.

Do not design busy UI or backoff here.

⸻

7. FDA blocking must NOT enter failure

Preserve:

FDA false
-> awaitingFda
-> existing FDA Presence flow

No reset began.

No preparation-failure state should appear.

Do not change FDA probing/caching in this slice.

⸻

8. Reuse the calm failure presentation

Do not create a second elaborate failure design.

The settled human language is already compatible:

MessageLens couldn't finish setup
MessageLens couldn't finish preparing your browsing data.
You can try again.

Reuse the existing calm failure presentation style wherever practical.

The user should see:

[failure icon]
MessageLens couldn't finish setup
MessageLens couldn't finish preparing your browsing data.
You can try again.
[Try Again]
[Send Report To Developer]

Do not show:

- raw reset exception;
- mutation-coordinator details;
- filename deletion details;
- environment summary;
- What to check;
- Technical Details;
- failed-stage claims.

⸻

9. Use a phase-neutral retry action

For this new preparation-failure state, use a simple human label:

Try Again

unless an existing established generic retry label fits better.

Do not use:

Retry Import and Graph Build
Retry Reset
Retry Cleanup

because those expose implementation phases.

The retry action should invoke the existing ordinary first-run setup entry point:

OnboardingGate.startImportAndGraphBuild()

which will:

admit operation
-> check FDA
-> reset rebuildable derived stores
-> run complete build

No resume behavior is introduced.

⸻

10. Clear process-local failure when retry begins

A valid retry from preparationFailed must be allowed.

Before or as the new operation begins, clear the process-local failure state so the ordinary lifecycle can take over:

preparationFailed
-> user chooses Try Again
-> new admitted setup attempt
-> Preparing setup…
-> ...

Do not require an app restart.

Do not create a second retry API.

Use the existing operation.

⸻

11. Refresh/re-evaluation behavior

Audit 41 recommends that a deliberate refresh/re-evaluation may clear the process-local failure and return control to current environment truth.

Implement the smallest behavior consistent with existing refresh semantics.

The invariant should be:

The process-local preparation-failure state is allowed to temporarily override environment-derived presentation so the current operation outcome is acknowledged, but it is not durable authority.

A deliberate supported refresh may discard it and re-project current filesystem/environment truth.

Do not invent a new refresh interaction.

Use an existing one if present.

⸻

12. Restart semantics

This status must disappear on process restart.

After relaunch:

no preparationFailed persistence
-> inspect actual filesystem/databases
-> environment probes classify current durable state

Possible outcomes remain:

readyToImport
automatic recovery
stable failure
ready
source/FDA blocker

Do not recreate preparation failure from logs.

Do not inspect prior exceptions to restore it.

Do not add a persistence row or Boolean.

⸻

13. Diagnostic error preservation

Although the human surface is phase-neutral, preserve the original error for current-process diagnostics where practical.

For example, a narrow process-local preparation-failure detail may retain:

error
stack trace
internal cause category

only if current architecture naturally needs it for logging/support.

Do not expose it in ordinary UI.

Do not create a generalized failure object hierarchy.

The minimum requirement is that the technical exception not be silently lost from logs or support evidence.

If the existing logging path already preserves enough evidence, do not duplicate it.

⸻

14. Do not misuse existing persisted controller-failure buckets

Do not call:

saveGraphProjectionFailure(...)
saveImportFailure(...)

for preparation/reset failure merely to reuse the stable UI.

Shared presentation does not require shared persistence.

The architecture must remain:

controller failure
-> existing durable coarse failure record
pre-controller preparation failure
-> process-local Onboarding status only

This distinction is central.

⸻

15. Filesystem/environment truth remains authoritative

Do not suppress environment re-evaluation indefinitely.

The new process-local state says:

the operation the human just observed did not finish.

The filesystem/probes say:

this is what durable data exists now.

Both truths may coexist in the current process.

After restart, only the durable/environment truth remains.

Do not make preparationFailed determine whether databases are valid.

⸻

16. Attachment preservation is a hard invariant

Do not change MessageDataResetService, its allow-list, or filesystem adapter.

Audit 41 verified that reset targets remain narrowly limited to:

macos_import_ss.db
working_ss.db
macos_import.db
working.db
and their SQLite sidecars

and cannot broaden into the attachment preservation archive.

The new failure state is presentation/application state only.

Do not:

- delete additional files;
- add cleanup on failure;
- retry deletion automatically;
- touch archived attachment payloads.

⸻

17. Keep explicit Settings Reset Message Data out of this slice

Audit 41 found that the production Settings reset is a second instance of the same mechanical reset-failure truth.

Do not include it yet.

Its presentation owner is Settings, not OnboardingGate.

This slice is limited to:

first-run Onboarding reset failure
automatic-recovery reset failure
non-contention automatic-recovery admission failure

Do not include dormant startReimport() either.

⸻

18. Do not fix busy-denial thrashing here

Audit 41 found that automatic recovery can potentially flash/retry under repeated ordinary mutation denial.

That is a separate deferral/backoff concern.

Do not add:

- timers;
- queues;
- backoff;
- busy states;
- mutation waiting UI.

Preserve ordinary contention semantics and document any remaining behavior.

⸻

19. Focused tests

Add tests proving at least:

First-run reset failure

Drive:

Import My Messages
-> admission success
-> FDA true
-> Preparing setup…
-> reset throws

Prove:

controller never starts
Gate -> preparationFailed
calm failure surface visible
Try Again visible
Send Report To Developer visible

and raw reset exception is not in ordinary UI.

First-run retry

From preparationFailed, press:

Try Again

Then prove a new reset/build attempt begins through the ordinary existing path.

No resume.

Automatic-recovery reset failure

Drive:

recoveringFailedAttempt
-> admission success
-> reset throws

Prove:

recovery spinner disappears
Gate -> preparationFailed
calm failure surface appears
automatic recovery does not remain stuck

Automatic non-contention admission error

Cause archive mutation admission to throw a non-ArchiveMutationDeniedException.

Prove:

in-flight flags unwind
recovery override clears
Gate -> preparationFailed
no reset occurs

Busy denial excluded

Cause ordinary ArchiveMutationDeniedException.

Prove:

no preparationFailed
no reset
existing deferral semantics retained

FDA excluded

Prove FDA false reaches existing FDA state and never preparationFailed.

No persistence

Recreate Gate/providers as a new process-equivalent fixture after a preparation failure.

Prove the status is not reconstructed.

The new instance must derive presentation from current environment/files only.

Existing controller failure unchanged

Prove caught Conversation Graph controller failure continues through the existing persisted stable-failure path, not preparationFailed.

Attachment preservation

Keep/reset existing preservation tests proving archive payloads remain untouched.

⸻

20. Presentation tests

Prove the new process-local failure surface contains only:

MessageLens couldn't finish setup
MessageLens couldn't finish preparing your browsing data. You can try again.
Try Again
Send Report To Developer

Do not show:

Environment Summary
What to check
raw exception
reset filename
graph projection
import ledger
previous launch

Reuse existing calm failure components rather than duplicating presentation where practical.

⸻

21. Architecture tripwires

Protect, where practical:

- preparationFailed is not persisted;
- no new overlay/database field stores it;
- reset failure does not call controller-failure persistence;
- Presence does not gain preparation/reset failure dependencies;
- attachment archive remains outside reset targets;
- Settings does not accidentally become owned by Onboarding in this slice.

Do not invent a new test framework.

⸻

22. Documentation

Create:

50-PROCESS-LOCAL-ONBOARDING-PREPARATION-FAILURE-IMPLEMENTATION.md

Record:

1. final process-local status/API;
2. cases entering the state;
3. cases explicitly excluded;
4. first-run reset-failure transition;
5. automatic-recovery reset-failure transition;
6. automatic non-contention admission-error unwind;
7. retry semantics;
8. refresh/clearing behavior;
9. restart semantics;
10. persistence explicitly not added;
11. controller-failure persistence explicitly not reused;
12. attachment-preservation invariant;
13. remaining busy-denial issue;
14. tests;
15. deviations from Audit 41.

Use the 50- number even though the preceding audit is 41-.

Update:

- 00-START-HERE.md
- package index
- DOCUMENTATION_PASS_LOG.md
- changelog/version if current convention requires it.

⸻

23. Verification

Run:

- focused preparation-failure tests;
- automatic-recovery tests;
- stable failure presentation tests;
- OnboardingGate tests;
- Environment Readiness tests;
- ArchiveMutationCoordinator tests;
- reset-preservation tests;
- complete Onboarding tests;
- architecture tripwires;
- flutter analyze;
- formatting;
- git diff --check;
- debug macOS build.

Do not launch against the production archive.

Hard constraints

Do not:

- persist preparation failure;
- add reset-failure records;
- change reset allow-lists;
- change reset ordering;
- change mutation policy;
- add busy/backoff behavior;
- change FDA behavior;
- change controller failure persistence;
- add durable job state;
- include Settings Reset Message Data;
- activate dormant direct reimport work;
- modify Presence;
- add ActionStep;
- change attachment archival.

If any of those appears necessary, stop and explain why.

Success criterion

After an admitted Onboarding preparation/reset operation fails, the current process should retain enough truth to tell the human:

MessageLens couldn't finish setup.
MessageLens couldn't finish preparing your browsing data.
You can try again.
[Try Again]
[Send Report To Developer]

without falsely recording a graph/import failure.

After relaunch, that process-local outcome disappears and MessageLens once again trusts the only durable authority it actually has:

the files and environment facts that remain

Busy contention and FDA blocking must remain visibly and mechanically distinct from preparation failure.

This is a more substantive slice than our recent copy cleanups, but the audit has earned it: we now have a real missing operation outcome, not merely wording that needs polishing.
