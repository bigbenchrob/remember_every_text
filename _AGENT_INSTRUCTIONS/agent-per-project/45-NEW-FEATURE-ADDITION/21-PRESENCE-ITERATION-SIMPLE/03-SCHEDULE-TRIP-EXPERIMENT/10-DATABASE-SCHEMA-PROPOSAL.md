# Schedule / Trip Presence Database Schema Proposal

## Status

Approved experimental architecture. This is a fresh derivation of the smallest
normalized storage model for the Schedule / Trip experiment and does not
preserve elements of the previous proposal merely for compatibility.

The default-next implementation is recorded in
[`20-LINEAR-EXECUTION-IMPLEMENTATION.md`](20-LINEAR-EXECUTION-IMPLEMENTATION.md).
The first canonical-routing increment is recorded in
[`30-FIXED-DESTINATION-ROUTING-IMPLEMENTATION.md`](30-FIXED-DESTINATION-ROUTING-IMPLEMENTATION.md).
Together they implement the six required structural tables,
`tell_step_definitions`, `fixed_destination_step_definitions`, and
`fda_test_step_definitions`. FDA-derived routing and the append-only execution
trace are implemented. The trace implementation is recorded in
[`60-EXECUTION-TRACE-IMPLEMENTATION.md`](60-EXECUTION-TRACE-IMPLEMENTATION.md).

The proposal treats the following distinction as fundamental:

```text
definitions prescribe
runtime state remembers the current checkpoint
trace records what happened
```

None of those layers may substitute for another.

## Recommendation In Brief

The one-Trip conjecture is coherent and materially simplifies the model.

There is one `Trip` class. A Trip sequences its ordered Steps and relays the
terminal Step's routing result without interpreting it. The universal routing
result is:

```text
TripDefinitionId?

null                  -> default next in Schedule batting order
TripDefinitionId(42)  -> canonical Trip 42 in the active Schedule
```

The Scheduler alone resolves that canonical definition identity to a unique
Schedule Trip occurrence.

Consequently:

- `trip_definitions.behavior` disappears;
- `test_trip_routes` disappears;
- `router_trip_routes` disappears;
- routing configuration lives only in concrete Step subtype tables that need
  it;
- a test Boolean remains local to its Step and never enters Trip or Scheduler
  routing;
- no universal persisted routing table is required;
- the Trip-level restart checkpoint remains unchanged.

The revised schema has seven structural tables plus the concrete Step subtype
tables earned by the worked experiment. It does not need specialized Trip
types or Schedule-specific routing rows.

## Central Model

### Schedule

A Schedule owns an ordered batting order of Trip occurrences. The same
canonical Trip definition may be reused across Schedules, but may appear at
most once in any one Schedule.

Default progression is derived from batting order. It is never stored as a
route edge.

### Trip

A Trip:

- has one canonical definition identity;
- contains an ordered sequence of Step occurrences;
- starts at its first Step;
- completes when its terminal Step completes;
- relays the terminal Step's `TripDefinitionId?` result;
- does not inspect, classify, or interpret that result.

Terms such as "informational Trip," "test-like Trip," and "router-like Trip"
may describe the effect of a particular Step composition. They are not domain
types, persisted behaviors, or branches in Trip execution.

### Step

Variation belongs in concrete Steps. A Step may present, ask, inspect, invoke,
or act according to its narrow contract. Most Steps return no explicit routing
destination. A terminal Step may resolve its local logic to the universal Trip
routing result.

A Step never returns a `ScheduleTripOccurrenceId`, navigates the Schedule, or
mutates a Schedule run.

### Scheduler

The Scheduler receives the completed Trip's `TripDefinitionId?` result.

For `null`, it selects the occurrence with the smallest position greater than
the current occurrence. If none exists, the Schedule completes.

For a canonical Trip definition ID, it finds that definition's unique
occurrence in the active Schedule. Absence or ambiguity is an invalid
definition state and must fail closed.

## Ownership And Physical Location

Presence owns:

- the schema;
- Schedule, Trip, Step, occurrence, run, and trace repositories;
- definition validation;
- Scheduler checkpoint transactions.

The shared database layer should eventually own:

- the physical filename;
- admitted archive-root path resolution;
- long-lived open and close lifecycle;
- health and inventory registration.

