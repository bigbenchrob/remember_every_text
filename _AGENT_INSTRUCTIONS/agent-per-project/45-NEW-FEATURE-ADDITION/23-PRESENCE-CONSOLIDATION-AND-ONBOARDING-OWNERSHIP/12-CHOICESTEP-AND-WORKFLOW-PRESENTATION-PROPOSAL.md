---
tier: project
scope: presence-choice-step-and-generic-presentation
owner: agent-per-project
last_reviewed: 2026-08-13
source_of_truth: proposal
links:
  - ./00-START-HERE.md
  - ./09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md
  - ./10-NEXT-REAL-WORKFLOW-CONCERN-PLAN.md
  - ./11-MESSAGES-SOURCE-HISTORY-SUFFICIENCY-TESTAGENT-IMPLEMENTATION.md
  - ../21-PRESENCE-ITERATION-SIMPLE/30-SYSTEM-BOUNDARIES.md
tests: []
---

# ChoiceStep And Generic Presence Presentation Proposal

## Governing Definition

> **ChoiceStep** is the generic Presence Step for a decision made by the human
> user from a finite set of two or more options. Each option has:
>
> - a **durable opaque value** used by execution;
> - a **mutable human-facing label** used by presentation;
> - a persisted destination Trip.
>
> The defining feature of `ChoiceStep` is not how the options are rendered. It
> is that the outgoing route is selected by a human choosing one of the
> persisted option values.

This definition governs the domain contract, persistence grammar, runtime
selection boundary, and presentation ownership below.

## 1. Why ChoiceStep Is Now Earned

The local Messages-history sufficiency Agent established a real Boolean fact:

```text
local Messages history is sufficiently populated
    -> continue

local Messages history is sparse
    -> explain the condition
    -> let the user choose what happens next
```

Production Onboarding already exposes the two meaningful choices:

```text
Re-check
    -> determine_messages_source_history_sufficiency

Import Anyway
    -> confirm_messages_source_history_accepted
```

Neither destination is a hidden implementation detail. The user is deciding
whether to test the external world again or knowingly accept a small local
archive. The decision changes the Schedule route and therefore belongs inside
the persisted workflow grammar.

Existing Step types cannot express that decision truthfully:

- `FixedDestinationStep` has one destination chosen by configuration.
- `TestStep` has two configured arms chosen by a factual Agent result.
- presentation-side routing would let a widget change Schedule state outside
  the Step grammar.

A finite human choice is therefore a distinct mechanical reason for selecting
one configured outgoing destination. `ChoiceStep` is earned by this concrete
workflow. Nothing broader has been earned.

## 2. Mechanical Distinction Among Step Types

The useful question is:

> Who determines the outgoing destination?

| Step type | What determines the route? | What Presence knows |
| --- | --- | --- |
| `TellStep` | Normal Trip progression | Display copy and completion |
| `FixedDestinationStep` | Persisted configuration | One configured destination |
| `TestStep` | Boolean result from an opaque Agent | Agent identity and two configured arms |
| `ChoiceStep` | Human selection of one persisted choice | Finite choices and each choice's configured destination |

In compact form:

```text
FixedDestinationStep
    configuration determines the route

TestStep
    Agent-computed Boolean determines the route

ChoiceStep
    human-selected durable value determines the route
```

The human does not provide a `TripDefinitionId`. The human selects a known
label:value item. `ChoiceStep` resolves that opaque value to the destination
already supplied by the workflow owner.

This preserves the Schedule as routing authority while admitting human intent
as one narrow routing input.

## 3. Smallest ChoiceStep Contract

In ordinary language:

> A `ChoiceStep` exposes a label:value menu definition.

The label is user-facing copy. The value is the stable opaque result emitted
when the human selects that item.

Buttons, radio controls, menus, and lists are possible presentations of this
same contract. They are not separate domain Step types. A new Step type would
require evidence of a genuinely different interaction contract, not merely a
different visual control.

