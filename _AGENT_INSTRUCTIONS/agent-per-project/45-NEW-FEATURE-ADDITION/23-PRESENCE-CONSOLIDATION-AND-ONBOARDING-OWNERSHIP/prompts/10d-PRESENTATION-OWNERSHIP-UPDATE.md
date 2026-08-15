Update `12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md` with the following definition near the beginning of the document, and use it as the governing definition throughout the proposal:

> **ChoiceStep** is the generic Presence Step for a decision made by the human user from a finite set of two or more options. Each option has:
>
> - a **durable opaque value** used by execution;
> - a **mutable human-facing label** used by presentation;
> - a persisted destination Trip.
>
> The defining feature of ChoiceStep is not how the options are rendered. It is that the outgoing route is selected by a human choosing one of the persisted option values.

Use this distinction explicitly:

```text
FixedDestinationStep
    configuration determines the route

TestStep
    Agent-computed Boolean determines the route

ChoiceStep
    human-selected durable value determines the route
```

Clarify that presentation forms such as:

```text
buttons
radio controls
menus
lists
```

are not separate domain Step types unless future evidence proves that a genuinely different interaction contract is required.

The durable/mutable distinction should be illustrated with an example such as:

```text
value = "pause"
label = "That's good for now"
destination = Trip X
```

where the label may later change to:

```text
"Finish for now"
```

without changing the value, destination, routing semantics, or persisted workflow identity.

Also state explicitly:

- option values are scoped to the containing ChoiceStep, not globally meaningful;
- Presence does not interpret the value semantically;
- Presence may display the label without understanding its meaning;
- the workflow definition stores the value-to-destination mapping;
- runtime presentation reports only the selected value;
- Presence resolves that value against the current ChoiceStep and returns the configured `TripDefinitionId`;
- the workflow owner is not consulted at runtime to translate the choice into a route.

Do not implement code or schema. This is a design-document refinement only.

Stop after updating the proposal and report back.

That captures the Platonic version nicely.
