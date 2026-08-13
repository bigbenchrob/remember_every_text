---
tier: project
scope: presence
owner: agent-per-project
last_reviewed: 2026-08-12
source_of_truth: doc
links:
  - 15-PRESENCE-DATABASE-IN-PLAIN-ENGLISH.md
  - ../23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md
tests: []
---

# Presence Database Schema Walkthrough

This is a companion to
[`15-PRESENCE-DATABASE-IN-PLAIN-ENGLISH.md`](15-PRESENCE-DATABASE-IN-PLAIN-ENGLISH.md).

The plain-English guide explains why the schema uses definitions, occurrences,
runs, and trace events. This document approaches the same database from the
other direction: it shows how the tables fit together and how the repository
turns their rows back into a runnable Presence Schedule.

Use this document when the question is:

> Which rows combine to make a Schedule, Trip, or Step, and what does each ID
> actually identify?

The code remains the source of truth. This is a reading aid for the current
schema.

---

## The Whole Schema In Four Layers

The easiest way to understand `presence.db` is to read it in four layers.

```text
1. DEFINITIONS
   What reusable things exist?

   schedule_definitions
   trip_definitions
   step_definitions
   tell_step_definitions
   fixed_destination_step_definitions
   fda_test_step_definitions (frozen migration evidence)
   contacts_source_readiness_step_definitions (frozen migration evidence)
   open_fda_settings_step_definitions
   test_agent_definitions
   test_step_definitions

2. COMPOSITION
   Where are those reusable things placed, and in what order?

   schedule_trip_occurrences
   trip_step_occurrences

3. EXECUTION CHECKPOINT
   Where should one actual run resume?

   schedule_runs

4. EXECUTION HISTORY
   What happened during that run?

   execution_trace_events
```

These layers answer different questions. None is a duplicate of another.

```text
definition  -> what is it?
occurrence  -> where is it used?
run         -> where is execution now?
trace       -> what happened previously?
```

---

## Relationship Map

The core relationships are:

```text
schedule_definitions
    |
    | one Schedule has ordered Trip placements
    v
schedule_trip_occurrences ----------------------+
    |                                            |
    | each placement selects one                 | current placement
    v                                            | for a run
trip_definitions                                 |
    |                                            |
    | one Trip has ordered Step placements       |
    v                                            |
trip_step_occurrences                            |
    |                                            |
    | each placement selects one                 |
    v                                            |
step_definitions                                 |
    |                                            |
    | type selects exactly one subtype row       |
    +-> tell_step_definitions                    |
    +-> fixed_destination_step_definitions       |
    +-> fda_test_step_definitions (frozen)       |
    +-> contacts_source_readiness_step_definitions (frozen)
    +-> open_fda_settings_step_definitions       |
    +-> test_step_definitions                    |
            |                                    |
            +-> test_agent_definitions           |
                                                 |
schedule_runs -----------------------------------+
    |
    | one run has an ordered, append-only history
    v
execution_trace_events
```

Two vertical chains are worth memorizing:

```text
Schedule -> Schedule Trip occurrence -> Trip
Trip     -> Trip Step occurrence     -> Step -> Step subtype
```

The occurrence tables are the ordered glue between reusable definitions.

---

## What One Row Means

| Table | One row means |
| --- | --- |
| `schedule_definitions` | One reusable Schedule identity and name |
| `trip_definitions` | One reusable Trip identity and name |
| `step_definitions` | One reusable Step identity, name, and concrete type |
| `tell_step_definitions` | The Tell-specific data for one Step definition |
| `fixed_destination_step_definitions` | The fixed destination for one routing Step definition |
| `fda_test_step_definitions` | Frozen pre-generic FDA routing evidence retained for migration continuity |
| `contacts_source_readiness_step_definitions` | Frozen pre-generic Contacts routing evidence retained for migration continuity |
| `open_fda_settings_step_definitions` | The payload-free subtype marker for one Settings-opening Step definition |
| `test_agent_definitions` | One opaque declared Boolean specialist identity; not proof of a runtime implementation |
| `test_step_definitions` | One generic Test Step's Agent identity and nullable true/false destinations |
| `schedule_trip_occurrences` | One Trip placed at one position in one Schedule |
| `trip_step_occurrences` | One Step placed at one position in one Trip |
| `schedule_runs` | The durable checkpoint for one actual Schedule execution |
| `execution_trace_events` | One immutable observation from one Schedule execution |

This table is the quickest way to recover orientation. If a row's meaning
does not match one of these sentences, it is probably being interpreted at the
wrong layer.

---

## The Four Kinds Of Identity

Several columns end in `id`, but they do not all identify the same kind of
thing.

### Definition identity