The recommended conceptual model is:

```text
ChoiceStep
    id
    name
    ordered choices

ChoiceOption
    value
    label
    destinationTripDefinitionId
```

The full runtime Step exposes an immutable ordered collection and one narrow
lookup operation:

```dart
ChoiceStep
    choices: List<ChoiceOption>
    destinationFor(ChoiceValue value): TripDefinitionId
```

Generic Presence presentation must not receive those full execution options.
The Presence application boundary projects them into a presentation-safe
label:value menu definition:

```text
ChoiceMenuItem
    label
    value
```

Destination is deliberately absent from that projection.

This shape is preferable to an operation which waits internally for UI input.
A domain object should not retain a pending renderer callback, `Completer`, or
widget lifecycle. Generic Presence presentation reports only a `ChoiceValue`
through a choice-specific selection boundary already bound to the current
execution context. Presence verifies that:

1. there is still a current Trip;
2. the current terminal Step is still the ChoiceStep to which the selection
   boundary was bound;
3. the submitted value belongs to that Step;
4. the configured destination is used;
5. ordinary Trip completion and checkpointing follow.

The exact Dart method names should be settled in implementation, but the API
must remain choice-specific. Do not introduce a generic input bag or retrofit
every Step with arbitrary input.

The contract supports two or more options without redesign. It contains no:

- hidden default;
- arbitrary result payload;
- free text;
- form state;
- Agent;
- presentation hint;
- Flutter type.

For the first implementation, a `ChoiceStep` is terminal within its Trip. Its
selected destination is the Trip's routing result. A non-terminal ChoiceStep
with destinations would conflict with the existing rule that only terminal
Step results cross the Trip boundary.

## 4. Choice Value And Identity Terminology

Each option should have a durable opaque `ChoiceValue` in addition to its
label and destination.

The terminology matters:

- **`ChoiceId`** emphasizes entity identity and can imply a globally
  meaningful Presence identifier which presentation must carry alongside
  execution identity.
- **`ChoiceValue`** describes the stable opaque value emitted when a human
  selects one item from the current label:value menu.

`ChoiceValue` is the better term for this boundary. It remains a strongly
typed, non-arbitrary token rather than a generic payload. Its meaning exists
only within the workflow-authored current `ChoiceStep`.

Label plus destination is insufficient because:

- labels are user-facing copy and may change;
- localization may produce different labels for the same meaning;
- duplicate labels are not inherently invalid;
- renderer callbacks need a value that is independent of displayed text;
- tests should not use copy as an execution key;
- two choices may legitimately share a destination while representing
  different acknowledged intentions;
- future trace diagnostics may need to distinguish the choice selected.

`ChoiceValue` should be stable, opaque to Presence, and scoped to its
`ChoiceStep`. A text representation is the least committal useful persistence
form. For example, Onboarding may author `recheck` and `import_anyway`, but
generic Presence must not parse or interpret those values.

The value remains stable when presentation copy changes:

```text
value = "pause"
label = "That's good for now"
destination = Trip X
```

The workflow owner may later revise the label to:

```text
label = "Finish for now"
```

without changing `pause`, Trip X, routing semantics, or the persisted workflow
identity represented by that option. Presence may display either label without
understanding what the words or the value mean.

Global choice-value uniqueness is unnecessary. The meaningful uniqueness
boundary is:

```text
step_definition_id + value
```

## 5. Persistence Proposal

The smallest schema consistent with the current subtype grammar is:

```text
choice_step_definitions
    step_definition_id PK/FK -> step_definitions.id

choice_step_options
    step_definition_id FK -> choice_step_definitions.step_definition_id
    value TEXT
    position INTEGER
    label TEXT
    destination_trip_definition_id FK -> trip_definitions.id

    PK (step_definition_id, value)
    UNIQUE (step_definition_id, position)
```

The marker row is retained because it identifies the Step subtype even before
its child rows are loaded and fits the existing exactly-one-subtype integrity
model. Options should be separate rows because their count is finite but not
fixed at two.