The expected physical shape remains a new centrally named Presence database
under the admitted archive root. It must not be stored in Import, Graph
Working, or Overlay, and feature or presentation code must not open it
directly. Backup, health-audit, reset, and production-preservation policy must
be approved before production use.

Those are future implementation obligations, not changes authorized by this
proposal.

## Terminology

**Occurrence** means an immutable composition slot:

- a Schedule Trip occurrence places one reusable Trip definition at one
  position in a Schedule;
- a Trip Step occurrence places one reusable Step definition at one position
  in a Trip.

A loop may execute the same Schedule Trip occurrence repeatedly. Those
executions do not create or mutate definition rows. Their history appears only
in the trace.

## Relationship Map

```text
ScheduleDefinition
    -> ordered ScheduleTripOccurrences
        -> reusable TripDefinition
            -> ordered TripStepOccurrences
                -> reusable StepDefinition
                    -> exactly one concrete Step subtype definition

ScheduleRun
    -> current ScheduleTripOccurrence or complete

ExecutionTraceEvent
    -> historical observation only
```

There is no relationship from a Trip definition to a Trip behavior, and no
Schedule-specific route relationship.

## Revised Minimal Schema

### 1. `schedule_definitions`

Represents reusable Schedule definitions.

| Column | Type | Rules |
| --- | --- | --- |
| `id` | INTEGER | Primary key |
| `name` | TEXT | Not null, unique; non-empty by repository rule |

No runtime state belongs here.

### 2. `trip_definitions`

Represents reusable Trip identities.

| Column | Type | Rules |
| --- | --- | --- |
| `id` | INTEGER | Primary key |
| `name` | TEXT | Not null, unique; non-empty by repository rule |

There is deliberately no `behavior` column. A Trip's behavior is the
consequence of its ordered Steps, not an independently configured Trip
category.

### 3. `step_definitions`

Represents reusable Step identities and their closed concrete subtype.

| Column | Type | Rules |
| --- | --- | --- |
| `id` | INTEGER | Primary key |
| `name` | TEXT | Not null, unique; non-empty by repository rule |
| `type` | TEXT | Not null; closed check for the approved subtype set |

For the worked FDA experiment, the closed set is:

```text
tell
fixed_destination
fda_test
```

The discriminator supports deterministic subtype loading. Payload and routing
configuration do not belong in this base table.

### 4. `schedule_trip_occurrences`

Places reusable Trip definitions into a Schedule batting order.

| Column | Type | Rules |
| --- | --- | --- |
| `id` | INTEGER | Primary key; stable composition identity |
| `schedule_definition_id` | INTEGER | Not null; FK to `schedule_definitions.id` |
| `trip_definition_id` | INTEGER | Not null; FK to `trip_definitions.id` |
| `position` | INTEGER | Not null; check `position >= 0` |

Required uniqueness:

```text
UNIQUE(schedule_definition_id, position)
UNIQUE(schedule_definition_id, trip_definition_id)
UNIQUE(schedule_definition_id, id)
```

The second constraint guarantees that a canonical Trip definition resolves to
at most one occurrence in a Schedule. The third supports a composite
same-Schedule foreign key from `schedule_runs`.

Positions need not be contiguous. Default-next means the occurrence with the
smallest greater position.

If a workflow needs conceptually similar work twice in one Schedule, it must
use two distinct canonical Trip definitions. This makes canonical destination
resolution unambiguous without Schedule-specific route tables.

### 5. `trip_step_occurrences`

Places reusable Step definitions into an ordered Trip.

| Column | Type | Rules |
| --- | --- | --- |
| `id` | INTEGER | Primary key; stable composition identity |
| `trip_definition_id` | INTEGER | Not null; FK to `trip_definitions.id` |
| `step_definition_id` | INTEGER | Not null; FK to `step_definitions.id` |
| `position` | INTEGER | Not null; check `position >= 0` |

Required uniqueness:

```text
UNIQUE(trip_definition_id, position)
```

Execution begins at the smallest position and proceeds to the next greater
position. Completing the terminal Step completes the Trip.

The same Step definition may be reused in more than one Trip. No occurrence
or Schedule identity enters the reusable Step definition.

### 6. Concrete Step subtype tables

Concrete configuration remains specific to the concrete Step that understands
it. The runtime result type is universal; its persisted causes are not.

#### `tell_step_definitions`

| Column | Type | Rules |
| --- | --- | --- |
| `step_definition_id` | INTEGER | Primary key; FK to `step_definitions.id` |
| `text` | TEXT | Not null; non-empty by repository rule |

