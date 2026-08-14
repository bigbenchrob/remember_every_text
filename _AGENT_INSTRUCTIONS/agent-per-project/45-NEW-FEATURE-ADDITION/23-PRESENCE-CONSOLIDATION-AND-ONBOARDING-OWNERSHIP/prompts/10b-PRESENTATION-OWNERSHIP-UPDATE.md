Update:

`12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md`

before any implementation begins.

We have refined one important boundary in the proposal.

The current proposal says presentation should submit:

```text
originating Step identity
+
ChoiceId
```

We now think that leaks too much Presence machinery into the workflow presentation.

The workflow presentation should not need to know:

```text
StepDefinitionId
TripDefinitionId
Trip occurrence
Schedule geometry
routing destinations
```

Presence already owns the current execution state.

---

## Revised governing rule

> Workflow presentation reports only what the human selected. It does not identify the current Step and it never tells Presence where to route.

Presence already knows which Step is current.

So the runtime exchange should conceptually be:

```text
Presence -> workflow presentation:

[
    label: "Re-check"
    value: "recheck"

    label: "Import Anyway"
    value: "import_anyway"
]

human selects:
    "Re-check"

workflow presentation -> Presence:
    "recheck"

Presence:
    current Step is a ChoiceStep
    current ChoiceStep contains value "recheck"
    persisted destination for "recheck" = Trip X
    complete current Trip with Trip X
```

Onboarding never sees `Trip X`.

---

## Label:value menu definition

Use this ordinary-language concept first:

> A ChoiceStep exposes a label:value menu definition.

For example:

```text
label: "That's good for now"
value: "pause"

label: "Keep going"
value: "continue"

label: "Review this first"
value: "review"
```

The **label** is user-facing copy.

The **value** is the stable opaque selection emitted when the human chooses that item.

This separation means copy can change without changing workflow identity:

```text
"That's good for now"
"Pause here"
"Finish for now"
```

may all correspond to the same stable value:

```text
pause
```

Presence must not interpret the word `pause`. It is opaque within the current ChoiceStep.

---

## Reconsider `ChoiceId` terminology

Evaluate whether the concept previously called `ChoiceId` should instead be called something like:

```text
ChoiceValue
```

or another term that better expresses:

> stable opaque value returned by selection

rather than:

> another globally meaningful Presence identity

The value should remain scoped to one ChoiceStep.

The meaningful uniqueness rule is conceptually:

```text
(step_definition_id, value)
```

not global uniqueness.

Do not rename merely for aesthetics, but explicitly compare `ChoiceId` versus `ChoiceValue` against the revised boundary.

---

## Revised persisted option shape

Reassess the option definition as something conceptually like:

```text
ChoiceOption
    value
    label
    position
    destinationTripDefinitionId
```

Presence stores all four.

Workflow presentation should receive only the presentation-safe projection:

```text
ChoiceMenuItem
    label
    value
```

The destination remains private to Presence execution.

Do not expose `destinationTripDefinitionId` through the presentation contract.

---

## Revised runtime selection boundary

Do not require workflow presentation to submit Step identity.

Instead design a narrow Presence selection boundary that is already bound to the current execution context.

Conceptually:

```text
selectCurrentChoice(value)
```

or an equivalent context-bound callback/command.

Presence must internally verify:

1. there is still a current Trip;
2. the current terminal Step is still a ChoiceStep;
3. the submitted value belongs to that current ChoiceStep;
4. the configured destination is used;
5. ordinary Trip completion/checkpointing follows.

The workflow presentation supplies only the opaque selected value.

---

## Stale UI protection

The previous proposal used originating Step identity to reject stale callbacks.

Preserve the requirement but solve it without teaching Onboarding Step IDs.

Evaluate the smallest approach, such as:

- a callback/selection handle bound to the currently presented ChoiceStep;
- an opaque interaction token that presentation does not interpret;
- another narrow mechanism.

Do not introduce a general interaction framework.

The important invariant is:

> stale presentation cannot complete a newer ChoiceStep.

But the workflow presentation should remain blissfully ignorant of Presence Step identity.

---

## Ownership restatement

The refined boundary should be:

```text
Workflow owner
    authors:
        labels
        opaque values
        destinations
        ordering

Presence / presence.db
    stores:
        value -> destination mapping

Presence runtime
    knows:
        current ChoiceStep
        selected opaque value
        configured destination

Workflow presentation
    knows:
        label
        value
        how to render them

Workflow presentation does NOT know:
        Step ID
        Trip ID
        destination
        routing
```

---

## Sparse-history example

Represent the current real case as:

```text
Persisted ChoiceStep:

value = "recheck"
label = "Re-check"
destination = determine_messages_source_history_sufficiency

value = "import_anyway"
label = "Import Anyway"
destination = confirm_messages_source_history_accepted
```

Onboarding presentation receives:

```text
[
    ("Re-check", "recheck"),
    ("Import Anyway", "import_anyway")
]
```

If the human chooses `Re-check`, presentation returns only:

```text
recheck
```

Presence resolves the destination from the current persisted ChoiceStep.

---

## Blank-stare extension

Add this invariant:

> Ask Onboarding presentation, “Which Trip does `recheck` go to?” and it should look blank.

And preserve:

> Ask Presence, “What does `recheck` mean?” and it should also look blank.

Presence knows only:

```text
for the current ChoiceStep:
    "recheck" -> configured Trip destination
```

It does not know the semantic meaning of the word.

---

## Required proposal updates

Revise the affected sections of Document 12, especially:

- Smallest ChoiceStep contract
- Choice identity
- Persistence proposal
- Runtime completion semantics
- Workflow-owned presentation boundary
- Renderer dispatch
- Sparse-history walkthrough
- Rejected alternatives
- Questions requiring human decision
- Final ownership test

Do not implement code or schema.

Do not broaden into ActionStep, generic interaction, forms, or payloads.

Stop after updating the proposal and report the revised recommendations.

That captures the improvement cleanly. The “label:value menu definition” is much friendlier to Onboarding and keeps the balls and sticks exactly where they belong.
