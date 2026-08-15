Begin Iteration 1D of PRESENCE-ITERATION-SIMPLE.

Read first:

- the three PRESENCE-ITERATION-SIMPLE root orientation documents;
- the completed Iteration 1A, 1B, and 1C implementations;
- JourneyProgressPage and its widget test;
- the latest iteration responses.

The controlling premise remains implementation-led redesign from first principles.

Do not consult the historical 43-PRESENCE package as authority.

This iteration adds one behaviour only:

The current Tell fades out, progress advances, and the next Tell fades in.

Do not add any new architecture unless that visible behaviour concretely requires it.

---

## Current working behaviour

The real debug application currently:

1. Loads Journey 42 from the in-memory store.
2. Displays Hello one.
3. Advances through Hello two and Hello three.
4. Displays Done.
5. Ignores further Next presses.

JourneyProgressPage owns one JourneyProgress instance in local State.

No provider has earned its existence.

---

## Goal

Change only the presentation of Next so that:

1. The current text fades out.
2. After fade-out completes, JourneyProgress.next() is called.
3. The page rebuilds with the next Step or Done.
4. The new text fades in.

The visible sequence remains:

Hello one
Hello two
Hello three
Done

Do not change Journey data, runtime progression, database loading, or repository behaviour.

---

## Preferred implementation

Use the smallest ordinary Flutter mechanism that makes the sequence understandable.

Prefer a single page-local animation mechanism over introducing an animation service, controller abstraction, provider, or reusable transition framework.

Evaluate the simplest options available in Flutter, such as:

- AnimatedOpacity with explicit phase handling;
- AnimatedSwitcher;
- one AnimationController owned by the State object.

Choose the implementation whose control flow is easiest to explain:

Next pressed
-> prevent another advance
-> fade current text out
-> advance JourneyProgress once
-> show new text
-> fade new text in
-> allow Next again

Do not choose an abstraction merely because it might later support more elaborate Presence transitions.

---

## Interaction during transition

Resolve one concrete question:

What happens if Next is pressed while a fade is already running?

Required behaviour:

- exactly one Step advance per completed transition;
- repeated presses during the transition must not skip Steps;
- the implementation must remain easy to understand.

Use the simplest explicit rule.

A likely rule is:

- disable or ignore Next while transitioning;
- re-enable it after fade-in completes.

Do not add event queues, debouncing utilities, cancellable commands, interaction occurrence objects, or coordination machinery.

---

## Completion state

Done participates in the same transition:

Hello three
-> fade out
-> JourneyProgress.next()
-> Done
-> fade in

After Done:

- further Next presses remain harmless;
- no additional transition occurs;
- no new completion object or state enum is introduced.

The button may be disabled or hidden when Done if that is the simplest presentation rule. State the choice explicitly.

Do not change JourneyProgress merely to support this UI decision.

---

## State

The page may add only the minimum presentation-local state required for fading.

Likely examples:

- one opacity or animation phase value;
- one boolean such as \_isTransitioning;
- one AnimationController if chosen.

Do not store duplicate Journey truth.

Do not add:

- current Step separately from JourneyProgress;
- a page-level Journey status;
- a Step completion record;
- a transition queue;
- a provider;
- a notifier;
- a stream.

Every new field must answer:

“What exact part of fade-out, advance, or fade-in fails without this?”

---

## Scope

Modify only the smallest set of presentation files and tests needed.

Expected primary files:

- journey_progress_page.dart
- journey_progress_page_test.dart

Do not modify:

- Journey;
- Step;
- JourneyProgress;
- JourneyRepository;
- DriftJourneyRepository;
- JourneyDefinitionStore;
- Journey 42 fixture;
- application bootstrap;

unless a concrete compilation issue makes a narrowly scoped change unavoidable.

---

## Presentation

Keep the appearance restrained.

Do not add:

- visual redesign;
- typography work;
- background treatments;
- Moments;
- progress indicators;
- timing controls;
- automatic advancement;
- sound;
- navigation;
- production onboarding copy.

Use one short, fixed transition duration suitable for a laboratory demonstration.

The exact duration is presentation detail, not domain state.

---

## Tests

Update the widget test to prove:

1. Hello one is initially visible.
2. Pressing Next begins a transition rather than immediately skipping multiple Steps.
3. After the transition settles, Hello two is visible.
4. The same process reaches Hello three.
5. The same process reaches Done.
6. Repeated taps during one transition do not skip a Step.
7. After Done, no further Step is shown.
8. Existing JourneyProgress behaviour remains unchanged.

Use controlled widget-test time advancement rather than real waiting.

Do not add database, provider, restart, or integration complexity to the widget test.

---

## Review questions

At completion, answer:

1. Which Flutter animation mechanism was chosen?
2. Why was it the simplest understandable option?
3. What page-local state was added?
4. How are repeated presses during transition handled?
5. When exactly does JourneyProgress.next() run?
6. How is Done presented?
7. Did the fade reveal a need for any new domain or application object?
8. Has a provider now earned its existence?

---

## Verification

Run:

- the updated widget test;
- all existing Presence tests;
- architecture tripwires;
- flutter analyze;
- a macOS debug build;
- formatting checks;
- git diff --check.

---

## Completion report

Report:

1. Every file created or modified.
2. The complete transition sequence.
3. The complete new page-local state.
4. The repeated-press rule.
5. Test and analyzer results.
6. Any new complexity discovered.
7. Confirmation that no provider, database change, domain change, or future Step behaviour was introduced.
