---
tier: project
scope: presence-choice-step-runtime
owner: agent-per-project
last_reviewed: 2026-08-13
source_of_truth: implementation
links:
  - 12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md
  - 13-CHOICESTEP-PURE-DOMAIN-IMPLEMENTATION.md
  - 14-CHOICESTEP-ADDITIVE-PERSISTENCE-IMPLEMENTATION.md
  - 00-START-HERE.md
tests:
  - test/essentials/presence/infrastructure/choice_step_runtime_test.dart
  - test/architecture/forbidden_imports_test.dart
---

# ChoiceStep Runtime Completion Implementation

## Scope

This is Slice 3 of the approved `ChoiceStep` proposal. It adds the narrow
runtime boundary through which an external human-facing caller reports one
selected `ChoiceValue` for the current terminal `ChoiceStep`. It adds no
Flutter presentation, generic Step input, active Onboarding usage, pending
choice persistence, or Choice-specific trace data.

## Existing Completion Path Reused

Before this slice, ordinary execution already followed this path:

```text
Step.complete()
    -> Trip.completeCurrentStep()
    -> TripStepCompletion.routingResultTripDefinitionId
    -> PresenceScheduler.completeCurrentStep()
    -> PresenceScheduleRepository.checkpointTripCompletion()
    -> active Schedule occurrence resolution
    -> schedule_runs.current_trip_occurrence_id checkpoint
```

`checkpointTripCompletion()` also records the ordinary `trip_completed` and
`route_decision` events before updating the checkpoint. The Scheduler then
installs the returned run and records the next `trip_started` event.

Slice 3 does not create a parallel route. It shares the Scheduler's existing
private Step-completion continuation and passes the configured
`TripDefinitionId` into the same repository method.

## Public Selection Boundary

The choice-specific public contract is:

```dart
typedef CurrentChoiceSelection = Future<void> Function(ChoiceValue value);

CurrentChoiceSelection issueCurrentChoiceSelection()
```

The caller obtains this function while Presence is at the current terminal
`ChoiceStep`, then reports only the opaque value selected by the human.

The public callable does not accept or expose:

- Step identity;
- Trip identity or occurrence identity;
- Schedule geometry;
- destination;
- routing instruction; or
- a generic payload.

Presence retains all execution identity internally.

## Current Choice And Stale Interaction

Issuing the function captures two pieces of private evidence:

1. the current in-memory `ChoiceStep` instance; and
2. an opaque activation object owned by `PresenceScheduler`.

The Scheduler replaces the activation object every time it installs a run's
current Trip. A function issued for an earlier activation therefore fails
before it can record completion or route a later Step. Checking the Step
instance provides an additional exact-current-Step assertion without exposing
that identity to the caller.

This is deliberately a local Choice mechanism, not a generic interaction-token
framework.

## Selection To Trip Completion

On invocation, Presence:

1. verifies that the captured activation is still current;
2. verifies that the current Step is the exact captured `ChoiceStep`;
3. verifies that the Step is terminal;
4. asks `ChoiceStep.destinationFor(value)` to validate the opaque value;
5. records the ordinary `step_started` event;
6. asks `Trip.completeCurrentChoice(value)` for the canonical Trip result;
7. records the ordinary `step_completed` event; and
8. sends that result through the unchanged repository checkpoint path.

An unknown value fails through the domain lookup before any Step event or
checkpoint change. Autonomous `completeCurrentStep()` now fails closed when
the current Step is a `ChoiceStep`; `ChoiceStep` itself remains a synchronous
value-to-destination mapping rather than an object waiting for UI.

## Checkpoint And Restart Semantics

No new durable state exists. Before accepted selection, the existing
`schedule_runs.current_trip_occurrence_id` still points to the Choice Trip, so
a restart reconstructs that Trip at Step 1. After successful checkpointing, it
points to the selected destination occurrence, so restart begins at that
destination's Step 1.

Presence does not persist the selected value, current Step, pending choice, or
interaction activation. Definitions prescribe the options; the run remembers
the current Trip; trace records the route taken.

## Repeated Selection

The Scheduler admits only one Choice transition at a time. A rapid second
invocation fails while the first is in progress. Once the first transition
installs the destination Trip, the captured activation is stale, so later
invocations of the same function also fail. Exactly one route checkpoint is
therefore accepted.

## Trace Behavior

Choice completion uses the existing universal sequence:

```text
step_started
step_completed
trip_completed
route_decision
next trip_started
```

The route event already records the canonical destination definition and
resolved destination occurrence. No `ChoiceValue` column, event type, or
Choice-specific result was added, and trace remains observational rather than
authoritative.

## Preserved Boundaries

- `ChoiceStep` stores no callback, `Completer`, or pending state.
- The public boundary is Choice-specific rather than arbitrary Step input.
- Presentation and Onboarding are absent from the runtime dependency chain.
- The active Onboarding Schedule remains unchanged.
- The development topology projector remains explicitly fail-closed.
- Existing Tell, Test, Fixed Destination, and transitional FDA behavior keeps
  using autonomous completion.

## Verification

Focused runtime coverage proves configured selection, unknown-value failure,
stale interaction rejection, repeated values on later ChoiceSteps, rapid
double-selection rejection, shared destinations, restart before and after
acceptance, universal trace ordering, autonomous fail-closed behavior, and
runtime terminal enforcement.

Verification completed with:

- 12 focused Choice runtime tests;
- 46 combined Choice domain, persistence, migration, and runtime tests;
- 121 complete Presence and development-harness tests;
- 82 complete Onboarding tests;
- 365 architecture tripwires;
- clean Flutter analysis;
- formatting; and
- `git diff --check`.

## Deviations From Document 12

None. The context-bound callable is the proposal's preferred stale-interaction
shape and introduces no general interaction framework.
