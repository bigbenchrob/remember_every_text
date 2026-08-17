Work on branch Ftr.archive-recovery.

Before doing any further Historical Archives UX work, perform a focused architecture audit of the ArchiveMutationCoordinator / dbMaintenanceLock / persistent database admission model.

This is prompted by a real staging failure:

historicalArchiveImport acquired mutation authority, thereby activating database-reopen blocking, and then its own required graph access was rejected because working_ss.db was “unavailable during database maintenance.”

The subsequent fix prepared the graph-import service before acquiring mutation authority so that an already-open graph connection survived the maintenance lock.

Treat that correction as PROVISIONAL for purposes of this audit.

The governing architectural principle is mechanical impossibility:

An operation that does not possess the required authority must be mechanically unable to mutate protected state.

But the inverse should also be mechanically coherent:

An operation that DOES possess the ball must not be mistaken for an unrelated train merely because a downstream guard has reduced rich ownership state to a global Boolean “track closed” signal.

Read the canonical database-access, archive-authority, mutation-coordinator, database-provider, Historical Archives, and production-readiness documentation and current implementation.

Answer these questions from code:

1. What exact authority does ArchiveMutationCoordinator grant to an admitted owner?

2. How is owner identity represented and propagated, including async-zone/reentrant ownership?

3. What information is lost when coordinator state becomes dbMaintenanceLockProvider?

4. Which database providers currently consult only the context-free maintenance Boolean?

5. Can those providers determine whether the caller requesting access is the currently admitted mutation owner?

6. Why was historicalArchiveImport able to grant itself mutation authority and then be denied its own required working_ss access?

7. Does the current “prepare the graph connection before acquiring authority” fix restore a correct authority model, or merely avoid exercising the faulty guard?

8. Search for other operations that similarly pre-resolve/open protected databases before acquiring mutation authority. Determine whether correctness currently depends on resource-opening order.

9. Investigate the observed Historical Archives UI flakiness during import/removal/reimport:
   - unexpected transition into Onboarding;
   - temporary Environment Readiness/setup-failure presentation;
   - later spontaneous recovery.
     Determine whether those states are caused by ordinary readers observing maintenance-induced graph unavailability without knowing that the unavailability belongs to a legitimate active mutation operation.

10. Define the smallest authority model in which:
    - unrelated operations/readers cannot open resources forbidden during maintenance;
    - the admitted owner can obtain every resource its declared operation is authorized to use;
    - nested/reentrant work retains the same authority;
    - correctness does not depend on opening connections before acquiring the ball;
    - presentation can distinguish “temporarily unavailable because legitimate maintenance owns the track” from “database genuinely unavailable/broken” where necessary.

Do not immediately implement a capability-token framework or other new abstraction.

First determine whether the existing coordinator owner/async-zone machinery already contains enough information to make database admission owner-aware.

Compare at least:

A. current Boolean maintenance-lock model;

B. owner-aware provider admission using existing coordinator context;

C. an explicit scoped mutation lease/capability passed to protected operations, but only if existing context cannot provide mechanical ownership safely.

Prefer the smallest model that restores mechanical impossibility.

Do not weaken the rule for unrelated readers.

Do not simply remove dbMaintenanceLockProvider.

Do not preserve the pre-open workaround merely because tests now pass.

Do not change Historical Archives UX in this task.

Do not touch production archives, donors, attachments, or staging data.

Create a Feature 26 architecture audit documenting:

- current ball/track model;
- exact self-blocking failure path;
- what the provisional patch does;
- whether it is architecturally correct or a sequencing workaround;
- all other code paths affected by the same flaw;
- relationship, if any, to the observed Onboarding redirects;
- one recommended correction.

If the audit establishes a small, unambiguous correction that restores owner-aware mechanical admission without broader redesign, you may propose it, but STOP before implementation and report first.

Run only non-mutating code/documentation analysis and git diff --check.
