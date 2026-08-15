We have materially simplified the Schedule / Trip / Step conjecture after reviewing the first database proposal.

Do not implement anything yet.

Re-read:

03-SCHEDULE-TRIP-EXPERIMENT/10-DATABASE-SCHEMA-PROPOSAL.md

Then produce a replacement/revision proposal based on the rules below.

The purpose of this pass is to determine whether the new model removes the need for specialized Trip behaviors and route tables.

⸻

New central conjecture

There is only one kind of Trip:

class Trip

A Trip is:

- a defined point in a Schedule;
- composed of an ordered sequence of Steps;
- executed from its first Step to its last Step;
- complete when its terminal Step completes;
- responsible only for sequencing its Steps and relaying the terminal Step’s routing result upward.

There are not separate runtime/domain types such as:

- OrdinaryTrip
- TestTrip
- RouterTrip

Those names may remain useful informally to describe how a particular Trip behaves, but they are not different Trip classes or Trip-definition behaviors.

The behavior comes from the Steps that compose the Trip.

⸻

Schedule rule

A Schedule contains an ordered batting order of Trip occurrences.

Each reusable canonical Trip definition may appear at most once in a given Schedule.

The same canonical Trip definition may appear in many different Schedules.

Therefore a Schedule should be able to resolve:

canonical TripDefinitionId +
current ScheduleDefinitionId
->
unique ScheduleTripOccurrence

Default progression is always:

current Trip
->
next Trip in Schedule batting order

unless the completed Trip returns an explicit canonical Trip definition ID.

⸻

Trip result contract

When a Trip’s terminal Step finishes, the Trip relays one routing result to the Scheduler:

null

means:

use the next Trip in Schedule batting order

while:

TripDefinitionId(42)

means:

find canonical Trip 42 in the current Schedule
and make that Trip occurrence current

The Trip itself does not interpret the meaning of the result.

It merely relays it.

The Scheduler owns resolution of a canonical Trip definition ID into the unique Trip occurrence in the active Schedule.

The Step must not directly navigate or mutate Schedule state.

⸻

Step responsibility

Steps are intentionally highly varied.

A Step may:

- show information to the user;
- ask a question;
- invoke an agent;
- inspect system state;
- perform side effects;
- calculate a routing decision;
- or perform some other narrowly defined operation.

Most Steps need know nothing about routing.

But the terminal Step of a Trip may determine the routing result returned by that Trip.

Examples:

Plain informational Trip

Tell Step
->
terminal result = null

The Scheduler therefore uses default-next.

Router-like Trip

FixedDestination Step
->
terminal result = TripDefinitionId(42)

There is no RouterTrip class.

The behavior comes from the Step.

Test-like Trip

FDA Test Step
->
invoke FDA testing agent
->
inspect Boolean result
->
return either:
null
or TripDefinitionId(X)

Or, if both outcomes override default:

true -> TripDefinitionId(X)
false -> TripDefinitionId(Y)

There is no TestTrip class.

The Boolean is local to the Step’s decision logic. The Trip does not receive a Boolean and then interpret true/false route arms.

Instead, the terminal Step resolves its own local logic into the one universal Trip routing result:

TripDefinitionId?

where null means default-next.

⸻

Important consequence

The previous proposal currently models:

trip_definitions.behavior
test_trip_routes
router_trip_routes

Re-evaluate all three.

Do not preserve them merely because they exist in the previous proposal.

If the new model makes them unnecessary, remove them.

This is a fresh derivation from the new rules.

⸻

Reusable definitions versus Schedule-specific routing

Be careful about where routing configuration lives.

A reusable Step definition may potentially be used in more than one Trip or Schedule.

A canonical destination such as:

TripDefinitionId(42)

is deliberately Schedule-independent.

The Step does not store or return a ScheduleTripOccurrenceId.

The Scheduler resolves the canonical Trip ID within the active Schedule.

Because of this, enforce the new rule:

UNIQUE(schedule_definition_id, trip_definition_id)

in Schedule Trip composition.

