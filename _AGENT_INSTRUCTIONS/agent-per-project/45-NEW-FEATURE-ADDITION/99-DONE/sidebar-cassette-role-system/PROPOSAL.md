---
tier: feature
scope: proposal
owner: agent-per-project
last_reviewed: 2026-03-20
source_of_truth: doc
links:
  - ../../50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/00-cross-surface-spec-system.md
  - ../../52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/00-universal-spec-handling-pattern.md
  - ../../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md
  - ../../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/INVIOLATE_RULES.md
   - ../../56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/00-view-spec-panel-architecture.md
   - ./API_SKETCH.md
   - ./SIDEBAR_GEOMETRY_CONTRACT.md
  - ./seed.txt
tests: []
feature: sidebar-cassette-role-system
status: proposed
created: 2026-03-20
---

# Feature Proposal - Sidebar Cassette Role System

**Proposed Branch**: `ftr-cass-roles`
**Status**: Proposed
**Created**: 2026-03-20

---

## Overview

Introduce a semantic role system for sidebar cassettes so the sidebar's visual hierarchy becomes a deterministic projection of declared cassette meaning rather than an accidental result of piecemeal layout adjustments.

This proposal is deliberately parallel to the canonical sidebar flow-state work:

- flow meaning should no longer be inferred from rendered sidebar state
- visual structure should no longer be inferred from individually tuned cassette chrome
- cassettes should declare meaning
- essentials should own layout, grouping, and hierarchy

The goal is not a cosmetic cleanup in isolation.

It is a structural correction to the sidebar presentation system so future cassettes can be added without reintroducing spacing drift, inconsistent margins, or feature-local layout exceptions.

## User Value

### Problem

The current sidebar visual composition has grown incrementally as cassettes were added one at a time.

As a result:

- horizontal alignment varies across cassettes
- vertical rhythm is partly controlled by per-cassette tweaks
- context cards, filters, and action controls are not grouped by a consistent visual model
- feature requests such as "make this one narrower so it lines up with that one" become one-off local patches rather than reusable rules
- new cassettes can easily disturb the overall sidebar hierarchy even when their feature meaning is correct

The current system already centralizes some chrome, but too much layout meaning still leaks through cassette-specific presentation choices such as `layoutStyle`, `isNaked`, `isControl`, and `topSpacing`.

### Proposed User-Facing Outcome

This feature should make the sidebar feel intentionally organized rather than historically accumulated.

Concretely, it should make these outcomes reliable:

- top-level app controls are visually separated from the rest of the sidebar
- current-context cassettes are grouped together and read as one semantic cluster
- filters read as filters rather than as unrelated cards in the stack
- action-oriented cassettes such as heat maps have their own consistent visual treatment
- adding a new cassette with the correct declared role places it into a coherent layout automatically
- feature-specific widget code no longer needs to negotiate outer spacing or stack position heuristics

### Benefits

- more legible sidebar hierarchy
- fewer ad hoc spacing fixes
- stronger separation of feature meaning from app-level layout ownership
- easier maintenance of cassette-heavy sidebar branches
- safer foundation for future sidebar additions across features

---

## Existing Architecture Summary

- the sidebar rack stores an ordered list of `CassetteSpec` values
- the app-level coordinator resolves each cassette through the owning feature into a `SidebarCassetteCardViewModel`
- essentials-owned chrome widgets such as `SidebarCassetteCard`, `SidebarInfoCard`, and `SidebarNavigationCard` wrap that payload
- the current coordinator then renders a flat list of widgets in rack order
- some layout policy already lives in essentials, but the effective result still depends on cassette-level view-model flags and local historical exceptions

The weakness is not that chrome exists.

The weakness is that layout semantics are not yet first-class.

## Assumptions

1. The current cassette rack and cross-surface spec architecture remain the correct structural foundation.
2. This feature should be implemented as a sidebar presentation/composition improvement, not as a rewrite of cassette feature ownership.
3. A small, reusable role taxonomy is sufficient; the system does not need feature-specific layout roles.
4. The first implementation should reduce dependence on `layoutStyle`, `isControl`, and `topSpacing` rather than trying to remove every escape hatch immediately.
5. It is acceptable to introduce section derivation and role-aware sidebar wrappers in essentials if feature resolvers only need to declare semantic intent.

## Hard Invariants

1. Do not replace the cross-surface spec architecture.
2. Do not move sidebar layout ownership into feature widget builders.
3. Do not introduce feature-specific roles such as `contactHero` or `messageHeatMap`.
4. Do not let individual cassettes control global outer spacing or section grouping once role-driven layout exists.
5. Do not widen this work into center-panel routing, database, persistence, or unrelated sidebar logic changes.
6. The final visual hierarchy must be explainable from role declarations and essentials-owned layout rules, not from ad hoc per-cassette tuning.

---

## Scope

### Phase 1 - Introduce Role-Driven Sidebar Layout

1. **Define semantic roles**
   Introduce a small essentials-owned role enum describing the functional place a cassette occupies in the sidebar.

2. **Require a declared role in sidebar presentation payloads**
   Make each cassette resolver return a role as part of its view-model contract.

3. **Derive sections from roles**
   Replace the current purely flat visual composition with essentials-owned grouping and section layout.

