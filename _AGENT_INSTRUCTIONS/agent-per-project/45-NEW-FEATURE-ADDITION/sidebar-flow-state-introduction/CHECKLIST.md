---
tier: feature
scope: checklist
owner: agent-per-project
last_reviewed: 2026-03-19
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
tests: []
---

# Checklist - Sidebar Flow State Introduction

## Planning

- [x] Proposal approved
- [x] Design notes drafted
- [x] Tests and verification plan documented

## Phase 1 - Canonical Sidebar Flow State

### Step 1.1: Decide Scope And State Shape

- [ ] Confirm whether the provider is scoped narrowly to the contacts/messages branch or includes the top-level branch selector
- [ ] Choose the phase 1 state representation: sealed union or data class with enforced invariants
- [ ] Confirm the minimum canonical fields for phase 1
- [ ] Confirm which fields are explicitly deferred to phase 2

### Step 1.2: Introduce Canonical Flow-State Owner

- [ ] Create the canonical flow-state provider
- [ ] Define the state type in a way that makes invalid combinations hard to represent
- [ ] Export the provider from the appropriate feature-level barrel if needed
- [ ] Verify no analyzer errors

### Step 1.3: Implement Phase 1 Transitions

- [ ] Add transition for contact selection
- [ ] Add transition for choosing another contact
- [ ] Add transition for handle selection and clearing
- [ ] Add transition for message-scope changes
- [ ] Encode reset semantics explicitly in transition logic

### Step 1.4: Project Sidebar Cassettes From State

- [ ] Define a deterministic projection from canonical state to cassette specs
- [ ] Route targeted sidebar branch rendering through projection logic
- [ ] Verify no contact/message branch logic still depends primarily on scanning the rack for truth
- [ ] Keep unrelated sidebar branches unchanged

### Step 1.5: Align Center-Panel Routing In Phase 1

- [ ] Define transition-driven `ViewSpec` updates for the targeted branch
- [ ] Ensure `chooseAnotherContact()` removes or replaces invalid contact-scoped panel content
- [ ] Ensure message-scope changes route to the correct panel content
- [ ] Verify sidebar and center panel remain coherent through supported flows

### Step 1.6: Remove Old State-Inference Paths

- [ ] Audit helper methods that recover canonical meaning from the rendered rack
- [ ] Remove or downgrade obsolete helpers after projection is in place
- [ ] Update comments and documentation that still describe stack-as-state behavior

## Phase 1 Verification

- [x] Run analyzer on touched files
- [ ] Execute planned manual verification scenarios from `TESTS.md`
- [ ] Confirm choosing a new contact resets subordinate state correctly
- [ ] Confirm no stale deleted/recovered view can linger after contact reset

## Phase 2 Planning - Cross-Surface Investigation State

- [ ] Decide whether phase 2 should extend the same state object or layer a separate investigation state above phase 1 flow state
- [ ] Decide whether `heatMapMonth` or similar location state belongs in canonical state
- [ ] Decide how saved investigation states should be serialized and restored
- [ ] Confirm phase 2 is still out of scope for initial implementation unless explicitly approved

## Completion

- [ ] Update `TESTS.md` with verification results
- [ ] Add `STATUS.md` when the feature ships
