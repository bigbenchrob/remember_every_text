# Linear Schedule / Trip Execution Implementation

## Status

Implemented on the `Ftr.prov-rules` experimental branch.

This is the first deliberately linear implementation of the approved Schedule
/ Trip / Step model. It proves persistence, ordered execution, Trip-boundary
checkpointing, and restart behavior. It does not implement the broader routing
experiment.

## What Was Implemented

The executable system is intentionally small:

```text
Scheduler knows which Trip is current.
Trip runs its Steps from first to last.
Terminal Tell Step returns null.
Scheduler advances to the next Trip.
Database remembers the current Trip across restart.
```

One development Schedule contains:

```text
Trip A
    Tell A1
    Tell A2

Trip B
    Tell B1
    Tell B2

Trip C
    Tell C1
```

The experimental host presents the current Schedule, Trip, and Tell Step. A
manual `Complete Step` control makes progression and restart behavior directly
observable without introducing timing or production workflow behavior.

## Physical Database Integration

Presence now has its own physical SQLite database:

```text
presence.db
```

The central database layer owns:

- the filename in `AppDatabaseFile`;
- path construction under the admitted archive root;
- the long-lived generated Riverpod provider;
- executor construction and database disposal.

Presence owns its Drift schema and repositories. Feature and presentation code
do not open the database directly.

`presence.db` is intentionally not registered with destructive reset behavior
or production health/backup inventory in this experiment. Those operations
require an explicit production-preservation decision; the implementation does
not guess one.

## Implemented Tables

Schema version 1 contains six structural tables:

1. `schedule_definitions`
2. `trip_definitions`
3. `step_definitions`
4. `schedule_trip_occurrences`
5. `trip_step_occurrences`
6. `schedule_runs`

It contains one concrete Step subtype table:

7. `tell_step_definitions`

The physical Tell payload column remains named `text`. Its Dart getter is
`stepText` because Drift already reserves `text()` as a column-builder method.

The schema enforces:

- primary and foreign-key identity;
- non-negative occurrence positions;
- one Trip per Schedule position;
- at most one occurrence of a canonical Trip definition in one Schedule;
- one Step per Trip position;
- one Tell subtype row per Tell Step identity;
- the closed Step discriminator `tell`;
- current Trip occurrence membership in the active Schedule through a
  composite foreign key.

The append-only trace, fixed-destination subtype, and FDA-test subtype are not
present in this slice.

## Domain And Runtime Classes

### Definitions

- `ScheduleDefinition` owns ordered `ScheduleTripDefinition` occurrences.
- `TripDefinition` owns ordered reusable `Step` definitions.
- `Step` is the sealed concrete-work boundary.
- `TellStep` is the only implemented Step and returns `null` from completion.

Definitions are immutable and contain no runtime progress.

### Runtime

- `ScheduleRun` represents the durable current Trip checkpoint.
- `Trip` is the one ordinary runtime Trip class and owns only a transient
  current-Step index.
- `PresenceScheduler` coordinates the loaded run, current Trip, and atomic
  Trip-boundary transition.

No specialized Trip class, behavior enum, current-Step field, `TripRun`, or
`StepRun` was introduced.

## Responsibility Boundaries

### Scheduler

The Scheduler:

- starts or loads one Schedule run;
- creates a fresh runtime Trip for the persisted current occurrence;
- receives only the terminal Step result relayed by Trip;
- asks the repository to atomically checkpoint the next occurrence.

It does not inspect Step subtypes or persist Step progress.

### Trip

Trip:

- starts at its first Step;
- completes Steps in list order;
- discards results from nonterminal Steps;
- relays only the terminal Step's `int?` canonical destination result.

It does not select the next Trip or write durable state.

### Step

A Step performs its own concrete work. `TellStep` owns its text and completes
with `null`. It does not know whether it is terminal, where it occurs, or what
the Scheduler will select.

## Repository Loading Algorithm

The Drift repository loads an active run as follows:

1. Load `schedule_runs` by run identity.
2. Load the owning Schedule definition.
3. If `current_trip_occurrence_id` is null, return a completed run.
4. Load the current Schedule Trip occurrence and verify that it belongs to the
   run's Schedule.