Persistence rules:

1. **Order is durable.** The workflow owner deliberately orders the choices;
   `position` preserves that order.
2. **Labels are persisted copy.** This matches current persisted `TellStep`
   copy. The workflow owner supplies the text; Presence merely stores it.
3. **Destination is required.** A choice which does not route is not part of
   the requirement that earned this Step.
4. **Two choices may share a destination.** That may be redundant, but it is
   not structurally false and should not be prohibited by generic Presence.
5. **At least two choices are required.** One option is a
   `FixedDestinationStep` with unnecessary interaction. Cross-row cardinality
   should be validated by the workflow writer and repository reconstruction;
   it does not justify a database trigger.
6. **Value and position are unique within the Step.** SQLite should enforce
   both mechanically.
7. **Destinations must belong to the loaded Schedule.** Repository validation
   should preserve the existing protection against routes outside the
   Schedule definition.
8. **Exactly one active subtype is required.** A `ChoiceStep` marker must not
   coexist with another active subtype row for the same base Step.

No selected option is stored in the definition tables. Definitions state what
may be selected, not what a particular run has selected.

## 6. Runtime Completion Semantics

The recommended flow is:

```text
Scheduler exposes current ChoiceStep
    -> Presence projects label:value menu items
    -> generic Presence presentation renders those items
    -> user selects one item
    -> presentation reports only its ChoiceValue
    -> bound selection context rejects a stale or unknown selection
    -> ChoiceStep maps ChoiceValue to its configured Trip destination
    -> Trip completes
    -> Scheduler checkpoints the selected destination
    -> next Trip is installed
```

`ChoiceStep` should not await presentation. Presentation should not call a
choice's destination directly. A narrow context-bound operation,
conceptually `selectCurrentChoice(value)`, keeps validation, Trip completion,
trace ordering, and checkpointing inside Presence.

Presentation must not submit Step identity. The Presence application boundary
should supply a choice-specific callback or selection handle bound internally
to the current ChoiceStep occurrence. Presence presentation sees only the menu
items and an operation which accepts `ChoiceValue`; the callback privately
retains whatever current execution evidence Presence needs.

When invoked, Presence verifies that the bound ChoiceStep is still the current
terminal Step before accepting the value. If replacement or progression has
occurred, the stale callback fails even when a newer ChoiceStep happens to
contain the same value. This preserves stale-interaction safety without
teaching any renderer about Step, Trip, occurrence, or Schedule identity. It is
a narrow ChoiceStep mechanism, not a general interaction framework.

The workflow owner is not consulted at runtime to translate the selection into
a route. Presence resolves the selected value against the current ChoiceStep's
persisted value-to-destination mapping and returns the configured
`TripDefinitionId` through ordinary Trip completion.

Pending interaction state is transient presentation state only. Presentation
may disable its controls while selection is being accepted, but it does not
own the selected destination or durable progress.

Selection and Trip checkpointing should form one accepted transition. If the
process fails before the checkpoint commits, the Journey has not durably
accepted the choice.

## 7. Restart Semantics

Current Trip-granular restart semantics are sufficient.

For a Trip containing:

```text
Tell
Tell
ChoiceStep
```

if the user quits before choosing:

```text
restart
    -> current Trip reconstructs from Step 1
    -> warning repeats
    -> choices are presented again
```

No current-Step or pending-choice persistence is needed. This is desirable:
the explanatory context is repeated before the user makes a consequential
decision.

If the process stops after interaction but before the Trip checkpoint commits,
the Trip also restarts. If checkpointing succeeds, restart begins at the
selected destination. The database checkpoint, not a widget callback, remains
the durable authority.

## 8. Generic Presence Presentation Conjecture

Three ownership models were considered.

### A. Workflow-Owned Rendering Of Generic Steps

Under this model, Onboarding would render an Onboarding `TellStep`,
`TestStep`, or `ChoiceStep`, while Archive Ingestion would render equivalent
shapes itself.

