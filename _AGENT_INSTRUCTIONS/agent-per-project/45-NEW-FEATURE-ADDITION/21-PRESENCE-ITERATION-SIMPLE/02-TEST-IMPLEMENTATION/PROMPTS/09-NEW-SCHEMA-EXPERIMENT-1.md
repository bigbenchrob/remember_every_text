Use this as the next Codex prompt:

We have completed the first linear Schedule / Trip / Step implementation and documented it in:

- 03-SCHEDULE-TRIP-EXPERIMENT/10-DATABASE-SCHEMA-PROPOSAL.md
- 03-SCHEDULE-TRIP-EXPERIMENT/20-LINEAR-EXECUTION-IMPLEMENTATION.md
- 30-SYSTEM-BOUNDARIES.md

The current implementation has proved:

Scheduler knows which Trip is current.
Trip runs its Steps from first to last.
Terminal Tell Step returns null.
Scheduler advances to the next Trip.
Database remembers the current Trip across restart.

The implementation report explicitly identifies canonical destination routing as the next experiment. 20-LINEAR-EXECUTION-IMPLEMENTATION.md

Implement only that next increment.

Do not add FDA behavior yet.

Do not add Boolean-derived routing yet.

Do not add execution trace yet.

The goal of this pass is to prove that a terminal Step can return a canonical Trip definition ID and that the Scheduler can resolve that ID within the active Schedule without changing the one-Trip runtime model.

⸻

Read first

Re-read the three documents above before changing code.

Preserve the current boundaries:

- one ordinary Trip runtime class;
- Steps perform concrete work;
- only the terminal Step’s routing result crosses the Trip boundary;
- Trip relays that result unchanged;
- Scheduler resolves the result;
- durable state remains only the current Trip occurrence.

The current boundary document is authoritative for the implementation experiment. 30-SYSTEM-BOUNDARIES.md

⸻

New concrete Step subtype

Add one concrete routing-capable Step:

FixedDestinationStep

Its persisted definition contains:

destination_trip_definition_id

This is a canonical TripDefinitionId, not a Schedule Trip occurrence ID.

When the Step completes, it returns:

TripDefinitionId(destination)

It must not:

- resolve that canonical ID to an occurrence;
- inspect the Schedule;
- mutate Schedule state;
- perform navigation itself.

Its responsibility is only:

return this canonical Trip destination

⸻

Schema change

Add the approved subtype table:

fixed_destination_step_definitions

with:

step_definition_id
destination_trip_definition_id

Follow the approved schema proposal.

The canonical destination must reference an existing trip_definitions.id.

Do not add:

- a universal routing table;
- RouterTrip;
- Trip behavior enums;
- Schedule-specific route rows;
- occurrence IDs inside reusable Step definitions.

The approved model deliberately keeps routing configuration in the concrete Step subtype. 10-DATABASE-SCHEMA-PROPOSAL.md

⸻

Scheduler change

The Scheduler currently supports only:

terminal result = null
-> next Trip in batting order

Extend it to support:

terminal result = TripDefinitionId(X)
-> resolve canonical Trip X within the active Schedule
-> checkpoint that Schedule Trip occurrence

Resolution must use the existing uniqueness invariant:

UNIQUE(schedule_definition_id, trip_definition_id)

Therefore:

current Schedule + canonical TripDefinitionId
-> exactly one Schedule Trip occurrence

If the destination does not occur in the active Schedule, fail closed.

Do not silently fall back to default-next.

Do not infer a destination from position.

Do not search trace/history.

The approved Scheduler contract is:

null
-> smallest greater Schedule position
TripDefinitionId(X)
-> unique matching Trip occurrence in this Schedule

10-DATABASE-SCHEMA-PROPOSAL.md

⸻

Repository / validation responsibility

Add the minimum definition validation required for fixed destinations.

A Schedule that contains a Trip using a FixedDestinationStep is executable only if that Step’s non-null canonical destination also exists exactly once in the same Schedule.

SQLite already guarantees at most one occurrence of a canonical Trip definition within a Schedule.

Repository/domain validation must guarantee destination presence.

Follow the approved closure rule:

every non-null canonical Trip destination
returned by a Step used in a Schedule
must occur in that Schedule

10-DATABASE-SCHEMA-PROPOSAL.md

Do not build generalized graph validation.

Validate only what this concrete Step requires.

⸻

Experimental fixture

Replace or extend the linear development fixture so the route is obvious.

Use four Trips:

Trip A
Tell A1
Trip B
FixedDestinationStep -> Trip D
Trip C
Tell C1
Trip D
Tell D1

Schedule batting order:

A
B
C
D

Expected execution:

A
terminal null
-> default B
B
terminal TripDefinitionId(D)
-> explicit D
D
terminal null
-> Schedule complete

Trip C must not execute.

This proves forward explicit routing.

⸻

Loop experiment

After forward routing works, add a second focused fixture/test proving backward routing.

For example:

Trip A
-> default B
Trip B
FixedDestinationStep -> Trip D
Trip C
unused
Trip D
FixedDestinationStep -> Trip B