A Tell Step completes with `null`. If terminal, the Schedule uses default-next.

#### `fixed_destination_step_definitions`

| Column | Type | Rules |
| --- | --- | --- |
| `step_definition_id` | INTEGER | Primary key; FK to `step_definitions.id` |
| `destination_trip_definition_id` | INTEGER | Not null; FK to `trip_definitions.id` |

A Fixed Destination Step completes with its canonical destination. It does not
resolve the destination to a Schedule occurrence.

#### `fda_test_step_definitions`

| Column | Type | Rules |
| --- | --- | --- |
| `step_definition_id` | INTEGER | Primary key; FK to `step_definitions.id` |
| `present_destination_trip_definition_id` | INTEGER | Nullable; FK to `trip_definitions.id` |
| `absent_destination_trip_definition_id` | INTEGER | Nullable; FK to `trip_definitions.id` |

The FDA Step invokes the FDA testing authority and keeps its Boolean result
local. It selects one configured arm, translating that arm to:

```text
null                     -> default-next
non-null canonical ID    -> explicit TripDefinitionId
```

Both arms may be null. That means the Step still performs its concrete FDA
inspection but both outcomes request default-next. No routing invariant
requires an explicit arm.

The model deliberately does not create a universal `step_routes` table. A
fixed destination and two FDA outcome arms are different concrete Step
contracts. Combining them would introduce sparse columns or an outcome
taxonomy that no runtime boundary needs.

### 7. `schedule_runs`

Contains the complete durable execution authority for one Schedule run.

| Column | Type | Rules |
| --- | --- | --- |
| `id` | INTEGER | Primary key; run identity |
| `schedule_definition_id` | INTEGER | Not null; FK to `schedule_definitions.id` |
| `current_trip_occurrence_id` | INTEGER | Nullable |

Composite foreign key:

```text
(schedule_definition_id, current_trip_occurrence_id)
    -> schedule_trip_occurrences(schedule_definition_id, id)
```

No status column is required:

```text
current_trip_occurrence_id IS NOT NULL -> active
current_trip_occurrence_id IS NULL     -> complete
```

A run is created atomically with the Schedule's first occurrence. There is no
persisted current Step. On restart, the current Trip begins again at Step 1.

When the terminal Step completes, the Scheduler resolves the relayed routing
result and updates `current_trip_occurrence_id` in one checkpoint transaction.

### 8. `execution_trace_events`

Append-only observational history. Execution must never query this table to
decide what runs next or where a run resumes.

| Column | Type | Rules |
| --- | --- | --- |
| `id` | INTEGER | Primary key |
| `schedule_run_id` | INTEGER | Not null; FK to `schedule_runs.id` |
| `sequence` | INTEGER | Not null; monotonically increasing within the run |
| `event_type` | TEXT | Not null; closed event set below |
| `trip_occurrence_id` | INTEGER | Nullable; FK to `schedule_trip_occurrences.id` |
| `step_occurrence_id` | INTEGER | Nullable; FK to `trip_step_occurrences.id` |
| `routing_result_trip_definition_id` | INTEGER | Nullable; FK to `trip_definitions.id` |
| `selected_destination_trip_occurrence_id` | INTEGER | Nullable; FK to `schedule_trip_occurrences.id` |
| `occurred_at_utc_us` | INTEGER | Not null |

Initial closed event set:

```text
schedule_run_started
trip_started
step_started
step_completed
trip_completed
route_decision
schedule_run_completed
```

Required uniqueness:

```text
UNIQUE(schedule_run_id, sequence)
```

The route-decision event may observe both sides of the Scheduler boundary:

- `routing_result_trip_definition_id` is null for default-next or contains
  the explicit canonical result relayed by the Trip;
- `selected_destination_trip_occurrence_id` contains the Scheduler's resolved
  destination, or is null when the Schedule completed.

The previous `boolean_result` field and `test_result` event disappear. The FDA
Boolean is local to its Step and is not part of the Trip/Scheduler contract.
If a future diagnostic requirement justifies observing concrete FDA details,
that must be designed as concrete observational data rather than promoted into
universal execution authority.

Event-shape checks should permit routing columns only on `route_decision`.
Step events require a Step occurrence; Trip events require a Trip occurrence;
Schedule events require neither. Repository validation must ensure referenced
Step occurrences belong to the traced Trip definition and selected
destinations belong to the run's Schedule.

