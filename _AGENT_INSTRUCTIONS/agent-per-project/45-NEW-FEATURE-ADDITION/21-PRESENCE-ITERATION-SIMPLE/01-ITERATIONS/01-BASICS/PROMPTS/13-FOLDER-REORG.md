Perform a narrowly bounded presentation-folder organization and naming refactor for PRESENCE-ITERATION-SIMPLE.

Read first:

- the three PRESENCE-ITERATION-SIMPLE root orientation documents;
- SYSTEM-BOUNDARIES.md, if it now exists;
- the current presence_iteration_simple feature;
- representative Messages feature presentation folders;
- all current Presence client widget tests.

This is a structural refactor only.

Do not change visible behaviour.

Do not add new architecture.

Do not begin moving animation into TellStepView.

Do not add Ask, Wait, Step types, a Journey view model, providers, factories, registries, or generic Step selection.

---

## Current intended presentation organization

The feature presentation folder should use the established MessageLens-style role separation:

presentation/
├── view/
│ ├── journey_view.dart
│ └── steps/
│ └── tell_step_view.dart
└── view_model/
└── steps/
└── tell_step_view_model.dart

Do not create empty folders or placeholder files for:

- Ask;
- Wait;
- widgets;
- layout;
- JourneyViewModel;
- Step factories;
- future Step types.

Only currently existing concepts receive files.

---

## Rename the Journey surface

The current name:

JourneyProgressPage

is no longer appropriate.

It is not fundamentally a page about JourneyProgress.

It is the current drop-in presentation surface for one already-loaded Journey.

Rename:

journey_progress_page.dart
→ journey_view.dart

JourneyProgressPage
→ JourneyView

Rename the corresponding test:

journey_progress_page_test.dart
→ journey_view_test.dart

Update all imports, constructors, references, test descriptions, and host usage.

Do not leave compatibility aliases, forwarding files, deprecated names, or duplicate classes.

Git preserves the old name.

---

## Move the Tell pair

Ensure:

tell_step_view.dart

lives under:

presentation/view/steps/

Ensure:

tell_step_view_model.dart

lives under:

presentation/view_model/steps/

Update imports accordingly.

The pair must remain unchanged in responsibility:

TellStepViewModel

- receives one Step;
- exposes its text.

TellStepView

- receives one TellStepViewModel;
- displays its text.

Do not add animation, controls, completion reporting, Journey knowledge, or sibling-Step knowledge during this task.

---

## JourneyView responsibility

JourneyView currently receives one already-loaded Journey and owns the local running demonstration.

For this refactor, it continues to own exactly what the former JourneyProgressPage owned:

- JourneyProgress;
- current-Step selection;
- Next;
- Done;
- transition locking;
- fade-out, pause, and fade-in;
- rebuilding local StatefulWidget state.

Do not move these responsibilities yet.

Do not create JourneyViewModel yet.

Do not make JourneyView load its Journey.

Do not make JourneyView know about repositories, Drift, or the fixture.

Its constructor should remain conceptually:

JourneyView(
journey: loadedJourney,
)

---

## Host responsibility

PresenceIterationSimpleHost continues to:

- create the development-only in-memory store and repository;
- seed and load Journey 42;
- handle asynchronous loading;
- pass the loaded Journey into JourneyView.

Update it only for the renamed class and import path.

Do not move loading into JourneyView.

Do not add a provider.

---

## Tests

Move and rename tests to mirror the production paths.

Expected shape:

test/features/presence_iteration_simple/presentation/
├── view/
│ ├── journey_view_test.dart
│ └── steps/
│ └── tell_step_view_test.dart
