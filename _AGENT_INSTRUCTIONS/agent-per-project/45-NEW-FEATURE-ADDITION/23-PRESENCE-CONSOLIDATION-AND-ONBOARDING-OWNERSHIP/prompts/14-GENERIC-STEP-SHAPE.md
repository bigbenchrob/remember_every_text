Good. Slice 4 should finally make the abstraction visible, but still keep the scope tight: **generic Presence presentation only**.

The goal is not “build onboarding UI.” It is:

> Given a current generic Presence Step, render the smallest appropriate generic UI for that Step shape and report generic interaction back through the already-proven Presence runtime seams.

No workflow-specific semantics. No live onboarding topology change yet.

Implement **ChoiceStep Slice 4 only** from:

`12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md`

using the completed implementation records:

- `13-CHOICESTEP-PURE-DOMAIN-IMPLEMENTATION.md`
- `14-CHOICESTEP-ADDITIVE-PERSISTENCE-IMPLEMENTATION.md`
- `15-CHOICESTEP-RUNTIME-COMPLETION-IMPLEMENTATION.md`

This slice introduces the **smallest generic Presence presentation layer for generic Step shapes**, including visible `ChoiceStep` interaction.

Do not extend the active Onboarding Schedule.

Do not add sparse-history ChoiceStep usage.

Do not create an Onboarding-specific renderer.

Do not redesign the development harness.

The central question is:

> Can generic Presence render a generic Step from persisted data, accept the narrow interaction that Step allows, and remain completely ignorant of workflow meaning?

For the generic Step shapes already proven, the answer should now become executable.

---

## Governing presentation rule

Presence presentation may understand:

```text
this is a TellStep
this is a ChoiceStep
this is a TestStep
this is a FixedDestinationStep
```

and may understand the **mechanics** of those generic Step types.

It must not understand:

```text
what "Import Anyway" means
what "recheck" means
why one destination is correct
what FDA means
what Contacts readiness means
what Onboarding is trying to accomplish
```

Rendering persisted copy is not semantic interpretation.

The approved boundary is:

> Generic Step shapes with complete persisted presentation data are rendered by Presence. Workflow-specific presentation participates only when the Step requires domain expertise not expressed by generic grammar.

---

# 1. Inspect the current development-host presentation seam

Before editing, trace the current UI path in:

`presence_iteration_simple`

for displaying and advancing:

- `TellStep`
- `TestStep`
- `FixedDestinationStep`
- `OpenFdaSettingsStep`

Identify which parts are:

```text
generic Step presentation mechanics
```

and which parts are:

```text
development-only harness concerns
```

Development-only concerns include things such as:

- trace UI;
- Mermaid;
- live map;
- source substitution;
- Run Again;
- diagnostics;
- experiment controls.

Do not move or graduate those.

Document the seam briefly in the implementation record.

---

# 2. Create a permanent Presence presentation home

Add the smallest appropriate permanent presentation structure under:

`lib/essentials/presence/presentation/`

Follow current project conventions.

Do not create a large presentation framework.

A direct component such as:

```text
PresenceStepPresenter
```

or equivalent is sufficient if that fits the codebase.

Do not prematurely add:

- renderer registry;
- visitor framework;
- plugin dispatch;
- polymorphic widget hierarchy;
- generic widget factories.

Prefer one readable exhaustive switch.

---

# 3. Generic Step-shape dispatch

Implement the smallest direct dispatch over current generic Step types.

Conceptually:

```text
switch current Step

TellStep
    -> generic Tell presentation

ChoiceStep
    -> generic finite-choice presentation

TestStep
    -> generic Test presentation/execution behavior already justified

FixedDestinationStep
    -> generic progression behavior

OpenFdaSettingsStep
    -> explicit exceptional/domain-specific boundary
```

Do not pretend `OpenFdaSettingsStep` is generic merely to make the switch exhaustive.

It remains transitional debt.

If the permanent Presence presenter cannot directly render it without domain knowledge, keep an explicit escape hatch rather than contaminating the generic cases.

---

# 4. ChoiceStep presentation-safe projection

The presentation layer must not receive full `ChoiceOption` objects containing destinations.

Project the current ChoiceStep into something conceptually like:

```text
ChoiceMenuItem
    label
    value
```

The presenter may see:

```text
label = "Re-check"
value = "recheck"
```

It must not see:

```text
destinationTripDefinitionId
```

The application/runtime boundary should provide the already-proven context-bound selection operation from Slice 3.

Conceptually:

```text
ChoicePresentationModel
    items
    select(ChoiceValue)
```

Do not settle on that exact class name unless natural.