This is possible but currently unjustified. The workflow renderer would be
asked to reproduce mechanics already completely described by the generic Step:

- persisted text for `TellStep`;
- bound factual evaluation for `TestStep`;
- finite persisted label:value items for `ChoiceStep`;
- configured progression for `FixedDestinationStep`.

It would create workflow-specific runtime presentation participation without
adding workflow truth.

### B. Presence-Owned Rendering Of Generic Steps

Under this model, Presence owns a small permanent presentation layer which
understands generic Step mechanics and persisted presentation data:

```text
TellStep
    -> show persisted text
    -> offer ordinary progression

TestStep
    -> run its already-bound Agent
    -> show only generic testing/progress behavior actually required

ChoiceStep
    -> show persisted labels
    -> report the selected opaque value

FixedDestinationStep
    -> perform ordinary generic progression
```

Rendering persisted copy does not give Presence semantic knowledge. Presence
can display `Import Anyway` for the same reason it can display a `TellStep`
sentence: the copy is definition data. Presence does not interpret it.

This model is supported by the current development host. It already switches
on generic Step shape and renders generic text and completion mechanics without
understanding Messages- or Contacts-readiness meaning.

### C. Hybrid With A Domain-Specific Escape Hatch

Not every possible future interaction is proven to fit generic Step
presentation. A Step requiring genuinely domain-specific UI may remain with
the workflow or specialist which understands it.

`OpenFdaSettingsStep` is the current unresolved example. It remains
domain-specific transitional debt and should not be used to deny generic
ownership for the Step shapes which are already self-describing.

### Recommendation

Adopt **Presence-owned presentation for generic Step shapes**, with a narrow
domain-specific escape hatch when generic Step grammar is insufficient.

The permanent rule becomes:

> Generic Step shapes with complete persisted presentation data are rendered
> by Presence. Workflow-specific presentation participates only when the Step
> requires domain expertise not expressed by generic grammar.

No current evidence requires Onboarding to participate at runtime merely
because the active generic Step belongs to its Schedule.

## 9. Presence-Owned Presentation Boundary

The recommended permanent boundary is:

```text
Workflow owner
    authors:
        Schedule meaning
        persisted copy
        choice labels
        opaque values
        configured destinations
        TestAgent identities and bindings

Presence domain/application/infrastructure
    owns:
        Schedule execution
        Step reconstruction
        presentation-safe projections
        generic interaction acceptance
        routing and checkpointing

Presence presentation
    knows:
        generic Step shape
        persisted text or labels
        opaque values permitted by the current projection
        context-bound generic Step operations

    owns:
        standard generic Step rendering
        ordinary control selection for finite choices
        layout, focus, accessibility, and in-flight presentation

    does not know:
        workflow meaning
        what persisted copy means
        what an opaque value means
        workflow-specific specialist rules
        Trip destinations

Specialists / workflow-specific presentation
    own:
        domain expertise and UI only when generic Step grammar is insufficient
```

`lib/essentials/presence/presentation/` is therefore an appropriate permanent
home for generic Step presentation. Flutter dependencies may exist in that
presentation layer, but must not leak into Presence domain, persistence, or
execution contracts.

For `ChoiceStep`, the Presence application boundary still projects full
execution options into label:value menu items and a context-bound selection
operation. The presentation layer does not receive destinations or execution
identity.

The existing production sparse-history overlay remains evidence of current
behavior, not the target ownership boundary. Onboarding should continue to
author its copy, values, and destinations, but a generic Presence runner can
render and execute the eventual persisted ChoiceStep without calling an
Onboarding presenter.

The current `presence_iteration_simple` host contains two different concerns:

```text
potentially permanent evidence
    generic Step-shape dispatch
    generic text presentation
    generic completion and in-flight behavior

development-only concerns
    trace
    Mermaid diagram
    live map
    source substitution
    Run Again
    diagnostics
```

