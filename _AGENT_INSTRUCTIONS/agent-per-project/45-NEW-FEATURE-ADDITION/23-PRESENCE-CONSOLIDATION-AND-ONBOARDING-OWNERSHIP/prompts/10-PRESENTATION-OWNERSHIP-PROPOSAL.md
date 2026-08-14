Yes. I’d make the next pass **ChoiceStep + ownership of rendering**, still design-first.

The critical distinction to preserve is:

```text id="hs8k6n"
workflow owner
    owns:
        what choices mean
        what labels say
        where they route

Presence
    owns:
        finite choice grammar
        selected destination result

workflow presentation
    owns:
        how those choices are rendered
```

And Presence should remain unable to answer:

> “Are these buttons?”

It should know only:

> “This ChoiceStep has these choices.”

Use this prompt:

Create:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md`

This is a **design-only pass**.

Do not implement `ChoiceStep` yet.

Do not change `presence.db`.

Do not change production onboarding.

Do not add `ActionStep`.

The goal is to design the smallest generic Presence contract for:

> Present a finite set of explicit user choices and route according to the choice selected.

The concrete workflow that has now earned this requirement is sparse Messages history:

```text
Re-check
    -> determine_messages_source_history_sufficiency

Import Anyway
    -> confirm_messages_source_history_accepted
```

---

## Governing ownership model

Use this as the starting point:

```text
Workflow owner
    owns:
        what choices exist
        what they mean
        user-facing labels
        destinations

Presence
    owns:
        generic ChoiceStep grammar
        finite choice definitions
        selected destination result
        persistence/reconstruction

Workflow presentation
    owns:
        buttons vs list vs menu vs other widgets
        spacing
        keyboard/focus behavior
        platform presentation
```

Presence must not know what a button is.

Onboarding must not hard-code Flutter widget geometry into persisted workflow definitions.

---

## Read first

Read:

- `10-NEXT-REAL-WORKFLOW-CONCERN-PLAN.md`
- `11-MESSAGES-SOURCE-HISTORY-SUFFICIENCY-TESTAGENT-IMPLEMENTATION.md`
- `09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md`
- current `step.dart`
- current Presence development host/presentation
- current `lib/essentials/onboarding/presentation/`
- current production sparse-history UI

Inspect actual code.

---

## 1. Prove ChoiceStep is earned

Document why existing Step types cannot faithfully express:

```text
Re-check
Import Anyway
```

without moving routing authority outside the Schedule.

Compare:

```text
FixedDestinationStep
TestStep
ChoiceStep
```

Use the mechanical question:

> Who determines the outgoing destination?

Expected conceptual distinction:

```text
FixedDestinationStep
    configuration decides

TestStep
    Agent result decides

ChoiceStep
    human selection decides
```

Do not broaden beyond this evidence.

---

## 2. Define the smallest ChoiceStep contract

Evaluate a generic runtime shape such as:

```text
ChoiceStep
    choices:
        Choice
            label
            destinationTripDefinitionId
```

Determine whether the Step should expose something conceptually like:

```dart
List<ChoiceDefinition> choices
Future<TripDefinitionId?> select(ChoiceId choiceId)
```

or another cleaner API.

Do not assume this exact shape.

The contract must support:

- at least two choices;
- potentially more than two without redesign;
- one selected destination;
- no hidden default choice;
- no arbitrary payload;
- no text entry;
- no form state;
- no Agent.

---

## 3. Choice identity

Decide whether each choice needs its own durable identity in addition to label and destination.

Evaluate:

### A. label + destination only

### B. opaque ChoiceId + label + destination

### C. another minimal design

Consider:

- duplicate labels;
- copy changes;
- trace/debugging;
- test stability;
- future localization;
- database integrity;
- renderer callbacks.

Prefer durable semantic identity if real evidence justifies it, but do not invent excessive structure.

---

## 4. Persistence grammar

Propose the smallest generic schema.

For example, assess something like:

```text
choice_step_definitions
    step_definition_id PK/FK

choice_step_options
    id / choice_id
    step_definition_id
    position
    label
    destination_trip_definition_id
```

or a simpler shape.

Questions:

1. Should choices be separate rows?
2. Does order belong in persistence?
3. Are labels persisted as workflow-owned copy?
4. Is destination required or nullable?
5. Can two choices route to the same Trip?
6. Must a ChoiceStep have at least two choices?
7. Should SQLite enforce uniqueness of choice identity/position?

Do not implement schema.

---

## 5. Runtime completion semantics

Determine exactly how a ChoiceStep becomes complete.

Expected model:

```text
render ChoiceStep
user selects one choice
ChoiceStep returns that configured TripDefinitionId
Trip completes
Scheduler checkpoints destination
```

Clarify:

- does ChoiceStep itself await a user selection?
- or does presentation call a completion method with a ChoiceId?
- who owns the pending interaction state?
- what happens if the process exits before selection?

Keep Trip-granular restart semantics intact if possible.

---

## 6. Restart semantics

Use the sparse-history Trip:

```text
Tell
Tell
ChoiceStep
```

User quits before choosing.

Expected:

```text
restart
-> Trip starts at Step 1
-> warning repeats
-> choices are presented again
```

No persisted selected choice should exist unless the choice has actually completed the Step and advanced the Trip.

Assess whether current Trip checkpoint semantics are sufficient.

Do not add current-Step persistence unless reality forces it.

---

## 7. Presentation ownership

This is a primary design question.

Determine the permanent boundary between generic Presence and workflow-specific presentation.

Provisional target:

```text
Presence
    exposes ChoiceStep data

