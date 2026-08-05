Implement the schema revision described in:

16-DB-SCHEMA-REVISION-RESPONSE.md

Read first:

- the three PRESENCE-ITERATION-SIMPLE root orientation documents;
- SYSTEM-BOUNDARIES.md;
- 16-DB-SCHEMA-REVISION-RESPONSE.md;
- the current Presence implementation and tests.

This remains implementation-led redesign from first principles.

Do not consult the historical 43-PRESENCE package as authority.

---

## Reason for this iteration

This schema revision has now earned its existence.

Not because we anticipate future Step types.

Because two real, working Step presentation components already exist:

- TellStepView
- AskStepView

The persistence model should now truthfully represent that fact.

No further Step types are part of this iteration.

---

## Goal

Revise the shared Presence schema and domain model so one Journey may contain:

- TellStep
- AskStep

while:

Journey
remains unaware of the concrete Step subtype.

JourneyProgress
remains unaware of the concrete Step subtype.

Only the repository constructs concrete subclasses.

---

## Implement

Follow the planning document exactly unless implementation reveals a concrete contradiction.

Implement:

Database

journeys

steps

- id
- journey_id
- position
- type

tell_steps

- step_id
- text

ask_steps

- step_id
- question

Use the relational constraints described in the planning document.

---

## Domain

Replace the current concrete Step entity with:

sealed Step

TellStep

AskStep

Do not add:

- answer storage;
- validation;
- callbacks;
- presentation logic;
- completion;
- status;
- runtime behaviour.

Journey continues to own:

List<Step>

JourneyProgress remains unchanged.

---

## Repository

Implement the loading strategy described in the planning response.

The repository:

- loads ordered base Step rows;
- validates subtype consistency;
- constructs TellStep or AskStep;
- returns Journey containing List<Step>.

Journey must never construct subclasses.

JourneyProgress must never inspect subtype.

---

## Fixture

Revise Journey 42 to:

Tell
Hello one

Ask
What should I call you?

Tell
Hello three

The Ask answer remains laboratory-only.

Do not persist answers.

---

## Presentation

Make only the minimum changes required for the application to compile.

JourneyView may temporarily perform:

switch(currentStep)

with:

TellStep
-> TellStepView

AskStep
-> AskStepView

Do not introduce:

- Step factory
- registry
- generic renderer
- provider
- polymorphic widget hierarchy

Two cases do not justify an abstraction.

---

## Tests

Implement the repository and domain tests from the planning document.

Retain existing Tell and Ask widget tests.

Update JourneyView tests only as required by the new domain hierarchy.

---

## Scope discipline

Do not implement:

- Wait
- Action
- FDA
- answer ownership
- Journey results
- providers
- persistence of responses
- generic Step framework
- generalized callbacks

Every field, class, and table must be justified by Tell and Ask only.

---

## Review

At completion report:

1. Every handwritten file modified.
2. Every generated file modified.
3. Every schema change.
4. Every new domain class.
5. The exact repository loading algorithm.
6. Every integrity check now performed by the repository.
7. The updated Journey 42 fixture.
8. Tests and analyzer results.
9. Any complexity that appeared unexpectedly.
10. Whether the resulting Journey and JourneyProgress remain blissfully ignorant of concrete Step behaviour.

Do not broaden the implementation beyond this schema revision.
