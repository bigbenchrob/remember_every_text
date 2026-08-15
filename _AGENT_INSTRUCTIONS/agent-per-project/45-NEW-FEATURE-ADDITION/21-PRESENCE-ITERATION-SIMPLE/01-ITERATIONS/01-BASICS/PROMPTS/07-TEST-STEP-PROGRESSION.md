Begin planning Iteration 1B of PRESENCE-ITERATION-SIMPLE.

Read first:

- 21-PRESENCE-ITERATION-SIMPLE/00-START-HERE.md
- 21-PRESENCE-ITERATION-SIMPLE/10-IMPLEMENTATION-PRINCIPLES.md
- 21-PRESENCE-ITERATION-SIMPLE/20-CODEX-INSTRUCTIONS.md
- the completed Iteration 1A response and implementation
- Journey, Step, JourneyRepository, JourneyDefinitionStore, and DriftJourneyRepository

The controlling premise remains implementation-led redesign from first principles.

Do not consult the historical 43-PRESENCE package as authority.

This is a planning task only.

Do not write code yet.

---

## Current working slice

Iteration 1A already proves:

- Journey definitions are stored relationally;
- Journey 42 loads through JourneyRepository;
- its three Steps are returned in deterministic order;
- each Step contains only id and text.

The next behaviour is:

load Journey 42

current Step
Hello one

Next

current Step
Hello two

Next

current Step
Hello three

Next

Done

No page, animation, Flutter, Riverpod, persistence of progress, Ask, or Wait belongs in this iteration.

---

## Central design question

What is the smallest understandable in-memory object responsible for progress through one loaded Journey?

Evaluate at least these possibilities:

1. Journey itself stores mutable progress.
2. A separate JourneyProgress or JourneyRun object stores current position.
3. A small controller owns a Journey and current index.
4. Another simpler structure discovered from the existing code.

Do not choose based on the historical Presence architecture.

Choose based on:

- one obvious responsibility per object;
- human comprehensibility;
- minimal synchronized state;
- no future-facing abstraction;
- ease of testing;
- compatibility with the existing immutable Journey definition loaded from the repository.

---

## Required behaviour

The chosen object must support only:

- access to the loaded Journey;
- access to the current Step;
- Next;
- Done.

Nothing else.

Define precisely what happens when:

- the Journey contains three Steps;
- Next is called after the first Step;
- Next is called after the third Step;
- Next is called again after Done;
- the Journey contains no Steps.

Do not invent behaviour silently. Recommend the simplest explicit rule.

---

## State

Determine the minimum runtime state.

A likely candidate is one integer index.

Do not add:

- status enum;
- current Step id stored separately from the index;
- lifecycle;
- revision;
- timestamps;
- completion record;
- persisted progress;
- response history;
- Step completion objects;
- callbacks;
- streams;
- providers;
- repository writes.

Avoid storing two values that express the same truth.

For example, do not store both currentIndex and isDone if one can be derived from the other.

---

## Naming

Use the clearest ordinary name.

Candidates may include:

- JourneyProgress
- JourneyRun
- JourneyController
- JourneyPlayer
- another simpler term

Do not give previous terminology privileged status.

Explain what question the object answers.

Examples:

- Journey: “What Steps belong to this Journey?”
- New runtime object: “Where am I in this Journey?”

Prefer the name that makes the code easiest to explain.

---

## Mutability

Decide whether the runtime object should be mutable for this iteration.

A mutable object with:

next()

may be simpler than rebuilding immutable progress values.

Do not introduce immutability, Freezed, copyWith, state notifiers, or event reducers merely for consistency.

Use them only if the current behaviour requires them.

---

## DDD placement

Determine where this runtime object belongs under the current shared Presence essential.

Inspect the project’s actual DDD conventions.

Likely possibilities include:

- domain/entities
- domain/services
- application
- another established location

Do not create a new generic folder without repository precedent.

The object must not depend on Drift or the repository implementation.

---

## Tests

Recommend focused pure-Dart tests proving:

1. A newly created runtime object starts on “Hello one”.
2. Next advances to “Hello two”.
3. Next advances to “Hello three”.
4. Next after “Hello three” makes the Journey Done.
5. currentStep is absent when Done.
6. Next after Done has one explicit, tested behaviour.
7. An empty Journey starts Done.
8. Journey definition data is not mutated.
9. No database, Flutter, Riverpod, UI, or persistence is required by the progress object.

Do not test presentation or animation.

---

## Explicitly not included

The plan must explicitly exclude:

- Flutter page;
- fade transitions;
- Next button;
- automatic timing;
- persisted current Step;
- restart;
- Journey run database table;
- Ask;
- Wait;
- Step types;
- actions;
- completion criteria;
- Coordinator;
- Renderer;
- historical Presence entities;
- providers;
- streams.

---

## Deliverable

Create a planning response in the current iteration’s responses folder.

Include:

1. Recommended object and name.
2. Its single responsibility.
3. Exact fields.
4. Exact public methods/getters.
5. Behaviour at each boundary condition.
6. Why progress does or does not belong inside Journey itself.
7. Exact file location.
8. Required tests.
9. Explicitly Not Included.
10. Smallest recommended coding task.

Do not begin implementation.
