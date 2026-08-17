Work on branch Ftr.archive-recovery.

Implement the bounded correction recommended by:

26-PRODUCTION-ARCHIVE-RECOVERY/07-ARCHIVE-MUTATION-OWNER-AWARE-DATABASE-ADMISSION-AUDIT.md

Also read the canonical database-access / archive-authority documentation linked from that audit and Audit 04.

This is an architecture correction, not a Historical Archives UX task.

GOAL

Restore the intended “ball and track” mechanical-impossibility model:

- an unrelated caller must be mechanically unable to open a protected graph database while a blocking mutation owns the track;
- the admitted mutation owner must not be mistaken for an unrelated caller;
- authorization must depend on the current operation scope and requested resource action, not merely “same owner”;
- nested operations must never silently weaken safety policy;
- correctness must not depend on opening database services before acquiring mutation authority.

FIRST PROVE THE ASYNC CONTEXT

Before choosing the final implementation shape, add a focused test proving whether construction/evaluation of the protected graph provider occurs in the requesting Dart async Zone and can therefore observe the coordinator’s private inherited owner context.

If that works, use the existing coordinator/Zone ownership mechanism.

Do NOT introduce a public capability-token/lease architecture unless this test demonstrates that the existing private async context cannot provide reliable mechanical caller identity.

IMPLEMENT OWNER-AWARE ADMISSION

Keep ArchiveMutationCoordinator as the sole mutation authority.

Add the smallest coordinator-owned admission API necessary for protected database resource decisions.

Feature/provider code must not inspect or supply raw owner IDs.

The coordinator must be able to answer, conceptually:

- is a reopen-blocking mutation active?
- is this async caller the admitted owner?
- what operation scope is currently active?
- does that operation authorize this requested resource action?

Do not reduce this decision to the existing global Boolean.

NESTED OPERATION POLICY

Correct reentrant ownership so that nested work remains the same owner but retains truthful nested operation scope.

Effective safety policy must never become weaker while nested.

In particular:

- a nested operation with blocksDatabaseReopen=true must preserve that stronger restriction;
- a nested operation requiring verified checkpoint evidence must actually enforce that requirement;
- leaving the nested scope must restore the previous operation scope correctly;
- diagnostics/state should truthfully represent the effective operation policy.

Do not solve this by treating reentry as a brand-new competing owner.

GRAPH DATABASE ADMISSION

Change fresh working_ss.db construction so it asks the coordinator for the owner-aware, operation-aware admission decision.

Required behavior:

- ordinary/unrelated caller during historicalArchiveImport -> denied;
- admitted historicalArchiveImport owner -> may create the graph resource it legitimately needs;
- ordinary/unrelated caller during historicalArchiveRemoval -> denied;
- admitted historicalArchiveRemoval owner -> may create the graph resource it legitimately needs;
- after maintenance ends, a previously denied provider construction can recover/retry normally.

Do not create a blanket rule that “the owner may always open working_ss.db.”

MESSAGE RESET

Handle messageDataReset according to its actual resource need.

Reset must be able to close/invalidate an existing graph connection before deleting derived graph state.

It must NOT be forced to construct a fresh working_ss.db connection merely so that it can close/delete it.

Do not turn owner-aware admission into permission for reset to open a brand-new graph database immediately before deleting it.

REMOVE THE PROVISIONAL WORKAROUND

Once owner-aware admission is working and tested, remove the Audit-04 Historical Archives workaround that resolves SourceScopedArchiveGraphImportService before acquiring mutation authority.

Historical import and removal should resolve the resources they legitimately need from inside admitted ownership.

There must be no correctness dependency on provider-resolution order.

MAINTENANCE VS FAILURE PRESENTATION

Make the smallest directly related correction to readiness classification.

Legitimate active archive maintenance must not be classified as graphProjectionFailed merely because ordinary graph readers are temporarily suppressed.

The system should distinguish:

“graph temporarily unavailable because an admitted maintenance operation owns the track”

from:

“graph projection genuinely failed.”

This should prevent the observed temporary jump into Onboarding / Environment Readiness during legitimate Historical Archives import/removal.

Do NOT redesign Onboarding or Historical Archives presentation in this slice.

Keep dbMaintenanceLockProvider if still useful as a coarse compatibility/presentation signal, but it must no longer be the sole graph admission authority.

REQUIRED TESTS

Prove at minimum:

1. provider construction observes requesting async Zone ownership;
2. admitted historical import can create its required graph provider after acquiring mutation authority;
3. admitted historical removal can do the same;
4. unrelated callers cannot create the graph provider during either operation;
5. nested operations preserve stronger blocksDatabaseReopen policy;
6. nested operations preserve/enforce stronger verified-checkpoint requirements;
7. exiting nested scope restores the outer operation policy;
8. message reset can close an existing graph handle without opening a new one;
9. message reset is not accidentally granted unnecessary fresh-open authority;
10. denied fresh graph construction recovers after maintenance release;
11. legitimate archive maintenance is not classified as graphProjectionFailed and does not drive OnboardingGate to awaitingUserAction merely because maintenance is active;
12. Historical Archives no longer requires the pre-open sequencing workaround.

Preserve existing mechanical exclusion tests.

SAFETY

Do not touch:

- production MessageLens data;
- frozen production snapshot;
- donor Messages folders;
- staging data;
- attachment payloads.

This implementation should be fully testable using fixtures/in-memory or temporary databases.

Do not perform a GUI archive import/removal.

DOCUMENTATION

Create the next Feature 26 implementation record documenting:

- the owner-aware admission model;
- how private Zone ownership is used;
- how nested operation policy is preserved;
- the distinction between resource ownership and resource permission;
- how message reset differs from import/removal;
- removal of the pre-open workaround;
- the maintenance-vs-failure readiness correction;
- objective test evidence.

Update canonical database-access documentation wherever the old Boolean-lock description would otherwise be misleading.

Do not begin narrator/Matrix UX work.

VERIFICATION

Run focused coordinator/provider/reset/Historical Archives/Onboarding tests, all architecture tripwires, flutter analyze, and git diff –check.

Review the complete diff for accidental weakening of unrelated-reader exclusion.

If everything passes, commit and push according to repository conventions.

STOP and report:

- exact authority model implemented;
- whether provider evaluation reliably retained the requesting Zone;
- how nested policies are represented;
- how graph-open permission differs by operation;
- how reset closes without reopening;
- whether the Audit-04 workaround is gone;
- whether maintenance can still trigger false Onboarding failure;
- tests run and results.

Do not proceed to Historical Archives UX redesign yet.
