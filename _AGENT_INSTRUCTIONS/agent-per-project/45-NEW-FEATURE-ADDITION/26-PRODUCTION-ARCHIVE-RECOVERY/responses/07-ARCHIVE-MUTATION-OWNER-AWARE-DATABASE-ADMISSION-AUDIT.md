---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-17
source_of_truth: audit
links:
  - 04-HISTORICAL-IMPORT-MAINTENANCE-LOCK-CORRECTION.md
  - ../../10-DATABASES/00-all-databases-accessed.md
  - ../../10-DATABASES/access_authority_documentation/010-DATABASE-ACCESS-IN-PLAIN-ENGLISH.md
  - ../../50-ENVIRONMENT-SAFETY/00-overview.md
tests:
  - test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart
  - test/essentials/archive_environment/application/archive_scoped_persistent_providers_test.dart
  - test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart
---

# Archive Mutation Owner-Aware Database Admission Audit

## Conclusion

The staging failure exposed a defect in the authority model, not a Historical
Archives-specific service-ordering mistake.

`ArchiveMutationCoordinator` knows which async owner holds the mutation ball.
`dbMaintenanceLockProvider` discards that ownership and exposes only a global
Boolean answer: database reopen is blocked. The graph database provider can
therefore distinguish only "track open" from "track closed." It cannot
distinguish the train holding the ball from an unrelated train.

The historical-import correction in Audit 04 is a sequencing workaround. It
opens and caches the graph connection before the operation acquires mutation
authority, so the graph provider's context-free guard is not exercised during
the protected interval. It does not make database admission owner-aware, and
correctness still depends on resource-opening order.

The smallest coherent correction is to extend the existing coordinator
context into an owner-aware database-admission decision. A new public
capability-token framework is not yet justified. The existing private async
Zone owner identity can provide mechanical caller identity, provided that
reentrant operation policy and checkpoint requirements are also preserved
truthfully.

This audit authorizes no implementation.

## Current Ball And Track Model

### What authority is actually granted

`ArchiveMutationCoordinator.run` grants one process-local async owner the
exclusive right to execute an admitted archive mutation against one admitted
archive. While that owner is active:

- competing owners are rejected;
- same-owner descendants may re-enter;
- the coordinator records the outer operation, owner, archive environment,
  archive instance, acquisition time, and hold count; and
- production operations classified as high risk require verified checkpoint
  evidence when admitted at the outer boundary.

This is currently an **execution admission**, not a recognized database-access
capability. No persistent database provider asks whether its caller holds that
authority. The admitted owner is therefore permitted to run its action in the
abstract, but downstream resource guards do not recognize that permission.

### Owner identity and propagation

The coordinator creates an owner ID in the form:

```text
<owner label>#<process-local sequence>
```

It stores that ID in `ArchiveMutationCoordinatorState.ownerId` and installs it
under a private object key in the current Dart async `Zone`. Awaited async work
inherits the Zone. A nested `run` reads the inherited owner ID, re-enters the
same coordinator ownership, increments `holdCount`, and executes without
creating a competing owner.

The private Zone key is useful security structure: ordinary callers cannot
manufacture coordinator ownership by supplying a public string. The
coordinator can compare the current Zone's owner ID with its active state to
prove that a call descends from the admitted owner.

No database provider currently performs that comparison, and no coordinator
API currently exposes a derived owner-aware admission answer.

### Reentrant policy is not preserved truthfully

Reentry retains the outer state's `operation` and `ownerLabel`; it records only
the increased hold count. The nested operation is otherwise discarded.

Checkpoint validation also runs only when there is no inherited owner ID.
Consequently, a nested operation with stronger policy can lose both:

- its `blocksDatabaseReopen` requirement; and
- its `requiresVerifiedCheckpoint` requirement.

For example, `messageDataReset` can run nested beneath `onboardingImport` or
`automaticRecovery`. The coordinator then continues to report only the outer
operation. This is not merely a diagnostics limitation. It means the effective
maintenance and production-safety policy can be weaker than the work currently
executing.

Existing reentry tests prove shared ownership and hold counting, but do not
prove preservation of nested operation policy or checkpoint requirements.

## Information Lost In The Boolean Projection

The projection is:

```text
ArchiveMutationCoordinatorState
    -> state.operation.blocksDatabaseReopen
    -> archiveDatabaseReopenBlockedProvider
    -> dbMaintenanceLockProvider
    -> bool
```

The Boolean retains only whether the recorded outer operation blocks database
reopen. It loses:

- active owner ID;
- current caller's relationship to that owner;
- owner label;
- nested operation identity;
- archive environment and archive instance;
- hold count and nesting;
- operation-specific resource permission;
- whether unavailability is legitimate and temporary; and
- why the resource is unavailable.

