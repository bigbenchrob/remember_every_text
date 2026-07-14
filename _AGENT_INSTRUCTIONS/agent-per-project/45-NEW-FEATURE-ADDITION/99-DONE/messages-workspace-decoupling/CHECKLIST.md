---
tier: feature
scope: checklist
owner: agent-per-project
last_reviewed: 2026-04-02
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
tests: []
---

# Checklist - Messages Workspace Decoupling

## Planning

- [x] Proposal drafted
- [x] Design notes drafted
- [x] Tests and verification plan documented
- [ ] Proposal approved for implementation

## Phase 1 - Canonical Messages Route Authority

### Step 1.1: Define Route Scope And State Shape

- [ ] Confirm the minimum canonical route fields
- [ ] Confirm which fields remain derived index state rather than route state
- [ ] Decide whether the route model is a sealed union, a constrained data class, or a hybrid
- [ ] Document transition semantics for contact change, handle change, scope change, and jump intent

### Step 1.2: Introduce The Route Owner

- [ ] Create the canonical messages-route provider
- [ ] Ensure the route provider is feature-owned and exported through the approved provider boundary if needed
- [ ] Verify no analyzer errors in touched files

### Step 1.3: Project Sidebar And Panel Surfaces

- [ ] Derive the messages-branch sidebar cassette stack from route state
- [ ] Derive the center-panel `MessagesSpec` from the same route state
- [ ] Remove or downgrade the most important repair paths where sidebar and panel try to reconcile each other indirectly
- [ ] Verify no stale contact-scoped panel can linger after route transitions

## Phase 2 - Timeline Index Plane

### Step 2.1: Define Lightweight Timeline Metadata

- [ ] Confirm the minimum metadata needed for ordinal, month, and anchor behavior
- [ ] Introduce index-layer contracts that do not require hydrated rows
- [ ] Keep display-version semantics explicit

### Step 2.2: Move Control Logic To The Index Layer

- [ ] Route visible-month tracking through index-only metadata
- [ ] Route month-jump target resolution through index-only metadata
- [ ] Ensure controller identity and jump behavior are stable across data refreshes
- [ ] Verify no control path falls back to full row hydration

## Phase 3 - Row-Local Hydration Plane

### Step 3.1: Isolate Row Hydration

- [ ] Introduce row hydration keyed by stable row identity
- [ ] Ensure hydration can be canceled or discarded cleanly on route change or row eviction
- [ ] Represent partial row readiness explicitly

### Step 3.2: Remove Control Coupling

- [ ] Remove remaining uses of hydrated row models for route, month, or anchor ownership
- [ ] Verify timeline scrolling remains responsive while rows hydrate lazily

## Phase 4 - Media Availability Service

### Step 4.1: Extract Availability Logic

- [ ] Define the media-availability result model
- [ ] Move live-path and archive-path resolution into the dedicated service layer
- [ ] Add caching and deduping for filesystem work

### Step 4.2: Adopt The Service In Presentation

- [ ] Update row hydration to consume the service result instead of probing directly
- [ ] Remove repeated synchronous file checks from ordinary widget build paths
- [ ] Verify archive-backed media no longer degrades control responsiveness disproportionately

## Phase 5 - Recovered Timeline Unification

### Step 5.1: Move Recovered Surfaces Onto The Shared Engine

- [ ] Replace recovered-specific visible-month and scroll ownership with the shared timeline contracts
- [ ] Keep recovered-specific query semantics and chrome while deleting sibling engine logic
- [ ] Verify regular and recovered surfaces now share the same core control behavior

## Cleanup

- [ ] Remove obsolete helper paths and comments that describe the legacy coupled model
- [ ] Update project docs if the final implementation changes the canonical messages architecture
- [ ] Add `STATUS.md` when the feature ships

## Verification

- [ ] Run analyzer on touched files
- [ ] Execute the automated tests listed in `TESTS.md`
- [ ] Execute the manual validation scenarios listed in `TESTS.md`
- [ ] Confirm archive-backed media no longer causes sticky controls under the tested scenarios