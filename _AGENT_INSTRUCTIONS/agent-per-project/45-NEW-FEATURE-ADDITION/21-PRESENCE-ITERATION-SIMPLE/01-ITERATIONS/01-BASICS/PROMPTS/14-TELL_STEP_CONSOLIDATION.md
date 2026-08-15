This next experiment should answer one question only:

Can a Tell Step own its complete local presentation lifecycle and report only “finished” to the Journey?

The cleanest trial is:

JourneyView
selects current Step
gives it to TellStepView
receives onFinished
advances JourneyProgress
TellStepView
fades in
displays its own Next button
fades out
pauses
reports finished

Use this prompt:

Begin the next PRESENCE-ITERATION-SIMPLE experiment.
Read first:

- the three iteration root orientation documents;
- SYSTEM-BOUNDARIES.md, if present;
- the completed Journey/Step/Progress implementation;
- JourneyView;
- TellStepView;
- TellStepViewModel;
- their current tests.
  This remains implementation-led redesign from first principles.
  Do not consult the historical 43-PRESENCE package as authority.

---

## Question being tested

Can one Tell Step component own its entire local presentation lifecycle while knowing nothing about Journey progression?
This experiment should move only Tell-specific presentation responsibility out of JourneyView.
It must not design a general Step framework.

---

## Desired responsibility boundary

JourneyView owns:

- one JourneyProgress;
- selecting the current Step;
- advancing JourneyProgress after the current Step reports finished;
- deciding when no Steps remain;
- displaying the final Done state.
  TellStepViewModel owns:
- one Step;
- the Tell text exposed to its view.
  TellStepView owns:
- displaying the Tell text;
- fading the Tell in;
- presenting its own Next control;
- preventing repeated activation during transition;
- fading the Tell out;
- holding the transparent pause;
- reporting completion through one callback.
  TellStepView must know nothing about:
- Journey;
- JourneyProgress;
- sibling Steps;
- which Step follows;
- whether this is the first or last Step;
- Done;
- repositories;
- Drift;
- providers.

---

## TellStepView public boundary

The intended public shape should remain very small:

````dart
TellStepView(
  key: ...,
  viewModel: TellStepViewModel(step),
  onFinished: ...,
)

Use one callback:

VoidCallback onFinished

The callback means only:

This Tell has completed its local presentation lifecycle.

It does not mean:

* advance to a particular Step;
* mark the Journey Done;
* perform database work;
* choose what appears next.

JourneyView decides what follows.

Do not introduce a result object, status enum, event class, completion protocol, or generic callback type.

⸻

Tell lifecycle

A newly mounted TellStepView should:

1. begin transparent;
2. fade its text and control in over 1 second;
3. remain visible and interactive.

When Next is pressed:

1. disable or ignore further presses;
2. fade the Tell out over 1 second;
3. remain fully transparent for 500 milliseconds;
4. invoke onFinished exactly once.

TellStepView does not fade the next Step in.

The next Step is a new TellStepView instance. It performs its own opening fade-in when JourneyView rebuilds after advancement.

This gives the user-experienced segments:

first Tell:
    fade in
middle transition:
    current Tell fades out
    pause
    next Tell mounts and fades in
last Tell:
    fades out
    pause
    JourneyView advances to Done

⸻

JourneyView

Remove from JourneyView:

* AnimatedOpacity;
* fade duration;
* pause duration;
* opacity state;
* transition-lock state;
* Next button;
* Tell fade callbacks.

JourneyView should become conceptually close to:

final currentStep = _progress.currentStep;
if (currentStep == null) {
  return const Text('Done');
}
return TellStepView(
  key: ValueKey(currentStep.id),
  viewModel: TellStepViewModel(currentStep),
  onFinished: _advance,
);

The exact surrounding layout may continue to display the Journey name.

Its advancement method should do only the minimum required:

void _advance() {
  setState(_progress.next);
}

Use a stable Step-specific key if required to ensure that advancing creates a fresh TellStepView state and therefore runs the next Tell’s fade-in.

Do not add a JourneyViewModel yet.

