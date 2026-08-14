---
tier: project
scope: presence
owner: agent-per-project
last_reviewed: 2026-08-13
source_of_truth: doc
links:
  - ../23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md
  - ../23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/17-ONBOARDING-MESSAGES-HISTORY-CHOICE-WORKFLOW-IMPLEMENTATION.md
tests: []
---

# Presence Database In Plain English

This document is a translation guide for the current `presence.db` schema.

Its purpose is practical:

> Six months from now, if you look at `presence_database.dart` and wonder
> “Where are the actual Steps?” or “Why does this table use the Step definition
> ID as its primary key?”, start here.

The key idea is that Presence separates:

```text
definitions     = what Schedules, Trips, and Steps are
occurrences     = where those reusable definitions are placed
schedule runs   = where one execution currently is
execution trace = what actually happened during that execution
```

---

## 1. The Three Basic Definition Tables

Presence starts with three simple definition tables:

```text
schedule_definitions
trip_definitions
step_definitions
```

Conceptually:

```text
ScheduleDefinition
    id
    name

TripDefinition
    id
    name

StepDefinition
    id
    name
    stepType
```

A Schedule and a Trip need only a stable identity and a human-readable name.

A Step additionally needs a `stepType` discriminator because Steps are
polymorphic: different kinds of Steps need different data and different
runtime behavior.

The currently implemented values are conceptually:

```text
tellStepType
fixedDestinationStepType
testStepType
choiceStepType
openFdaSettingsStepType
```

Older databases may still contain the retired `fda_test` and
`contacts_source_readiness` subtype rows as migration evidence. They are no
longer active runtime Step types.

The important point is:

> `step_definitions` does **not** contain one row per Step class.

It contains one row per actual reusable configured Step definition.

For example:

```text
StepDefinitions

id    name                    type
----  ----------------------  ----------------
9421  welcome_message         tellStepType
9422  initial_source_test     testStepType
9423  route_to_onboarding     fixedDestinationStepType
```

`stepType` merely tells the loader which subtype-specific table contains the
rest of that Step’s definition.

---

## 2. Where Are The Actual Step Parameters Stored?

A complete Step definition is composed from:

1. one base row in `step_definitions`; and
2. one matching subtype row.

This is a common relational pattern often called class-table inheritance
or table-per-subclass.

For example:

```text
StepDefinitions
id = 9421
name = welcome_message
type = tellStepType
```

plus:

```text
TellStepDefinitions
stepDefinitionId = 9421
text = "Welcome to MessageLens."
```

Together those two rows mean:

> Step definition 9421 is the configured Tell Step named `welcome_message`,
> whose text is “Welcome to MessageLens.”

The subtype tables currently look conceptually like:

```text
tell_step_definitions
    stepDefinitionId
    text

fixed_destination_step_definitions
    stepDefinitionId
    destinationTripDefinitionId

test_step_definitions
    stepDefinitionId
    testAgentId
    trueDestinationTripDefinitionId
    falseDestinationTripDefinitionId

open_fda_settings_step_definitions
    stepDefinitionId
```

`OpenFdaSettingsStep` needs no configured payload. Its subtype row exists to
prove that the base Step definition has exactly that concrete subtype; the
runtime Settings-opening authority is supplied when the repository loads it.

The subtype table’s `stepDefinitionId` is both:

```text
primary key
and
foreign key -> step_definitions.id
```

That is deliberate.

There is exactly one subtype-extension row for a given Step definition, so an
independent subtype-row ID would identify nothing useful.

For example:

```text
StepDefinition 9421
        |
        +-- TellStepDefinition 9421
              text = "Welcome to MessageLens."
```

The actual text is stored in `tell_step_definitions`.

It is not stored later in some separate Step-instance table.

---

## 3. The Generic Boolean Test Grammar

Schema version 7 introduced the persisted, domain-neutral grammar for declaring
a Boolean specialist and describing a Step that routes from its result. Schema
version 8 made that grammar executable by activating the generic `test` Step
discriminator and reconstructing every active test through its declared Agent.

In ordinary language:

```text
Test Agent definition
    = an opaque declared specialist identity

Test Step definition
    = a Step that names one Test Agent and two Boolean routing arms
```

The relational names are:

```text
test_agent_definitions
    id

test_step_definitions
    stepDefinitionId
    testAgentId
    trueDestinationTripDefinitionId
    falseDestinationTripDefinitionId
```

The Agent ID is stored exactly as supplied. Presence does not parse the owner
or meaning from it. The two destinations are nullable because a null arm keeps
the established default-next routing meaning.

A row in `test_agent_definitions` proves only that the identity is declared in
the persisted workflow grammar. It does **not** prove that the running process
has an implementation capable of evaluating it. Runtime availability belongs
to `TestAgentResolver`, not SQLite.