```text
schedule_definitions.id
trip_definitions.id
step_definitions.id
```

These identify reusable configured things.

`trip_definition_id = 5` means "the canonical Trip definition numbered 5."
It does not say where Trip 5 appears in a Schedule or whether it is currently
running.

### Occurrence identity

```text
schedule_trip_occurrences.id
trip_step_occurrences.id
```

These identify placements.

`schedule_trip_occurrences.id = 3005` means "this particular placement of a
Trip in a Schedule." Its row also says which Schedule, which Trip definition,
and which position are involved.

### Run identity

```text
schedule_runs.id
```

This identifies one actual execution of a Schedule definition.

The definition may be reusable. The run is historical and particular.

### Trace-event identity

```text
execution_trace_events.id
```

This identifies one immutable observation made during a run. The event also
has a per-run `sequence`, which establishes its order within that run.

### The practical translation

```text
TripDefinitionId
    Which Trip is meant?

ScheduleTripOccurrenceId
    Which placement of that Trip in this Schedule is meant?

ScheduleRunId
    Which execution of the Schedule is meant?

ExecutionTraceEventId
    Which recorded event in that execution is meant?
```

---

## How A Complete Step Is Stored

There is no single table containing every field for every Step type.

A Step is assembled from:

```text
one step_definitions row
        +
one matching subtype row
```

For a Tell Step:

```text
step_definitions
    id   = 9421
    name = welcome_message
    type = tell

tell_step_definitions
    step_definition_id = 9421
    text = "Welcome to MessageLens."
```

The shared primary key is the join. Together, these rows describe one
configured `TellStep`.

The same pattern applies to routing Steps:

```text
step_definitions.type = fixed_destination
    -> fixed_destination_step_definitions

step_definitions.type = open_fda_settings
    -> open_fda_settings_step_definitions

step_definitions.type = test
    -> test_step_definitions
        -> test_agent_definitions
```

The persisted rows declare the required opaque identity and Boolean routes.
They do not contain the specialist implementation. Application composition
supplies concrete `TestAgent` objects, builds one immutable resolver, and
injects it into the repository. Presence joins declaration to implementation
by `TestAgentId` without learning what fact the Agent establishes.

The subtype row has no independent ID because it cannot meaningfully exist
apart from its base Step definition. Its `step_definition_id` is therefore
both:

- its primary key; and
- a foreign key to `step_definitions.id`.

### What the type discriminator does

The `type` column is an instruction to the repository:

```text
tell              -> load Tell subtype data
fixed_destination -> load Fixed Destination subtype data
open_fda_settings -> load the payload-free Settings-opening subtype marker
test              -> load generic Test subtype data and its opaque Agent ID
```

It is not the Step's behavior by itself. It tells the repository which data
must exist so the repository can construct the correct domain object.

Schema version 8 activates generic Test reconstruction. The repository reads
the opaque Agent ID from `test_step_definitions`, resolves a process-local
`TestAgent`, and constructs `TestStep`.

Active subtype integrity follows the base discriminator. For `type = test`,
the generic row is active truth. Retained FDA and Contacts rows are frozen
migration evidence and do not count as conflicting active subtypes.

The database declaration and runtime binding answer different questions:

```text
test_agent_definitions
    Which opaque Agent identities does this persisted grammar declare?

TestAgentResolver
    Which actual Agent implementations can this process supply?
```

All Agents used by a requested Schedule must resolve before its run can begin
or advance. Resolution does not scan unrelated Schedules.

---

## How A Schedule Is Reconstructed

The repository does not issue one magical query that returns a complete object
graph. It follows the relationships deliberately.

### 1. Load the Schedule definition

```text
schedule_definitions
    WHERE id = requested Schedule ID
```

This supplies the Schedule's stable identity and name.

### 2. Load its ordered Trip placements

```text
schedule_trip_occurrences
    WHERE schedule_definition_id = requested Schedule ID
    ORDER BY position
```

Each occurrence supplies:

- its own placement identity;
- its position;
- the Trip definition to load.

### 3. Load each Trip definition

```text
trip_definitions
    WHERE id = occurrence.trip_definition_id
```

This supplies the Trip's stable identity and name.

### 4. Load the Trip's ordered Step placements

```text
trip_step_occurrences
    WHERE trip_definition_id = requested Trip ID
    ORDER BY position
```

Each occurrence identifies the Step definition at that position.

### 5. Load each base Step row

```text
step_definitions
    WHERE id = occurrence.step_definition_id
```

The repository reads `type` and then loads the matching subtype row.

### 6. Construct the concrete Step

For example:

```text
base Step row
    type = tell

matching Tell subtype row
    text = "Welcome to MessageLens."

repository constructs
    TellStep(...)
```

