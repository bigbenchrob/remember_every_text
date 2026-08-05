Implement Iteration 1B exactly as planned in:

07-TEST-STEP-PROGRESSION-RESPONSE.md

Read first:

- the three PRESENCE-ITERATION-SIMPLE root orientation documents;
- the completed Iteration 1A implementation;
- Journey, Step, JourneyRepository, JourneyDefinitionStore, and their tests;
- 07-TEST-STEP-PROGRESSION-RESPONSE.md.

This remains implementation-led redesign from first principles.

Do not consult the historical 43-PRESENCE package as authority.

---

## Goal

Add the smallest pure-Dart object that tracks in-memory progress through one already-loaded Journey.

The required behaviour is:

new JourneyProgress
current Step = Hello one

next()
current Step = Hello two

next()
current Step = Hello three

next()
current Step = null
isDone = true

next() again
remains Done

No database changes, application integration, Flutter, Riverpod, or presentation belong in this task.

---

## Create only

lib/essentials/presence/domain/entities/journey_progress.dart

test/essentials/presence/domain/entities/journey_progress_test.dart

Do not create any additional production files.

---

## JourneyProgress

Implement:

```dart
class JourneyProgress {
  JourneyProgress(Journey journey);

  Journey get journey;
  Step? get currentStep;
  bool get isDone;
  void next();
}
```
