---
tier: feature
scope: design-notes
owner: agent-per-project
last_reviewed: 2026-03-20
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./API_SKETCH.md
  - ./SIDEBAR_GEOMETRY_CONTRACT.md
  - ./seed.txt
  - ../../50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/00-cross-surface-spec-system.md
  - ../../52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/00-universal-spec-handling-pattern.md
  - ../../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md
tests: []
---

# Design Notes - Sidebar Cassette Role System

## Objective

Introduce a role-driven sidebar layout model so that cassette widgets declare semantic intent while essentials owns the resulting visual hierarchy, section grouping, and spacing.

The first delivery should improve structural coherence without turning into a broad redesign of every cassette surface detail.

## Existing Architecture Summary

- the cassette rack owns ordered `CassetteSpec` values
- feature coordinators and resolvers turn those specs into `SidebarCassetteCardViewModel`
- essentials-owned chrome widgets render the view model into sidebar cards
- the current app-level coordinator composes the sidebar as a flat list of wrapped widgets
- layout differences are still influenced by view-model flags such as `layoutStyle`, `isNaked`, `isControl`, and `topSpacing`

The weakness is not that essentials owns the card wrappers.

The weakness is that the wrappers currently operate at the cassette level only, without a first-class notion of semantic section or role-derived grouping.

The phase 1 API should first make role and placement explicit at the essentials-owned sidebar presentation boundary.

See `API_SKETCH.md` for the concrete proposed type shape.

## Constraints (Non-negotiable)

- do not replace the cross-surface spec architecture
- do not bypass feature-owned cassette specs or feature-owned content builders
- do not move outer sidebar spacing or section grouping into feature code
- do not introduce feature-specific semantic roles
- do not widen this work into flow-state, panel-routing, database, or persistence changes

## Recommended Shape

### Phase 1 Boundary

Phase 1 should introduce:

- an essentials-owned `SidebarCassetteRole`
- a requirement that sidebar presentation payloads declare one role
- role-derived grouping at the app-level sidebar composition layer
- section-level layout ownership for outer spacing and grouping treatment

Phase 1 should not require rewriting the rack model or the cassette spec hierarchy.

### Phase 2 Boundary

Phase 2 can tighten the system by:

- reducing or removing legacy layout knobs
- broadening role coverage across more sidebar branches
- adding stronger assertions or tests around invalid composition patterns

## Role Model

### Recommended Initial Enum

```text
SidebarCassetteRole
  appControl
  contextPrimary
  contextSecondary
  filter
  action
```

This set is intentionally small. It encodes structural meaning, not feature identity.

### Role Semantics

`appControl`

- top-level mode or branch switching
- visually separated from the main investigative stack
- expected to appear rarely in a single sidebar branch

`contextPrimary`

- establishes the current subject of the sidebar
- should read as the main identity-bearing cassette in the branch

`contextSecondary`

- supporting explanation or context-adjacent affordances
- grouped with the current subject rather than with filters or actions

`filter`

- narrows the current dataset without changing the subject
- may appear multiple times in the same branch

`action`

- drives exploration, navigation within the current context, or next-step investigation
- visually separate from filters to avoid conflating state narrowing with movement or exploration

## Where Role Should Live

### Recommendation

Place role on the essentials-owned sidebar presentation payload first.

That means the likely first home is near or within `SidebarCassetteCardViewModel`, not directly on `CassetteSpec`.

### Why This Is The Right Insertion Point

- the resolver boundary is already where feature meaning becomes surface-specific presentation
- the feature remains responsible for semantic intent, but not for stack-level layout policy
- it avoids prematurely injecting layout semantics into the rack and topology domain
- it keeps the first migration focused on sidebar composition rather than cassette spec redesign

### Tradeoff

This choice does not provide the strongest possible compile-time guarantee that every future cassette spec has a role inherently attached.