Append-only behavior should be enforced mechanically with SQLite triggers
that reject `UPDATE` and `DELETE`. Whole-file deletion under explicit reset or
development authority is a separate lifecycle operation.

### Foreign-key deletion policy

Use restrictive/no-action deletion for definitions, occurrences, runs, Step
subtypes, and trace relationships. Cascading deletion could erase history or
silently change an active run's meaning. Development fixture replacement may
delete rows explicitly in dependency order before any run exists.

## Universal Runtime Result, Concrete Stored Configuration

The universal abstraction is the value returned at the Trip boundary:

```text
TripDefinitionId?
```

It is not a universal database row.

### Default-next

A terminal Step with no explicit route completes with `null`. No route row is
stored. The Scheduler derives the next occurrence from Schedule position.

### Fixed canonical destination

The concrete Fixed Destination Step stores one canonical Trip definition ID
in `fixed_destination_step_definitions` and returns it when complete.

### Test-derived canonical destination

The concrete FDA Test Step stores its two possible canonical destinations in
`fda_test_step_definitions`. Either arm may be null to request default-next.
The Step evaluates the Boolean internally and returns only the selected
`TripDefinitionId?`.

This preserves one tiny Scheduler contract without pretending all Step
configuration has the same shape.

## Reusability And Schedule Closure

Canonical destination IDs deliberately make Step definitions independent of
Schedule occurrence identity. This allows a Fixed Destination or FDA Test Step
to be reused wherever its complete destination set is present.

That reusability creates one necessary validation rule:

> For every Schedule containing a Trip that uses a routing-capable Step, every
> non-null Trip definition ID that Step can return must also occur in that
> Schedule.

Conceptually, validation computes:

```text
ScheduleTripOccurrence
    -> TripStepOccurrences
        -> concrete Step destination set
            -> each non-null TripDefinitionId
                -> exactly one ScheduleTripOccurrence in the same Schedule
```

`UNIQUE(schedule_definition_id, trip_definition_id)` makes the resolution
unambiguous, but does not by itself prove destination presence. The foreign
keys in concrete subtype tables prove only that a canonical Trip definition
exists globally.

The repository must validate Schedule closure before exposing a Schedule as
executable. The Scheduler must also fail closed if resolution unexpectedly
finds zero destinations. Finding two is mechanically prevented by the unique
constraint.

SQLite triggers could attempt cross-Schedule closure enforcement, but would
make definition construction order-sensitive and duplicate aggregate
validation. A single repository validation of the complete immutable Schedule
definition is clearer.

If a reusable routing Step's destinations are inappropriate in another
Schedule, that Schedule must not use it. Create a distinct Step definition for
the different routing role rather than storing Schedule-specific route arms.

## Terminal-Step Integrity

Every Trip must have at least one Step. The terminal Step is the occurrence
with the greatest position.

Concrete Steps whose contract can produce a non-null routing result must be
terminal wherever composed. Otherwise their result would be discarded before
the Trip boundary. This is a repository/domain invariant because SQLite cannot
compare a Step subtype with maximum composition position using ordinary checks
and foreign keys.

Non-routing Steps remain free to occupy any position, including the terminal
position, where they naturally produce `null`.

## Scheduler Resolution

At a Trip boundary:

1. The Trip completes its terminal Step.
2. The Trip relays that Step's `TripDefinitionId?` unchanged.
3. For `null`, the Scheduler selects the smallest greater Schedule position.
4. For a canonical ID, the Scheduler selects the one occurrence whose
   `(schedule_definition_id, trip_definition_id)` matches the active Schedule
   and returned ID.
5. The Scheduler atomically writes the selected occurrence to
   `schedule_runs.current_trip_occurrence_id`.
6. If default-next finds no later occurrence, the Scheduler writes null and
   the Schedule is complete.

The selected destination may be the current occurrence or an earlier
occurrence. Loops require no special construct.

## Worked FDA Example

The rows below use the conceptual Trip numbers as canonical
`trip_definitions.id` values so the routing contract remains visible.

### Schedule definition

| `id` | `name` |
| ---: | --- |
| 1 | `fda_routing_experiment` |

### Trip definitions

