---
tier: feature
scope: proposal
owner: agent-per-project
last_reviewed: 2026-04-18
source_of_truth: doc
links:
  - ../../55-EPHEMERAL-SPEC-HANDLING/README.md
  - ../../55-EPHEMERAL-SPEC-HANDLING/00-ephemeral-spec-handling-architecture.md
  - ../../55-EPHEMERAL-SPEC-HANDLING/INVIOLATE_RULES.md
  - ../../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md
  - ../settings-menu-semantic-revision/PROPOSAL.md
tests: []
feature: ephemeral-sidebar-projection
status: proposed
created: 2026-04-18
supersedes:
  - settings-menu-semantic-revision
---

# Feature Proposal - Ephemeral Sidebar Projection

**Proposed Branch**: `Ftr.set-ephem`
**Status**: Proposed
**Created**: 2026-04-18

## Overview

Introduce a first-class architectural distinction between stable sidebar projection and ephemeral sidebar projection.

This proposal replaces the earlier attempt to model temporary settings flows inside the existing retained cassette rack.

The new design treats the visible sidebar as two projection layers:

- stable projection, derived from durable flow state
- ephemeral projection, representing temporary one-off sidebar action flows

The visible sidebar order is always:

- stable specs first
- ephemeral specs second

This is not a settings-only fix.

It is a general extension to the essentials-owned sidebar cassette system so temporary flows can exist without masquerading as durable state.

## Problem

The current sidebar pipeline still mixes durable and temporary cassette meaning into one retained rack.

That creates a structural bug:

- durable branch state and temporary action UI use the same storage shape
- retained providers make temporary UI look reconstructible
- temporary settings flows such as `Send logs` and `Reset message data` can behave like durable sidebar state

The recent mode-exit reset workaround confirmed the problem but is not the correct solution.

Under the new 55-series architecture, mode-specific cleanup is explicitly a hack. The real fix is to separate projection layers.

## Existing Architecture Summary

- `SidebarFlowState` owns durable meaning for flow-managed sidebar branches.
- `cassetteRackStateProvider(mode)` currently stores the stable rendered cassette stack for a mode, even though that role has not yet been named explicitly as the stable projection layer.
- `CassetteWidgetCoordinator` currently reads one rack and resolves every visible spec through the shared sidebar pipeline.
- Settings transient behavior is still represented through the stable settings root spec via `expandedActionId`.
- The dispatcher still contains mixed settings-menu transport that was added to distinguish persistent and transient behavior inside a single flow.

This is the architectural conflict:

- the current cassette rack is doing double duty as both durable projection and temporary action projection
- the settings root spec is still carrying ephemeral expansion state
- the dispatcher still accepts a mixed intent type for settings top-menu selection

## User Value

After this work:

- durable sidebar context will restore deterministically from flow state
- temporary action flows will no longer reappear after rebuilds or mode return
- the coordinator will render temporary flows without introducing a second rendering system
- future one-off sidebar prompts will have a correct home in the architecture

## Assumptions

1. The 55-series ephemeral-spec-handling docs are now the canonical source of truth for temporary sidebar flows.
2. The current settings transient path is the first migration target, but the architecture must remain mode-agnostic.
3. `SidebarFlowState.persistentSettingsContext` remains valid durable state.
4. `cassetteRackStateProvider(mode)` remains the stable projection provider; this work adds an ephemeral projection provider rather than replacing the stable one.
5. Stable projection must remain logically derivable from durable flow state, even if that derivation continues to be expressed partly through explicit rack mutations rather than a fully reactive recomputation model.
6. Existing shared sidebar payload, render-router, chrome, and layout rules remain correct and should not be replaced.

## Hard Invariants

1. Durable meaning lives only in flow state.
2. Stable and ephemeral cassette specs must not share a retained rack.
3. Ephemeral actions must never write to flow state.
4. Intent durability must be intrinsic to the intent type.
5. Ephemeral projection is replace-only and terminal.
6. The coordinator must render stable projection first and ephemeral projection second.
7. Ephemeral specs must still flow through spec -> coordinator -> resolver -> payload -> render router.
8. No mode-specific lifecycle workaround may remain as the actual architecture.

## Scope

### In Scope

1. Introduce an additional ephemeral projection provider keyed by `SidebarMode`, alongside the existing stable rack provider.
2. Refactor settings transient flows to live only in ephemeral projection.
3. Replace mixed settings menu intents with typed persistent and typed ephemeral intent classes.
4. Update the dispatcher to route by intent durability instead of payload fields.
5. Update the coordinator to resolve stable specs and ephemeral specs in visible order.
6. Remove logic that treats temporary settings UI as durable state.
7. Replace the temporary mode-exit reset workaround with general ephemeral-layer behavior.
8. Add regression coverage for replace-only ephemeral projection, terminal ephemeral topology, and mode clearing.