### 7. Assemble outward

```text
concrete Steps
    -> TripDefinition
        -> ScheduleTripDefinition placement
            -> ScheduleDefinition
```

The result is an immutable domain description assembled from normalized
relational rows.

---

## Why Definitions And Placements Are Separate

Suppose the configured FDA test is Step definition 9421.

The definition answers:

> What does this Step do?

The occurrence answers:

> Where does this Step appear in this Trip?

Those are independently useful facts.

```text
StepDefinition 9421
    = the reusable configured FDA test

TripStepOccurrence 8201
    = Step 9421 placed at position 0 in Trip 2
```

A Step definition can be used by more than one Trip. It can also appear at
different positions without copying its subtype data.

The current Schedule-level rule is narrower: one Trip definition may appear at
most once in a particular Schedule. That keeps a routing result such as
`TripDefinitionId(5)` unambiguous when the Scheduler resolves it to a Schedule
Trip occurrence.

The occurrence still deserves its own identity because runtime state points to
the placement in the active Schedule, not merely to the reusable Trip.

---

## How Routing Uses The Schema

A terminal Step may return:

```text
an explicit TripDefinitionId
or
null
```

An explicit destination means:

```text
Step returns TripDefinitionId(5)
    -> Scheduler searches the active Schedule's occurrences
    -> finds the unique occurrence whose trip_definition_id is 5
    -> checkpoints that occurrence as current
```

A null destination means there is no explicit route. The repository selects
the next Schedule Trip occurrence by position.

```text
current occurrence position = 2
    -> choose the lowest position greater than 2
```

If there is no later occurrence, the run is complete and
`current_trip_occurrence_id` becomes null.

For `test_step_definitions`, either branch destination may itself be null. That
means that branch uses ordinary default-next behavior; it does not mean that
the Agent result is unknown.

---

## What `schedule_runs` Does And Does Not Remember

A `schedule_runs` row stores:

```text
id
schedule_definition_id
current_trip_occurrence_id
```

This is deliberately a small checkpoint.

```text
current_trip_occurrence_id = 3005
    Resume from Schedule Trip occurrence 3005.

current_trip_occurrence_id = null
    This run is complete.
```

The database enforces that a non-null current occurrence belongs to the same
Schedule as the run. A run cannot point into another Schedule's composition.

The run currently does **not** persist:

- a current Step occurrence;
- a current Step index;
- answers or form values;
- rendered UI state;
- the latest trace-event ID.

Therefore restart semantics are currently Trip-granular:

> Reload the current Trip definition and begin that Trip again at its first
> Step.

This is not missing data accidentally omitted from the schema. It is the
current checkpoint contract.

---

## What `execution_trace_events` Does And Does Not Do

The trace is an append-only diary for one Schedule run.

Events include:

```text
schedule_run_started
trip_started
step_started
step_completed
trip_completed
route_decision
schedule_run_completed
```

Every event belongs to one `schedule_run_id`. Its `sequence` is unique within
that run. Update and delete triggers make trace rows append-only.

The optional identity columns become meaningful according to event type:

| Event kind | Trip occurrence | Step occurrence | Routing fields |
| --- | --- | --- | --- |
| Schedule start/completion | absent | absent | absent |
| Trip start/completion | present | absent | absent |
| Step start/completion | present | present | absent |
| Route decision | present | absent | may be present |

A route decision can record both:

```text
routing_result_trip_definition_id
    What canonical destination did the terminal Step request?

selected_destination_trip_occurrence_id
    Which placement in this Schedule did the Scheduler select?
```

That distinction makes the routing decision inspectable without making the
trace authoritative.

Restart does not replay the trace to discover current state. It reads
`schedule_runs.current_trip_occurrence_id`.

```text
schedule_runs           = checkpoint authority
execution_trace_events  = historical evidence
```

---

## Integrity: Database Rules Versus Repository Rules

Some truths are enforced directly by SQLite. Others require the repository to
inspect several tables together.

### SQLite enforces

- definition names are unique within each definition table;
- positions are non-negative;
- one Schedule cannot have two Trip occurrences at the same position;
- one Trip definition may appear at most once in one Schedule;
- one Trip cannot have two Step occurrences at the same position;
- subtype rows reference real Step definitions;
- generic Test Steps reference declared Test Agent identities;
- destination IDs reference real Trip definitions;
- a run's current Trip occurrence belongs to that run's Schedule;
- trace sequence numbers are unique within one run;
- trace identity fields are structurally compatible with event type;
- trace rows cannot be updated or deleted.

### The repository additionally validates

