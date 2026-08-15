First stop: **pure ChoiceStep domain contract only** — no schema, no Scheduler, no Flutter. We make the Platonic object real before we connect it to anything.

Implement **ChoiceStep Slice 1 only** from:

`12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md`

This slice introduces the **pure generic Presence domain model** for finite human choice.

Do not change `presence.db`.

Do not change Scheduler or Trip runtime behavior.

Do not add presentation.

Do not extend the onboarding Schedule.

Do not implement sparse-history choices yet.

The governing definition is now settled:

> **ChoiceStep is the generic Presence Step for a decision made by the human user from a finite set of two or more options. Each option has a durable opaque value, a mutable human-facing label, and a persisted destination Trip. The route is selected by a human choosing one of the persisted option values.**

---

## 1. Implement `ChoiceValue`

Add a strongly typed generic Presence value representing the opaque result of one human selection.

Conceptually:

```text
ChoiceValue
    wraps one non-empty text value
```

Requirements:

- opaque to Presence;
- scoped semantically to its containing ChoiceStep;
- not globally registered;
- not parsed;
- not normalized into workflow meaning;
- stable independently of user-facing label copy;
- rejects empty or whitespace-only values if consistent with existing typed-value conventions;
- equality and hashing are value-based.

Examples:

```text
recheck
import_anyway
pause
continue
```

Presence must treat those strings as meaningless tokens.

Use `ChoiceValue`, not `ChoiceId`, unless current project conventions reveal a concrete problem with that name.

The proposal deliberately prefers `ChoiceValue` because this is the stable value emitted by human selection, not another globally meaningful Presence entity identity.

---

## 2. Implement `ChoiceOption`

Add the smallest immutable domain value representing one configured option:

```text
ChoiceOption
    value
    label
    destinationTripDefinitionId
```

Do **not** include presentation position inside `ChoiceOption` unless the existing domain conventions strongly favor it.

The ordered containing collection can provide ordering.

Requirements:

- `value: ChoiceValue`
- `label: String`
- `destinationTripDefinitionId: TripDefinitionId`
- immutable;
- label may change across workflow-definition revisions without changing the value;
- destination is required;
- Presence does not interpret label or value.

Do not add:

- icon;
- preferred/default;
- destructive;
- cancel;
- color;
- menu/button/radio hint;
- keyboard shortcut;
- arbitrary metadata.

The current proposal explicitly says none of those concepts has been earned.

---

## 3. Implement generic `ChoiceStep`

Add a generic Presence `ChoiceStep` conforming to the current `Step` model.

It should own:

```text
ordinary Step identity/name
ordered immutable ChoiceOptions
```

and expose a narrow lookup operation conceptually equivalent to:

```dart
TripDefinitionId destinationFor(ChoiceValue value)
```

The Step does **not** wait for UI input.

It does **not** contain callbacks, `Completer`, widget lifecycle, or pending state.

Its mechanical responsibility is only:

```text
human-selected ChoiceValue
    -> validate it belongs to this ChoiceStep
    -> return its configured TripDefinitionId
```

This matches the approved contract.

---

## 4. Minimum cardinality

A `ChoiceStep` requires at least **two** options.

One option is not a meaningful human choice; it is mechanically a fixed destination with unnecessary interaction.

Reject construction with:

```text
0 options
1 option
```

Use the smallest explicit domain error consistent with project conventions.

Do not add a general Step-validation framework.

---

## 5. Duplicate values

Choice values must be unique **within the ChoiceStep**.

Reject:

```text
[
    value = "review",
    value = "review"
]
```

even if labels or destinations differ.

The meaningful identity boundary is:

```text
containing ChoiceStep + ChoiceValue
```

Global uniqueness is not required.

---

## 6. Duplicate labels are allowed

Do **not** require labels to be unique.

This should be valid:

```text
value = "choice_a"
label = "Continue"

value = "choice_b"
label = "Continue"
```

Copy is not execution identity.

Do not let presentation copy become the lookup key.

---

## 7. Shared destinations are allowed

Do not prohibit:

```text
choice A -> Trip 15
choice B -> Trip 15
```

Presence should not judge workflow redundancy or semantic meaning.

The proposal explicitly allows distinct human intentions to share a destination.

---

## 8. Unknown selection failure

Calling:

```text
destinationFor(ChoiceValue("not-present"))
```

must fail explicitly.

Do not:

- return `null`;
- select the first option;
- choose a default;
- reinterpret the unknown value.

There is no hidden default in ChoiceStep.

The selected value must belong to the current Step's finite definition.

---

## 9. Ordering and immutability

The option order supplied at construction must be preserved.

The resulting collection must not be mutable by callers.

Prove defensive behavior if necessary:

```text
caller mutates original list
    -> ChoiceStep ordering/content remains unchanged
```

Do not introduce a collection abstraction unless existing project conventions make one useful.