The important boundary is:

```text
presentation sees:
    label
    value
    context-bound selection operation

presentation does not see:
    Step ID
    Trip ID
    destination
    Schedule geometry
```

---

# 5. Render ChoiceStep generically

Render two or more Choice options using the simplest generic finite-choice presentation already consistent with MessageLens UI conventions.

Do not create separate domain concepts such as:

```text
MenuChoiceStep
RadioChoiceStep
ButtonChoiceStep
```

The domain remains one `ChoiceStep`.

The presentation layer decides how finite choices look.

For this first slice, choose one simple visual treatment.

Examples could be:

```text
ordinary buttons
simple selectable rows
radio-style rows
```

Choose whichever integrates most naturally with the current host.

Do not add persisted styling metadata.

Do not infer style from `ChoiceValue`.

---

# 6. Preserve label:value separation

The visible label must come from persisted definition copy.

The interaction must report the corresponding opaque `ChoiceValue`.

For example:

```text
visible:
    That's good for now

returned:
    ChoiceValue("pause")
```

The widget must not use the label as the execution key.

Prove this with tests.

---

# 7. In-flight behavior

When one Choice option is selected:

- prevent accidental repeated submission while the transition is in flight;
- use the Slice 3 context-bound selection seam;
- let stale/repeated protection remain authoritative in Presence runtime.

The UI may disable controls while selection is pending.

Do not add durable pending state.

Do not add a Choice-specific mutex if runtime already protects against double execution.

Presentation-side disabling is UX only; runtime remains correctness authority.

---

# 8. Error behavior

If choice submission fails because:

- interaction is stale;
- value is invalid;
- runtime state changed;

handle it using the smallest existing Presence presentation/error convention.

Do not route locally.

Do not silently retry.

Do not invent fallback destinations.

Do not teach UI how to repair Schedule state.

The presenter may surface an ordinary development-visible error in the harness if that matches current behavior.

---

# 9. TellStep

Move or extract only the genuinely generic part of current Tell presentation into permanent Presence presentation.

Generic Tell presentation may know:

```text
display persisted text
offer ordinary progression
```

It must not know what the text means.

If current host behavior already proves this cleanly, reuse rather than redesign.

---

# 10. TestStep

Be conservative.

The generic presenter may understand that a TestStep:

```text
performs an opaque Boolean evaluation
```

but should not know what the Agent tests.

If current runtime executes Tests automatically with no meaningful user-facing control, preserve that.

Do not manufacture a new progress UI just because the presentation layer now exists.

Only extract behavior already justified by current evidence.

---

# 11. FixedDestinationStep

Likewise, preserve existing generic progression mechanics.

Do not create visible controls if the Step currently completes automatically and no user interaction is required.

The generic presenter should reflect the actual runtime contract, not force every Step to become visual.

---

# 12. OpenFdaSettingsStep escape hatch

Treat `OpenFdaSettingsStep` explicitly.

It is the sole remaining active domain-specific Presence debt identified in the consolidation audit.

Do one of these:

```text
generic presenter delegates it through an explicit exceptional boundary
```

or:

```text
current host retains rendering for that one exceptional Step
```

Choose the smaller change.

Do not generalize it into ActionStep in this slice.

Do not redesign FDA settings behavior.

Document exactly where the generic boundary stops.

---

# 13. Development harness integration

Use `presence_iteration_simple` as the proof host for the generic Presence presenter.

The harness should continue owning:

```text
trace
Mermaid
live topology
diagnostics
source substitution
Run Again
```

while delegating generic Step rendering to permanent Presence presentation.

Do not graduate the entire feature into essentials.

Do not remove development diagnostics.

This slice should make the ownership split visible:

```text
Presence presentation
    renders generic Step

development harness
    surrounds it with observability
```

---

# 14. No active Onboarding Choice yet

Do not change the real onboarding Schedule.

If a ChoiceStep is needed for manual or widget testing, use:

- a test fixture;
- a development-only Schedule;
- an isolated harness route.

Do not wire the sparse-history ChoiceStep into production definitions yet.

That belongs to the later Onboarding workflow-definition slice.

---

# 15. Choice presentation tests

Add focused widget/presentation tests proving at least:

### Labels render

Given:

```text
value = blue
label = Blue

value = pink
label = Pink

value = purple
label = Purple
```

prove the visible UI contains:

```text
Blue
Pink
Purple
```

### Value returned, not label

Click:

```text
Pink
```

prove the runtime callback receives:

```text
ChoiceValue("pink")
```

not `"Pink"`.

### Destination invisible

The presentation model/widget API must not expose `TripDefinitionId`.