If a workflow genuinely needs the “same” Trip twice in one Schedule, create a distinct canonical Trip definition for that second role rather than placing one Trip definition twice.

Stress-test whether this is sufficient to avoid Schedule-specific routing tables.

⸻

Runtime state remains minimal

Preserve the existing restart conjecture unless the new model disproves it.

Durable execution state should ideally remain:

schedule_run_id
schedule_definition_id
current_trip_occurrence_id

No current Step is persisted.

If MessageLens terminates while a Trip is incomplete, restart that Trip from Step 1.

Trip boundaries remain checkpoint boundaries.

If a Trip becomes unpleasant to repeat, prefer splitting it into smaller Trips before adding Step-level resume state.

⸻

Execution trace remains observational only

Preserve the distinction:

definitions prescribe
runtime state remembers the checkpoint
trace records what happened

The execution trace may record:

- Schedule start/completion;
- Trip start/completion;
- Step start/completion;
- terminal routing result;
- selected destination;
- timestamps/durations;
- repeated loops.

The Scheduler must never consult the trace to determine what happens next.

⸻

Worked FDA example

Re-model the previous FDA flow using the new universal Trip model.

Conceptually:

Trip 1
-> default Trip 2
Trip 2
terminal FDA-test Step:
FDA present -> null
FDA absent -> TripDefinitionId(5)
Trip 3
-> default Trip 4
Trip 4
terminal fixed-destination Step:
-> TripDefinitionId(8)
Trip 5
-> default Trip 7
Trip 7
terminal FDA-test Step:
FDA present -> null
FDA absent -> TripDefinitionId(2)
Trip 8
continues onboarding

Thus:

1 -> 2
2 present -> default 3 -> default 4 -> explicit 8
2 absent -> explicit 5 -> default 7
7 present -> default 8
7 absent -> explicit 2

The loop:

2 -> 5 -> 7 -> 2

must require no special loop construct.

⸻

Your task

Produce a revised schema-design report that answers:

1. What is now the smallest normalized on-disk schema?
2. Can trip_definitions.behavior be removed entirely?
3. Can test_trip_routes be removed entirely?
4. Can router_trip_routes be removed entirely?
5. Where should concrete Step subtype configuration live?
6. How should a terminal Step represent:
   - default-next;
   - fixed canonical Trip destination;
   - test-derived canonical Trip destination?
7. Does that require a universal routing-result column/table, or should routing configuration remain specific to concrete Step subtype tables?
8. How do we preserve Step reusability without coupling Steps to Schedule occurrence IDs?
9. Is UNIQUE(schedule_definition_id, trip_definition_id) sufficient to make canonical Trip ID routing unambiguous?
10. What validation is required to ensure every possible TripDefinitionId returned by a Step actually exists in every Schedule where that Trip/Step composition is used?
11. Does the minimal schedule_runs.current_trip_occurrence_id checkpoint model still work unchanged?
12. What changes, if any, are needed to the execution trace?
13. What invariants can SQLite enforce and what still belongs in repository/domain validation?

Include a complete table-by-table schema proposal and the worked FDA rows.

⸻

Important design pressure

Prefer:

one universal Trip
varied specialized Steps
tiny Scheduler routing contract

over creating new Trip categories.

But do not force the conclusion.

If this model creates a genuine contradiction or requires awkward storage, identify it clearly.

We are testing a conjecture, not defending it.

⸻

Constraints

Do not implement application code.

Do not create Drift tables or migrations yet.

Do not preserve previous schema elements merely for compatibility.

Do not invent:

- generic graph engines;
- arbitrary Step-to-Step routing;
- Schedule occurrence IDs inside reusable Step definitions;
- generalized context/result bags;
- plugin registries;
- generalized outcome taxonomies;
- nested Journeys;
- current-Step persistence;
- speculative concurrency;
- broad workflow frameworks.

Keep the model brutally small.

End with:

- Recommended revised minimal schema
- What disappeared from the previous proposal
- Remaining genuine ambiguities
- Things deliberately not modeled

The architectural test is:

Can Trip remain one boring class while all meaningful variation is expressed by the Steps it sequences?