### The database/runtime join

This is the shortest current mental model:

```text
presence.db stores:
    Test Agent identities
    Test Steps that reference them

runtime composition supplies:
    actual TestAgent objects

Presence joins the two by TestAgentId
without knowing what the Agent does
```

Onboarding currently contributes the concrete Agents for its readiness tests.
The development application composition collects those bindings and builds an
immutable resolver. Presence receives the finished resolver; it does not
discover clients, inspect provider containers, or infer Agent meaning from the
stored ID.

### The schema 8 activation

Version 7 prepared generic Test rows for the two proven readiness definitions.
Version 8 activates them by changing the corresponding base discriminators to
`test`.

```text
base type = test
    generic Test subtype row is active
    retained specialized row is frozen migration evidence
```

The base `step_definitions.type` selects active subtype truth. A row retained
in a different subtype table does not become a second active subtype merely
because it still exists.

When the repository reconstructs a Test Step, it reads the opaque Agent ID and
asks the injected `TestAgentResolver` for the process-local implementation.
Every Agent required by the requested Schedule must resolve before that
Schedule can create or advance a run. Unrelated Schedules are not inspected.

Generated Drift table and companion APIs for the frozen legacy tables remain
available because those tables remain in the physical schema. Current
application code does not use those APIs to reconstruct or write Boolean
tests. Removing that generated surface would require a schema or
database-access redesign, not a consolidation cleanup.

---

## 4. The Generic Choice Grammar

Schema version 9 adds durable definitions for finite human choices. It stores
what may be selected; it does not store a current or previous selection.

```text
choice_step_definitions
    stepDefinitionId

choice_step_options
    stepDefinitionId
    value
    position
    label
    destinationTripDefinitionId
```

The first table is a subtype marker. The second stores the ordered options.
`value` is opaque execution identity, `label` is display copy, `position` is
durable ordering, and the destination is the configured next Trip. Presence
does not infer workflow meaning from either the value or label.

The database guarantees unique values and positions within one Choice Step.
The repository orders options by position, requires the marker, constructs the
generic `ChoiceStep`, and rejects a destination outside the containing
Schedule. The domain object rejects definitions with fewer than two options.

Choice execution now has one deliberately narrow runtime seam. Presence issues
a function bound privately to the current Choice activation; its caller
supplies only `ChoiceValue`. Presence validates that the function is still
current, resolves the value through the reconstructed `ChoiceStep`, and sends
the resulting Trip identity through the ordinary Trip checkpoint path.

No selection is added to `schedule_runs` or `execution_trace_events`. Before
acceptance, restart returns to the Choice Trip at Step 1. After the ordinary
destination checkpoint succeeds, restart begins at the selected destination
Trip.

Generic Presence presentation now receives only each option's ordered label
and opaque value plus a context-bound selection function. It does not receive
the destination. The active required-sources Onboarding Schedule uses this
grammar for its sparse Messages-history choice:

```text
recheck       -> evaluate the history Test Agent again
import_anyway -> continue to the existing confirmation
```

Onboarding authors those rods in the definition. It does not translate either
value at runtime.

---

## 5. Definition Versus Occurrence

Presence then has two ordered composition tables:

```text
schedule_trip_occurrences
trip_step_occurrences
```

These can be thought of as join tables with position and their own identity.

### `schedule_trip_occurrences`

A row means:

> This Trip definition is used in this Schedule at this batting-order position.

Conceptually:

```text
id
scheduleDefinitionId
tripDefinitionId
position
```

Example:

```text
occurrence 3002
schedule = onboarding
trip = initial_fda_check
position = 2
```

### `trip_step_occurrences`

A row means:

> This Step definition is used in this Trip at this Step position.

Conceptually:

```text
id
tripDefinitionId
stepDefinitionId
position
```

Example:

```text
occurrence 8201
trip = initial_fda_check
stepDefinition = 9421
position = 0
```

The distinction is:

```text
definition = what the reusable thing is
occurrence = where that reusable thing is being used
```

A TripStepOccurrence does not point merely to a Step type.

It points to a specific configured StepDefinition.

The loader can therefore follow:

```text
TripStepOccurrence
    |
    +-> StepDefinition 9421
            name = welcome_message
            type = tellStepType
                    |
                    +-> TellStepDefinition 9421
                            text = "Welcome to MessageLens."
```

That is the complete Step at that position in the Trip.

---

## 6. Why Occurrences Have Their Own IDs

The occurrence itself has meaning because runtime code needs to identify a
specific placement in the execution structure.

For example:

```text
TripDefinition
    = "initial_fda_check"
```

answers:

> What Trip is this?

While:

```text
ScheduleTripOccurrence 3002
```

answers:

> Where is this Trip placed in this Schedule?

The occurrence also carries `position`, which determines default execution
order.