---

## 10. Step result boundary

Do **not** make ChoiceStep itself asynchronously complete in this slice.

This is an important distinction from `TestStep`.

`TestStep` can call its Agent itself:

```text
evaluate()
    -> bool
    -> TripDefinitionId?
```

ChoiceStep requires an external human selection.

For Slice 1, implement only the pure mapping:

```text
ChoiceValue
    -> TripDefinitionId
```

The later runtime/Scheduler slice will decide when and how that selected destination becomes the terminal Trip result.

Do not retrofit generic input into `Step.complete()`.

Do not add arbitrary Step input/result APIs.

---

## 11. Terminal-Step rule

Document and test the architectural expectation that ChoiceStep is intended to be terminal in a Trip because its selected destination determines the next Trip.

Do not change Trip validation yet if that enforcement currently belongs to repository/Schedule reconstruction.

The domain object itself need only model the choice correctly.

A later persistence/runtime slice will enforce terminal placement.

---

## 12. Blank-stare invariants

The domain model should pass these conceptual tests:

Ask `ChoiceStep`:

> What does `"import_anyway"` mean?

Correct answer:

```text
I don't know.
```

Ask it:

> Where does `"import_anyway"` route in this Step?

It may answer:

```text
Trip X.
```

Ask it:

> Should those choices appear as buttons, radio controls, or a menu?

Correct answer:

```text
I don't know.
```

The Step understands geometry, not semantics or presentation.

---

## 13. Focused tests

Add focused domain tests proving at least:

### ChoiceValue

- preserves its exact opaque value;
- equality/hash behavior;
- distinct values remain distinct;
- empty/whitespace invalid if adopted.

### ChoiceOption

- preserves value;
- preserves mutable-copy label as supplied;
- preserves destination.

### ChoiceStep

- two choices construct successfully;
- three or more choices construct successfully;
- zero choices fail;
- one choice fails;
- order is preserved;
- choices are immutable/defensively copied;
- duplicate values fail;
- duplicate labels succeed;
- shared destinations succeed;
- known value resolves correct destination;
- unknown value fails explicitly;
- labels are not used for lookup.

Include an example where:

```text
value = "pause"
label = "That's good for now"
```

and another fixture where the label changes to:

```text
"Finish for now"
```

while the same value still maps to the same destination.

This proves the durable-value / mutable-label distinction.

---

## 14. Architecture protection

Add or extend architecture tripwires so these pure domain types do not depend on:

- Onboarding;
- Flutter;
- widgets/presentation;
- TestAgent;
- Conversation Graph;
- database infrastructure;
- Riverpod;
- archive ingestion.

ChoiceStep is generic Presence domain grammar only.

---

## 15. File organization

Place the new generic concepts under:

`lib/essentials/presence/`

Use the current domain organization naturally.

For example, assess whether:

```text
domain/entities/choice_value.dart
domain/entities/choice_option.dart
```

plus `ChoiceStep` in the existing Step domain file is cleanest.

Do not split `step.dart` merely because a new subtype exists if it remains coherent.

---

## 16. Documentation

Create:

`13-CHOICESTEP-PURE-DOMAIN-IMPLEMENTATION.md`

Record:

1. final `ChoiceValue` API;
2. final `ChoiceOption` API;
3. final `ChoiceStep` API;
4. minimum cardinality rule;
5. value uniqueness rule;
6. duplicate-label rule;
7. shared-destination rule;
8. unknown-selection failure;
9. ordering/immutability;
10. confirmation that ChoiceStep contains no UI or workflow semantics;
11. test results;
12. any deviation from Document 12.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

Do not rewrite the approved proposal.

---

## 17. Verification

Run:

- focused ChoiceStep domain tests;
- complete Presence tests;
- Onboarding tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`.

No code generation should be necessary.

No macOS build is required unless the changes unexpectedly affect app compilation.

---

## Hard constraints

Do not in Slice 1:

- change `presence.db`;
- add ChoiceStep tables;
- modify Scheduler;
- modify Trip routing;
- add selection callbacks;
- add presentation;
- add Flutter dependencies to Presence domain;
- extend the onboarding Schedule;
- add sparse-history UI;
- add ActionStep;
- add generic interaction input;
- add trace fields;
- modify production onboarding.

If any of those appears necessary, stop and explain why.

---

## Success criterion

At the end of this slice, the pure domain should be able to express:

```text
ChoiceStep

    value = "blue"
    label = "Blue"
    destination = Trip 12

    value = "pink"
    label = "Pink"
    destination = Trip 15

    value = "purple"
    label = "Purple"
    destination = Trip 19
```

and answer:

```text
destinationFor("pink")
    -> Trip 15
```

while remaining completely unable to explain:

```text
what pink means
why Trip 15 is correct
how the choices should look on screen
```

Stop after the pure domain slice and report back before persistence work begins.