| `id` | `name` |
| ---: | --- |
| 1 | `welcome` |
| 2 | `initial_fda_test` |
| 3 | `fda_present_explanation` |
| 4 | `continue_after_fda_present` |
| 5 | `fda_guidance` |
| 7 | `repeat_fda_test` |
| 8 | `continue_onboarding` |

There is no behavior column. Each row is the same kind of Trip definition.

### Schedule Trip occurrences

| occurrence `id` | Schedule | position | Trip definition |
| ---: | ---: | ---: | ---: |
| 1001 | 1 | 0 | 1 |
| 1002 | 1 | 1 | 2 |
| 1003 | 1 | 2 | 3 |
| 1004 | 1 | 3 | 4 |
| 1005 | 1 | 4 | 5 |
| 1007 | 1 | 5 | 7 |
| 1008 | 1 | 6 | 8 |

These rows satisfy both Schedule-position uniqueness and one occurrence per
canonical Trip definition.

### Step definitions

| `id` | `name` | `type` |
| ---: | --- | --- |
| 101 | `welcome_tell` | `tell` |
| 201 | `inspect_fda_initially` | `fda_test` |
| 301 | `fda_present_tell` | `tell` |
| 401 | `route_to_onboarding` | `fixed_destination` |
| 501 | `fda_guidance_tell` | `tell` |
| 701 | `inspect_fda_again` | `fda_test` |
| 801 | `continue_onboarding_tell` | `tell` |

### Trip Step occurrences

| occurrence `id` | Trip definition | position | Step definition |
| ---: | ---: | ---: | ---: |
| 1101 | 1 | 0 | 101 |
| 1201 | 2 | 0 | 201 |
| 1301 | 3 | 0 | 301 |
| 1401 | 4 | 0 | 401 |
| 1501 | 5 | 0 | 501 |
| 1701 | 7 | 0 | 701 |
| 1801 | 8 | 0 | 801 |

Each example Trip has one terminal Step only to keep the routing rows concise.
The schema supports any ordered multi-Step Trip.

### Tell subtype rows

| Step definition | `text` |
| ---: | --- |
| 101 | `Welcome.` |
| 301 | `Full Disk Access is already available.` |
| 501 | `Please grant Full Disk Access.` |
| 801 | `Onboarding continues.` |

### Fixed Destination subtype row

| Step definition | destination Trip definition |
| ---: | ---: |
| 401 | 8 |

### FDA Test subtype rows

| Step definition | FDA present destination | FDA absent destination |
| ---: | ---: | ---: |
| 201 | null | 5 |
| 701 | null | 2 |

### Resulting paths

```text
Trip 1
    -> terminal Tell returns null
    -> default Trip 2

Trip 2
    FDA present -> null -> default Trip 3
    FDA absent  -> TripDefinitionId(5)

Trip 3
    -> terminal Tell returns null
    -> default Trip 4

Trip 4
    -> terminal FixedDestination returns TripDefinitionId(8)

Trip 5
    -> terminal Tell returns null
    -> default Trip 7

Trip 7
    FDA present -> null -> default Trip 8
    FDA absent  -> TripDefinitionId(2)
```

The loop:

```text
2 -> 5 -> 7 -> 2
```

emerges from ordinary Step results and Schedule order. It requires no loop
row, Router Trip, Test Trip, graph edge, or occurrence-specific destination.

### Initial Schedule run row

| `id` | Schedule definition | current Trip occurrence |
| ---: | ---: | ---: |
| 9001 | 1 | 1001 |

This is the complete durable starting checkpoint. It contains no current Step
and no routing state.

### Representative route-decision trace rows

After the `Trip 2` FDA-present path and the explicit `Trip 4` route, the
observational rows may include:

| run | sequence | event | source occurrence | routing result Trip definition | selected occurrence |
| ---: | ---: | --- | ---: | ---: | ---: |
| 9001 | 12 | `route_decision` | 1002 | null | 1003 |
| 9001 | 24 | `route_decision` | 1004 | 8 | 1008 |

The first row records default-next; the second records an explicit canonical
result and its Schedule-local resolution. These rows are observations only and
are never consulted by the Scheduler.

## Restart And Checkpoint Semantics

The minimal checkpoint remains:

```text
schedule_run_id
schedule_definition_id
current_trip_occurrence_id
```

On restart:

1. Load the active Schedule run.
2. Load `current_trip_occurrence_id`.
3. Load that occurrence's Trip definition and ordered Steps.
4. Restart the Trip at Step 1.

