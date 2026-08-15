Absolutely. I’d give Codex a planning-only prompt and make it prove the schema before it writes any implementation.

Here is the prompt I’d use:

We are beginning a new experimental Presence architecture for MessageLens.

Do not implement anything yet.
Your task is to design the smallest normalized on-disk database schema that can support the conjectural execution model described below, and write your findings as documentation in the active Presence experiment folder.

The goal is not to preserve the current Journey implementation. Treat this as a fresh architectural experiment.

Conjectural execution model

A Schedule is an ordered sequence of Trip occurrences.

A Trip is an ordered sequence of Step occurrences.

A reusable Trip definition may appear in more than one Schedule position. A reusable Step definition may appear in more than one Trip position. Therefore, distinguish reusable definitions from their ordered occurrences.

Inside a Trip:

- execution always starts at the first Step;
- Steps execute in order;
- a Step reports only that it has completed;
- when the final Step completes, the Trip completes;
- there is no conditional branching between Steps.

Between Trips:

- the default behaviour after a Trip completes is to execute the next Trip occurrence in the Schedule’s batting order;
- some Trip types can override that default.

For this experiment there are three Trip behaviours:

Ordinary Trip

- completes;
- defaults to the next Trip occurrence in Schedule order.

Test Trip

- behaves like every other Trip internally and contains an ordered series of Steps;
- its final result is Boolean;
- it may specify a destination Trip occurrence for true;
- it may specify a destination Trip occurrence for false;
- either arm may be absent, in which case that outcome follows the default next-Trip behaviour.

Router Trip

- behaves like every other Trip internally;
- when complete, it specifies one destination Trip occurrence instead of following the default next Trip.

Routing therefore happens only at Trip boundaries.

Loops are valid. For example:

FDA Test -> Guide User -> FDA Retest -> FDA Test

A previously completed reusable Trip may therefore be executed again.

Runtime-state conjecture

Definitions are immutable/reusable and must not contain execution state.

We currently believe that durable runtime state can be extremely small.

At minimum, a running Schedule probably needs to remember:

- which Schedule run this is;
- the current Trip occurrence;
- whether the Schedule is active or complete, if such a status proves necessary.

We currently do not want to persist the current Step.

If MessageLens terminates while a Trip is incomplete, that Trip should restart from Step 1 when the application relaunches.

Trip boundaries therefore act as restart/checkpoint boundaries. If repeating a Trip becomes unpleasant for the user, the preferred remedy is to split it into smaller Trips rather than immediately add Step-level persistence.

Do not add more persisted state unless you can demonstrate that one of these rules cannot be satisfied without it.

Execution trace

Separately from runtime state, we want an append-only execution trace.

The trace may eventually record such facts as:

- Schedule run started;
- Trip occurrence started/completed;
- Step occurrence started/completed;
- Test result;
- routing decision;
- timestamps/durations.

This is a historical record only.

The trace must never be required to determine what executes next or where a Schedule resumes.

The intended separation is:

- definitions prescribe;
- runtime state remembers where execution currently is;
- trace observes what happened.

Storage requirement

This experiment should now use a real normalized on-disk Presence database, not the current in-memory experimental store.

Presence should have its own physical database rather than storing its definitions in Import, Working, or Overlay.

Follow the existing MessageLens DDD/database ownership conventions where appropriate:

- Presence owns its schema and repositories;
- shared database infrastructure should own physical path/open/close/inventory concerns if that is consistent with the existing project.

Do not assume the old Presence schema should be retained.

Your task

Read the active experiment documentation and relevant existing database infrastructure before proposing anything.

Then produce a schema-design report answering:

1. What is the smallest normalized schema that satisfies the rules above?
2. Which tables represent reusable definitions?
3. Which tables represent ordered occurrences?
4. How should ordinary, Test, and Router Trip configuration be represented?
5. How should Schedule runtime state be represented?
6. What is the minimum state required to survive application restart?
7. How should the append-only execution trace be represented without making it part of execution logic?
8. What foreign keys, uniqueness constraints, ordering constraints, and indexes are required?
9. Which invariants can SQLite enforce directly and which must be enforced in repository/domain code?
10. How should schema versioning/migration begin for this new physical database?
11. Are there any aspects of the proposed execution rules that make a normalized relational representation awkward or ambiguous?

Include an explicit proposed schema, preferably table-by-table with columns, keys, and relationships.

Also include a small worked example representing this routing structure:

- Trip 1 → default Trip 2
- Trip 2 is an FDA Test
  - true → default Trip 3
  - false → Trip 5
- Trip 3 → default Trip 4
- Trip 4 is a Router → Trip 8
- Trip 5 → default Trip 7
- Trip 7 is an FDA Test
  - true → default Trip 8
  - false → Trip 2

Show how the Schedule batting order, Test destinations, Router destination, and loop are represented in the proposed schema.

Constraints

Be aggressively conservative.

Do not add:

- generic graph engines;
- arbitrary Step-to-Step routing;
- persisted current-Step state;
- context/result bags;
- plugin/agent registries;
- generalized outcome enums;
- nested Journeys;
- speculative scheduling machinery;
- analytics infrastructure beyond the minimum append-only trace model;
- compatibility layers for obsolete experimental Presence code.

If something is not required by the conjecture above, leave it out.

Prefer deletion/replacement over accommodating old abstractions.

Do not modify production code.

Do not create migrations or Drift tables yet.

This is a read-and-document planning pass only.

End the report with:

- Recommended minimal schema
- Open questions that must be resolved before implementation
- Things deliberately not modeled yet

The key test is not “is this flexible?”

The key test is:

Can another developer look at the database rows and understand exactly what the Schedule will do?

I would have Codex write that as something like:

21-PRESENCE-ITERATION-SIMPLE/03-SCHEDULE-TRIP-EXPERIMENT/10-DATABASE-SCHEMA-PROPOSAL.md

That gives us something concrete to attack before a single new class gets written.
