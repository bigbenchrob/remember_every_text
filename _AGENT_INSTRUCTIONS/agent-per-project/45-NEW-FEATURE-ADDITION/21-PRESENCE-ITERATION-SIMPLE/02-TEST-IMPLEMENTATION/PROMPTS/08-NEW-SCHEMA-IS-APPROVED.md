Here is the prompt I’d give Codex now. It deliberately implements only the linear, boring baseline and makes the restart semantics the thing to prove.

We have approved the revised Schedule / Trip / Step conjecture in:

\_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/21-PRESENCE-ITERATION-SIMPLE/03-SCHEDULE-TRIP-EXPERIMENT/10-DATABASE-SCHEMA-PROPOSAL.md

The current model is:

Schedule
ordered Trips
Trip
ordered Steps
relays terminal Step's TripDefinitionId?
Step
performs concrete work
terminal Step may produce:
null -> default next Trip
TripDefinitionId -> explicit canonical destination
Scheduler
resolves default-next or canonical destination

There is one ordinary Trip class. No specialized TestTrip, RouterTrip, or OrdinaryTrip types.

We are now ready for the first implementation experiment.

Do not implement the FDA flow yet.

Do not implement fixed-destination routing yet.

Do not implement Boolean-derived routing yet.

The purpose of this pass is to prove the smallest possible linear execution and restart model against a real on-disk Presence database.

⸻

Read first

Before changing code, read:

- the active Presence experiment documentation under
  45-NEW-FEATURE-ADDITION/21-PRESENCE-ITERATION-SIMPLE/
- especially
  03-SCHEDULE-TRIP-EXPERIMENT/10-DATABASE-SCHEMA-PROPOSAL.md
- the existing shared database/file-path/open-close/inventory infrastructure;
- the current experimental Presence implementation;
- existing Drift patterns used elsewhere in MessageLens.

Treat the revised schema proposal as the current experimental authority.

Do not preserve obsolete Journey implementation merely for compatibility.

⸻

Goal of this implementation pass

Prove all of the following:

1. Presence has its own physical on-disk SQLite/Drift database.
2. A Schedule can contain ordered reusable Trip definitions.
3. A Trip can contain ordered reusable Step definitions.
4. A Trip always begins at its first Step.
5. Steps execute in order.
6. Completing the terminal Step completes the Trip.
7. For this first experiment, every terminal Step returns null.
8. null causes the Scheduler to execute the next Trip in Schedule batting order.
9. If there is no later Trip, the Schedule completes.
10. Durable runtime state stores only the current Trip occurrence.
11. If the app is terminated during an incomplete Trip, relaunch restarts that Trip from Step 1.
12. Previously completed Trips are not replayed after restart.

This pass should prove those rules in code and tests.

⸻

Implement only the minimum schema required

Implement these structural tables from the approved proposal:

schedule_definitions
trip_definitions
step_definitions
schedule_trip_occurrences
trip_step_occurrences
schedule_runs

Implement one concrete Step subtype:

tell_step_definitions

Do not implement yet:

fixed_destination_step_definitions
fda_test_step_definitions

The append-only execution trace is approved conceptually, but it is not required to prove this first executor slice.

Prefer leaving execution_trace_events for the next experiment unless implementing it now is genuinely simpler than deferring it.

Do not let trace work broaden this task.

⸻

Physical database requirement

Presence must now use a real on-disk database.

Follow existing MessageLens database ownership conventions.

Presence should own:

- its schema;
- its repositories;
- definition loading/validation;
- Schedule execution/checkpoint transactions.

Shared database infrastructure should own physical concerns such as:

- file identity/name;
- archive-root path resolution;
- long-lived open/close lifecycle;
- inventory/health registration where required by existing conventions.

The intended physical file is a Presence-owned database such as:

presence.db

under the admitted archive root.

Do not put Presence state in:

- Import;
- Working;
- Overlay.

Do not have feature/presentation code open the database directly.

Do not implement speculative backup/reset policy beyond what is required to integrate safely with current development database infrastructure.

If production-preservation decisions are required before registration in some central reset system, stop and document that rather than guessing.

⸻

Minimal domain/runtime shape

Keep the model deliberately small.

A reusable Trip definition should not contain runtime state.

A reusable Step definition should not contain runtime state.

Runtime authority belongs in schedule_runs.

Conceptually:

ScheduleRun
id
scheduleDefinitionId
currentTripOccurrenceId

A non-null current Trip occurrence means the Schedule is active.

A null current Trip occurrence means the Schedule is complete.

Do not add a status enum unless implementation proves it necessary.

Do not persist current Step.

Do not add TripRun or StepRun tables.

Do not add completion flags to reusable definitions or occurrences.

⸻

The first experimental fixture

Seed or otherwise construct one development Schedule containing three Trips:

Schedule: linear_presence_experiment
Trip 10
Tell: "Trip 10 - Step 1"
Tell: "Trip 10 - Step 2"
Trip 20
Tell: "Trip 20 - Step 1"
Tell: "Trip 20 - Step 2"
Trip 30
Tell: "Trip 30 - Step 1"

Exact IDs/text may vary if project conventions make different values cleaner, but preserve the structure:

Trip A: 2 Steps
Trip B: 2 Steps
Trip C: 1 Step