Trace is not consulted.

At a Trip boundary, route resolution and the run checkpoint update form one
transaction. A crash before commit restarts the previous Trip. A crash after
commit starts the selected Trip.

This remains at-least-once Trip execution around crashes. External work within
a Trip must be safe to repeat, or the workflow must be split into smaller
Trips. Current-Step persistence is neither required nor justified by the new
routing contract.

## Execution Trace

The trace is implemented as observational and append-only storage. Its
authority does not extend beyond recording and read-only inspection.

The revised model changes only its vocabulary:

- remove `test_result` as a universal event;
- remove `boolean_result` as a universal field;
- record the terminal `TripDefinitionId?` on `route_decision`;
- record the Scheduler's selected occurrence separately;
- preserve Schedule, Trip, and Step lifecycle observations;
- permit repeated occurrences and loops without special rows.

The Scheduler never reconstructs routing from trace events. Run creation emits
`schedule_run_started`; Scheduler entry and Step execution emit their ordinary
lifecycle observations; and the repository commits `trip_completed`,
`route_decision`, the checkpoint update, and optional
`schedule_run_completed` in one transaction.

## SQLite-Enforced Invariants

SQLite can enforce:

- primary-key identity;
- valid closed Step subtype values;
- non-negative positions;
- one Trip occurrence per Schedule position;
- at most one occurrence of a canonical Trip definition per Schedule;
- one Step occurrence per Trip position;
- all definition, composition, subtype, run, and trace foreign keys;
- each configured canonical destination exists globally;
- an FDA destination arm is either null or a valid canonical Trip ID;
- an active run's current occurrence belongs to its Schedule;
- unique event sequence within a run;
- append-only trace rows through triggers.

## Repository/Domain-Enforced Invariants

Repository and domain validation must enforce:

- names and required text are non-empty after trimming;
- every Schedule contains at least one Trip occurrence;
- every Trip contains at least one Step occurrence;
- Schedule and Step occurrence lists are loaded in position order;
- each Step definition has exactly one subtype row matching its discriminator;
- no Step definition has rows in other subtype tables;
- routing-capable Step subtypes are terminal wherever composed;
- every possible non-null canonical destination from every Step used by a
  Schedule occurs exactly once in that Schedule;
- canonical route resolution fails closed when the destination is absent;
- definition composition is immutable once used by a run;
- a traced Step occurrence belongs to the traced Trip definition;
- a traced selected destination belongs to the run's Schedule;
- trace event fields match their event type;
- execution never reads trace rows;
- checkpoint updates follow the terminal Step result exactly.

SQLite cannot enforce parent-has-child, exactly-one-subtype-across-tables,
terminal-position subtype rules, or Schedule route closure with ordinary
foreign keys and row checks. Those are aggregate invariants and belong at the
repository validation boundary.

## Required Indexes

Primary and unique constraints provide ordered and identity lookups. Add only:

```text
schedule_trip_occurrences(trip_definition_id)
trip_step_occurrences(step_definition_id)
fixed_destination_step_definitions(destination_trip_definition_id)
fda_test_step_definitions(present_destination_trip_definition_id)
fda_test_step_definitions(absent_destination_trip_definition_id)
schedule_runs(schedule_definition_id)
```

`UNIQUE(schedule_run_id, sequence)` supports ordered trace reads. No analytics
indexes are justified.

## Schema Versioning

The experimental physical Presence database began at schema version 1 and is
currently at schema version 4.

- `onCreate` creates the complete current schema, indexes, foreign-key
  enforcement, and append-only trace triggers;
- `beforeOpen` enables `PRAGMA foreign_keys = ON`;
- the v3-to-v4 migration adds `execution_trace_events` and both append-only
  triggers without changing definitions or active runs;
- future schema versions use explicit forward migrations;
- destructive fallback and silent recreation are not acceptable for durable
  runs or trace history.

Before a production physical database is opened, implementation must register
its file identity, provider lifecycle, health inventory, backup, and reset
behavior with the central database/archive systems.

## Direct Answers To The Design Questions

1. **Smallest normalized schema:** seven structural tables
   (`schedule_definitions`, `trip_definitions`,
   `step_definitions`, `schedule_trip_occurrences`,
   `trip_step_occurrences`, `schedule_runs`, `execution_trace_events`) plus one
   normalized table for each approved concrete Step subtype. The FDA example
   therefore uses ten tables in total: seven structural and three subtype
   tables.
