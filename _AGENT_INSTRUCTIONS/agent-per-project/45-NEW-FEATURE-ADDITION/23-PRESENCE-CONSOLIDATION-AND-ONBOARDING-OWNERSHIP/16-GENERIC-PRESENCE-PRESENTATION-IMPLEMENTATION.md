---
tier: project
scope: presence-generic-step-presentation
owner: agent-per-project
last_reviewed: 2026-08-13
source_of_truth: implementation
links:
  - 12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md
  - 13-CHOICESTEP-PURE-DOMAIN-IMPLEMENTATION.md
  - 14-CHOICESTEP-ADDITIVE-PERSISTENCE-IMPLEMENTATION.md
  - 15-CHOICESTEP-RUNTIME-COMPLETION-IMPLEMENTATION.md
  - 00-START-HERE.md
tests:
  - test/essentials/presence/application/presence_step_presentation_test.dart
  - test/essentials/presence/presentation/presence_step_presenter_test.dart
  - test/architecture/forbidden_imports_test.dart
---

# Generic Presence Presentation Implementation

## Scope

This is Slice 4 of the approved `ChoiceStep` proposal. It introduces the
smallest permanent presentation layer for generic Presence Step shapes and
uses the development harness as its first host. It does not add a Choice to
the active Onboarding Schedule or create an Onboarding renderer.

## Existing Harness Seam

Before this slice,
`features/presence_iteration_simple/presentation/linear_presence_experiment_host.dart`
owned both:

- generic mechanics: showing persisted Step copy, offering ordinary
  completion, disabling an in-flight action, and displaying failure; and
- laboratory concerns: source substitution, Mermaid generation, live topology,
  execution trace, diagnostics, and Run Again.

Only the generic mechanics moved. The development feature still owns and
renders every laboratory concern around the permanent presenter.

## Permanent Presentation Files

The permanent boundary consists of:

- `essentials/presence/application/presence_step_presentation.dart`, which
  projects the current domain Step into presentation-safe data and bound
  operations;
- `essentials/presence/presentation/presence_step_presenter.dart`, which uses
  one exhaustive switch to render the projected generic Step shape; and
- `essentials/presence/presentation/presence_presentation_tokens.dart`, the
  existing small Presence typography and readable-width token set relocated
  from the development feature because generic Tell rendering now owns it.

No provider, registry, visitor, plugin dispatch, or polymorphic widget
framework was introduced.

## Generic Dispatch

The application projection distinguishes exactly the current Step shapes:

```text
TellStep
    -> persisted text plus ordinary completion

TestStep
    -> persisted label plus the existing opaque evaluation completion

FixedDestinationStep
    -> persisted label plus existing configured progression

ChoiceStep
    -> ordered label:value items plus a context-bound selection operation

OpenFdaSettingsStep
    -> explicit specialist boundary
```

The presenter renders the four generic shapes. It delegates the specialist
marker to a builder supplied by the host rather than learning FDA meaning.

## Choice Presentation-Safe Projection

The projection converts every full domain `ChoiceOption` into:

```text
ChoicePresentationItem
    label
    ChoiceValue
```

The projection also obtains the Slice 3 context-bound selection function.
Neither `ChoicePresentationItem`, `ChoiceStepPresentation`, nor
`PresenceStepPresenter` exposes a Step ID, Trip ID, occurrence ID,
`TripDefinitionId`, destination, or Schedule geometry.

The full option is consumed only while Presence constructs the projection.
Flutter receives persisted labels, opaque values, and the already-bound
operation.

## Label And Value Boundary

Buttons display `ChoicePresentationItem.label`. Selection reports the paired
`ChoicePresentationItem.value`. Labels may change without changing execution,
and duplicate labels remain distinguishable because interaction uses the
opaque value rather than visible text.

The current visual treatment is an ordered, centered `Wrap` of ordinary macOS
buttons. That treatment is not persisted. Buttons may later become rows or a
menu without changing Choice definitions, schema, routing, or runtime.

## In-Flight And Error Behavior

The presenter disables every Choice control while one submission is in flight.
This is presentation feedback only. Slice 3's Scheduler activation checks and
single-transition admission remain correctness authority.

A rejected submission is displayed as the ordinary Step-completion error. The
presenter does not retry, choose a destination, route locally, or repair
Schedule state.

## Open FDA Settings Escape Hatch

`OpenFdaSettingsStep` remains transitional domain-specific debt. The generic
projector emits only a specialist marker. The development host retains its
existing `Open System Settings` copy and completion behavior through the
explicit specialist builder.

This slice does not generalize that Step into an Action abstraction and does
not move FDA knowledge into generic Presence presentation.

## Development-Only Concerns Retained

The development harness continues to own:

- Contacts source substitution;
- Mermaid generation and copying;
- live Schedule topology;
- execution trace display;
- diagnostic Schedule, Trip, and Step position labels; and
- Run Again.

It now delegates only the current generic Step body and interaction to
permanent Presence presentation.

## Preserved Boundaries

- The active Onboarding Schedule is unchanged.
- No Onboarding runtime renderer exists.
- No Choice destination reaches presentation.
- No opaque value is interpreted.
- No widget style or pending interaction is persisted.
- Presence domain remains Flutter-free.
- `presence.db`, checkpointing, trace, and Trip-granular restart are unchanged.

## Verification

Focused projection and widget coverage proves generic dispatch, specialist
delegation, ordered labels, label:value separation, mutable labels, two and
four choices through the same shape, duplicate labels, in-flight disabling,
and visible stale-interaction failure.

Verification completed with:

- 12 focused projection and widget tests;
- 58 combined Choice domain, persistence, migration, runtime, projection, and
  widget tests;
- 133 complete Presence and development-harness tests;
- 82 complete Onboarding tests;
- 366 architecture tripwires;
- clean Flutter analysis;
- formatting; and
- `git diff --check`.

## Deviations From Document 12

None. The direct projection and exhaustive presenter implement the proposal's
preferred generic boundary without extending the active workflow.