4. **Centralize spacing and grouping rules**
   Move section spacing, outer margins, and grouping treatment fully into essentials-owned layout code.

5. **Introduce an authoritative geometry contract**
   Define the centrally owned content envelope, approved body placement modes, and sidebar-owned gutter behavior that all cassette content must respect.

6. **Reduce ad hoc layout escape hatches**
   Keep legacy knobs temporarily where required, but tighten their purpose and stop using them as the main hierarchy mechanism.

### Phase 2 - Tighten And Generalize

1. **Audit legacy layout knobs**
   Remove or narrow `layoutStyle`, `isControl`, `topSpacing`, or similar escape hatches where role-driven composition fully covers the need.

2. **Broaden role coverage**
   Ensure the same role taxonomy can support non-messages sidebar branches without feature-specific drift.

3. **Add stronger structural guarantees**
   Optionally harden the contract so unsupported role combinations or misgroupings are easier to detect in tests.

### Candidate Role Set

Initial working set:

- `appControl`
- `contextPrimary`
- `contextSecondary`
- `filter`
- `action`

The taxonomy should remain deliberately small. If a cassette cannot be classified cleanly, either the role definitions are unclear or the cassette is currently doing more than one semantic job.

### Out Of Scope

- replacing the cassette rack model
- rewriting the canonical sidebar flow-state system
- redesigning all cassette visuals from scratch
- changing center-panel behavior
- feature-specific art direction work beyond what is needed to support role-driven hierarchy
- database, importer, migration, or overlay changes

---

## Proposed Direction

### Core Principle

Sidebar layout is a projection of declared cassette roles, not a side effect of individually tuned cassette chrome.

### Ownership Model

- features continue to own cassette meaning and content
- feature resolvers declare the cassette's semantic role
- essentials owns grouping, section layout, spacing, and structural hierarchy

### Role Placement

The first implementation should place role on the essentials-owned sidebar presentation payload rather than immediately requiring every `CassetteSpec` variant to encode layout semantics.

Why:

- the resolver boundary is already the place where feature meaning becomes surface-specific presentation
- it minimizes disruption to rack and topology code
- it allows role-driven layout to be introduced without rewriting the cassette spec layer first

If that proves too weak later, the system can be hardened further. Phase 1 should choose the least disruptive insertion point that still centralizes layout meaning.

### Geometry Contract

Role-driven grouping alone is not sufficient.

The sidebar also needs an authoritative geometry contract defining:

- the centrally owned content envelope
- which placement modes are available
- when a trailing gutter is reserved
- how centrally owned geometry tokens propagate through sidebar shells and feature-owned widget constraints

That contract is documented in `SIDEBAR_GEOMETRY_CONTRACT.md` and should be treated as a sidebar-system rule set, not a suggestion for feature builders.

The current proposed essentials-side type shape is documented in `API_SKETCH.md`.

### Section Derivation

Sections should be derived from role centrally rather than declared ad hoc by cassettes.

Initial intended grouping:

- `appControl` -> app-level section
- `contextPrimary` + `contextSecondary` -> context section
- `filter` -> filter section
- `action` -> action section

This allows the sidebar coordinator to transform:

`resolved cassette view models -> role-grouped sections -> section wrappers -> rendered sidebar`

### Relationship To Existing Layout Hooks

The current layout hooks should be treated as legacy or secondary once role-driven grouping exists.

In particular:

- `layoutStyle` should stop being the main way semantic hierarchy is expressed
- `topSpacing` should not remain the normal way to create section separation
- `isControl` should be reconsidered as either redundant with role or as a narrower rendering concern
- `isNaked` may remain as a chrome primitive, but it must not be allowed to undermine section-level layout rules

### Expected Outcome

After the feature lands, a new cassette should be able to integrate into the sidebar cleanly by doing two things only:

1. declare the correct semantic role
2. provide correct feature content

If additional per-cassette spacing negotiation is still routinely needed, the feature is incomplete.

## Relationship To Existing Topology

This feature does not replace cassette order or cascade topology.

Rack order still matters.

What changes is how that ordered rack is visually composed once resolved. The app-level sidebar system should stop treating the rack as a visually flat list and instead treat it as an ordered semantic sequence that can be grouped by role into a stable layout hierarchy.

## Risks

### Risk 1: Role System Too Weak To Replace Current Knobs

If role is added but layout still depends primarily on `layoutStyle` and `topSpacing`, the new system will exist only on paper.

### Risk 2: Overfitting To The Current Messages Sidebar

If role definitions are secretly derived from one branch only, future branches will either misuse roles or demand feature-specific role proliferation.

### Risk 3: Mixing Structural And Cosmetic Concerns

If the implementation tries to solve all typography, color, and container styling questions at once, the migration will become harder than necessary.

### Risk 4: Ambiguous Navigation/Context Cases

Some current cassettes may combine explanation, reset affordance, and navigation. Those cases may need clearer decomposition or a carefully chosen primary role.

## Success Criteria

This feature is successful when:

- the sidebar's visual groupings are explainable from declared roles alone
- new cassettes no longer require bespoke width or spacing patches to fit the sidebar
- essentials owns section spacing and grouping centrally
- feature code no longer has to solve stack-level visual alignment problems cassette by cassette