That is acceptable for phase 1 because the coordinator/view-model pipeline is already the established contract for sidebar presentation.

## Section Derivation Model

Sections should be derived centrally from ordered resolved roles, not explicitly declared by features.

Initial grouping rule:

```text
appControl -> app section
contextPrimary + contextSecondary -> context section
filter -> filter section
action -> action section
```

Important detail:

section grouping is not the same thing as rack reordering.

The rack order still determines the logical sequence. The grouping layer should preserve order while applying section boundaries and section-level layout around contiguous semantic groupings.

## Layout Ownership

Essentials should own:

- outer horizontal rails per section
- a centrally defined content envelope and approved body placement modes
- geometry tokens that can be tuned in one place and propagate throughout sidebar rendering
- vertical spacing between sections
- spacing between cassettes within a section
- optional section container treatment where appropriate

See `SIDEBAR_GEOMETRY_CONTRACT.md` for the concrete envelope, placement-mode, and gutter model.

Features should not own:

- stack-level top spacing to simulate sections
- outer margin changes to line up with neighboring cassettes
- custom cross-cassette alignment logic

## Relationship To Current Chrome Primitives

### `cardType`

Keep `cardType` separate from role.

Reason:

- role answers where the cassette belongs semantically
- `cardType` answers which chrome primitive renders it

Those are related, but not identical.

### `layoutStyle`

Treat as a narrowing compatibility tool, not the main hierarchy mechanism.

If it remains widely used to express semantic grouping, the migration has not gone far enough.

It should also stop being the primary place where cassette-level width behavior is expressed once the geometry contract is in place.

### `isControl`

Reevaluate. It may collapse into role semantics or become a more limited rendering hint.

### `topSpacing`

Should become exceptional or disappear. Section wrappers should create the major vertical rhythm.

### `isNaked`

May remain useful as a low-level chrome option, but it must not allow a cassette to escape role-owned section layout.

## Migration Strategy

### Step 1: Add Role To Sidebar Presentation Payload

Introduce the role enum and require each resolver to return a role.

### Step 2: Build A Role-Aware Composition Layer

Update the app-level sidebar coordinator so it composes resolved view models into derived sections before rendering widgets.

At the same time, introduce the geometry contract so section wrappers and role-specific shells render against the same centrally owned content envelope and placement modes.

### Step 3: Map Existing Cassettes

Classify the current cassette set into the initial role taxonomy and inspect friction points.

### Step 4: Reduce Legacy Layout Overrides

Remove or downgrade the existing one-off spacing and alignment decisions where section layout now owns the answer.

### Step 5: Stabilize And Test

Verify the current messages/contacts investigative branch reads correctly and that adding or reordering a cassette does not immediately reintroduce layout drift.

## Risks And Failure Modes

### Risk 1: False Centralization

If role exists, but most interesting spacing still comes from per-cassette layout flags, the design will still be emergent.

The same applies if the content envelope exists on paper, but feature builders still effectively choose their own width behavior with local paddings.

### Risk 2: Role Taxonomy Too Abstract

If the roles are so generic that they cannot guide real layout decisions, the feature will produce bureaucracy without leverage.

### Risk 3: Role Taxonomy Too Specific

If the roles are tailored too tightly to today's messages sidebar, future branches will either misuse them or demand role proliferation.

### Risk 4: Combined-Semantics Cassettes

Some current cassettes may combine explanation, reset affordance, and navigation in one surface. Those cases may reveal that a cassette should be split or that the dominant semantic role must be defined more carefully.

## Open Decisions

1. Should contiguous runs of the same derived section be merged visually even if separated by a role-compatible but different chrome type?
2. Should `appControl` remain in the same scrolling stack or receive stronger visual isolation?
3. Is there a real need for a distinct future role for escape/navigation controls, or can those live under `contextSecondary` or `action`?
4. Which current cassettes still genuinely need a low-level layout override after role-driven grouping exists?
