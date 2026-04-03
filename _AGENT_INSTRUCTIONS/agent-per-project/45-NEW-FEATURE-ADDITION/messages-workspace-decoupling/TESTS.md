---
tier: feature
scope: tests
owner: agent-per-project
last_reviewed: 2026-04-02
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./CHECKLIST.md
tests: []
---

# Tests and Verification - Messages Workspace Decoupling

## Automated Tests To Add

### Route Ownership Tests

- verify contact selection produces the expected canonical route state
- verify `chooseAnotherContact()` clears invalid subordinate route fields
- verify handle selection and all-handles transitions update route meaning without stale carry-over
- verify switching between regular and recovered scope produces the expected derived panel and sidebar outputs
- verify route transitions do not require inspecting the rendered cassette stack to recover meaning

### Projection Tests

- verify the sidebar cassette branch is a deterministic projection of route state
- verify the center-panel `MessagesSpec` is a deterministic projection of route state
- verify no stale contact-scoped or recovered-scoped panel survives after an incompatible route transition

### Timeline Index Tests

- verify visible-month tracking reads only lightweight index metadata
- verify month-jump target resolution does not require full row hydration
- verify controller identity and anchor restoration remain stable across display-version updates
- verify index-layer changes do not recreate initial-jump behavior incorrectly

### Row Hydration Tests

- verify row hydration is keyed by stable row identity rather than scroll position alone
- verify route changes invalidate obsolete row hydration cleanly
- verify partially ready rows remain renderable without blocking the list

### Media Availability Tests

- verify live-path versus archive-path resolution is cached and deduped
- verify message rows consume explicit availability results rather than probing the filesystem directly
- verify archive-backed media lookup failure produces explicit diagnostic state rather than silent suppression

### Recovered Timeline Parity Tests

- verify recovered deleted surfaces use the shared visible-month contract
- verify recovered deleted surfaces use the shared anchor/jump behavior
- verify recovered and regular surfaces differ by dataset and chrome, not by core timeline control logic

## Manual Verification

### Scenario 1: Contact Flow Responsiveness Under Archive Load

1. Open a contact with a large volume of archive-backed media.
2. Scroll enough to trigger ongoing row hydration.
3. Trigger `Change contact...`.
4. Confirm the control responds immediately.
5. Confirm the sidebar and center panel both project the new route correctly.

### Scenario 2: Normal Timeline Month Tracking

1. Open a contact-scoped messages surface.
2. Scroll across several month boundaries.
3. Confirm the heat map updates continuously.
4. Trigger a month jump.
5. Confirm the list repositions without jitter or dead controls.

### Scenario 3: Recovered Deleted Parity

1. Open the recovered deleted surface for a contact.
2. Scroll across several month boundaries.
3. Confirm the visible month updates with the same behavior as the normal surface.
4. Trigger contact or scope changes.
5. Confirm the workspace remains responsive and coherent.

### Scenario 4: Import Refresh Stability

1. Open a contact-scoped surface.
2. Leave the user on a stable point in the timeline.
3. Trigger or simulate an import/display-version refresh.
4. Confirm controller identity remains stable.
5. Confirm the app does not replay initial jump behavior incorrectly.

### Scenario 5: Media Availability Resilience

1. Test rows where the live path exists.
2. Test rows where only the archive path exists.
3. Test rows where neither path exists.
4. Confirm each case renders an explicit, non-blocking state.
5. Confirm repeated scrolling does not reintroduce sticky controls.

## Instrumentation Targets

- measure how often media-availability lookups hit the filesystem during ordinary scrolling
- measure how often visible-month updates trigger without a top-visible ordinal change
- measure route-to-surface projection churn after contact and scope transitions
- capture hydration latency separately from route and index transition latency

## Verification Results

No implementation has landed yet.

This document defines the required verification targets for the approved refactor.