This creates:

B -> D -> B -> D ...

Do not invent a loop construct.

Do not add retry state.

Do not add visit counters.

The purpose is simply to prove that a canonical destination may resolve to an earlier Trip occurrence and that the existing runtime/checkpoint model needs no special accommodation.

Limit the automated test to a finite number of transitions so it terminates deterministically.

⸻

Restart semantics

Preserve the existing restart rule unchanged.

Only the current Trip occurrence is durable.

If the app terminates while executing a Trip reached by explicit routing:

restart
-> load persisted current Trip occurrence
-> recreate Trip
-> begin at Step 1

The mechanism must be identical to restart after default-next routing.

Explicit routing must not introduce additional persisted routing state.

The existing checkpoint model is already:

schedule_run_id
schedule_definition_id
current_trip_occurrence_id

10-DATABASE-SCHEMA-PROPOSAL.md

⸻

Trip boundary

Do not change Trip into a routing-aware class.

Trip must continue to:

- execute Steps in order;
- ignore nonterminal Step results for Schedule routing;
- relay only the terminal Step’s result.

It must not:

- distinguish Tell from FixedDestination;
- resolve Trip IDs;
- know Schedule batting order;
- decide where execution goes next.

The experiment succeeds only if the same boring Trip class survives this change.

⸻

Typed canonical ID

The current implementation report notes that the runtime boundary presently uses an int? canonical destination result. 20-LINEAR-EXECUTION-IMPLEMENTATION.md

During this pass, evaluate whether the introduction of real canonical destination routing is the point at which a small typed identifier such as:

TripDefinitionId

now earns its existence.

Prefer a typed ID if it materially prevents confusion between:

- Trip definition IDs;
- Schedule Trip occurrence IDs;
- Step IDs;
- other database integers.

Do not create a broad ID framework or generic entity-ID abstraction.

If a tiny local value type improves the boundary, use it.

If not, document why raw integers remain sufficiently clear.

⸻

Tests

Add focused tests proving at least:

Schema / loading

- FixedDestinationStep persists and reloads correctly;
- its destination references a canonical Trip definition;
- no Schedule occurrence ID leaks into the reusable Step definition.

Forward routing

- A defaults to B;
- B returns D;
- Scheduler resolves D within the active Schedule;
- C is skipped;
- D runs;
- D’s terminal null completes the Schedule.

Backward routing

- a destination may resolve to an earlier Trip occurrence;
- repeated B -> D -> B transitions work without a loop object or extra state.

Invalid closure

- a Schedule using a FixedDestinationStep whose destination Trip is absent from that Schedule is rejected/fails closed before execution.

Restart

- after explicit routing checkpoints D as current, database close/reopen resumes D;
- D restarts at Step 1;
- no additional route state is required.

Existing behavior

- existing default-next tests continue to pass;
- the one-Trip runtime class remains sufficient.

Run the existing architecture tripwires, analyzer, debug macOS build, and git diff --check.

⸻

Presentation

Make only the minimum development UI change needed to make explicit routing observable.

It should be possible to watch:

A -> B -> D -> complete

Do not redesign Presence presentation.

Do not add production onboarding.

⸻

Documentation

Create:

03-SCHEDULE-TRIP-EXPERIMENT/30-FIXED-DESTINATION-ROUTING-IMPLEMENTATION.md

Document:

- schema change;
- new concrete Step subtype;
- canonical destination contract;
- Scheduler resolution algorithm;
- Schedule-closure validation;
- forward-route result;
- backward-route/loop result;
- restart result;
- whether TripDefinitionId became a typed value;
- tests and verification;
- anything that proved awkward;
- any architectural rule that had to change.

Update 30-SYSTEM-BOUNDARIES.md only if implementation genuinely changes an approved boundary.

Do not broaden it speculatively.

⸻

Hard constraints

Do not add:

- Test/FDA Steps;
- Boolean routing;
- specialized Trip subclasses;
- Trip behavior enums;
- RouterTrip;
- routing tables;
- generic route/result objects beyond the minimum canonical ID boundary;
- arbitrary Step-to-Step control flow;
- context bags;
- current-Step persistence;
- TripRun/StepRun tables;
- execution trace;
- retry/cancellation/failure machinery;
- generalized workflow abstractions;
- production onboarding behavior.

If the implementation seems to require any of those, stop and document why.

⸻

Success criterion

We should finish able to describe the new capability this simply:

Terminal Step returns null
-> Scheduler uses next Trip.
Terminal Step returns Trip 42
-> Scheduler finds Trip 42 in this Schedule and goes there.
Trip itself does not care which happened.

And this class should still conceptually be enough:

class Trip

If explicit routing makes Trip substantially smarter, treat that as evidence that the model is drifting and report it rather than hiding the complexity.

This is a good next test because it isolates exactly one new rod in the balls-and-rods model: an explicit connection between two canonical Trips. If that works without disturbing anything else, the architecture gets a lot more credible.