5. Load its canonical Trip definition.
6. Load that Trip's Step occurrences ordered by position.
7. For each occurrence, load the base Step row.
8. Validate the discriminator and required Tell subtype row.
9. Construct `TellStep`, then the immutable `TripDefinition`.
10. Return `ScheduleRun`; the Scheduler constructs a fresh runtime `Trip` at
    Step 1.

Definition insertion also validates non-empty names and Tell text, unique
Schedule occurrence identities and positions, one Trip definition per
Schedule, non-negative positions, and consistency when reusable Trip or Step
definitions already exist.

## Restart And Checkpoint Behavior

Only `schedule_runs.current_trip_occurrence_id` is durable runtime authority.

If the process stops after Step 1 of Trip B, the stored occurrence still points
to Trip B. Reopening the physical database reconstructs Trip B and starts it at
Step 1. Trip A is not replayed, and Trip B does not resume at Step 2.

When a terminal Step completes, the repository transaction:

1. verifies the expected current occurrence;
2. finds the same Schedule's occurrence with the smallest greater position;
3. conditionally updates the current occurrence, or writes null at completion;
4. verifies that exactly one run row changed;
5. commits before the Scheduler installs the next Trip.

A failure before commit leaves the previous Trip as the restart destination. A
successful commit makes the next Trip the restart destination.

## Tests Added

Focused tests use a real temporary file-backed `presence.db` and prove:

- the database file survives close and reopen;
- Schedule Trip order is deterministic;
- Trip Step execution order is deterministic;
- duplicate use of one Trip definition within one Schedule is rejected by
  SQLite;
- one canonical Trip may be reused by different Schedules;
- execution proceeds A1, A2, B1, B2, C1, complete;
- terminal `null` advances by Schedule position;
- restart during Trip B returns to B1 without replaying Trip A;
- the Trip-boundary checkpoint changes the restart destination atomically;
- central database filename and path construction include `presence.db`;
- Presence imports no MessageLens feature implementation.

The focused tests, architecture tripwires, analyzer, and debug macOS build are
the verification gates for this slice.

## Obsolete Experiment Code Removed

The conflicting Journey experiment was removed rather than adapted:

- Journey and JourneyProgress entities;
- Journey repository and in-memory Drift definition store;
- Journey 42 fixture;
- Ask/Tell Journey views and view models;
- nested FDA auditing experiment remnants;
- Journey-specific tests and generated Drift/Freezed output.

Git remains the archive. No compatibility layer was added.

## What Proved Awkward

Two implementation details required care but no architectural expansion:

1. Drift's `text()` builder prevents a Dart table getter named `text`; the
   schema keeps the correct SQL name while the generated API uses `stepText`.
2. `presence.db` is durable enough to demand a future preservation decision,
   but this experimental slice cannot truthfully choose its production reset,
   backup, or health policy. It therefore integrates only with central
   filename, admitted-root, provider-lifecycle, and open/close authority.

## Rules Changed

No approved execution rule changed.

The active system-boundary document was rewritten to remove obsolete Journey
and nested-FDA responsibilities and to record the implemented Schedule / Trip /
Step boundaries.

## What This Experiment Proved

- One ordinary Trip class is sufficient for linear execution.
- Reusable Schedule, Trip, and Step definitions can be normalized without
  storing runtime state in them.
- Persisting only the current Trip occurrence produces the approved restart
  semantics.
- A terminal `null` result is sufficient for deterministic default-next
  progression.
- Atomic Trip-boundary checkpointing prevents partial durable transitions.
- The resulting implementation remains conceptually small.

## What It Did Not Prove

- canonical destination routing;
- fixed-destination or FDA-test Steps;
- loops;
- execution trace;
- production onboarding behavior;
- current-Step recovery;
- production backup, health, inventory, or reset policy for `presence.db`.

## What Should Be Implemented Next, If This Remains Promising

The next experiment should add one concrete routing-capable Step and canonical
Trip-definition destination resolution. It should preserve the same one-Trip
runtime class and prove that explicit routing composes with default-next before
adding FDA behavior or trace history.
