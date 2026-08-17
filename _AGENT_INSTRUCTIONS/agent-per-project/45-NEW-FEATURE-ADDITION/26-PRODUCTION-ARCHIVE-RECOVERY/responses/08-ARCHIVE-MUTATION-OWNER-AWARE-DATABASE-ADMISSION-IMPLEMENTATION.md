---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-17
source_of_truth: implementation-record
links:
  - ../00-START-HERE.md
  - 07-ARCHIVE-MUTATION-OWNER-AWARE-DATABASE-ADMISSION-AUDIT.md
  - 04-HISTORICAL-IMPORT-MAINTENANCE-LOCK-CORRECTION.md
tests:
  - test/architecture/historical_archives_graph_admission_test.dart
  - test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart
  - test/essentials/archive_environment/application/archive_scoped_persistent_providers_test.dart
  - test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart
  - test/essentials/onboarding/application/onboarding_gate_provider_test.dart
---

# Archive Mutation Owner-Aware Database Admission Implementation

## Outcome

The provisional Historical Archives pre-open sequencing workaround is removed.
Fresh Conversation Graph construction now asks the
`ArchiveMutationCoordinator` for an owner-aware and operation-aware resource
decision.

The resulting rule is mechanical:

```text
no blocking mutation
    -> ordinary graph construction is unrestricted

blocking mutation active
    -> unrelated async caller is denied
    -> admitted owner is still denied unless its current operation scope
       explicitly permits this graph action
    -> any stronger active nested scope can forbid the action
```

`dbMaintenanceLockProvider` remains a coarse compatibility and presentation
signal. It is not the resource-admission authority.

## Private Async Ownership

The coordinator installs a private context in the admitted operation's Dart
Zone. A focused provider test proved that Riverpod evaluates the protected
graph provider in the requesting async Zone, so provider construction can ask
the coordinator to identify the caller without exposing owner IDs or public
capability tokens.

Every reentrant operation receives its own scope entry while retaining the same
private owner identity. The Zone context records both:

- owner identity; and
- the requesting branch's current operation.

The provider supplies neither value. It asks only whether the requested
resource action is allowed.

## Caller-Specific Scope Is A Hard Invariant

Permission belongs to the requesting async branch's innermost operation scope.
An outer or sibling scope cannot lend its permission to that caller.

Aggregate safety is evaluated separately. If any active blocking scope for the
same owner forbids fresh graph construction, the action remains denied. This
ensures nested work may strengthen policy but never weaken it. Leaving the
nested scope restores the outer policy.

Verified-checkpoint requirements are evaluated for every scope, including
reentrant nested operations. Reentry no longer bypasses a stronger checkpoint
requirement.

## Operation-Specific Graph Permission

The first protected action is:

```text
openConversationGraphConnection
```

Only these current operations permit their admitted owner to request it while
graph reopen blocking is active:

- `historicalArchiveImport`;
- `historicalArchiveRemoval`.

This is not a blanket rule that the mutation owner may open the graph. An
unrelated caller remains denied during either operation, and a nested blocking
operation that lacks this permission denies the action even though owner
identity is unchanged.

## Message Reset

`messageDataReset` is intentionally different. It may close a graph connection
that already exists, but it may not construct a new graph immediately before
deleting derived graph files.

The DB layer now tracks only an already constructed Conversation Graph handle.
Reset asks that lifecycle boundary to close the handle if present. If no handle
exists, the request is a no-op and the graph provider is never read or
initialized. Provider invalidation is likewise conditional on an existing
handle having been closed.

This preserves the distinction:

```text
resource ownership
    !=
permission to perform every resource action
```

## Historical Archives Sequencing

Historical import now resolves its graph import service inside the admitted
`historicalArchiveImport` action. Removal already followed that shape. Neither
operation depends on opening graph infrastructure before acquiring mutation
authority.

## Maintenance Is Not Failure

Onboarding environment classification now represents active maintenance as
`maintenanceInProgress`, with no onboarding blocker. `OnboardingGate` maps that
truthful state to `notNeeded`.

Ordinary readers may still observe the coarse maintenance signal and decline
to reopen the graph, but that temporary suppression is no longer interpreted
as `graphProjectionFailed` and does not request onboarding action.

## Verification Evidence

Focused tests prove:

1. protected provider construction retains the requesting Dart Zone;
2. historical import and removal owners may construct the graph after
   admission;
3. unrelated callers remain denied during both operations;
4. denied construction recovers after maintenance release;
5. caller permission comes from its own operation scope;
6. stronger nested reopen and checkpoint policies remain enforced;
7. nested exit restores outer policy;
8. reset does not construct an unopened graph provider;
9. reset closes an existing graph handle before file deletion;
10. maintenance is neither graph failure nor onboarding action.

No database schema, source identity, archive data, donor, staging data, or
attachment payload changed in this implementation.