Do not graduate the host. Extract only mechanics which earn permanent Presence
presentation responsibility.

## 10. Renderer Dispatch

A direct exhaustive switch in a generic Presence presenter is the appropriate
first implementation:

```text
switch current Step shape
    TellStep
        -> generic Tell presentation

    TestStep
        -> generic Test execution/presentation

    ChoiceStep
        -> generic finite-choice presentation

    FixedDestinationStep
        -> generic progression

    otherwise
        -> explicit domain-specific presentation boundary
```

`OpenFdaSettingsStep` currently reaches the final arm. This proposal does not
decide whether it should later become a generic operation shape.

For `ChoiceStep`, dispatch supplies only the menu projection and context-bound
selection callback. It must not expose the full `ChoiceOption`, infer route
meaning from labels, or choose a destination independently.

The presenter may understand that a Step is a `ChoiceStep`; it may not
understand what any choice means. A simple switch is sufficient. Do not add a
renderer registry, visitor framework, or polymorphic widget hierarchy.

## 11. Presentation Metadata Policy

The first persisted choice needs only:

```text
opaque value
label
position
destination
```

Do not add:

- preferred/default status;
- destructive or cancel roles;
- icon identity;
- button style;
- color;
- keyboard shortcut;
- menu/list/button hints;
- generic metadata maps.

The sparse-history workflow does not currently require those concepts.

Generic Presence presentation must not style `Import Anyway` by interpreting
its value. The first implementation should use the ordinary generic finite-
choice presentation.

If caution styling later proves necessary, that evidence must be evaluated
separately: it may justify a small generic persisted role or a genuinely
domain-specific presentation boundary. It does not justify hidden value
parsing, and neither possibility is added now.

## 12. Trace Implications

The existing Step-started, Step-completed, and route-decision events are
sufficient for the first sparse-history implementation because its two choices
lead to different destinations. Execution can be reconstructed as:

```text
ChoiceStep completed
    -> configured destination selected
    -> route decision checkpointed
```

Recording opaque `ChoiceValue` would improve diagnostics if multiple choices
share a destination or copy changes obscure historical intent. It is useful,
but not required for routing correctness and should be deferred from the first
implementation slice.

If that evidence becomes necessary, add one typed optional choice observation
to the trace contract. Do not introduce arbitrary interaction payloads or
analytics. Trace remains observational and cannot become routing authority.

## 13. Sparse-History Walkthrough

The real workflow becomes:

```text
determine_messages_source_history_sufficiency
    TestStep
        Agent: onboarding.messages-source-history-sufficient

    true
        -> confirm_messages_source_history_accepted

    false
        -> guide_sparse_or_unsynced_messages_source

guide_sparse_or_unsynced_messages_source
    TellStep
        explains that little local history was found

    TellStep
        explains synchronization and the consequences of continuing

    ChoiceStep
        value: recheck
        label: Re-check
            -> determine_messages_source_history_sufficiency

        value: import_anyway
        label: Import Anyway
            -> confirm_messages_source_history_accepted
```

Generic Presence presentation receives only:

```text
[
    (label: "Re-check", value: "recheck"),
    (label: "Import Anyway", value: "import_anyway")
]
```

Selecting `Re-check` reports only `recheck`. Presence presentation never sees
`determine_messages_source_history_sufficiency`; Presence execution resolves
that destination from the current persisted ChoiceStep. No Onboarding runtime
presenter is consulted.

Ownership in that walkthrough:

- **Onboarding workflow definition owns** the Agent identity, threshold
  meaning, Trip definitions, Step copy, values, labels, and destinations.
- **The source-count specialist owns** the fresh `COUNT(*)` fact.
- **Presence owns** reconstruction, finite-choice validation, Step/Trip
  completion, routing, checkpointing, and restart.
- **Presence presentation knows** only generic Step shape, persisted labels,
  and values and owns their standard rendering and interaction mechanics.
- **The Scheduler sees** one selected opaque value resolved by the current
  Step to one configured destination. It does not know what re-checking or
  importing means.

