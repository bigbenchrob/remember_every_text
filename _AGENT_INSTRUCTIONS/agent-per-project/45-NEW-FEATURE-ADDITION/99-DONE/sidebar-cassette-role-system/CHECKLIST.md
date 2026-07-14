---
tier: feature
scope: checklist
owner: agent-per-project
last_reviewed: 2026-03-20
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./API_SKETCH.md
  - ./SIDEBAR_GEOMETRY_CONTRACT.md
  - ./TESTS.md
  - ./seed.txt
tests: []
---

# Checklist - Sidebar Cassette Role System

## Planning

- [x] Proposal approved
- [x] Design notes drafted
- [x] Tests and verification plan documented

## Phase 1 - Role-Driven Sidebar Layout

### Step 1.1: Define Role Contract

- [ ] Confirm the initial `SidebarCassetteRole` taxonomy
- [ ] Confirm whether role lives directly on `SidebarCassetteCardViewModel` or on a closely related essentials-owned presentation payload
- [ ] Confirm which existing layout flags are considered legacy compatibility knobs versus long-term API

### Step 1.2: Add Essentials-Owned Role Model

- [ ] Introduce the role enum in the essentials sidebar presentation layer
- [ ] Require sidebar presentation payloads to declare one semantic role
- [ ] Verify all current cassette resolvers compile after the contract change

### Step 1.2a: Finalize Phase 1 API Shape

- [ ] Confirm the phase 1 `SidebarCassetteRole` / `SidebarBodyPlacementMode` / `SidebarGeometryConstraints` type shape
- [ ] Decide whether to evolve `SidebarCassetteCardViewModel` in place or replace it with a new presentation payload type
- [ ] Decide where centrally owned geometry tokens live in essentials

### Step 1.3: Define Sidebar Geometry Contract

- [ ] Define the centrally owned content envelope and approved placement modes in essentials
- [ ] Define sidebar-owned trailing gutter behavior
- [ ] Define the centrally owned geometry tokens used to tune envelope and gutter dimensions
- [ ] Define the constraint payload passed down to feature-owned widget content
- [ ] Confirm current cassette types can be expressed without introducing new ad hoc paddings

### Step 1.4: Add Role-Aware Composition Layer

- [ ] Replace purely flat sidebar composition with role-aware section derivation
- [ ] Preserve rack order while introducing section grouping
- [ ] Define essentials-owned spacing and grouping rules for each derived section

### Step 1.5: Map Existing Cassettes

- [ ] Assign roles to the current cassette set used in the messages/contacts branch
- [ ] Assign placement modes to the current cassette set used in the messages/contacts branch
- [ ] Audit non-messages sidebar cassettes for role classification completeness
- [ ] Identify any cassette whose current structure makes role assignment ambiguous

### Step 1.6: Reduce Legacy Layout Drift

- [ ] Remove or downgrade ad hoc top spacing used to simulate sections
- [ ] Reduce dependence on `layoutStyle` for semantic grouping
- [ ] Reevaluate whether `isControl` remains necessary after role-driven grouping
- [ ] Ensure `isNaked` does not bypass section-level layout ownership

### Step 1.7: Validate Structural Coherence

- [ ] Confirm app controls, context cassettes, filters, and actions read as distinct groups
- [ ] Confirm the current messages/contacts branch no longer needs bespoke width alignment fixes
- [ ] Confirm adding a correctly classified cassette does not immediately require a new spacing escape hatch

## Verification

- [ ] Run analyzer on touched files
- [ ] Execute focused automated tests from `TESTS.md`
- [ ] Execute manual verification scenarios from `TESTS.md`
- [ ] Confirm no unrelated sidebar branches regress visually or structurally

## Phase 2 Planning - Tightening And Generalization

- [ ] Decide which legacy layout knobs can be removed entirely after phase 1
- [ ] Decide whether section wrappers need their own view-model abstraction or can remain coordinator-owned
- [ ] Decide whether a future explicit navigation/escape role is needed

## Completion

- [ ] Update `TESTS.md` with verification results
- [ ] Add `STATUS.md` when the feature ships
