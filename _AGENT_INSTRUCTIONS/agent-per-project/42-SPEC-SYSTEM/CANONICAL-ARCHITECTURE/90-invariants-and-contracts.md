## Data Pipeline Invariants

See:

CANONICAL-ARCHITECTURE/60-DATA-PIPELINE-INVARIANTS/10-PIPELINE-INVARIANTS-CORE.md

These define non-negotiable rules governing data ingestion, projection, and UI access.

TL;DR

These rules are non-negotiable. Specs are declarative. Durable state is separate from ephemeral projection. Coordinators do not leak widgets. Topology is reconstructed through approved local spec rules, not procedural branch assembly. Rendering is downstream.

# Invariants and Contracts

## Non-negotiable architectural rules

### 1. The pipeline is mandatory

All spec-driven behavior follows:

Spec → Coordinator → Resolver → Payload / ViewModel → Rendering

Do not skip stages for convenience.

### 2. State is truth; UI is projection

Durable app meaning lives in semantic state such as global flow state, panel stacks, or approved surface state.

Rendered widgets are not durable truth.

### 3. Specs are declarative

Specs describe intent or configuration. They do not execute behavior, perform IO, or construct widgets.

### 4. Coordinators do not render

Coordinators route specs to the correct handling path and return structured output. They must not construct shared chrome or use widgets as a shortcut around resolution.

No widget leakage across the coordinator boundary is permitted for new canonical work. Coordinators must preserve the data-only boundary.

### Panel legacy note

Older panel reference material may describe synchronous widget-returning coordinators. Treat that as a legacy/current-state migration boundary, not as an approved pattern for new work.

Do not expand widget-returning coordinator contracts into new panel variants, new surfaces, sidebar behavior, or shared abstractions.

### 5. Features provide content, not orchestration

Features may interpret their own spec variants and produce data for rendering. They must not own app-level flow, cross-surface reconciliation, panel stack policy, sidebar topology, or shared chrome.

### 6. Rendering is terminal

Build widgets at the render edge. Do not store built widgets as durable state, transport them through flow state, or use them as semantic evidence.

### 7. Stable and ephemeral state stay separate

Durable meaning belongs in flow state. Ephemeral action projection belongs in ephemeral projection state and is cleared when incompatible durable context changes.

Ephemeral projection must not become reconstructable durable meaning.

### 8. Topology is local and single-step

Sidebar topology answers only:

Current spec + minimal durable state -> next spec or null

Topology must not procedurally assemble full branches, omit arbitrary nodes from a prebuilt branch, scan previous specs, or look ahead to future specs.

### 9. Cross-surface changes use specs

When one surface needs another surface to change, it dispatches a spec through that surface's state API.

Do not call another surface's coordinator directly. Do not mutate another surface's internals.

### 10. Incompatible downstream content must cease to be effective

If global flow or investigation identity changes and panel or sidebar content
no longer matches it, effective downstream content must be re-derived without
the incompatible presentation.

Stored state may survive temporary incompatibility when restoration is useful.
That distinction must be explicit: stored state records prior intent; effective
state is the compatible projection currently allowed to render. Visibility and
downstream anchors consume effective state.

Do not scatter `clear`, `close`, or `dismiss` calls across unrelated actions to
repair a missing compatibility rule. Fix derivation, ownership, or projection.

## Anti-patterns

These are architectural violations:

- feature coordinator returns a sidebar card widget
- app-level coordinator embeds business logic
- resolver receives a whole spec and reinterprets routing already done by the coordinator
- feature imports another feature's resolver or widget builder
- sidebar rack is scanned to determine selected contact when flow state owns that value
- a panel remains effective after the active sidebar flow or investigation
  makes it semantically invalid
- ephemeral confirmation flow is written into durable flow state
- topology builds a list of cassette specs instead of returning one next child
- widget builder performs IO or decides navigation
- surface state stores built widget subtrees as if they were semantic state

## Common failure modes

### Stale panel content

Symptom:

The center or right panel displays content from a previous sidebar branch.

Cause:

Panel state was treated as independent when it should have been projected from global flow, or widget timing reasserted an old view spec.

Required response:

Move durable meaning upstream, project the correct `ViewSpec`, and derive an
effective panel stack that excludes incompatible stored state. Preserve stored
state only when its originating context may validly become current again.

### Widget-as-state drift

Symptom:

The app shows old meaning after semantic state changed.

Cause:

A built widget subtree or cached widget list crossed an architectural boundary.

Required response:

Transport specs, payloads, view models, identifiers, and layout roles instead. Build widgets at the render edge.

### Procedural topology reconstruction

Symptom:

A branch is built by constructing a custom list, omitting nodes, or patching a rack based on the desired final shape.

Cause:

Topology was treated as a branch builder instead of a local next-child relation.

Required response:

Express each transition as a local next-child rule using only current spec plus minimal durable state.

### Ephemeral state persistence

Symptom:

Temporary action UI survives mode changes, branch changes, or restoration as if it were durable context.

Cause:

Ephemeral projection was mixed into stable rack or global flow state.

Required response:

Separate stable and ephemeral projection. Clear ephemeral projection on incompatible durable transitions.

### Feature orchestration creep

Symptom:

A feature starts deciding panel routing, sidebar topology, or shared chrome because it knows what it wants to display.

Cause:

Feature code crossed from content responsibility into app-level orchestration.

Required response:

Move flow decisions to essentials/global state, use specs for cross-surface dispatch, and restrict feature code to approved spec interpretation and content resolution.

## Boundary violation examples

Forbidden:

```text
Feature coordinator → builds SidebarCassetteCard → returns Widget
```

Required:

```text
Feature coordinator → Resolver → SidebarCassettePayload → essentials render router → SidebarCassetteCard
```

Forbidden:

```text
Widget scans current rack -> infers selected contact -> opens panel
```

Required:

```text
Global flow state stores selected contact -> projected ViewSpec updates panel -> effective projection excludes incompatible stored content
```

Forbidden:

```text
Ephemeral reset confirmation appended to stable rack and retained across mode switch
```

Required:

```text
Ephemeral reset intent -> ephemeral projection provider -> rendered after stable projection -> cleared on mode or durable context change
```

Forbidden:

```text
Topology builds [hero, info, scopeToggle, handleFilter, heatmap]
```

Required:

```text
hero -> next info
info -> next scopeToggle
scopeToggle + durable scope -> next handleFilter or recovered info
```

## Enforcement expectations

Before implementing any spec-system change:

- read [00-overview.md](00-overview.md)
- read the relevant canonical surface doc
- read this document
- identify whether the change touches durable state, specs, coordinators, resolvers, payloads, or rendering

During implementation:

- keep edits in the owning layer
- use barrel-only feature imports
- preserve two-level sealed specs
- keep widget construction downstream
- preserve stable vs ephemeral separation
- use approved state provider APIs for surface changes

During review:

- reject widget leakage across coordinator boundaries
- reject direct feature-to-feature imports
- reject procedural rack reconstruction
- reject hidden durable state in widgets
- reject ephemeral state written into durable flow
- require reconciliation for dependent surfaces that can become stale

## Reference material

For detailed subsystem rules, use:

- [REFERENCE/50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/INVIOLATE_RULES.md](../REFERENCE/50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/INVIOLATE_RULES.md)
- [REFERENCE/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/INVIOLATE_RULES.md](../REFERENCE/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/INVIOLATE_RULES.md)
- [REFERENCE/55-EPHEMERAL-SPEC-HANDLING/INVIOLATE_RULES.md](../REFERENCE/55-EPHEMERAL-SPEC-HANDLING/INVIOLATE_RULES.md)
- [REFERENCE/55-EPHEMERAL-SPEC-HANDLING/INVIOLATE_TOPOLOGY_CONTRACT.md](../REFERENCE/55-EPHEMERAL-SPEC-HANDLING/INVIOLATE_TOPOLOGY_CONTRACT.md)
- [REFERENCE/56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/INVIOLATE_RULES.md](../REFERENCE/56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/INVIOLATE_RULES.md)