Add architecture/static protection if practical.

### Mutable label

Same:

```text
ChoiceValue("pause")
```

with label:

```text
That's good for now
```

then:

```text
Finish for now
```

renders the revised copy with no execution API change.

### Ordering

Presentation preserves persisted Choice option order.

### Two choices

Renders correctly.

### Three or more choices

Renders correctly without a different domain type.

### Duplicate labels

If two labels are identical but values differ, interaction still returns the correct distinct value.

### In-flight disable

Rapid repeated tap cannot issue two active submissions from the widget.

### Stale runtime callback

If the runtime callback rejects as stale, presentation does not locally route.

---

# 16. Generic dispatch tests

Prove the permanent presenter dispatches correctly for:

- TellStep;
- ChoiceStep;
- TestStep;
- FixedDestinationStep;

and handles the exceptional `OpenFdaSettingsStep` boundary explicitly.

Do not write tests asserting workflow semantics.

Good:

```text
ChoiceStep renders finite label:value options
```

Bad:

```text
Import Anyway button is red because importing sparse history is risky
```

No such semantic styling has been earned.

---

# 17. Architecture tripwires

Add/extend tests proving:

- Presence presentation may depend on Presence domain/application;
- Presence presentation must not depend on Onboarding;
- Presence domain must not depend on Flutter;
- Choice presentation API exposes no destination;
- no `ChoiceValue` parsing for semantics;
- no Onboarding-specific branch inside generic presenter;
- no generic renderer registry introduced.

A useful textual tripwire may reject strings such as:

```text
import_anyway
recheck
messages-source-history
```

inside generic Presence presentation, if that fits existing architecture-test style.

Do not over-engineer.

---

# 18. Styling principle

Do not persist presentation style.

The Choice definition remains:

```text
value
label
position
destination
```

Presence presentation may later change:

```text
buttons
```

to:

```text
radio-style rows
```

or:

```text
menu/list
```

without schema or workflow-definition migration.

Document this explicitly.

The permanent thing is the Choice interaction contract, not today's widget.

---

# 19. Documentation

Create:

`16-GENERIC-PRESENCE-PRESENTATION-IMPLEMENTATION.md`

Document:

1. existing harness presentation seam discovered;
2. permanent Presence presentation files added;
3. generic Step dispatch;
4. Choice presentation-safe projection;
5. exact label:value interaction boundary;
6. in-flight behavior;
7. error behavior;
8. OpenFdaSettingsStep escape hatch;
9. which development-host concerns remain development-only;
10. confirmation that no Onboarding runtime renderer exists;
11. confirmation that no destination reaches presentation;
12. tests;
13. deviations from Document 12.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

Do not rewrite Document 12.

---

# 20. Verification

Run:

- focused Choice widget/presentation tests;
- generic Presence presenter tests;
- Choice runtime tests;
- Choice persistence tests;
- Choice domain tests;
- complete Presence/development-harness tests;
- Onboarding tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`.

Run macOS build only if the new permanent Flutter presentation code creates compilation risk not covered by tests/analyze.

---

# Hard constraints

Do not in Slice 4:

- extend the live Onboarding Schedule;
- add sparse-history ChoiceStep to production;
- add Onboarding-specific Choice renderer;
- expose Step identity to presentation;
- expose Trip identity to presentation;
- expose Choice destinations to presentation;
- persist widget/control style;
- add MenuChoiceStep / RadioChoiceStep / ButtonChoiceStep domain types;
- add generic renderer registry;
- add ActionStep;
- generalize arbitrary Step input;
- add ChoiceValue trace fields;
- modify Presence database schema;
- modify Trip-granular restart semantics;
- reinterpret opaque values;
- redesign OpenFdaSettingsStep.

If any of those appears necessary, stop and explain why.

---

# Success criterion

At the end of Slice 4, the development harness can host a current generic:

```text
ChoiceStep

    label = "Blue"
    value = "blue"

    label = "Pink"
    value = "pink"

    label = "Purple"
    value = "purple"
```

and generic Presence presentation can:

```text
show:
    Blue
    Pink
    Purple

human clicks:
    Pink

report:
    ChoiceValue("pink")
```

while remaining unable to answer:

```text
what pink means
which Trip pink reaches
why pink is appropriate
what workflow owns this Step
```

Presence execution, privately, still knows the configured route.

The development harness may show all the balls and sticks around it.

The generic presenter should not.

Stop after Slice 4 and report back before extending the real Onboarding workflow.

This is the satisfying one: by the end of it, we should finally be able to point at the screen and say, “There. **That** is a ChoiceStep.”
