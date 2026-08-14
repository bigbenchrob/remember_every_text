---
tier: project
scope: presence-choice-step-domain
owner: agent-per-project
last_reviewed: 2026-08-13
source_of_truth: implementation
links:
  - 12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md
  - 14-CHOICESTEP-ADDITIVE-PERSISTENCE-IMPLEMENTATION.md
  - 00-START-HERE.md
tests:
  - test/essentials/presence/domain/entities/choice_value_test.dart
  - test/essentials/presence/domain/entities/choice_option_test.dart
  - test/essentials/presence/domain/entities/choice_step_test.dart
  - test/architecture/forbidden_imports_test.dart
---

# ChoiceStep Pure Domain Implementation

## Scope

This is Slice 1 of the approved `ChoiceStep` proposal. It makes the finite
human-choice grammar real as pure Presence domain code. It does not add
persistence, Scheduler input, Trip routing, presentation, or Onboarding
workflow usage.

## Final Domain API

### ChoiceValue

```dart
ChoiceValue(String value)

String value
```

`ChoiceValue` preserves its supplied text exactly and treats it as opaque. It
rejects empty and whitespace-only text and provides value-based equality and
hashing. It is not registered globally and acquires meaning only within the
containing `ChoiceStep` definition.

### ChoiceOption

```dart
const ChoiceOption({
  required ChoiceValue value,
  required String label,
  required TripDefinitionId destinationTripDefinitionId,
})
```

`ChoiceOption` is an immutable value containing only the durable choice value,
mutable-across-definition-revisions display copy, and required destination.
It contains no presentation hints or workflow semantics.

### ChoiceStep

```dart
ChoiceStep({
  required int id,
  required String name,
  required List<ChoiceOption> options,
})

List<ChoiceOption> options

TripDefinitionId destinationFor(ChoiceValue value)
```

The supplied option order is preserved in an unmodifiable defensive copy.
`destinationFor` recognizes only configured opaque values and returns the
corresponding configured Trip identity.

The existing `Step` base type requires a `complete()` member. `ChoiceStep`
therefore supplies a synchronous fail-fast override rather than pretending it
can obtain human input autonomously. Runtime choice submission remains a later
slice.

## Enforced Rules

- A `ChoiceStep` requires at least two options. Zero and one are rejected with
  `ArgumentError`.
- `ChoiceValue` instances must be unique within one `ChoiceStep`.
- Labels need not be unique because presentation copy is not execution
  identity.
- Multiple choices may share one destination.
- An unknown selected value fails explicitly with `ArgumentError`; there is no
  default, fallback, or null result.
- Labels are never used for destination lookup.
- Changing `"That's good for now"` to `"Finish for now"` does not change the
  durable `pause` value or its destination.
- `ChoiceStep` is intended to be terminal in its Trip because its selected
  destination is the next-Trip result. Terminal placement is not enforced by
  the domain object in this slice.

## Architectural Boundary

`ChoiceValue`, `ChoiceOption`, and the `ChoiceStep` implementation contain no
Flutter, Riverpod, Onboarding, Conversation Graph, archive-ingestion,
database, `TestAgent`, callback, pending-state, or presentation dependency.

The model can answer where `pink` routes in one configured Step. It cannot
explain what pink means, why its destination is correct, or how choices should
appear on screen.

Because `Step` is sealed, existing exhaustive persistence and development
topology switches initially required explicit fail-closed `ChoiceStep` cases.
The persistence case gained bounded support in
[Slice 2](14-CHOICESTEP-ADDITIVE-PERSISTENCE-IMPLEMENTATION.md); the development
topology projector and runtime consumers remain fail-closed. This does not
change the pure-domain boundary established here.

## Verification

- 19 focused `ChoiceValue`, `ChoiceOption`, and `ChoiceStep` tests passed.
- 94 complete Presence and Presence development-harness tests passed.
- 82 complete Onboarding tests passed.
- All 363 architecture tripwires passed, including the new positive
  Choice-domain dependency boundary.
- `flutter analyze` completed with no issues.
- Formatting and `git diff --check` completed cleanly.
- No code generation or macOS build was required.

## Deviations From Document 12

There was no semantic deviation from the approved proposal. The two explicit
fail-closed exhaustive-switch cases and the synchronous `complete()` failure
are compatibility consequences of introducing a subtype into the current
sealed `Step` hierarchy before persistence and runtime support exist. They add
no Choice behavior beyond the approved pure value-to-destination mapping.