Onboarding presentation
    decides how to render that ChoiceStep

Archive Ingestion presentation
    may render the same generic ChoiceStep differently
```

Assess whether Presence should contain **any Flutter renderer at all**.

Preferred direction:

```text
lib/essentials/presence/
    no workflow UI widgets

lib/essentials/onboarding/presentation/
    renders onboarding Steps
```

The current `presence_iteration_simple` renderer remains a development harness.

Document how production Onboarding could inspect the current Step and render:

```text
TellStep
TestStep
ChoiceStep
OpenFdaSettingsStep
```

without putting workflow semantics into Presence.

---

## 8. Renderer dispatch question

Determine how workflow presentation knows what Step it received.

Possible pattern:

```text
switch (step) {
    TellStep ...
    ChoiceStep ...
    ...
}
```

or visitor/polymorphic equivalent.

Do not introduce a generic renderer registry unless real complexity requires it.

Compare the simplest options.

The renderer may know Step **shape**, but should not own routing meaning.

---

## 9. Labels and presentation hints

For the first ChoiceStep, evaluate whether persisted generic data should contain only:

```text
label
destination
```

Do not add speculative fields such as:

```text
preferred
destructive
cancel
icon
buttonStyle
color
keyboardShortcut
```

unless the current sparse-history workflow genuinely needs them.

If “Import Anyway” eventually needs caution styling, decide whether that belongs:

- in workflow presentation based on choice identity;
- in generic persisted role metadata;
- or should remain deferred.

Prefer defer unless required.

---

## 10. Trace implications

Determine what execution trace should record when a choice is made.

At minimum, assess whether existing Step completion + route decision is sufficient.

Would it be useful/necessary to record an opaque ChoiceId?

Do not add user-choice analytics or payload logging.

Trace must remain observational, not authoritative.

---

## 11. Sparse-history walkthrough

Show exactly how the real workflow would be represented:

```text
determine_messages_source_history_sufficiency
    TestStep

false ->
guide_sparse_or_unsynced_messages_source
    Tell
    Tell
    ChoiceStep
        Re-check
            -> determine_messages_source_history_sufficiency

        Import Anyway
            -> confirm_messages_source_history_accepted
```

Explain what:

- Onboarding owns;
- Presence owns;
- presentation owns;
- Scheduler sees.

---

## 12. Future examples

Use only a few grounded hypothetical examples to test generality, such as:

```text
Archive Ingestion:
    Choose archive folder source A / source B

Recovery:
    Retry / Start Over / Cancel
```

Do not implement or over-design these workflows.

The point is only to see whether the narrow finite-choice grammar generalizes naturally.

---

## 13. Rejected alternatives

Explicitly evaluate and reject where appropriate:

- buttons outside the Step grammar directly changing Schedule state;
- encoding user choice as a fake TestAgent;
- one specialized `SparseHistoryChoiceStep`;
- `FixedDestinationStep` plus presentation-side routing;
- giant generic InteractionStep;
- arbitrary payload/result bags;
- ChoiceStep owning Flutter widgets.

---

## 14. ActionStep comparison

State explicitly whether this ChoiceStep evidence changes the case for generic ActionStep.

Expected answer unless evidence says otherwise:

```text
No.
```

`OpenFdaSettingsStep` remains a separate operation-shaped concern.

---

## Deliverable structure

Create:

`12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md`

with sections:

1. **Why ChoiceStep is now earned**
2. **Mechanical distinction among Step types**
3. **Smallest ChoiceStep contract**
4. **Choice identity**
5. **Persistence proposal**
6. **Runtime completion semantics**
7. **Restart semantics**
8. **Workflow-owned presentation boundary**
9. **Renderer dispatch**
10. **Presentation metadata policy**
11. **Trace implications**
12. **Sparse-history walkthrough**
13. **Future generality checks**
14. **Rejected alternatives**
15. **Relationship to ActionStep**
16. **Recommended implementation slices**
17. **Questions requiring human decision**

End with:

```text
What does Presence know?

What does ChoiceStep know?

What does Onboarding know?

Who decides whether choices are buttons, a list, or a menu?

Who determines the destination?

Does Presence know what "Import Anyway" means?
```

The final answer must be:

```text
No.
```

---

## Hard constraints

Do not:

- implement ChoiceStep;
- change schema;
- add ActionStep;
- add Agent supertype;
- add generic interaction framework;
- add text input/forms;
- add current-Step persistence;
- change production onboarding;
- extend the live Schedule;
- modify onboarding copy.

---

## Success criterion

We should finish with a narrow design for:

```text
finite persisted choices
+ human selection
-> one configured Trip destination
```

while preserving:

```text
workflow owner = meaning
Presence = execution grammar
presentation = UI rendering
```

Stop after the proposal and report back before implementation.
