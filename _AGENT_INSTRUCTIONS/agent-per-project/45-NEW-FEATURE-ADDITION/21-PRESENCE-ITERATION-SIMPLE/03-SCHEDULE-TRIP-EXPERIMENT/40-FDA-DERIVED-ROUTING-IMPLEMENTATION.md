# FDA-Derived Routing Implementation

## Status

Implemented on the `Ftr.prov-rules` experimental branch as the third bounded
Schedule / Trip / Step routing experiment.

The new capability is:

```text
FdaTestStep asks one factual question
    -> keeps the Boolean answer local
    -> returns null or TripDefinitionId(X)

Trip relays the terminal result unchanged

Scheduler applies its existing routing rule
```

No generalized condition, result, routing-table, loop, or retry abstraction was
introduced.

## Schema Version 3

`presence.db` advances from version 2 to version 3. The closed Step
discriminator adds:

```text
fda_test
```

The new subtype table is:

```text
fda_test_step_definitions
    step_definition_id                          Step foreign key
    present_destination_trip_definition_id      nullable Trip definition FK
    absent_destination_trip_definition_id       nullable Trip definition FK
```

Both routing columns hold canonical Trip definition identities. They never
hold Schedule Trip occurrence identities. `null` means default-next in Schedule
order. Both destination columns are indexed and retain foreign-key integrity.

The migration expands the discriminator constraint and adds the subtype table.
The existing v1 migration remains valid, and a file-backed v2 migration test
proves that an existing Tell definition and active run survive upgrade to v3.

## FdaTestStep

`FdaTestStep` owns:

- a nullable destination for the FDA-present result;
- a nullable destination for the FDA-absent result;
- one narrow `FdaTestingAuthority` dependency.

Completion awaits `hasFullDiskAccess()`, selects one arm, and returns only that
arm's `TripDefinitionId?`. The Boolean is a local implementation detail. It does
not enter Trip completion, Scheduler, persistence, or restart authority.

Because the factual test may be asynchronous, `Step.complete()` and
`Trip.completeCurrentStep()` now return Futures. This changes execution
mechanics, not ownership. Trip still executes Steps in order, discards any
nonterminal result, and relays only the terminal result.

## Testing Authority Boundary

The permanent Presence package defines only:

```text
FdaTestingAuthority
    hasFullDiskAccess() -> Future<bool>
```

The disposable development client supplies a mutable fake. Presence imports no
onboarding, archive-ingestion, Messages, Contacts, attachment, or other feature
implementation. The real onboarding FDA provider was deliberately not reused:
it is an onboarding-owned macOS boundary, while this experiment requires an
injectable factual contract and no production behavior.

The development host exposes a Present/Absent toggle. It changes only the fake
authority's next answer. It does not reset a run, choose a route, or change
macOS permission.

## Repository Loading And Integrity

Insertion persists the base Step row and one FDA subtype row after canonical
Trip rows exist. Loading is discriminator-driven and fails closed when an FDA
Step:

- lacks its FDA subtype row;
- also has a Tell or Fixed Destination subtype row;
- contains an unknown discriminator.

The injected authority is attached while reconstructing the concrete
`FdaTestStep`. It is not persisted and does not participate in definition
equality; persisted arm identities are the definition.

Schedule closure validation requires:

- every non-null present destination to occur in the Schedule;
- every non-null absent destination to occur in the Schedule;
- every FDA Test Step to be terminal in its Trip.

The existing Schedule uniqueness constraint guarantees at most one occurrence
of each canonical Trip. Repository validation guarantees presence. No graph
validator was added.

## Experimental Schedule

The disposable fixture is:

```text
1: Tell -> default 2
2: FDA present -> default 3; absent -> 5
3: Tell -> default 4
4: Fixed destination -> 8
5: Tell remediation guidance -> default 7
7: FDA present -> default 8; absent -> 2
8: Tell -> complete
```

Its Schedule order is `1, 2, 3, 4, 5, 7, 8`.

### FDA present

```text
1 -> 2 -> 3 -> 4 -> 8 -> complete
```

### FDA absent, then granted

```text
1 -> 2 -> 5 -> 7 -> 8 -> complete
```

### FDA remains absent

```text
1 -> 2 -> 5 -> 7 -> 2 -> 5 -> 7 -> ...
```

The loop is ordinary repeated canonical routing. It has no loop object,
attempt counter, retry state, or specialized Trip.

## Restart Result

A file-backed test closes the database while Trip 7 is current, reopens it, and
reconstructs Trip 7 at Step 1. Completing the reloaded FDA Step while the fake
remains absent checkpoints Trip 2.

The only durable runtime authority remains:

```text
current_trip_occurrence_id
```

No Boolean, prior condition result, route decision, or current-Step position is
persisted.

## Trip And Scheduler Changes

Trip gained no FDA knowledge and no subtype inspection. Its completion method
became asynchronous solely so it can await the existing polymorphic Step
contract.

Scheduler gained no new routing logic. It now awaits Trip completion and still
interprets exactly two terminal values:

```text
null                    -> default next
TripDefinitionId(X)     -> canonical destination X
```

There is no FDA, Boolean, remediation, or loop branch in Scheduler.

## Tests And Verification

Focused tests cover:

- true and false fake responses staying inside `FdaTestStep`;
- nullable and non-null arm results;
- persistence and reconstruction of both canonical arms;
- the present path;
- the absent-then-granted path;
- the repeated absent loop;
- restart at the current Trip inside that loop;
- rejection of either configured arm when its destination is absent;
- rejection of a nonterminal FDA Test Step;
- migration of a file-backed v2 run to schema v3;
- all existing fixed-destination and linear behavior.

Verification completed successfully with:

- all 25 Presence tests;
- all 353 architecture tripwires;
- `flutter analyze` with no issues;
- a debug macOS build;
- formatting;
- `git diff --check`.

## What Proved Awkward

The only new mechanical pressure was asynchronous factual testing. Making the
existing Step/Trip completion seam awaitable was smaller and more truthful than
introducing a synchronous cache or allowing the Scheduler to invoke the test.

The repository also needs the runtime authority when reconstructing an FDA
Step. A narrow injected contract keeps that dependency explicit without making
the repository, Trip, or Scheduler own FDA decisions.

## Architectural Result

No responsibility rule changed. One previously proposed rule became concrete:
a concrete terminal Step may calculate its routing result internally.

The experiment succeeds because the complete new behavior remains describable
as:

```text
FdaTestStep asks one question.
It turns the answer into null or TripDefinitionId(X).
Trip relays that value unchanged.
Scheduler does exactly what it already did.
```
