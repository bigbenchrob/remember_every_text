---
tier: feature
scope: checklist
owner: agent-per-project
last_reviewed: 2026-04-19
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
  - ../../55-EPHEMERAL-SPEC-HANDLING/00-ephemeral-spec-handling-architecture.md
tests: []
feature: ephemeral-sidebar-projection
status: in_progress
created: 2026-04-18
---

# Checklist - Ephemeral Sidebar Projection

## Phase 0 - Alignment

- [x] Confirm the 55-series docs supersede the old settings transient-in-rack approach
- [x] Confirm the first implementation slice migrates Settings send-logs and reset-message-data flows onto the new ephemeral projection layer
- [x] Confirm durable settings context remains in `SidebarFlowState`
- [x] Confirm stable topology may consult durable flow state only for the immediate next child of the current spec
- [x] Confirm no step in the plan depends on specs carrying all branch meaning intrinsically

## First Implementation Slice

- [x] Introduce the new ephemeral projection provider with the narrow public API: replace projection and clear only
- [x] Introduce the small essentials helper/provider that owns the merged stable-first ordered spec list above the coordinator
- [x] Update the coordinator to consume that merged ordered list without changing the render pipeline
- [x] Add the typed `SidebarPersistentIntent` and `SidebarEphemeralIntent` base classes
- [x] Migrate only the Settings menu emission path for `Send logs` and `Reset message data` onto typed ephemeral intent emission
- [x] Keep stable settings behavior unchanged except where required to isolate transient flows from the stable path

## Phase 1 - Projection Layer Split

- [x] Explicitly designate `cassetteRackStateProvider(mode)` as the stable projection provider in implementation and tests
- [x] Introduce an additional ephemeral projection provider keyed by `SidebarMode`
- [x] Keep stable and ephemeral providers separate even if they share a common `CassetteRack` value shape
- [x] Add helper utilities for deriving an ephemeral cassette chain from an ephemeral root spec without replacing stable rack mutation patterns
- [x] Give the ephemeral projection provider a narrower public mutation surface than the stable rack provider: replace projection and clear only, not other non-topological structure editing APIs
- [x] Keep stable topology decisions local to the current spec instead of widening them into branch construction

## Phase 2 - Coordinator Composition

- [ ] Update the sidebar coordinator to read stable specs and ephemeral specs separately
- [x] Ensure visible ordering is stable first and ephemeral second
- [x] Introduce a small essentials helper/provider above the coordinator that owns the merged stable-first ordered spec list before resolution
- [x] Preserve the shared feature coordinator, payload, and render-router pipeline
- [ ] Audit cassette index assumptions at the render edge and in action dispatch contexts and avoid introducing new index-coupled behavior

## Phase 3 - Intent Taxonomy

- [x] Introduce `SidebarPersistentIntent` and `SidebarEphemeralIntent` base types
- [x] Emit intrinsic typed settings intents
- [x] Ensure the dispatcher no longer needs to inspect payload fields or row metadata to determine durability
- [x] Preserve existing typed durable intents in messages mode or migrate them carefully without changing behavior

## Phase 4 - Dispatcher Ownership

- [x] Route persistent intents to flow state plus stable projection updates
- [ ] Route ephemeral intents to ephemeral projection replacement only
- [x] Clear incompatible ephemeral projection when durable context changes
- [x] Clear ephemeral projection for the mode being left on sidebar mode change
- [x] Remove the temporary settings-mode exit cleanup hack
- [x] Keep flow state ownership limited to durable meaning rather than chain authorship

## Phase 5 - Settings Migration

- [x] Keep the stable settings root spec stateless
- [x] Keep transient settings flows out of stable topology
- [x] Introduce an explicitly isolated ephemeral topology path for settings temporary flows
- [x] Update settings menu rows to emit typed persistent or typed ephemeral intents directly
- [x] Keep group headers inert, non-interactive, and intent-free while the menu widget remains projection-only
- [x] Keep `Send logs` and `Reset message data` on the shared sidebar cassette pipeline as ephemeral flows

## Phase 6 - Verification And Cleanup

- [ ] Replace old single-rack tests with stable-versus-ephemeral projection tests
- [x] Add coordinator tests proving visible order is stable then ephemeral
- [x] Add lifecycle tests proving ephemeral projection is replace-only and cleared on mode change
- [x] Add topology tests proving no stable cassette is derived beneath an ephemeral root
- [x] Add topology tests proving stable topology consults only the durable fact needed for the current spec's immediate child
- [ ] Remove or rewrite tests that assert the old mode-specific cleanup behavior
- [ ] Confirm no plan step converted stable projection to a new fully reactive recomputation model
- [x] Update any feature docs that still describe temporary settings UI as part of the stable rack