- a loaded Schedule has at least one Trip;
- a loaded Trip has at least one Step;
- a Step type has its required subtype row;
- a Step does not also have a conflicting subtype row;
- a routed Trip definition exists in the active Schedule;
- a recorded Step occurrence belongs to the current Trip at the expected
  position;
- checkpoint updates still refer to the expected current Trip occurrence;
- repeated definition identities do not carry conflicting content.

The subtype rule is the clearest example of why both layers matter. Individual
foreign keys can prove that subtype rows point to real Steps. The repository
must still prove the cross-table statement:

> This `tell` Step has one Tell subtype row and no other active subtype row.

Frozen legacy rows are inactive evidence, selected out mechanically by the
base type.

Generated Drift table and companion APIs for the frozen legacy subtype tables
remain present because those tables remain part of the physical schema. The
active repository neither reads nor writes them. Mechanically removing their
generated write surface would require a schema-level or database-access
change, which is outside the current consolidation.

---

## A Small Worked Example

Suppose a Schedule contains a welcome Trip, an FDA-check Trip, ordinary
continuation, and an FDA-remediation Trip.

### Definitions

```text
schedule_definitions
    1  onboarding

trip_definitions
    10 welcome
    20 check_fda
    30 continue_setup
    40 explain_fda

step_definitions
    100 welcome_message  tell
    200 test_source      test
    300 continue_message tell
    400 explain_fda      tell
```

### Step subtype data

```text
tell_step_definitions
    step_definition_id = 100
    text = "Welcome to MessageLens."

    step_definition_id = 300
    text = "Let's continue."

    step_definition_id = 400
    text = "MessageLens needs Full Disk Access."

test_agent_definitions
    id = onboarding.messages-source-readable

test_step_definitions
    step_definition_id = 200
    test_agent_id = onboarding.messages-source-readable
    true_destination_trip_definition_id = null
    false_destination_trip_definition_id = 40
```

### Schedule composition

```text
schedule_trip_occurrences
    id 3001  Schedule 1  Trip 10  position 0
    id 3002  Schedule 1  Trip 20  position 1
    id 3003  Schedule 1  Trip 30  position 2
    id 3004  Schedule 1  Trip 40  position 3
```

### Trip composition

```text
trip_step_occurrences
    id 8001  Trip 10  Step 100  position 0
    id 8002  Trip 20  Step 200  position 0
    id 8003  Trip 30  Step 300  position 0
    id 8004  Trip 40  Step 400  position 0
```

### One execution

```text
schedule_runs
    id = 5001
    schedule_definition_id = 1
    current_trip_occurrence_id = 3002
```

This means:

> Run 5001 is executing the Onboarding Schedule and should resume at the
> placement of the FDA-check Trip identified by occurrence 3002.

If the FDA Step reports presence, it returns null and ordinary default-next
routing selects occurrence 3003. If it reports absence, it returns Trip
definition 40. The Scheduler resolves that canonical definition to occurrence
3004 in Schedule 1 and writes 3004 as the new checkpoint.

The trace records the transition, but the `schedule_runs` row is what makes the
new current state durable.

---

## Common Questions

### Where is the text shown by a Tell Step?

In `tell_step_definitions.text`, joined to its base `step_definitions` row by
the shared Step definition ID.

### Where is the order of Steps stored?

In `trip_step_occurrences.position`, not in `step_definitions`.

### Where is the order of Trips stored?

In `schedule_trip_occurrences.position`, not in `trip_definitions`.

### Where is the current Step stored?

It is not currently persisted. The durable checkpoint is the current Schedule
Trip occurrence.

### Why does a run point to a Trip occurrence rather than a Trip definition?

Because execution is at a particular placement in one particular Schedule.
The occurrence identifies that placement and carries its Schedule membership.

### Why does routing return a Trip definition rather than an occurrence?

Steps express a canonical workflow destination. The Scheduler owns the
Schedule-specific resolution from that destination definition to the unique
occurrence in the active Schedule.

### Could the trace reconstruct current state?

It might describe what happened, but it is deliberately not the checkpoint
authority. Current state comes from `schedule_runs`.

### Why is everything in one database?

Definitions, composition, runtime checkpoints, and trace are related Presence
truths. Keeping them together allows foreign keys and transactions to protect
their relationships.

---

## Reading Checklist

When inspecting an unfamiliar row, ask these questions in order:

1. **Is this a definition?** What reusable thing does it describe?
2. **Is this an occurrence?** Where is that definition placed?
3. **Is this a run?** Which execution does it checkpoint?
4. **Is this a trace event?** What historical observation does it record?
5. **Which ID namespace is this?** Definition, occurrence, run, or event?
6. **Is this truth enforced by SQLite or reconstructed by the repository?**

That sequence usually reveals the role of a table without requiring the whole
schema to be held in memory at once.
