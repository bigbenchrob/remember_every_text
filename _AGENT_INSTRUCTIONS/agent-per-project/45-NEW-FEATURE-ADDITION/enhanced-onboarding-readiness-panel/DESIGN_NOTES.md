# Environment Readiness Center Panel Design Notes

## Current Conformance Note (2026-06-06)

These design notes remain useful for the surface shape and coordinator /
resolver / renderer split. Replace ordinary migration ownership references with
source-scoped graph build/readiness ownership. Retained migration references
should be diagnostic/compatibility-only.

## Summary

The environment-readiness experience should move from an overlay/dialog model
to a center-panel feature surface driven by the existing ViewSpec system.

This feature should not invent a new architectural pattern. It should apply the
existing app-level routing plus feature coordinator plus resolver plus builder
discipline to a new readiness surface.

## Existing Architecture Summary

Relevant current structure:

- app-level panel routing is owned by `ViewSpec` and the panel coordinator
- feature coordinators route specs and delegate meaning to resolvers
- resolvers own interpretation and assembly inputs
- widgets render decided state and actions
- the onboarding environment evaluator already gathers evidence about machine
  readiness and source-scoped graph pipeline health

That means the new feature can be introduced without disturbing source-scoped
import or graph-build ownership boundaries.

## Hard Invariants

- ViewSpec remains the only navigation mechanism for center-panel routing
- app-level coordinators choose the surface; they do not interpret readiness
  steps
- feature coordinators route only; resolvers own meaning
- widgets do not inspect the machine or decide step ordering
- source-scoped import remains owned by the graph import spine
- graph build/projection remains owned by graph orchestration
- retained import/migration systems are compatibility diagnostics only
- existing DB access invariants remain intact
- readiness success must derive from a fresh resolver pass, not from a button
  click side effect

## Assumptions

- the current environment evaluator is sufficiently useful to serve as the
  low-level evidence source for phase 1
- the center panel can be shown with sidebar content cleared or suppressed by
  app-level navigation logic
- the first implementation can keep readiness and import progress conceptually
  separate, even if they are adjacent in startup flow

## Recommended Domain Model

Suggested feature-owned concepts:

- `EnvironmentReadinessSpec`
- `EnvironmentReadinessStepKey`
- `EnvironmentReadinessStepStatus`
- `EnvironmentReadinessActionKind`
- `EnvironmentReadinessAction`
- `EnvironmentReadinessSnapshot`
- `EnvironmentReadinessSurfaceViewModel`
- `EnvironmentReadinessStepViewModel`

Suggested initial step keys:

- `fullDiskAccess`
- `messagesDatabaseAvailability`
- `contactsDatabaseReadability`
- `importReadiness`

Suggested step statuses:

- `pending`
- `active`
- `success`
- `failure`

Optional later enrichment:

- `checking`
- `unknown`

## Snapshot Model

One resolver pass should produce a full readiness snapshot.

The snapshot should answer:

- which steps exist and in what order
- which steps have passed
- which step is currently active
- whether the environment is fully ready
- what explanatory content belongs to the active step
- which actions should be shown for the active step

This preserves deterministic behavior and avoids widget-local sequencing.

## Relationship To Existing Onboarding Diagnostics

The new feature should not discard the current environment-report work.

Recommended layering:

1. low-level environment evaluator gathers concrete evidence
2. readiness resolver maps that evidence into step-level readiness semantics
3. feature coordinator maps the snapshot into a surface view model
4. widget builder renders the summary rail and active-step content

This allows the earlier onboarding diagnostics investment to remain valuable
while moving the user experience into a more scalable surface.

## Cross-Surface Routing Shape

Recommended route shape:

- add a new top-level `ViewSpec.environmentReadiness(...)` variant owned by
  essentials, wrapping a feature-owned `EnvironmentReadinessSpec`
- app-level navigation decides when this surface is the active center panel
- the sidebar is empty or intentionally suppressed while readiness is active
- once ready, routing proceeds into import/bootstrap flow

Implemented decision:

- readiness now uses its own feature-owned spec family under
  `lib/features/environment_readiness/domain/spec_classes/`
- onboarding retains only onboarding-specific surfaces such as the dev panel
- app-level routing delegates `ViewSpec.environmentReadiness(...)` to the
  readiness feature coordinator

## Suggested Feature Structure

Recommended feature ownership:

`lib/features/environment_readiness/`

Suggested structure:

```text
features/environment_readiness/
  application/
    view_spec/
      coordinators/
      resolvers/
      resolver_tools/
      widget_builders/
  domain/
    entities/
    spec_classes/
  infrastructure/
    services/
  presentation/
    view/
    widgets/
  feature_level_providers.dart
```

This follows the documented universal spec-handling pattern.

## Coordinator Responsibilities

App-level coordinator responsibilities:

- determine when the readiness surface should be shown
- route the readiness spec to the readiness feature coordinator
- remain ignorant of step details and machine interpretation

Feature coordinator responsibilities:

- pattern-match the readiness spec
- call exactly one resolver
- receive a complete readiness snapshot or surface VM
- return fully decided surface content

Feature coordinators must not:

- directly inspect the filesystem
- directly query OS state
- watch arbitrary reactive providers for hidden business logic
- distribute step logic across UI files

## Resolver Responsibilities

Resolvers should:

- gather or reuse concrete environment evidence
- compute the ordered readiness steps
- determine the first failing step
- compute active-step actions
- produce a complete readiness snapshot

Resolvers should not:

- build widgets directly beyond calling a widget builder with decided inputs
- bury checks inside widget lifecycle hooks
- rely on ad hoc mutable widget state to track progress

## Builder / Widget Responsibilities

The readiness widget layer should receive decided inputs such as:

- summary-rail items
- active step title
- reassurance copy
- explanation body
- instruction list
- action list
- success/failure visual state

Widgets should not:

- select the active step
- infer pass/fail
- inspect DBs or file paths
- decide repair sequencing

## UX Content Guidance

The surface should sound calm and precise.

Every active step should explain:

- what MessageLens needs
- why it needs it
- what privacy reassurance applies
- what exact steps the user should take
- how to re-check afterward

The copy should avoid:

- Apple-internal jargon where it does not help
- speculative certainty about iCloud state
- blameful or alarming phrasing

## Action Model

Recommended structured actions:

- `openSystemSettings`
- `recheck`
- `continue`
- `learnMore`

Important rule:

- external helper actions are not success
- only resolver recomputation can mark a step successful

## Recommended First Implementation Slice

Tracer-bullet v1 should be small and architectural:

1. add the new center-panel route/spec
2. render a static readiness scaffold in the center panel
3. introduce the readiness snapshot and step VM types
4. map existing environment-report evidence into those step states
5. render one active step with actions and explanation
6. keep explicit Re-check behavior before considering auto-refresh on app focus

## Future Enhancements

- auto re-check when app regains focus
- animated step progression polish
- support-time export of a last-known readiness snapshot
- richer details disclosure for non-technical support use
- optional continuation gating between readiness success and import launch
