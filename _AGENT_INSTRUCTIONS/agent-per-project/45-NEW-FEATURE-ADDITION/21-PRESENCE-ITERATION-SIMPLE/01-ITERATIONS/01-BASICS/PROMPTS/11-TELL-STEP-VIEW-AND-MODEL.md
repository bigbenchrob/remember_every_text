Begin the next PRESENCE-ITERATION-SIMPLE experiment.
The purpose is to test one boundary only:
Can one Tell Step own its own presentation?
This is not a framework design task.
Do not add generic Step handling, Journey presentation architecture, providers, registries, factories, protocols, animation abstractions, or future Step types.
Create only:

- TellStepViewModel
- TellStepView
  The existing Step entity remains unchanged.
  TellStepViewModel should:
- receive one Step;
- expose only the text needed by the view.
  Its complete initial shape should be approximately:

````dart
class TellStepViewModel {
  const TellStepViewModel(this.step);
  final Step step;
  String get text => step.text;
}

TellStepView should:

* be a StatelessWidget;
* receive one TellStepViewModel;
* display viewModel.text;
* contain no JourneyProgress logic;
* contain no Next button;
* contain no Done logic;
* contain no animation yet.

Modify the current Journey progress page only enough to replace its direct Step-text rendering with TellStepView.

The page must continue to own:

* JourneyProgress;
* Next;
* Done;
* advancement;
* existing fade behaviour.

Do not move those responsibilities yet.

The expected visible behaviour must remain unchanged.

Add the smallest focused test proving:

* TellStepView displays the text supplied by TellStepViewModel;
* the existing Journey page still advances through Hello one, Hello two, Hello three, and Done.

After implementation, report:

1. Files created or modified.
2. The exact responsibility of TellStepViewModel.
3. The exact responsibility of TellStepView.
4. What deliberately remains owned by the page.
5. Whether this boundary improved comprehensibility.
6. Whether either new class contains anything not required by this experiment.
7. Whether the next experiment should move animation into the Tell pair or delete this boundary.

Do not broaden the task.

That is the beautifully simple beginning:
```text
Journey
    knows its Steps
JourneyProgress
    knows where we are
TellStepViewModel
    knows what this Tell says
TellStepView
    shows it

Nothing knows more than it needs.
````
