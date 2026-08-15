Begin Iteration 1A of PRESENCE-ITERATION-SIMPLE.

Read first:

- 21-PRESENCE-ITERATION-SIMPLE/00-START-HERE.md
- 21-PRESENCE-ITERATION-SIMPLE/10-IMPLEMENTATION-PRINCIPLES.md
- 21-PRESENCE-ITERATION-SIMPLE/20-CODEX-INSTRUCTIONS.md
- 21-PRESENCE-ITERATION-SIMPLE/00-THREE-STEP-TELL-JOURNEY/

The controlling premise is implementation-led redesign from first principles.

Do not consult the historical 43-PRESENCE architecture as authority.

Do not preserve old names, entities, boundaries, or invariants merely because they existed before.

This task is a narrowly bounded design-and-planning step.

Do not write application code yet.

---

## Iteration 1 behaviour

The complete target behaviour remains:

one Journey
contains three ordered Steps

each Step
contains one Tell statement

Next
advances to the following Step

after the third Step
Journey is Done

This task addresses only the persisted definition of the Journey and its Steps.

It does not address Next, current Step, Done, presentation, animation, or runtime progress.

---

## Data/runtime boundary

Use this provisional boundary:

Database
stores what the Journey is

Dart objects
represent the loaded Journey and ordered Steps

Memory
will later store where the current run is

Do not persist runtime progress in this iteration.

Do not introduce a Journey run, current-step record, lifecycle, revision, status, provenance, activation, or completion record.

---

## Minimal schema

Evaluate and refine this candidate schema:

journeys

- id
- name

steps

- id
- journey_id
- position
- text

The seed data should represent:

Journey 42
Three-step Tell Journey

Step 1
position 0
Hello one

Step 2
position 1
Hello two

Step 3
position 2
Hello three

Do not add a join table unless the current iteration concretely requires one.

Do not add:

- step type;
- action;
- completion criterion;
- status;
- timestamps;
- feature ownership;
- version;
- JSON payload;
- metadata;
- future Ask or Wait fields.

Every column must answer:

“What exact requirement in Iteration 1A fails without this?”

---

## Minimal Dart entities

Evaluate and refine this candidate runtime model:

Journey

- id
- name
- ordered Steps

Step

- id
- text

Do not introduce a Tell subtype yet unless a second Step kind exists in the current iteration.

Do not create:

- DTO/domain duplicates;
- mapper hierarchies;
- abstract repositories;
- generic Step protocols;
- sealed unions;
- Freezed classes merely for consistency;
- interfaces for future replacement;
- execution-state objects.

Use the project’s normal data-access conventions only where the existing codebase genuinely requires them.

---

## Questions to answer

Determine:

1. Which existing database should own these two tables, if any?
2. Should this use Drift, given the project’s existing architecture?
3. Where should the schema live?
4. Where should Journey and Step live?
5. What is the narrowest loading path for:
   load Journey 42 with Steps ordered by position?
6. What database constraints are immediately required?
7. Should position be zero-based or one-based?
8. Is Journey 42 best inserted through a migration, test fixture, or development-only seed?
9. How can the seed remain clearly laboratory-only?
10. Which tests are required before any runtime progress logic is introduced?

---

## Required constraints

At minimum, consider whether the current behaviour requires:

- journey primary key;
- step primary key;
- foreign key from step to journey;
- deterministic Step ordering;
- uniqueness of position within one Journey;
- rejection of orphan Steps.

Do not add constraints for hypothetical future behaviour.

---

## Deliverable

Create a planning response in the current iteration’s responses folder.

Do not modify code or schema.

The response must include:

1. Recommended minimal database schema.
2. Recommended minimal Dart entities.
3. Exact file locations.
4. Recommended seed strategy.
5. Required constraints and why each is needed now.
6. Required tests.
7. Any existing project convention that forces more complexity than the conceptual model.
8. A list titled “Explicitly Not Included.”
9. The smallest recommended first coding task.

The first coding task should not extend beyond creating the two tables, the seed data, the two Dart entities, and a focused test that Journey 42 loads with Steps in the correct order.
