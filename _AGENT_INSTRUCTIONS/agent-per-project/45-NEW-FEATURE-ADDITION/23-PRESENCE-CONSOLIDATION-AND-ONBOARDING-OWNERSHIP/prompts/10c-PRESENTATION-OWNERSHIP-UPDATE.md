The new question is bigger than ChoiceStep:

> **Can Presence own generic presentation for generic Step shapes, so workflow owners like Onboarding do not participate in runtime presentation unless a truly domain-specific Step requires them?**

That is worth updating before implementation.

Update:

`12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md`

before any implementation begins.

We have refined the presentation boundary again.

The earlier proposal assumed that workflow-specific presentation such as Onboarding would render generic `ChoiceStep` data.

We now think that assumption may be unnecessarily complicated.

Re-evaluate whether **generic Presence itself should own presentation for generic Step shapes**.

This is still a design-only change.

Do not implement code or schema.

---

## Revised conjecture

If `presence.db` already contains a complete generic Step definition, including its user-facing copy and routing geometry, then a workflow owner should not need to participate in runtime presentation merely because that Step belongs to its workflow.

For example:

```text
ChoiceStep

label = "Re-check"
value = "recheck"
destination = Trip X

label = "Import Anyway"
value = "import_anyway"
destination = Trip Y
```

Presence already has everything required to present and execute this interaction generically.

It does not need to understand what either label or value means.

---

## Generic Presence presentation

Evaluate a permanent architecture like:

```text
lib/essentials/presence/
    domain/
    application/
    infrastructure/
    presentation/
```

where Presence presentation understands only generic Step shapes.

For example:

```text
TellStep
    -> show persisted text
    -> provide ordinary Continue/Next affordance

ChoiceStep
    -> show persisted labels
    -> return selected opaque value

TestStep
    -> execute its bound TestAgent
    -> render only whatever generic testing/progress behavior is actually required

FixedDestinationStep
    -> generic progression behavior

OpenFdaSettingsStep
    -> still exceptional/domain-specific transitional debt
```

The key invariant is:

> Generic Presence presentation may understand Step mechanics and persisted presentation data. It must not understand workflow meaning.

---

## Reassess the workflow-owner presentation rule

The previous proposal said:

```text
Workflow presentation
    owns buttons vs list vs menu
```

Reconsider that.

For a plain finite label:value choice, there may be no workflow-specific presentation problem at all.

Presence can own a standard generic representation.

For example:

```text
few choices
    -> ordinary finite-choice controls

many choices
    -> generic list/menu presentation
```

Do not over-design exact thresholds or widgets in this proposal.

The architectural question is whether generic presentation mechanics belong to Presence.

---

## New ownership model to evaluate

Consider:

```text
Workflow owner
    authors:
        Schedule meaning
        persisted copy
        choice labels
        opaque values
        destinations
        TestAgent identities/bindings

Presence
    owns:
        Schedule execution
        Step reconstruction
        generic Step presentation
        generic user interaction
        routing
        checkpointing

Specialists
    own:
        domain-specific factual/operational expertise
```

Under this model, Onboarding is not called merely because a current Step belongs to the onboarding Schedule.

---

## ChoiceStep runtime example

Persisted definition:

```text
ChoiceStep

label: "That's good for now"
value: "pause"
destination: Trip 15

label: "Keep going"
value: "continue"
destination: Trip 22
```

Presence presentation receives the generic ChoiceStep and shows:

```text
That's good for now
Keep going
```

The user selects the first item.

Presence receives only:

```text
pause
```

The current ChoiceStep resolves:

```text
pause -> Trip 15
```

Then ordinary Trip/Scheduler routing continues.

Onboarding is not consulted.

---

## Label:value menu definition

Retain the refined model:

```text
ChoiceOption
    value
    label
    position
    destinationTripDefinitionId
```

Presence presentation exposes only:

```text
label
value
```

The destination remains execution data.

The workflow owner may change:

```text
"That's good for now"
```

to:

```text
"Pause here"
```

without changing:

```text
value = "pause"
```

or the routing geometry.

---

## Important distinction

Presence rendering a label does **not** mean Presence understands it.

This is analogous to `TellStep`.

Presence can display:

```text
"MessageLens needs access to..."
```

without knowing what the sentence means.

Likewise, Presence can display:

```text
"Import Anyway"
```

without understanding imports.

Persisted copy is data, not domain expertise.

---

## Generic runner / presenter question

Assess whether the now-emerging concept is a generic Presence runner/presenter which:

```text
loads current Step
renders according to generic Step shape
accepts the narrow interaction permitted by that Step
returns control to Presence execution
```

