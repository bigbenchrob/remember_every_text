# Fixed-Destination Routing Implementation

## Status

Implemented on the `Ftr.prov-rules` experimental branch as the second bounded
Schedule / Trip / Step experiment.

This increment adds one capability only:

```text
terminal null
    -> default next in Schedule order

terminal TripDefinitionId(X)
    -> Trip X in the active Schedule
```

The ordinary `Trip` runtime class is unchanged in responsibility. It sequences
Steps and relays only the terminal Step's result.

## Schema Change

`presence.db` advances from schema version 1 to version 2.

The `step_definitions.type` closed set now contains:

```text
tell
fixed_destination
```

The new subtype table is:

```text
fixed_destination_step_definitions
    step_definition_id                 primary key and Step foreign key
    destination_trip_definition_id     Trip definition foreign key
```

The destination is a canonical Trip definition identity. A Schedule Trip
occurrence identity never enters a reusable Step definition. The destination
column is indexed for definition-integrity and future diagnostic reads.

The version-1 migration rebuilds the base Step table with the expanded closed
set, creates the new subtype table, and preserves existing Tell definitions and
Schedule runs. A file-backed migration test verifies that an existing run can
still be loaded after upgrade.

## New Concrete Step

`FixedDestinationStep` owns one `TripDefinitionId` and returns it from
`complete()`.

It does not:

- inspect the Schedule;
- resolve its destination to an occurrence;
- mutate a Schedule run;
- know whether it is terminal.

The repository permits the Step in executable definitions only when it is
terminal. `Trip` independently retains its general rule that results from
nonterminal Steps do not cross the Trip boundary.

## Typed Canonical Identity

This increment introduced the local immutable `TripDefinitionId` value type.
It now identifies `TripDefinition`, the Step's destination, Trip completion,
and the repository checkpoint request.

The type earned its existence because routing puts three unrelated integers at
one boundary:

- canonical Trip definition identity;
- Schedule Trip occurrence identity;
- Step identity.

Keeping the canonical value typed makes it mechanically harder to persist or
return an occurrence ID by mistake. No generic identity framework was added.

## Repository Construction And Loading

Definition insertion now occurs in three phases inside one transaction:

1. Insert or validate every canonical Trip base row.
2. Insert each new Trip's ordered Step composition and concrete subtype rows.
3. Insert the Schedule's Trip occurrences.

Creating all Trip identities before Step subtype rows allows a fixed
destination to reference a later Trip without weakening the foreign key.

Loading remains discriminator-driven. A Tell Step must have one Tell subtype
row and no fixed-destination row. A Fixed Destination Step must have one
fixed-destination row and no Tell row. Missing, unknown, or conflicting subtype
state fails closed.

## Schedule Closure

Before insertion, the repository verifies that:

- each canonical Trip appears at most once in the Schedule;
- every Fixed Destination Step is terminal in its Trip;
- every Fixed Destination Step's canonical destination appears in the same
  Schedule.

SQLite's unique key on
`(schedule_definition_id, trip_definition_id)` guarantees at most one matching
occurrence. Repository validation guarantees presence. The checkpoint query
also fails closed if an expected destination is unexpectedly absent.

## Scheduler Resolution

At a Trip boundary, the repository resolves and writes the next checkpoint in
one transaction:

1. Verify the run still points to the expected current occurrence.
2. For `null`, select the same Schedule's smallest greater position.
3. For `TripDefinitionId(X)`, select the same Schedule's occurrence whose
   canonical Trip identity is X.
4. Fail closed when an explicit destination is absent.
5. Conditionally update the run to the selected occurrence, or to null when
   default-next reaches the end.
6. Load the checkpointed run; the Scheduler creates a fresh ordinary `Trip`.

The Scheduler does not inspect `FixedDestinationStep`. The repository does not
derive explicit routing from Schedule position.

## Experimental Results

### Forward route

The development Schedule is:

```text
A: Tell -> null
B: Fixed Destination -> D
C: Tell
D: Tell -> null
```

Its execution is:

```text
A -> B -> D -> complete
```

Trip C is not executed. The persisted Step destination is canonical Trip ID
40, not Schedule occurrence ID 2040.

### Backward route

A focused test replaces D's Tell with a Fixed Destination Step to B. A finite
number of transitions produces:

```text
A -> B -> D -> B -> D
```

No loop object, visit counter, retry state, or additional durable routing state
is involved. Resolving an earlier occurrence uses the same checkpoint path as
resolving a later occurrence.

### Restart

After B explicitly checkpoints D, closing and reopening the physical database
loads D as current and creates a fresh D runtime at Step 1. Restart uses only:

```text
schedule_run_id
schedule_definition_id
current_trip_occurrence_id
```

No route decision is persisted separately.

## Development Run Replacement

Completed runs remain completed across normal application restart. The
development host offers an explicit `Run Again` action for repeating the
experiment. It replaces the experiment's sole run in one transaction with a
new run checkpointed at the Schedule's first Trip occurrence.

This action is invoked only by the disposable debug client. It is not part of
normal launch initialization, does not change restart semantics, and does not
automatically reset completed runs.

## Tests

Focused tests prove:

- Fixed Destination persistence and deterministic reconstruction;
- canonical ID storage with no occurrence-ID leakage;
- migration from the Tell-only version-1 schema without losing an active run;
- A defaulting to B, B explicitly selecting D, C being skipped, and completion
  after D;
- finite backward B-to-D-to-B routing;
- rejection of a destination absent from the Schedule;
- rejection of a nonterminal Fixed Destination Step;
- restart at Step 1 of the explicitly selected Trip;
- completed-run persistence until explicit development replacement, followed
  by a new sole run at the first Trip;
- `Trip` discarding a nonterminal routing result without subtype inspection;
- all existing default-next behavior.

Verification completed successfully with all Presence tests, all 353
architecture tripwires, the analyzer, a debug macOS build, formatting, and
`git diff --check`.

## What Proved Awkward

The only material ordering constraint came from truthful foreign keys: a Step
may point to a Trip declared later in Schedule order, so all canonical Trip rows
must exist before subtype rows are inserted. The three-phase transaction solves
that without making the Step Schedule-aware or weakening referential integrity.

## Architectural Changes

One approved boundary became concrete rather than changing:
`TripDefinitionId?` is now the typed Trip-to-Scheduler routing contract.

No other architectural rule changed. In particular:

- there is still one ordinary `Trip` class;
- only a terminal Step result crosses the Trip boundary;
- the Scheduler resolves destinations;
- durable authority remains the current Trip occurrence;
- trace, condition-derived routing, retries, and production onboarding remain
  outside this experiment.
