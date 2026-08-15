Begin Iteration 1C.

Read first:

- the three PRESENCE-ITERATION-SIMPLE root orientation documents;
- the completed Iteration 1A and 1B implementations;
- the latest iteration planning documents.

This iteration has one purpose:

Display the three-step Journey inside the real Flutter application.

Nothing more.

---

## Controlling principle

Use the Flutter counter application as the model.

Choose the simplest implementation that demonstrates the behaviour.

Do not introduce Riverpod merely because the rest of the application uses it.

Do not introduce providers until the current iteration demonstrates that they are actually required.

The page itself may temporarily own mutable state.

This is a deliberate laboratory decision.

---

## Required behaviour

The application should:

1. Load Journey 42 from JourneyRepository.
2. Construct one JourneyProgress.
3. Display the current Step's text.
4. Display one button labelled:

Next

5. Pressing Next advances JourneyProgress.
6. After the third Step, display:

Done

or another equally simple completion message.

Nothing else.

---

## Ownership

For this iteration:

The page owns JourneyProgress.

Use:

StatefulWidget

and

initState()

Store:

late JourneyProgress \_progress;

When the button is pressed:

\_progress.next();

followed by:

setState(() {});

The goal is simply to preserve the JourneyProgress instance across widget rebuilds.

Do not introduce:

- Riverpod
- ChangeNotifier
- ValueNotifier
- Streams
- StateNotifier
- providers
- callbacks
- observers

unless the current iteration cannot function without them.

---

## Presentation

Keep the page almost as simple as Flutter's counter example.

Show:

Journey title

Current Step text

Next button

When Done:

replace the Step text with a simple completion message.

Do not add:

- fade animations
- transitions
- styling
- Moments
- Ask
- Wait
- progress bars
- layout experiments
- navigation
- dialogs

---

## Database

Use the existing JourneyRepository.

Do not modify:

- schema
- entities
- JourneyProgress
- repository interface

unless a concrete contradiction appears.

---

## Development seed

Move the Journey 42 fixture from test ownership into the smallest development-only application integration needed for this iteration.

The repository should still load Journey 42 exactly as it would load any Journey.

Do not create production startup behaviour.

Do not introduce persistence beyond the existing in-memory executor.

---

## Tests

Retain all existing tests.

Add only the smallest widget test proving:

- Hello one appears first.
- Tapping Next displays Hello two.
- Tapping Next displays Hello three.
- Tapping Next displays Done.

Nothing else.

---

## Scope discipline

Do not implement:

- Riverpod providers
- restart persistence
- current Step persistence
- Ask
- Wait
- Step types
- animation
- fade
- timing
- Coordinator
- Renderer
- historical Presence concepts

If a provider seems useful, document why, but do not introduce it unless the page cannot function correctly without it.

---

## Completion report

Report:

1. Every file created or modified.
2. Where JourneyProgress is owned.
3. Why StatefulWidget was sufficient.
4. Every place where a provider was consciously avoided.
5. The complete user interaction from launch through Done.
6. Any new complexity discovered.
7. Whether the next iteration has now earned a provider.
