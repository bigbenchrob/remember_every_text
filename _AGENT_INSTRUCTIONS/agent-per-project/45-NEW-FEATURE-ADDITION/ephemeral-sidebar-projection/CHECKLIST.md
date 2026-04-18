---
tier: feature
scope: checklist
owner: agent-per-project
last_reviewed: 2026-04-18
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
  - ../../55-EPHEMERAL-SPEC-HANDLING/00-ephemeral-spec-handling-architecture.md
tests: []
feature: ephemeral-sidebar-projection
status: proposed
created: 2026-04-18
---

# Checklist - Ephemeral Sidebar Projection

## Phase 0 - Alignment

- [ ] Confirm the 55-series docs supersede the old settings transient-in-rack approach
- [ ] Confirm the first implementation slice migrates Settings send-logs and reset-message-data flows onto the new ephemeral projection layer
- [ ] Confirm durable settings context remains in `SidebarFlowState`

## First Implementation Slice

- [ ] Introduce the new ephemeral projection provider with the narrow public API: replace projection and clear only
- [ ] Introduce the small essentials helper/provider that owns the merged stable-first ordered spec list above the coordinator
- [ ] Update the coordinator to consume that merged ordered list without changing the render pipeline
- [ ] Add the typed `SidebarPersistentIntent` and `SidebarEphemeralIntent` base classes
- [ ] Migrate only the Settings menu emission path for `Send logs` and `Reset message data` onto typed ephemeral intent emission
- [ ] Keep stable settings behavior unchanged except where required to remove transient expansion from the stable path

## Phase 1 - Projection Layer Split

- [ ] Explicitly designate `cassetteRackStateProvider(mode)` as the stable projection provider in implementation and tests
- [ ] Introduce an additional ephemeral projection provider keyed by `SidebarMode`
- [ ] Keep stable and ephemeral providers separate even if they share a common `CassetteRack` value shape
- [ ] Add helper utilities for deriving an ephemeral cassette chain from an ephemeral root spec without replacing stable rack mutation patterns
- [ ] Give the ephemeral projection provider a narrower public mutation surface than the stable rack provider: replace projection and clear only, not `pushCassette`, `truncateAfter`, or new index-relative editing APIs

## Phase 2 - Coordinator Composition

- [ ] Update the sidebar coordinator to read stable specs and ephemeral specs separately
- [ ] Ensure visible ordering is stable first and ephemeral second
- [ ] Introduce a small essentials helper/provider above the coordinator that owns the merged stable-first ordered spec list before resolution
- [ ] Preserve the shared feature coordinator, payload, and render-router pipeline
- [ ] Audit cassette index assumptions at the render edge and in action dispatch contexts and avoid introducing new index-coupled behavior

## Phase 3 - Intent Taxonomy

- [ ] Introduce `SidebarPersistentIntent` and `SidebarEphemeralIntent` base types
- [ ] Replace mixed settings menu transport with intrinsic typed intents
- [ ] Ensure the dispatcher no longer needs to inspect payload fields or row metadata to determine durability
- [ ] Preserve existing typed durable intents in messages mode or migrate them carefully without changing behavior

## Phase 4 - Dispatcher Ownership

- [ ] Route persistent intents to flow state plus stable projection updates
- [ ] Route ephemeral intents to ephemeral projection replacement only
- [ ] Clear incompatible ephemeral projection when durable context changes
- [ ] Clear ephemeral projection for the mode being left on sidebar mode change
- [ ] Remove the temporary settings-mode exit cleanup hack

## Phase 5 - Settings Migration

- [ ] Remove `expandedActionId` from the stable settings root spec path
- [ ] Remove transient settings expansion from stable topology
- [ ] Introduce an explicitly isolated ephemeral topology path for settings temporary flows
- [ ] Update settings menu rows to emit typed persistent or typed ephemeral intents directly
- [ ] Keep group headers inert, non-interactive, and intent-free while the menu widget remains projection-only
- [ ] Keep `Send logs` and `Reset message data` on the shared sidebar cassette pipeline as ephemeral flows

## Phase 6 - Verification And Cleanup

- [ ] Replace old single-rack tests with stable-versus-ephemeral projection tests
- [ ] Add coordinator tests proving visible order is stable then ephemeral
- [ ] Add lifecycle tests proving ephemeral projection is replace-only and cleared on mode change
- [ ] Add topology tests proving no stable cassette is derived beneath an ephemeral root
- [ ] Remove or rewrite tests that assert the old mode-specific cleanup behavior
- [ ] Confirm no plan step converted stable projection to a new fully reactive recomputation model
- [ ] Update any feature docs that still describe transient settings expansion as part of the stable rack