The human chooses an Onboarding meaning. Generic Presence receives only the
opaque value of a configured option.

## 14. Future Generality Checks

The narrow grammar survives a few grounded examples without extension:

### Archive Ingestion

```text
Choose source A
    -> inspect source A

Choose source B
    -> inspect source B
```

The archive workflow owns source meaning and labels. Generic Presence
presentation chooses an ordinary finite-choice representation from the Step
shape and current presentation constraints. Presence execution still receives
one configured value.

### Recovery

```text
Retry
    -> repeat recovery assessment

Start Over
    -> begin a configured recovery Trip

Cancel
    -> leave through a configured cancellation Trip
```

Three options require no new grammar. This example does not establish generic
cancel or destructive roles; those remain workflow meanings.

These examples test cardinality and presentation independence only. They do
not authorize either workflow.

## 15. Rejected Alternatives

### Buttons directly change Schedule state

Rejected. It moves routing authority into presentation and makes correctness
depend on every renderer reproducing workflow rules.

### Encode the decision as a fake TestAgent

Rejected. An Agent establishes an external Boolean fact. Human intent is not a
probe result, and pretending otherwise destroys the mechanical distinction
which made generic `TestStep` coherent.

### Add `SparseHistoryChoiceStep`

Rejected. Sparse history supplies the meaning, not a new execution mechanism.
The mechanism is a finite choice among configured routes.

### Use `FixedDestinationStep` with presentation-side routing

Rejected. A fixed Step has one route. Letting presentation replace it based on
a click again moves routing outside the Schedule.

### Add a giant `InteractionStep`

Rejected. No evidence exists for text entry, forms, validation, arbitrary
results, or multiple interaction families.

### Add arbitrary payload or result bags

Rejected. The only required input is one opaque value selected from the
current Step's finite set. The only required routing result is its configured
destination.

### Let ChoiceStep own Flutter widgets

Rejected. The domain Step remains toolkit-independent. Generic widgets belong
in the separate Presence presentation layer, not in `ChoiceStep`.

### Require each workflow to render generic Step shapes

Rejected for the current evidence. Persisted `TellStep`, `TestStep`,
`ChoiceStep`, and `FixedDestinationStep` definitions already contain the
mechanics and presentation data needed by a generic Presence presenter.
Workflow rendering would add runtime coupling and duplicated mechanics without
adding workflow truth.

### Assume Presence rendering implies semantic understanding

Rejected. Displaying persisted copy is not interpretation. Presence may render
the label `Import Anyway` while remaining unable to explain imports or the
meaning of that choice.

### Use label plus destination instead of a value

Rejected. Copy is not a stable selection value, and destination alone cannot
distinguish choices which share a route.

### Require presentation to submit Step identity

Rejected. Presence already owns current execution state. A context-bound
selection callback can reject stale UI without exposing Step, Trip,
occurrence, or Schedule identities to generic presentation.

### Let ChoiceStep await a renderer callback

Rejected. It couples a durable domain object to transient presentation
lifetime. Selection should enter through an explicit Scheduler boundary.

## 16. Relationship To ActionStep

This requirement does not strengthen the case for a generic `ActionStep`.

`ChoiceStep` captures human selection among configured routes. It does not ask
a specialist to perform an operation. `OpenFdaSettingsStep` remains a separate
operation-shaped concern and should be evaluated on its own evidence.

The answer remains:

```text
No ActionStep is justified by this workflow.
```

## 17. Recommended Implementation Slices

Implementation should remain reviewable in narrow stages:

1. **Pure domain contract**
   - add `ChoiceValue`, `ChoiceOption`, and `ChoiceStep`;
   - prove ordered immutable choices, minimum cardinality, value lookup,
     unknown-choice rejection, and configured destination resolution;
   - add no schema or UI.

2. **Additive persistence grammar**
   - add the marker and option tables;
   - reconstruct ordered choices with integrity validation;
   - add migration and repository tests;
   - do not extend the live Schedule.