The Boolean remains useful as a coarse compatibility or presentation signal.
It is insufficient as the sole database-admission decision.

## Persistent Database Admission

Of the centralized persistent database providers, only
`driftConversationGraphDatabaseProvider` consults
`dbMaintenanceLockProvider`. The source-scoped import, Overlay, and Presence
database providers do not.

The graph provider samples the Boolean when constructing a connection. If it
is true, the provider also watches the signal so a failed first construction
can retry after maintenance releases. It then throws:

```text
working_ss.db is unavailable during database maintenance
```

The provider is keep-alive. Once its connection has been created, activating
maintenance does not revoke that handle or check each later query. The current
contract is therefore specifically **fresh connection/reopen admission**, not
per-query database authority.

The provider cannot determine whether the caller requesting a fresh connection
is the active mutation owner. It sees no owner context and no operation-specific
permission, only the Boolean.

## Exact Historical Import Self-Block

The original failure path was:

```text
HistoricalArchivesWorkflow.beginImportForSelectedSource
    -> ArchiveMutationCoordinator.run(historicalArchiveImport)
    -> coordinator records historicalArchiveImport
    -> dbMaintenanceLockProvider becomes true
    -> action resolves SourceScopedArchiveGraphImportService
    -> graph projector providers resolve working_ss.db
    -> graph provider sees only true
    -> graph provider throws
```

The import possessed exclusive mutation authority, but the graph provider had
no way to recognize it. The same owner therefore closed the track globally and
was then treated as an unrelated train attempting to enter it.

## What The Provisional Patch Does

The current Historical Archives workflow resolves
`SourceScopedArchiveGraphImportService` before calling
`ArchiveMutationCoordinator.run`. That resolution constructs and caches the
graph provider while the Boolean is still false.

The admitted import then uses the already-open connection. Because the graph
provider no longer reacts by disposing an established connection when the
Boolean changes, the import succeeds while unrelated fresh opens remain
blocked.

This is operationally useful and preserved the staging rehearsal, but it does
not repair authority:

- the admitted owner is still denied if it first requests the provider after
  admission;
- the owner succeeds only if resource construction happened in the right
  order;
- the cached connection is not an owner-scoped capability;
- unrelated code in the same provider container may also obtain that already
  cached connection; and
- tests now codify preparation order rather than owner-aware admission.

The patch avoids exercising the faulty guard. It does not make the guard
correct.

## Other Order-Dependent Paths

### Historical archive removal

`historicalArchiveRemoval` acquires mutation authority and then resolves
`sourceScopedArchiveGraphRemovalServiceProvider`. That service transitively
resolves graph resetters and projectors backed by `working_ss.db`.

It therefore has the same self-blocking path whenever the required graph
provider has not already been cached. Apparent success can depend on earlier
application activity having opened the graph.

### Message-data reset

Top-level `messageDataReset` blocks graph reopen, then attempts to obtain the
graph provider so it can close the database before deleting derived files. If
the provider is already established, it can close it. If the provider must be
constructed at that point, the reset can reject its own request.

This operation needs a more precise resource contract than "owners bypass the
lock." Reset may need authority to close an existing handle without being
authorized to create a new graph connection immediately before deleting it.
The eventual correction must not turn owner awareness into an unconditional
owner exemption.

### Nested onboarding reset

Settings reimport and automatic recovery enter the coordinator as
`onboardingImport` or `automaticRecovery`, then invoke the reset service, which
re-enters as `messageDataReset`.

Because reentry retains only the outer operation, these paths can avoid the
reset operation's reopen-blocking and checkpoint policies entirely. Their
correctness currently depends on the outer operation and resource lifecycle,
not on the policy of the work actually running.

### Other mutation operations

No other operation was found deliberately preparing a protected graph service
before acquiring mutation authority. Graph build, live graph update,
attachment reconciliation, and the currently used attachment operations do
not set `blocksDatabaseReopen`. `destructiveMaintenance` declares the policy
but has no active `run` call site in the inspected implementation.

The concrete order dependencies found in active code are therefore:

1. historical import: explicitly pre-opens as a workaround;
2. historical removal: resolves after admission and can self-block;
3. top-level message reset: resolves its close target after admission and can
   self-block; and
4. nested reset: can silently lose the stronger operation policy.

## Relationship To Onboarding And UI Flakiness

The observed Onboarding redirects are consistent with ordinary presentation
readers misclassifying legitimate maintenance as database failure.

`onboardingEnvironmentReportProvider` watches the context-free Boolean. During
maintenance it deliberately avoids reading the graph and creates an unready
`ConversationGraphReadiness` with the reason `database maintenance is active`.
Because the import ledger still has data and the graph file still exists, the
normal classifier maps that temporary state to:

```text
OnboardingEnvironmentState.graphProjectionFailed
OnboardingBlockerKind.graphProjectionFailed
```

