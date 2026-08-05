````text
Begin the next PRESENCE-ITERATION-SIMPLE experiment.

The purpose is to discover how one Ask Step differs from the working Tell Step.

This is not a general Step-system design task.

Do not introduce a universal Step interface, generic result hierarchy, registry, factory, provider, persistence model, or historical Presence architecture.

Build only the smallest Ask experiment needed to answer:

How does an Ask Step collect one answer and report it upward?

--------------------------------------------------------------------
Current working boundary
--------------------------------------------------------------------

The current Tell component proves:

JourneyView
    gives one Step to TellStepView

TellStepView
    presents itself
    reports onFinished

JourneyView
    advances JourneyProgress

TellStepView knows nothing about:

- Journey;
- JourneyProgress;
- sibling Steps;
- what comes next;
- Done;
- repositories;
- Drift.

Preserve that style of ignorance for Ask.

--------------------------------------------------------------------
Ask experiment
--------------------------------------------------------------------

Create:

- AskStepViewModel
- AskStepView

The visible interaction should be:

What should I call you?

[ text field ]

[ Continue ]

No fade or animation yet.

No database-defined Ask Step yet.

No persistence of the answer.

No validation beyond rejecting an empty or whitespace-only response.

--------------------------------------------------------------------
AskStepViewModel
--------------------------------------------------------------------

The view model should receive only the information required for this experiment.

It must expose:

- the question text;
- the minimum answer-related behaviour genuinely needed by the view.

Do not add fields or methods for future validation, persistence, Journey state, Step selection, or other answer types.

Decide carefully whether the draft answer belongs in:

- AskStepView local State;
- AskStepViewModel;
- or a TextEditingController.

Choose the smallest understandable arrangement.

Explain the decision afterward.

Do not make the view model artificially substantial merely to justify its existence.

--------------------------------------------------------------------
AskStepView
--------------------------------------------------------------------

AskStepView should:

- display the question;
- accept one String answer;
- disable or reject Continue while the answer is blank;
- report one accepted answer upward;
- prevent duplicate submission.

Its public boundary should remain small, conceptually resembling:

```dart
AskStepView(
  viewModel: AskStepViewModel(...),
  onAnswered: ...,
)
````

Use the simplest callback that preserves the answer, likely:

```dart
ValueChanged<String> onAnswered
```

The callback means only:

> The user submitted this nonblank answer.

AskStepView must not:

- advance JourneyProgress;
- select the next Step;
- decide whether the Journey is Done;
- store the answer in a database;
- know sibling Steps;
- know Journey;
- know repositories;
- use providers.

---

## Temporary integration

Do not yet add Ask to the persisted Journey schema.

Do not add a Step type column.

Do not modify JourneyDefinitionStore, JourneyRepository, Journey, Step, or JourneyProgress unless a concrete contradiction makes that unavoidable.

Create the smallest laboratory surface needed to display one AskStepView and observe the returned String.

A simple temporary host or focused widget test is sufficient.

After submission, display the returned answer plainly so the real application or test proves that it crossed the boundary.

For example:

```text
What should I call you?
[ Rob ]
[ Continue ]

→

Answer received: Rob
```

This completion display is laboratory evidence only. It is not a Journey Step or final architecture.

Do not connect Ask into the existing three-Tell Journey yet.

---

## Folder placement

Use the existing mirrored presentation structure:

presentation/
├── view/
│ └── steps/
│ └── ask_step_view.dart
└── view_model/
└── steps/
└── ask_step_view_model.dart

Mirror it under test/.

Do not create base Step view or view-model classes.

---

## Tests

Add focused tests proving:

1. AskStepView displays its question.
2. Continue cannot submit an empty answer.
3. Whitespace-only input is rejected.
4. A nonblank String can be submitted.
5. The callback receives the submitted String.
6. Submission occurs exactly once.
7. AskStepView does not advance JourneyProgress.
8. No database, provider, repository, or persistence is required.

Use ordinary widget-test input.

Do not test animation.

---

## Questions this experiment must answer

After implementation, report:

1. What does AskStepViewModel know?
2. What does AskStepView know?
3. Where is draft text stored, and why?
4. What exactly does onAnswered mean?
5. How is duplicate submission prevented?
6. How does Ask differ from Tell?
7. What does Ask still share conceptually with Tell?
8. Did a common Step abstraction become necessary?
9. Did the answer need to be retained outside AskStepView?
10. What new question should the next iteration investigate?

---

## Scope discipline

Do not introduce:

- Step types;
- Tell or Ask domain subclasses;
- generic Step results;
- validation services;
- Journey answer storage;
- JourneyViewModel;
- providers;
- persistence;
- animation;
- Ask integration into JourneyProgress;
- factories;
- registries;
- historical Presence concepts.

This experiment is expected to be small and disposable.

Optimize for learning and human comprehensibility, not reuse.

---

## Verification

Run:

- AskStepView tests;
- all existing Presence tests;
- architecture tripwires;
- flutter analyze;
- formatting checks;
- git diff --check.

Do not broaden the task.

```

```
