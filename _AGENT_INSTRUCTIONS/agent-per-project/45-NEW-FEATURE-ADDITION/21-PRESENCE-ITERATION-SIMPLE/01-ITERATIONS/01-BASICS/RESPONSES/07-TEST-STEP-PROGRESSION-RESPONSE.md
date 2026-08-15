# Iteration 1B: In-Memory Step Progression

## Scope

This response plans only in-memory progress through one already-loaded
`Journey`.

Iteration 1A remains responsible for defining and loading a `Journey` and its
ordered `Step` list. Iteration 1B adds no persistence, presentation, framework,
or interaction machinery.

## Recommendation

Create one small mutable object named `JourneyProgress`.

Its single responsibility is to answer:

> Where am I in this Journey?

The existing objects retain their current responsibilities:

- `Journey`: What Steps belong to this Journey?
- `Step`: What statement does this Step contain?
- `JourneyProgress`: Which Step is current, or is progress Done?

`JourneyProgress` is preferable to the alternatives considered:

- Mutable progress inside `Journey` would mix the persisted definition with
  one in-memory traversal of that definition. The same loaded definition could
  no longer be treated independently from its current use.
- `JourneyRun` suggests an identified runtime occurrence and lifecycle that do
  not exist in this iteration.
- `JourneyController` suggests application orchestration or framework-facing
  control. This object coordinates nothing beyond one integer.
- `JourneyPlayer` suggests presentation or timed playback.

`JourneyProgress` describes exactly the state introduced in this iteration
without implying those later concepts.

## Single Responsibility And State

The complete state is:

```dart
final Journey journey;
int _currentIndex = 0;
```

`journey` provides access to the loaded definition. `_currentIndex` is the only
runtime state.

Do not store:

- the current `Step` separately;
- an `isDone` flag;
- a status enum.

All three would duplicate truth already derivable from the ordered Step list
and `_currentIndex`.

## Public Contract

The exact public surface should be:

```dart
JourneyProgress(Journey journey)

Journey get journey
Step? get currentStep
bool get isDone
void next()
```

The constructor starts at index zero. `currentStep` returns the Step at the
current index while progress is active and returns `null` when Done. `isDone`
is derived by comparing `_currentIndex` with `journey.steps.length`.

`next()` is deliberately synchronous and mutable. Advancing one integer is the
entire behavior. Rebuilding immutable progress values, adding `copyWith`, or
introducing an event reducer would make this iteration harder to explain
without adding capability.

## Boundary Behavior

### Three-Step Journey

For Journey 42:

```text
new JourneyProgress
    currentStep = Hello one
    isDone = false

next()
    currentStep = Hello two
    isDone = false

next()
    currentStep = Hello three
    isDone = false

next()
    currentStep = null
    isDone = true
```

The index after the final advance equals the Step count. No additional Done
state is stored.

### Next After Done

Calling `next()` after Done is a no-op.

This is the simplest explicit rule. It keeps the object Done, avoids an
exception for an operation that cannot corrupt state, and requires no extra
terminal-state mechanism. The behavior must be tested rather than left
implicit.

### Empty Journey

An empty Journey starts Done:

```text
currentStep = null
isDone = true
```

Calling `next()` remains a no-op. The empty list requires no special stored
state because index zero already equals the Step count.

## Why Progress Does Not Belong In Journey

`Journey` is the definition loaded from the repository. Its id, name, and
ordered Steps describe what the Journey contains.

The current index describes one use of that definition in memory. Putting the
index inside `Journey` would give one object two responsibilities and would
couple repository-loaded definition data to transient progress. Keeping them
separate also permits tests to prove that traversal does not alter the loaded
Journey or its Step list.

This separation does not establish a future runtime architecture. It is only
the smallest way to preserve the responsibility already established by
Iteration 1A while adding the behavior required by Iteration 1B.

## DDD Placement

Create:

```text
lib/essentials/presence/domain/entities/journey_progress.dart
```

The object belongs beside `Journey` and `Step` because it is framework-free
domain state. It is stateful and therefore does not fit a stateless domain
service. It performs no application orchestration, so placing it under
`application/` would overstate its role.

It must import only the Presence domain entities. It must not depend on Drift,
`JourneyRepository`, Flutter, Riverpod, or any MessageLens feature.

## Required Tests

Create one pure-Dart-focused test at:

```text
test/essentials/presence/domain/entities/journey_progress_test.dart
```

Use directly constructed `Journey` and `Step` entities. Do not load a database
fixture merely to test one integer.

The tests must prove:

1. New progress over the three-Step Journey starts on `Hello one`.
2. The first `next()` advances to `Hello two`.
3. The second `next()` advances to `Hello three`.
4. The third `next()` makes progress Done.
5. `currentStep` is `null` when Done.
6. Further calls to `next()` are no-ops and remain Done.
7. Progress over an empty Journey starts Done and remains Done after `next()`.
8. Advancing does not replace, reorder, remove, or modify the Journey's Steps.
9. The test needs no database, Flutter widget, Riverpod container, UI, or
   persistence setup.

The existing Iteration 1A repository and relational-integrity tests remain
unchanged.

## Explicitly Not Included

Iteration 1B does not include:

- a Flutter page;
- fade transitions;
- a Next button;
- automatic timing;
- persisted current Step;
- restart behavior;
- a Journey-run database table;
- Ask;
- Wait;
- Step types;
- actions;
- completion criteria;
- a Coordinator;
- a Renderer;
- historical Presence entities;
- providers;
- streams;
- callbacks;
- response history;
- completion records.

## Smallest Recommended Coding Task

The complete coding task should create only:

```text
lib/essentials/presence/domain/entities/journey_progress.dart
test/essentials/presence/domain/entities/journey_progress_test.dart
```

Implement `JourneyProgress` with one private integer and the four-member public
contract described above. Add the focused pure-Dart tests, run the existing
Iteration 1A tests, analyzer, architecture tripwires, formatting, and
`git diff --check`.

Do not modify the database schema, repository, `Journey`, or `Step` unless the
coding task exposes a concrete contradiction that cannot be resolved within
this two-file scope.