All Tell Steps complete with:

TripDefinitionId? = null

Therefore execution must be:

Trip A
Step 1
Step 2
-> null
Scheduler
-> next Trip B
Trip B
Step 1
Step 2
-> null
Scheduler
-> next Trip C
Trip C
Step 1
-> null
Scheduler
-> no later Trip
-> Schedule complete

⸻

Important Trip/Step boundary

Preserve this rule:

Only the terminal Step’s routing result crosses the Trip boundary.

For this experiment every Tell Step naturally produces null.

Do not over-generalize this into a rule that routing-capable Step classes may only ever exist in terminal position.

The narrower rule is:

- Steps may eventually perform many kinds of internal calculations;
- only the terminal Step’s routing result is relayed by the Trip;
- results from nonterminal Steps do not currently affect Schedule routing.

More complex inter-Step logic is deliberately deferred until a real requirement appears.

⸻

Scheduler behavior

For this first pass, the Scheduler needs only default-next behavior.

Given:

current Schedule
current Trip occurrence
terminal result = null

resolve:

occurrence with smallest position greater than current position

If found:

update schedule_runs.current_trip_occurrence_id

If none exists:

set schedule_runs.current_trip_occurrence_id = null

That checkpoint update must be atomic at the Trip boundary.

Do not implement canonical-ID routing yet, but structure the boundary so that a future TripDefinitionId result can be added without rewriting Trip execution.

⸻

Restart semantics to prove

This is one of the primary purposes of the experiment.

Suppose the Schedule is executing Trip B and the app terminates after:

Trip B
Step 1 completed

but before Trip B completes.

Because current Step is not persisted, relaunch must do:

load schedule_run
current Trip = Trip B
restart Trip B at Step 1

It must not:

- replay Trip A;
- resume at Trip B Step 2;
- infer progress from presentation state;
- infer progress from logs;
- serialize a whole object graph.

Trip is the checkpoint/restart unit.

⸻

Tests

Add focused tests proving at least:

Database/schema

- the Presence database is physically persistent, not in-memory;
- Schedule batting order is deterministic;
- Trip Step order is deterministic;
- duplicate Trip definition within one Schedule is rejected by:

UNIQUE(schedule_definition_id, trip_definition_id)

Linear execution

- Schedule starts at first Trip;
- Trip starts at first Step;
- Steps execute in order;
- terminal null advances to next Trip;
- last Trip + terminal null completes the Schedule.

Restart

- persisted current Trip survives database close/reopen;
- reopening during Trip B resumes at Trip B;
- Trip B begins again at Step 1;
- Trip A is not replayed.

Checkpoint boundary

Demonstrate the intended semantics:

- before the Trip-boundary checkpoint commits, restart returns to the previous current Trip;
- after it commits, restart begins the newly selected Trip.

Keep tests deterministic. Do not depend on actual FDA/macOS permissions.

⸻

Presentation

Reuse the existing experimental Presence presentation only as much as necessary to make the linear Schedule visibly runnable.

Do not redesign the visual language.

Do not broaden onboarding.

Do not add production routing.

The UI exists only to help us observe:

Trip A -> Trip B -> Trip C -> complete

and, manually if useful, restart behavior.

⸻

Delete or isolate obsolete experiment code

If the old Journey-based implementation directly conflicts with the new Schedule/Trip model, prefer replacing/removing experimental code rather than building adapters around it.

Git is the archive.

Do not create compatibility abstractions for obsolete experimental concepts.

Preserve unrelated worktree changes.

⸻

Hard constraints

Do not add:

- specialized Trip subclasses;
- Trip behavior enums;
- Test Trip logic;
- Router Trip logic;
- fixed-destination Step types;
- FDA Test Step types;
- agent registries;
- generic handler/plugin registries;
- arbitrary Step-to-Step routing;
- current-Step persistence;
- TripRun/StepRun persistence;
- context/result bags;
- generalized workflow engines;
- nested Journeys;
- loop objects;
- retries/cancellation/failure taxonomies;
- speculative analytics;
- definition revision systems.

If implementation seems to require one of these, stop and document why rather than introducing it.

⸻

Deliverables

Implement the smallest working slice and write:

03-SCHEDULE-TRIP-EXPERIMENT/20-LINEAR-EXECUTION-IMPLEMENTATION.md

documenting:

- what was implemented;
- physical database integration;
- final implemented tables;
- domain/runtime classes;
- Scheduler responsibility;
- Trip responsibility;
- Step responsibility;
- restart/checkpoint behavior;
- tests added and results;
- obsolete experimental code removed/replaced;
- anything that proved awkward;
- any rule that had to change.

End with:

What this experiment proved

What it did not prove

What should be implemented next, if this remains promising

⸻

Success criterion

We should finish this pass able to describe the executable system this simply:

Scheduler knows which Trip is current.
Trip runs its Steps from first to last.
Terminal Step returns null.
Scheduler advances to the next Trip.
Database remembers the current Trip across restart.

If the implementation requires substantially more conceptual machinery than that, treat the discrepancy as evidence against the model and report it rather than hiding it behind abstractions.

This is the point where I’d want Codex to be almost suspicious of every class it adds. If the first linear implementation comes out boring, that is exactly the result we want.