Do not build a generic renderer registry or framework yet.

Evaluate the smallest direct implementation shape.

A simple exhaustive Step-type switch may still be the correct first architecture.

---

## Where workflow-specific presentation is still justified

Do not claim that all future Step presentation belongs in Presence.

Instead define the boundary:

> Generic Step shapes with generic persisted presentation data may be rendered by Presence.

> A Step requiring genuinely domain-specific UI may remain owned/rendered by the workflow or specialist that understands it.

Identify `OpenFdaSettingsStep` as the current obvious unresolved example.

It may eventually become a generic operation shape, but that decision remains deferred.

---

## Re-evaluate renderer dispatch

The current proposal suggests an Onboarding-specific switch over:

```text
TellStep
TestStep
ChoiceStep
OpenFdaSettingsStep
FixedDestinationStep
```

Reconsider whether the generic cases instead belong in Presence presentation.

For example:

```text
PresenceStepPresenter

TellStep
    -> generic Tell presentation

ChoiceStep
    -> generic Choice presentation

TestStep
    -> generic Test execution/presentation as appropriate

FixedDestinationStep
    -> generic non-choice progression

otherwise
    -> domain-specific presentation boundary
```

Do not settle exact class names prematurely.

---

## Re-evaluate current development harness

The current `presence_iteration_simple` host already renders generic Step mechanics for development.

Assess whether it contains useful evidence for the eventual generic Presence presenter.

Do not simply graduate the whole harness.

Separate:

```text
generic Step presentation mechanics
```

from:

```text
development-only trace
Mermaid
live map
source substitution
Run Again controls
diagnostics
```

The latter remain development harness concerns.

---

## Blank-stare tests

Add these conceptual invariants to the proposal:

Ask Onboarding:

> Which Trip does `pause` route to?

Correct answer:

```text
I don't know.
```

Ask Onboarding:

> How should a generic ChoiceStep render three ordinary labels?

Possible correct answer:

```text
Why are you asking me? Presence knows how to present a generic ChoiceStep.
```

Ask Presence:

> What does `pause` mean?

Correct answer:

```text
I don't know.
```

Ask Presence:

> What does the current ChoiceStep say `pause` routes to?

Presence may answer:

```text
Trip 15.
```

That is geometry, not semantics.

---

## Revise the ownership statement

Update the proposal from:

```text
workflow owner = meaning
Presence = execution grammar
workflow presentation = UI rendering
```

to assess whether the cleaner permanent rule is:

```text
workflow owner = meaning and authored definition data
Presence = execution grammar + generic Step presentation
specialist/workflow-specific UI = only when generic Step grammar is insufficient
```

Do not adopt this merely because it is simpler. Test it against the current implemented Step types.

---

## ChoiceStep remains narrow

Do not let this amendment broaden `ChoiceStep`.

It still means only:

```text
finite persisted label:value choices
human selects one value
ChoiceStep maps value to configured destination
```

No:

- forms;
- text entry;
- arbitrary payloads;
- generic interaction bags;
- ActionStep;
- renderer registry;
- persisted presentation styles.

---

## Required proposal updates

Revise the affected sections of Document 12:

- Smallest ChoiceStep contract
- Runtime completion semantics
- Workflow/presentation ownership
- Renderer dispatch
- Presentation metadata policy
- Sparse-history walkthrough
- Rejected alternatives
- Recommended implementation slices
- Questions requiring human decision
- Final ownership test

Add a short section:

`Generic Presence Presentation Conjecture`

that compares:

1. workflow-owned rendering of generic Steps;
2. Presence-owned rendering of generic Steps;
3. hybrid/domain-specific escape hatch.

Recommend one based on the actual current evidence.

---

## Important implementation consequence

Do not begin ChoiceStep implementation until this presentation ownership question is settled.

If Presence owns generic ChoiceStep presentation, the implementation sequence may need to distinguish:

```text
ChoiceStep domain
ChoiceStep persistence/runtime
generic Presence presentation
development harness diagnostics
```

rather than treating Onboarding presentation as the renderer.

Document the revised slices accordingly.

---

## Hard constraints

Do not:

- implement ChoiceStep;
- change schema;
- move presentation files yet;
- create ActionStep;
- create generic renderer registry;
- modify production onboarding;
- extend the active Schedule.

This is still design refinement only.

---

## Success criterion

The proposal should answer:

> Why should Onboarding be involved at runtime merely because the current generic Step belongs to the Onboarding Schedule?

If the answer is:

```text
It should not be.
```

then state clearly what generic presentation responsibility moves to Presence and what remains outside it.

Stop after updating the proposal and report back before implementation.