### Out Of Scope

- redesigning the visual appearance of the settings menu
- changing reset and send-logs side effects beyond projection ownership
- adding new layout or chrome types for ephemeral cassettes
- converting stable projection to a fully reactive recomputation model
- migrating unrelated non-settings features to ephemeral projection in the first implementation slice unless needed to validate the shared architecture

## Proposed Direction

### 1. Separate Projection Ownership Without Replacing Stable Rack

Keep the current stable rack provider and add a second provider for ephemeral projection.

The architecture becomes:

- existing stable cassette projection provider
- ephemeral cassette projection provider

Both are keyed by `SidebarMode`.

Stable projection remains reconstructible from flow state.
Ephemeral projection remains live-only UI projection.

This is a projection-layer separation, not a replacement of the existing stable rack.

The ephemeral provider should intentionally expose a narrower mutation surface than the stable rack provider.

Because ephemeral projection is replace-only, the plan should assume:

- replace the current ephemeral projection from a new ephemeral root
- clear the current ephemeral projection

It should not mirror stable-rack mutations such as `pushCassette`, `truncateAfter`, or index-relative structure editing as public ephemeral APIs.

### 2. Remove Ephemeral Meaning From Stable Settings Specs

The stable settings root spec must stop carrying `expandedActionId`.

Ephemeral action chains such as send logs and reset confirmation should instead originate from the ephemeral projection provider.

### 3. Encode Durability In Intent Type

Replace mixed transport like `SettingsTopMenuActionChosen(actionId, semantic)` with typed intent classes whose durability is intrinsic.

Examples:

- persistent intent for text-size settings context
- persistent intent for image-size settings context
- ephemeral intent for send-logs flow
- ephemeral intent for reset-message-data flow

Inert menu rows such as group headers must emit no intent at all.

The dispatcher should route on intent type alone.

### 4. Isolate Ephemeral Topology Explicitly

Ephemeral topology must be a distinct topology path from stable topology.

It may reuse shared helper patterns where appropriate, but it must remain explicitly separated so that:

- stable topology never consults ephemeral projection
- ephemeral topology never feeds back into durable meaning
- no stable cassette is ever derived beneath an ephemeral root

### 5. Keep One Sidebar Rendering System

Ephemeral handling does not create a separate rendering mechanism.

The existing essentials-owned sidebar system remains intact.

The coordinator simply reads:

- stable specs
- ephemeral specs

then resolves them together in stable-first order.

To avoid ad hoc merge logic spreading through the coordinator, the merged ordered list should be owned by a small essentials helper/provider immediately above the resolution loop. The coordinator remains the single composition point for payload resolution, but it should consume one stable-first ordered visible-spec list rather than improvising the merge in multiple places.

### 6. Treat Cassette Index As Migration Debt

Existing `cassetteIndex`-based behavior may remain temporarily where functionally necessary, but it should be treated as legacy migration debt rather than a design goal.

This implementation should not introduce new index-coupled behavior unless there is no practical alternative in the current surface.

### 7. Make Mode Clearing A Projection-Layer Rule

Mode changes must clear the ephemeral projection for the mode being left.

That behavior belongs in the ephemeral projection layer contract, not in settings-specific rack cleanup.

## Risks

### Risk 1 - Index semantics shift once two layers are rendered

Visible cassette indices may no longer map directly to the stable rack. Any action that still relies on visible index lookup must be audited carefully, and new index-coupled behavior should be avoided.

### Risk 2 - Stable topology may accidentally remain coupled to settings transient expansion

If `expandedActionId` survives in stable topology or stable specs, the architecture remains broken even if tests pass locally.

### Risk 3 - Mixed intents may survive in UI emitters

If widgets still emit generic action intents that require downstream interpretation, the new intent contract will only be partially implemented.

### Risk 4 - Stable and ephemeral topology may accidentally share logic paths

If ephemeral derivation is threaded through existing stable topology entry points, the layer boundary may blur and ephemeral behavior can leak back into stable logic.

## Success Criteria

The feature is not complete unless all of the following are true:

- stable and ephemeral projections are stored separately
- no ephemeral settings flow is reconstructible from stable state
- the dispatcher routes based on typed persistent versus typed ephemeral intents
- the coordinator renders stable projection followed by ephemeral projection
- leaving and re-entering a mode restores only stable projection
- no mode-specific cleanup hack is required to maintain transient behavior