⸻

TellStepView implementation

TellStepView may become a StatefulWidget because it now owns local presentation state.

Add only the state required by the current behaviour.

Likely state:

* opacity;
* whether transition is active.

Do not store:

* current Step separately from the view model;
* Journey state;
* current index;
* Done;
* sibling information;
* presentation segment objects;
* phase enums unless implementation proves they are indispensable.

Prefer ordinary AnimatedOpacity and a small understandable transition method.

Use mounted checks where an awaited delay crosses widget lifetime.

Do not introduce:

* AnimationController unless AnimatedOpacity proves insufficient;
* providers;
* ChangeNotifier;
* ValueNotifier;
* streams;
* queues;
* services;
* reusable animation infrastructure.

⸻

TellStepViewModel

Keep TellStepViewModel comically thin:

class TellStepViewModel {
  const TellStepViewModel(this.step);
  final Step step;
  String get text => step.text;
}

Do not move animation state or Flutter concerns into it.

Do not add methods merely to make the view model appear more substantial.

This experiment tests the boundary, not the amount of logic in the class.

⸻

Done presentation

After the final Tell reports finished:

* JourneyView advances JourneyProgress;
* currentStep becomes null;
* JourneyView displays Done.

Do not make TellStepView know it was the final Step.

Do not introduce a special final Tell or completion Step.

Done may appear plainly in this experiment. Do not add a separate Done animation unless it is unavoidable for preserving current behaviour.

⸻

Tests

Update or add focused tests at the existing mirrored presentation paths.

TellStepView tests must prove:

1. It initially mounts transparent and fades in over 1 second.
2. It displays the text from TellStepViewModel.
3. It owns its own Next control.
4. Pressing Next begins fade-out.
5. Repeated presses during fade-out and pause do not cause duplicate completion.
6. onFinished has not fired at the end of fade-out.
7. onFinished fires exactly once after the 500 ms transparent pause.
8. It knows nothing about JourneyProgress or sibling Steps.

JourneyView tests must prove:

1. Hello one appears through TellStepView.
2. Completing it advances to Hello two.
3. The new TellStepView fades itself in.
4. The sequence reaches Hello three.
5. Completing the final Tell causes JourneyView to display Done.
6. JourneyView no longer owns or directly renders a Next button.
7. Existing database and JourneyProgress behaviour remains unchanged.

Use controlled pump durations:

* 1 second fade;
* 500 millisecond pause;
* any final frame required for callback-driven rebuilding.

Do not use real waiting.

⸻

Scope discipline

Do not introduce:

* Ask;
* Wait;
* Step type;
* Tell subtype in the domain;
* generic Step view interface;
* base Step view model;
* Step factory or registry;
* JourneyViewModel;
* provider;
* persistence;
* Journey loading inside JourneyView;
* animation services;
* segment classes;
* historical Presence terminology.

Do not modify:

* JourneyDefinitionStore;
* repositories;
* Journey;
* Step;
* JourneyProgress;
* fixture;
* host loading;

unless a concrete compilation contradiction requires a narrowly scoped correction.

⸻

Review questions

After implementation, report:

1. What responsibility moved from JourneyView to TellStepView?
2. What responsibility remained in JourneyView?
3. What does onFinished mean—and what does it explicitly not mean?
4. What local state does TellStepView now own?
5. Does TellStepView know anything about sibling Steps or Journey progression?
6. Did a generic Step abstraction become necessary?
7. Did a provider become necessary?
8. Is the resulting JourneyView easier to understand?
9. Should this boundary be retained, revised, or discarded before Ask is introduced?

⸻

Verification

Run:

* TellStepView tests;
* JourneyView tests;
* all Presence tests;
* architecture tripwires;
* flutter analyze;
* macOS debug build;
* formatting checks;
* git diff –check.

Do not broaden the task.

The hoped-for result is beautifully small:
```text
JourneyView:
    “Here is the current Step. Tell me when it is finished.”
TellStepView:
    “I will present this Tell. I’m finished.”

Neither needs to understand how the other performs its job.
````