2. **Remove `trip_definitions.behavior`:** yes, entirely.
3. **Remove `test_trip_routes`:** yes, entirely.
4. **Remove `router_trip_routes`:** yes, entirely.
5. **Concrete Step configuration:** in normalized tables owned by each closed
   Step subtype.
6. **Terminal representations:** no route data for default-next; one canonical
   destination on Fixed Destination; nullable canonical outcome arms on FDA
   Test.
7. **Universal route storage:** no. The universal result is ephemeral at the
   Trip boundary; persisted causes remain subtype-specific.
8. **Step reusability:** store canonical Trip definition IDs only, never
   Schedule occurrence IDs, and validate destination closure in each consuming
   Schedule.
9. **Uniqueness sufficiency:** it guarantees at most one destination and thus
   unambiguous resolution; repository closure validation must additionally
   guarantee the destination exists.
10. **Destination validation:** inspect every possible non-null destination of
    every Step reachable through each Schedule's Trip composition before the
    Schedule becomes executable.
11. **Checkpoint model:** unchanged; only current Trip occurrence is durable.
12. **Trace:** remove universal Boolean/test vocabulary and observe the
    terminal canonical result plus selected occurrence.
13. **Enforcement boundary:** row identity, keys, position uniqueness, global
    destination existence, and current-run membership fit SQLite; aggregate
    completeness, subtype consistency, terminality, Schedule closure, and
    immutable executable definitions fit repository/domain validation.

## Architectural Test

Yes: Trip can remain one boring class.

All meaningful variation in this experiment is expressed by the Steps it
sequences. Every Trip presents the same boundary to the Scheduler:

```text
terminal Step completes
    -> Trip relays TripDefinitionId?
    -> Scheduler resolves default-next or canonical destination
```

No specialized Trip class, behavior flag, routing table, or loop construct is
needed.

## Recommended Revised Minimal Schema

Approve seven structural tables:

1. `schedule_definitions`
2. `trip_definitions`
3. `step_definitions`
4. `schedule_trip_occurrences`
5. `trip_step_occurrences`
6. `schedule_runs`
7. `execution_trace_events`

For the worked experiment, approve three concrete Step subtype tables:

1. `tell_step_definitions`
2. `fixed_destination_step_definitions`
3. `fda_test_step_definitions`

Do not add a Trip behavior discriminator, a universal route table, or
Schedule-specific route configuration.

## What Disappeared From The Previous Proposal

- the `behavior` column on `trip_definitions`;
- Ordinary/Test/Router Trip categories;
- `test_trip_routes`;
- `router_trip_routes`;
- true/false routing interpretation by Trip or Scheduler;
- Schedule occurrence IDs in routing configuration;
- the unresolved question of who gives a Test Trip its Boolean;
- universal Boolean fields and events in execution trace;
- the need for any special loop representation.

The Boolean authority is no longer ambiguous: the concrete FDA Test Step owns
its test invocation and local interpretation, then emits the same
`TripDefinitionId?` boundary result as any other terminal Step.

## Remaining Genuine Ambiguities

1. May more than one active run of the same Schedule exist? If not, a partial
   unique index can make single-active-run authority mechanical.
2. Are published definitions permanently immutable, or will explicit
   definition revisions eventually be required?
3. What exact operational contract invokes the FDA testing authority? The
   storage shape does not need a generic agent registry, but execution still
   needs one concrete boundary before implementation.

None of these ambiguities requires specialized Trip behavior or
Schedule-specific route tables.

## Things Deliberately Not Modeled

- specialized Trip classes or behavior discriminators;
- arbitrary Step-to-Step routing;
- a universal Step routing table;
- generic graph edges;
- Schedule occurrence identities in reusable Step definitions;
- current-Step persistence;
- nested Journeys;
- generalized context or result bags;
- plugin or handler registries;
- generalized outcome taxonomies;
- loop objects;
- Schedule priorities, calendars, clocks, or speculative scheduling;
- parallel Trip or Step execution;
- cancellation, failure, or retry taxonomies;
- definition revisions;
- per-Trip runtime rows;
- analytics projections;
- compatibility with the obsolete Journey experiment;
- production FDA behavior.

Nothing else is required to keep Trip one boring class while specialized Steps
express the meaningful variation.