So for a Schedule:

```text
position 0 -> Trip 1
position 1 -> Trip 2
position 2 -> Trip 3
```

default-next means:

> select the occurrence with the next greater position.

The same rule applies to Steps inside a Trip.

### Extending a canonical definition without resetting runs

The active Onboarding definition can now be extended additively inside the
same schema. The repository preserves every existing occurrence identity and
its associated Trip identity, then transactionally adds new definitions and
occurrences, updates ordinal positions, and applies approved generic Test-route
changes.

This matters because `schedule_runs.current_trip_occurrence_id` points to the
occurrence identity, not its position. Moving confirmation occurrence `6107`
from position 6 to position 8 therefore leaves a run already waiting there at
the same semantic checkpoint.

The extension rejects removal or Trip remapping of an existing occurrence. It
does not delete runs or traces. This is definition evolution, not a schema
migration and not a run reset.

---

## 7. Why A Trip Definition May Appear Only Once Per Schedule

The current model permits a canonical Trip definition to appear at most once
within one Schedule.

That rule exists because terminal Steps return canonical TripDefinitionId
values, not Schedule-specific occurrence IDs.

Conceptually:

```text
terminal Step
    -> TripDefinitionId(42)

Trip
    -> relays TripDefinitionId(42)

Scheduler
    -> "Which occurrence of Trip 42 exists in my active Schedule?"
    -> resolves the unique ScheduleTripOccurrence
```

If Trip 42 appeared twice in the same Schedule, that lookup would be ambiguous.

In practice this is less restrictive than it first appears.

Two Trips that may contain the same reusable FDA-test Step can still be
different semantic Trips:

```text
Trip 2
    initial FDA check
    Tell + FDA Test

Trip 7
    verify FDA assignment succeeded
    different Tell + same reusable FDA Test logic
```

The Step is reusable.

The two Trips play different roles and therefore deserve distinct Trip
definitions.

Likewise, a generic operation such as “Press Next” is more naturally modeled
as a reusable Step included in different Trips than as one reusable
single-Step Trip repeated throughout a Schedule.

So a useful current modeling assumption is:

> Trips are semantic workflow chunks and are normally unique within one
> Schedule. Steps are the more reusable building blocks inside them.

This assumption should be revisited only if a real workflow proves otherwise.

---

## 8. `schedule_runs`: One Actual Execution Of A Schedule

Definitions contain no runtime progress.

A row in:

```text
schedule_runs
```

represents one actual execution of a Schedule definition.

Conceptually:

```text
id
scheduleDefinitionId
currentTripOccurrenceId
```

Example:

```text
ScheduleDefinitions
id = 1
name = "Onboarding"
```

and:

```text
ScheduleRuns
id = 5001
scheduleDefinitionId = 1
currentTripOccurrenceId = 3002
```

means:

> Run 5001 is one execution of the Onboarding Schedule, and its durable
> checkpoint is currently ScheduleTripOccurrence 3002.

The run does not duplicate the Schedule’s Trips or Steps.

It only stores the minimum durable state needed to answer:

> Where should this execution resume?

The current model deliberately does not persist current Step position.

Therefore:

```text
currentTripOccurrenceId = 3002
```

means:

> On restart, reconstruct that Trip and begin again at its first Step.

And:

```text
currentTripOccurrenceId = null
```

means:

> This Schedule run is complete.

---

## 9. Why Runtime State Lives In `presence.db`

It would have been possible to store Presence definitions in `presence.db`
while putting current-run state somewhere like `user_overlays.db`.

The current architecture deliberately does not do that.

Presence owns all three related truths:

```text
what the workflow is
where this execution currently is
what happened during this execution
```

Keeping these in one relational database permits ordinary foreign-key
relationships among:

```text
Schedule definitions
Schedule Trip occurrences
Schedule runs
Execution trace events
```

For example, SQLite can enforce that a run’s current Trip occurrence actually
belongs to its Schedule.

`user_overlays.db` has a different meaning: durable user intent.

A Presence execution checkpoint is not user intent; it is Presence runtime
state.

So:

```text
Trips & Steps helper app
    may eventually edit Presence definitions

MessageLens
    executes those definitions
    writes ScheduleRun state
    writes execution trace

all in presence.db
```

The two programs may have different responsibilities without dividing the
Presence relational model across databases.

---

## 10. `execution_trace_events`: The Append-Only Diary

`execution_trace_events` records what actually happened during one
`ScheduleRun`.

Every trace row includes:

```text
scheduleRunId
```

so the complete event history for one execution can be retrieved in sequence
order.

Typical events include:

```text
schedule_run_started
trip_started
step_started
step_completed
trip_completed
route_decision
schedule_run_completed
```

A run might therefore produce:

```text
#01 Schedule started
#02 Trip 1 started
#03 Step 101 started
#04 Step 101 completed
#05 Trip 1 completed
#06 Route: default -> Trip 2
#07 Trip 2 started
...
```

The trace records both:

**Within-Trip activity:**

```text
step_started
step_completed
```

and:

**Trip-boundary activity:**

```text
trip_completed
route_decision
trip_started
```

A route-decision row can record both sides of the boundary:

```text
routingResultTripDefinitionId
selectedDestinationTripOccurrenceId
```

For example:

```text
terminal Step returned canonical Trip 5
Scheduler resolved that to ScheduleTripOccurrence 3005
```

This is particularly useful for development visualization and later diagnostic
analysis.

---

## 11. Trace Is Not Runtime Authority

This distinction is critical:

```text
Definitions prescribe.
ScheduleRun remembers where execution is.
Trace records where execution went.
```

If every trace row disappeared, Presence should still know exactly what to
execute next.

Restart uses:

```text
schedule_runs.currentTripOccurrenceId
```

not the last trace event.

Likewise, routing is calculated from:

```text
Schedule definition
+
terminal Step result
```

not from history.

This is why a repeated FDA-remediation path can simply appear in trace as:

```text
2 -> 5 -> 7 -> 2 -> 5 -> 7
```

There is no special loop object or loop trace event.

Presence merely records repeated ordinary Trip entries and route decisions.

---

## 12. A Complete Walk-Through

Suppose Onboarding contains:

```text
ScheduleDefinition 1
    name = onboarding
```

Its batting order includes:

```text
ScheduleTripOccurrence 3001
    TripDefinition 1
    position 0

ScheduleTripOccurrence 3002
    TripDefinition 2
    position 1

ScheduleTripOccurrence 3005
    TripDefinition 5
    position 2
```

Trip 2 contains:

```text
TripStepOccurrence 8201
    TripDefinition 2
    StepDefinition 9421
    position 0
```

The base Step row says:

```text
StepDefinition 9421
    name = initial_fda_test
    type = fdaTestStepType
```

The subtype row says:

```text
FdaTestStepDefinition 9421
    presentDestination = null
    absentDestination = TripDefinitionId(5)
```

When the Step runs and FDA is absent:

```text
FdaTestStep 9421
    -> returns TripDefinitionId(5)

Trip 2
    -> relays TripDefinitionId(5)

Scheduler
    -> active Schedule is 1
    -> finds the unique occurrence of TripDefinition 5
    -> ScheduleTripOccurrence 3005
    -> writes currentTripOccurrenceId = 3005
```

Trace may then record:

```text
Step 9421 completed
Trip 2 completed
Route result = TripDefinitionId(5)
Selected occurrence = 3005
Trip occurrence 3005 started
```

That single example ties together:

```text
definition
subtype data
occurrence
runtime checkpoint
trace
```

---

## 13. Translation Dictionary

| Database concept          | Plain-English meaning                                               |
| ------------------------- | ------------------------------------------------------------------- |
| `ScheduleDefinition`      | A reusable definition of a complete workflow                        |
| `TripDefinition`          | A reusable semantic chunk of that workflow                          |
| `StepDefinition`          | One reusable configured Step identity                               |
| `stepType`                | Tells the loader which subtype table contains the rest of this Step |
| subtype table             | The type-specific fields for that actual configured Step            |
| `ScheduleTripOccurrence`  | This Trip placed at this position in this Schedule                  |
| `TripStepOccurrence`      | This Step placed at this position in this Trip                      |
| `position`                | Batting order / default-next order                                  |
| `ScheduleRun`             | One actual execution of a Schedule                                  |
| `currentTripOccurrenceId` | Durable checkpoint: where this run resumes                          |
| `executionTraceEvent`     | One immutable observation of what happened during a run             |
| `scheduleRunId` on trace  | Which particular execution this historical event belongs to         |

---

## 14. The Question To Ask When Lost

If the schema becomes confusing, ask:

```text
Am I looking at...

WHAT something is?
    -> definition

WHERE that reusable thing is placed?
    -> occurrence

WHERE one live execution currently is?
    -> schedule_run

WHAT happened during that execution?
    -> execution_trace_events
```

And, specifically:

> **Where is “Welcome to MessageLens” stored?**

Answer:

```text
StepDefinitions
    identifies the configured Step and says it is a Tell Step

TellStepDefinitions
    row with the same primary key stores:
    text = "Welcome to MessageLens."
```

TripStepOccurrences then says where that configured Step is used inside a
Trip.

That is the missing mental link that is easiest to forget.

For the current Boolean Test architecture, ask one additional question:

```text
Is this the persisted declaration of which Agent is required,
or the process-local implementation that knows how to establish the fact?
```

The declaration belongs in `presence.db`. The implementation belongs to the
workflow owner or specialist and enters Presence through runtime composition.