3. **Choice-specific runtime completion**
   - add the narrow context-bound current-choice selection boundary;
   - reject stale callbacks and unknown choice values internally;
   - expose no Step or Trip identity to generic Presence presentation;
   - reuse existing checkpoint and trace ordering;
   - add no generic input framework.

4. **Generic Presence presentation**
   - add the smallest direct Step-shape switch under Presence presentation;
   - render Tell and Choice mechanics from persisted generic data;
   - preserve the presentation-safe projection and bound selection callback;
   - add no renderer registry or workflow-specific branch.

5. **Development-harness integration**
   - let `presence_iteration_simple` host the generic Presence presenter;
   - prove selection, routing, restart, and repeated-click protection;
   - keep trace, Mermaid, live map, source substitution, Run Again, and
     diagnostics in the disposable harness.

6. **Onboarding workflow definition**
   - add the already-proven history Agent to the Schedule;
   - add sparse-history guidance and the two Onboarding-owned choices;
   - regenerate topology and verify restart behavior.

7. **Production generic-runner integration**
   - present the active Onboarding Schedule through generic Presence
     presentation;
   - keep Onboarding responsible for authored definitions and Agent bindings,
     not generic runtime rendering;
   - retain an explicit domain-specific boundary for unresolved exceptional
     Steps such as `OpenFdaSettingsStep`;
   - cut over only after the development route is proven.

Each slice should stop for review. None should introduce `ActionStep` or a
general interaction architecture.

## 18. Questions Requiring Human Decision

Before implementation, confirm these bounded choices:

1. **Choice value form:** adopt an opaque text `ChoiceValue`, scoped to its
   Step, rather than `ChoiceId` or a global identity.
2. **Runtime entry point:** adopt a context-bound choice-specific selection
   callback accepting only `ChoiceValue`, rather than exposing Step identity
   or a generic Step input/result API.
3. **Generic presentation ownership:** make Presence presentation the default
   renderer for generic `TellStep`, `TestStep`, `ChoiceStep`, and
   `FixedDestinationStep` mechanics.
4. **Domain-specific escape hatch:** retain an explicit boundary for a Step
   whose UI genuinely requires specialist knowledge, without generalizing it.
5. **Trace scope:** defer recording `ChoiceValue` because existing route trace
   is sufficient for the first workflow.
6. **Presentation metadata:** defer caution/destructive/default roles and use
   ordinary generic finite-choice presentation initially.
7. **Equivalent routes:** allow two choices to share a destination because
   Presence should not judge workflow redundancy.

These are the only decisions needed before the first pure-domain slice. Visual
details remain a later generic Presence-presentation decision.

## Final Ownership Test

```text
What does Presence know?
    A finite ordered choice grammar, opaque choice value,
    and configured destination resolution.

What does ChoiceStep know?
    Which opaque values belong to it and which configured destination
    corresponds to each value.

What does Onboarding know?
    The workflow definition knows what each value means, what its label says,
    and where it should route when the definition is authored.

Why should Onboarding participate at runtime merely because the current
generic Step belongs to its Schedule?
    It should not.

Who decides whether choices are buttons, a list, or a menu?
    Generic Presence presentation for a generic ChoiceStep.

Who determines the destination?
    The workflow owner configures it; Presence resolves the destination from
    the current ChoiceStep and human-selected ChoiceValue.

Which Trip does `recheck` go to?
    Ask Onboarding at runtime and it should look blank. Presence execution may
    answer from the current persisted ChoiceStep because that is geometry.

How should a generic ChoiceStep render three ordinary labels?
    Ask Onboarding and it should ask why it is being consulted. Generic
    Presence presentation owns that mechanic.

What does `recheck` mean?
    Ask Presence and it should also look blank. Presence knows only the
    current ChoiceStep's value-to-destination mapping.

Does Presence know what "Import Anyway" means?
    No.
```
