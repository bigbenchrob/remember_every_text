Begin planning the next PRESENCE-ITERATION-SIMPLE slice.
The purpose is to revise the Journey-definition schema and domain entities so one Journey can contain the two Step types now proven by working presentation experiments:

- Tell
- Ask
  This is a planning task only.
  Do not write code yet.
  Do not design Wait, Action, FDA, restart, workers, or a universal Step framework.

---

## Current working model

The current schema is:
journeys

- id
- name
  steps
- id
- journey_id
- position
- text
  The current domain model is:
  Journey
- id
- name
- List<Step>
  Step
- id
- text
  This was sufficient while every Step was a Tell.
  It is no longer sufficient because Ask has different data:
  Tell
- text
  Ask
- question
  Do not add every possible subtype field to one shared Step table or class.

---

## Goal

Find the smallest normalized schema and Dart model that supports:
Journey
contains ordered Steps
Step
is an abstract/common base
TellStep
contains Tell-specific data
AskStep
contains Ask-specific data
Journey and JourneyProgress must continue to treat all subclasses simply as Step.

---

## Candidate relational model

Evaluate this candidate:
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
  The base steps table should contain only data shared by every Step:
- identity;
- Journey membership;
- position;
- subtype discriminator.
  Subtype tables should contain only subtype-specific data.
  Do not add fields for hypothetical future Step types.

---

## Questions to resolve

1. Should `type` be stored as text or integer?
2. What exact allowed values are required now?
3. Should subtype tables use `step_id` as both primary key and foreign key?
4. Should subtype rows cascade when the base Step is deleted, even though deletion is not yet implemented?
5. How should the repository load ordered base rows and then construct the correct subtype?
6. Is one query with joins clearer, or separate subtype queries?
7. What should happen when:
   - a base Step has no matching subtype row;
   - a Tell base row has an Ask subtype row;
   - both subtype rows exist;
   - the type discriminator is unknown?
8. Which invalid states should the database prevent now, and which should the repository reject?
9. Does Drift support this cleanly without introducing a mapper hierarchy?
10. How should the Journey 42 fixture change to include both Tell and Ask?

---

## Domain model

Evaluate a minimal sealed hierarchy:

```dart
sealed class Step {
  const Step({required this.id});
  final int id;
}
final class TellStep extends Step {
  const TellStep({
    required super.id,
    required this.text,
  });
  final String text;
}
final class AskStep extends Step {
  const AskStep({
    required super.id,
    required this.question,
  });
  final String question;
}

Do not add:

* completion state;
* callbacks;
* answers;
* validation;
* presentation widgets;
* type getters merely mirroring runtimeType;
* base-class text/question fields;
* generic payloads;
* JSON;
* Freezed unless a current repository convention requires it.

Journey remains:

class Journey {
  final int id;
  final String name;
  final List<Step> steps;
}

JourneyProgress remains unchanged unless compilation proves a real contradiction.

⸻

Repository

JourneyRepository should continue to expose only:

Future<Journey> loadJourney(int id);

DriftJourneyRepository must return concrete Step subclasses in persisted order.

The client must not import Drift row types.

Do not add repositories per Step subtype.

Do not add CRUD methods.

⸻

Fixture

Revise the laboratory Journey so the sequence proves both types.

Candidate:

1. TellStep
    “Hello one”
2. AskStep
    “What should I call you?”
3. TellStep
    “Hello three”

The exact text may be refined, but the fixture must contain at least one Tell and one Ask.

Do not yet store or persist the answer.

⸻

Tests

Recommend focused tests proving:

1. A mixed Journey loads in position order.
2. Tell rows become TellStep.
3. Ask rows become AskStep.
4. Tell-specific text is preserved.
5. Ask-specific question is preserved.
6. JourneyProgress advances through mixed Step subclasses unchanged.
7. Orphan subtype rows are rejected.
8. Missing subtype data is rejected.
9. Unknown Step type is rejected.
10. Inconsistent subtype/type combinations are rejected.
11. Journey and JourneyProgress remain ignorant of subtype behaviour.
12. Existing Tell and Ask widget tests remain independent of Drift.

Do not test answer ownership yet.

⸻

Presentation impact

Document only the immediate consequence:

JourneyView can now inspect the current Step runtime subtype and select:

* TellStepView for TellStep;
* AskStepView for AskStep.

Do not implement that selection in this planning task.

Do not introduce a generic Step-view interface, registry, factory, or provider yet.

⸻

Scope discipline

Do not introduce:

* WaitStep;
* ActionStep;
* FdaStep;
* worker requirements;
* Journey answers;
* StepResult;
* result containers;
* persistence of user responses;
* restart;
* providers;
* generic Step protocols;
* universal payload columns;
* metadata bags.

Every schema column and class member must be required by Tell or Ask now.

⸻

Deliverable

Create a planning response in the current iteration folder.

Include:

1. Recommended revised schema.
2. Recommended sealed Dart hierarchy.
3. Exact constraints.
4. Loading strategy.
5. Invalid-state handling.
6. Fixture revision.
7. Required tests.
8. Exact files likely to change.
9. Explicitly Not Included.
10. Smallest recommended coding task.

Do not implement code.

The key test is simple:
> Does the schema model shared facts once, subtype facts only where they belong, and let `Journey` remain blissfully ignorant?
```