`OnboardingGate` maps `graphProjectionFailed` to
`OnboardingStatus.awaitingUserAction`, which can place Environment Readiness in
the application panel stack. When maintenance releases, the report recomputes,
the graph becomes readable again, and the gate returns to `notNeeded`. That
explains both the alarming transition and its spontaneous recovery.

The automatic-recovery detector does avoid proposing a reset while the Boolean
is active. The defect here is primarily false failure presentation, not proof
that maintenance itself launched a reset.

Other Boolean consumers show the same information loss:

- the Contacts list returns an empty list during maintenance; and
- the Historical Archives execution-gate view labels any reopen-blocking
  operation `Blocked`, even when the current workflow is the owner that created
  the condition.

The long Historical Archives control panel and unclear expected action are
separate presentation concerns. This audit does not redesign them.

## Alternatives

### A. Current Boolean maintenance lock

**Result:** Rejected as the complete admission model.

It correctly suppresses unrelated fresh graph opens, but cannot identify the
owner, cannot express operation-specific resource permission, loses nested
policy, creates self-blocks, and causes legitimate maintenance to resemble
database failure.

It may remain as a derived compatibility/presentation signal after richer
admission exists.

### B. Owner-aware admission using existing coordinator context

**Result:** Recommended.

The private Zone owner ID and coordinator state already contain the basis for a
mechanical ownership check. The coordinator should derive the database
admission answer so callers do not inspect or forge raw owner IDs.

Conceptually, a fresh graph-open decision must answer:

```text
Is graph reopen unrestricted?
    yes -> admit

Is a reopen-blocking mutation active?
    no -> admit

Does the current async caller own that mutation,
and does the effective operation authorize a fresh graph connection?
    yes -> admit
    no  -> deny temporarily with maintenance context
```

This preserves mechanical exclusion for unrelated readers while allowing an
authorized owner to obtain the resources its declared operation requires.

The model must also preserve nested operation scopes. At minimum, effective
reopen-blocking and checkpoint policy must never become weaker during reentry,
and the current nested operation must be available when deciding owner
resource permission. Exiting a nested scope must restore the preceding scope
truthfully.

Implementation must prove that provider evaluation remains in the requesting
async Zone. That is an implementation test requirement, not grounds to invent
a lease pre-emptively.

### C. Explicit scoped mutation lease or capability

**Result:** Not currently justified.

An explicit lease would be appropriate if protected authority had to cross an
isolate, outlive the coordinator action, survive detached work, or be checked
on every use of a cached database handle. None of those requirements has been
established for the current fresh-reopen contract.

Introducing a passed capability now would duplicate information already held
by the coordinator and broaden APIs before the existing context has been
tested properly.

## Recommended Correction

Adopt one bounded model correction: **coordinator-owned, owner-aware resource
admission with truthful reentrant operation policy**.

The correction should establish these invariants:

1. The coordinator remains the only mutation admission authority.
2. Private async context proves whether the current caller is the active owner;
   raw owner IDs are not accepted from feature code.
3. Nested operations remain the same owner but retain their own operation
   scope; effective safety policy never weakens during nesting.
4. Every operation that requires production checkpoint evidence is validated,
   including a stronger operation entered through reentry.
5. Fresh graph construction asks the coordinator for an owner-aware,
   operation-aware decision rather than consulting only a Boolean.
6. Historical import and removal may construct the graph resources their
   operation contract explicitly authorizes while unrelated callers remain
   denied.
7. Message reset receives only the resource lifecycle authority it actually
   needs. Closing an existing graph handle must not require constructing a new
   one that the reset is about to delete.
8. Correctness no longer depends on pre-opening services before acquiring the
   mutation ball.
9. The coarse maintenance Boolean may remain for compatibility, but readiness
   presentation must distinguish legitimate temporary maintenance from genuine
   graph failure.
10. Established graph handles remain governed by the existing reopen contract;
    this correction does not silently claim per-query capability enforcement.

After those invariants are covered by focused tests, the historical-import
pre-open workaround should be removed and import/removal should resolve their
feature-owned services inside admitted ownership. That removal belongs to the
future implementation slice, not this audit.

## Required Future Verification

Any implementation proposal following this audit should first demonstrate:

- an admitted historical import can create its required graph provider after
  acquiring authority;
- an admitted historical removal can do the same;
- an unrelated caller remains unable to create a graph provider during either
  operation;
- nested reset policy and checkpoint requirements are not lost;
- reset closes an existing graph handle without opening a new one;
- a denied fresh open retries after maintenance release;
- readiness reports legitimate maintenance without classifying it as graph
  projection failure; and
- no production, donor, staging, or attachment data is required by the tests.

No implementation should proceed merely by adding more pre-resolution order
requirements.
